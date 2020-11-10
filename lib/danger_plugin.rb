# frozen_string_literal: true

require 'find'
require 'yaml'
require 'shellwords'
require_relative '../ext/swiftlint/swiftlint'

module Danger
  # Lint Swift files inside your projects.
  # This is done using the [SwiftLint](https://github.com/realm/SwiftLint) tool.
  # Results are passed out as a table in markdown.
  #
  # @example Specifying custom config file.
  #
  #          # Runs a linter with comma style disabled
  #          swiftlint.config_file = '.swiftlint.yml'
  #          swiftlint.lint_files
  #
  # @see  artsy/eigen
  # @tags swift
  #
  class DangerSwiftlint < Plugin
    # The path to SwiftLint's execution
    attr_accessor :binary_path

    # The path to SwiftLint's configuration file
    attr_accessor :config_file

    # Allows you to specify a directory from where swiftlint will be run.
    attr_accessor :directory

    # Maximum number of issues to be reported.
    attr_accessor :max_num_violations

    # Provides additional logging diagnostic information.
    attr_accessor :verbose

    # Whether all files should be linted in one pass
    attr_accessor :lint_all_files

    # Whether we should fail on warnings
    attr_accessor :strict

    # Warnings found
    attr_accessor :warnings

    # Errors found
    attr_accessor :errors
    
    # All issues found
    attr_accessor :issues

    # Whether all issues or ones in PR Diff to be reported
    attr_accessor :filter_issues_in_diff

    # Lints Swift files. Will fail if `swiftlint` cannot be installed correctly.
    # Generates a `markdown` list of warnings for the prose in a corpus of
    # .markdown and .md files.
    #
    # @param   [String] files
    #          A globbed string which should return the files that you want to
    #          lint, defaults to nil.
    #          if nil, modified and added files from the diff will be used.
    # @return  [void]
    #
    def lint_files(files = nil, inline_mode: false, fail_on_error: false, additional_swiftlint_args: '', no_comment: false, &select_block)
      # Fails if swiftlint isn't installed
      raise 'swiftlint is not installed' unless swiftlint.installed?

      config_file_path = if config_file
                           config_file
                         elsif !lint_all_files && File.file?('.swiftlint.yml')
                           File.expand_path('.swiftlint.yml')
                         end
      log "Using config file: #{config_file_path}"

      dir_selected = directory ? File.expand_path(directory) : Dir.pwd
      log "Swiftlint will be run from #{dir_selected}"

      # Get config
      config = load_config(config_file_path)

      # Extract excluded paths
      excluded_paths = format_paths(config['excluded'] || [], config_file_path)

      log "Swiftlint will exclude the following paths: #{excluded_paths}"

      # Extract included paths
      included_paths = format_paths(config['included'] || [], config_file_path)

      log "Swiftlint includes the following paths: #{included_paths}"

      # Prepare swiftlint options
      options = {
        # Make sure we don't fail when config path has spaces
        config: config_file_path ? Shellwords.escape(config_file_path) : nil,
        reporter: 'json',
        quiet: true,
        pwd: dir_selected,
        force_exclude: true
      }
      log "linting with options: #{options}"

      if lint_all_files
        issues = run_swiftlint(options, additional_swiftlint_args)
      else
        # Extract swift files (ignoring excluded ones)
        files = find_swift_files(dir_selected, files, excluded_paths, included_paths)
        log "Swiftlint will lint the following files: #{files.join(', ')}"

        # Lint each file and collect the results
        issues = run_swiftlint_for_each(files, options, additional_swiftlint_args)
      end

      if filter_issues_in_diff
        # Filter issues related to changes in PR Diff
        issues = filter_git_diff_issues(issues)
      end

      @issues = issues
      other_issues_count = 0
      unless @max_num_violations.nil? || no_comment
        other_issues_count = issues.count - @max_num_violations if issues.count > @max_num_violations
        issues = issues.take(@max_num_violations)
      end
      log "Received from Swiftlint: #{issues}"
      
      # filter out any unwanted violations with the passed in select_block
      if select_block && !no_comment
        issues = issues.select { |issue| select_block.call(issue) }
      end

      # Filter warnings and errors
      @warnings = issues.select { |issue| issue['severity'] == 'Warning' }
      @errors = issues.select { |issue| issue['severity'] == 'Error' }
      
      # Early exit so we don't comment
      return if no_comment

      if inline_mode
        # Report with inline comment
        send_inline_comment(warnings, strict ? :fail : :warn)
        send_inline_comment(errors, (fail_on_error || strict) ? :fail : :warn)
        warn other_issues_message(other_issues_count) if other_issues_count > 0
      elsif warnings.count > 0 || errors.count > 0
        # Report if any warning or error
        message = "### SwiftLint found issues\n\n".dup
        message << markdown_issues(warnings, 'Warnings') unless warnings.empty?
        message << markdown_issues(errors, 'Errors') unless errors.empty?
        message << "\n#{other_issues_message(other_issues_count)}" if other_issues_count > 0
        markdown message

        # Fail danger on errors
        should_fail_by_errors = fail_on_error && errors.count > 0
        # Fail danger if any warnings or errors and we are strict
        should_fail_by_strict = strict && (errors.count > 0 || warnings.count > 0)
        if should_fail_by_errors || should_fail_by_strict
          fail 'Failed due to SwiftLint errors'
        end
      end
    end

    # Run swiftlint on all files and returns the issues
    #
    # @return [Array] swiftlint issues
    def run_swiftlint(options, additional_swiftlint_args)
      result = swiftlint.lint(options, additional_swiftlint_args)
      if result == ''
        {}
      else
        JSON.parse(result).flatten
      end
    end

    # Run swiftlint on each file and aggregate collect the issues
    #
    # @return [Array] swiftlint issues
    def run_swiftlint_for_each(files, options, additional_swiftlint_args)
      # Use `--use-script-input-files` flag along with `SCRIPT_INPUT_FILE_#` ENV
      # variables to pass the list of files we want swiftlint to lint
      options.merge!(use_script_input_files: true)

      # Set environment variables:
      #   * SCRIPT_INPUT_FILE_COUNT equal to number of files
      #   * a variable in the form of SCRIPT_INPUT_FILE_# for each file
      env = script_input(files)

      result = swiftlint.lint(options, additional_swiftlint_args, env)
      if result == ''
        {}
      else
        JSON.parse(result).flatten
      end
    end

    # Converts an array of files into `SCRIPT_INPUT_FILE_#` format
    # for use with `--use-script-input-files`
    # @return [Hash] mapping from `SCRIPT_INPUT_FILE_#` to file
    #         SCRIPT_INPUT_FILE_COUNT will be set to the number of files
    def script_input(files)
      files
        .map.with_index { |file, i| ["SCRIPT_INPUT_FILE_#{i}", file.to_s] }
        .push(['SCRIPT_INPUT_FILE_COUNT', files.size.to_s])
        .to_h
    end

    # Find swift files from the files glob
    # If files are not provided it will use git modifield and added files
    #
    # @return [Array] swift files
    def find_swift_files(dir_selected, files = nil, excluded_paths = [], included_paths = [])
      # Assign files to lint
      files = if files.nil?
                (git.modified_files - git.deleted_files) + git.added_files
              else
                Dir.glob(files)
              end
      # Filter files to lint
      excluded_paths_list = Find.find(*excluded_paths).to_a
      included_paths_list = Find.find(*included_paths).to_a
      files.
        # Ensure only swift files are selected
        select { |file| file.end_with?('.swift') }.
        # Convert to absolute paths
        map { |file| File.expand_path(file) }.
        # Remove dups
        uniq.
        # Ensure only files in the selected directory
        select { |file| file.start_with?(dir_selected) }.
        # Reject files excluded on configuration
        reject { |file| excluded_paths_list.include?(file) }.
        # Accept files included on configuration
        select do |file|
          next true if included_paths.empty?
          included_paths_list.include?(file)
        end
    end

    # Get the configuration file
    def load_config(filepath)
      return {} if filepath.nil? || !File.exist?(filepath)

      config_file = File.open(filepath).read

      # Replace environment variables
      config_file = parse_environment_variables(config_file)

      YAML.safe_load(config_file)
    end

    # Find all requested environment variables in the given string and replace them with the correct values.
    def parse_environment_variables(file_contents)
      # Matches the file contents for environment variables defined like ${VAR_NAME}.
      # Replaces them with the environment variable value if it exists.
      file_contents.gsub(/\$\{([^{}]+)\}/) do |env_var|
        return env_var if ENV[Regexp.last_match[1]].nil?
        ENV[Regexp.last_match[1]]
      end
    end

    # Parses the configuration file and return the specified files in path
    #
    # @return [Array] list of files specified in path
    def format_paths(paths, filepath)
      # Extract included paths
      paths
        .map { |path| File.join(File.dirname(filepath), path) }
        .map { |path| File.expand_path(path) }
        .select { |path| File.exist?(path) || Dir.exist?(path) }
    end

    # Create a markdown table from swiftlint issues
    #
    # @return  [String]
    def markdown_issues(results, heading)
      message = "#### #{heading}\n\n".dup

      message << "File | Line | Reason |\n"
      message << "| --- | ----- | ----- |\n"

      results.each do |r|
        filename = r['file'].split('/').last
        line = r['line']
        reason = r['reason']
        rule = r['rule_id']
        # Other available properties can be found int SwiftLint/…/JSONReporter.swift
        message << "#{filename} | #{line} | #{reason} (#{rule})\n"
      end

      message
    end

    # Send inline comment with danger's warn or fail method
    #
    # @return [void]
    def send_inline_comment(results, method)
      dir = "#{Dir.pwd}/"
      results.each do |r|
        github_filename = r['file'].gsub(dir, '')
        message = "#{r['reason']}".dup

        # extended content here
        filename = r['file'].split('/').last
        message << "\n"
        message << "`#{r['rule_id']}`" # helps writing exceptions // swiftlint:disable:this rule_id
        message << " `#{filename}:#{r['line']}`" # file:line for pasting into Xcode Quick Open
        
        send(method, message, file: github_filename, line: r['line'])
      end
    end

    def other_issues_message(issues_count)
      violations = issues_count == 1 ? 'violation' : 'violations'
      "SwiftLint also found #{issues_count} more #{violations} with this PR."
    end

    # Make SwiftLint object for binary_path
    #
    # @return [SwiftLint]
    def swiftlint
      Swiftlint.new(binary_path)
    end

    def log(text)
      puts(text) if @verbose
    end

    # Filters issues reported against changes in the modified files
    #
    # @return [Array] swiftlint issues
    def filter_git_diff_issues(issues)
      modified_files_info = git_modified_files_info()
      return issues.select { |i| 
           modified_files_info["#{i['file']}"] != nil && modified_files_info["#{i['file']}"].include?(i['line'].to_i) 
        }
    end

    # Finds modified files and added files, creates array of files with modified line numbers
    #
    # @return [Array] Git diff changes for each file
    def git_modified_files_info()
        modified_files_info = Hash.new
        updated_files = (git.modified_files - git.deleted_files) + git.added_files
        updated_files.each {|file|
            modified_lines = git_modified_lines(file)
            modified_files_info[File.expand_path(file)] = modified_lines
        }
        modified_files_info
    end

    # Gets git patch info and finds modified line numbers, excludes removed lines
    #
    # @return [Array] Modified line numbers i
    def git_modified_lines(file)
      git_range_info_line_regex = /^@@ .+\+(?<line_number>\d+),/ 
      git_modified_line_regex = /^\+(?!\+|\+)/
      git_removed_line_regex = /^\-(?!\-|\-)/
      file_info = git.diff_for_file(file)
      line_number = 0
      lines = []
      file_info.patch.split("\n").each do |line|
          starting_line_number = 0
          case line
          when git_range_info_line_regex
              starting_line_number = Regexp.last_match[:line_number].to_i
          when git_modified_line_regex
              lines << line_number
          end
          line_number += 1 if line_number > 0 && !git_removed_line_regex.match?(line)
          line_number = starting_line_number if line_number == 0 && starting_line_number > 0
      end
      lines
    end
  end
end
