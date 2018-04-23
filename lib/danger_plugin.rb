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
    def lint_files(files = nil, inline_mode: false, fail_on_error: false, additional_swiftlint_args: '')
      # Fails if swiftlint isn't installed
      raise 'swiftlint is not installed' unless swiftlint.installed?

      config_file_path = if config_file
                           config_file
                         elsif File.file?('.swiftlint.yml')
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

      # Extract swift files (ignoring excluded ones)
      files = find_swift_files(dir_selected, files, excluded_paths, included_paths)
      log "Swiftlint will lint the following files: #{files.join(', ')}"

      # Prepare swiftlint options
      options = {
        # Make sure we don't fail when config path has spaces
        config: config_file_path ? Shellwords.escape(config_file_path) : nil,
        reporter: 'json',
        quiet: true,
        pwd: dir_selected,
        force_exclude: ''
      }
      log "linting with options: #{options}"

      # Lint each file and collect the results
      issues = run_swiftlint(files, options, additional_swiftlint_args)
      other_issues_count = 0
      unless @max_num_violations.nil?
        other_issues_count = issues.count - @max_num_violations if issues.count > @max_num_violations
        issues = issues.take(@max_num_violations)
      end
      log "Received from Swiftlint: #{issues}"

      # Filter warnings and errors
      warnings = issues.select { |issue| issue['severity'] == 'Warning' }
      errors = issues.select { |issue| issue['severity'] == 'Error' }

      if inline_mode
        # Report with inline comment
        send_inline_comment(warnings, :warn)
        send_inline_comment(errors, fail_on_error ? :fail : :warn)
        warn other_issues_message(other_issues_count) if other_issues_count > 0
      elsif warnings.count > 0 || errors.count > 0
        # Report if any warning or error
        message = +"### SwiftLint found issues\n\n"
        message << markdown_issues(warnings, 'Warnings') unless warnings.empty?
        message << markdown_issues(errors, 'Errors') unless errors.empty?
        message << "\n#{other_issues_message(other_issues_count)}" if other_issues_count > 0
        markdown message

        # Fail Danger on errors
        if fail_on_error && errors.count > 0
          fail 'Failed due to SwiftLint errors'
        end
      end
    end

    # Run swiftlint on each file and aggregate collect the issues
    #
    # @return [Array] swiftlint issues
    def run_swiftlint(files, options, additional_swiftlint_args)
      files
        .map { |file| options.merge(path: file) }
        .map { |full_options| swiftlint.lint(full_options, additional_swiftlint_args) }
        .reject { |s| s == '' }
        .map { |s| JSON.parse(s).flatten }
        .flatten
    end

    # Find swift files from the files glob
    # If files are not provided it will use git modifield and added files
    #
    # @return [Array] swift files
    def find_swift_files(dir_selected, files = nil, excluded_paths = [], included_paths = [])
      # Needs to be escaped before comparsion with escaped file paths
      dir_selected = Shellwords.escape(dir_selected)

      # Assign files to lint
      files = if files.nil?
                (git.modified_files - git.deleted_files) + git.added_files
              else
                Dir.glob(files)
              end
      # Filter files to lint
      files.
        # Ensure only swift files are selected
        select { |file| file.end_with?('.swift') }.
        # Make sure we don't fail when paths have spaces
        map { |file| Shellwords.escape(File.expand_path(file)) }.
        # Remove dups
        uniq.
        # Ensure only files in the selected directory
        select { |file| file.start_with?(dir_selected) }.
        # Reject files excluded on configuration
        reject { |file| file_exists?(excluded_paths, file) }.
        # Accept files included on configuration
        select do |file|
        next true if included_paths.empty?
        file_exists?(included_paths, file)
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

    # Return whether the file exists within a specified collection of paths
    #
    # @return [Bool] file exists within specified collection of paths
    def file_exists?(paths, file)
      paths.any? do |path|
        Find.find(path)
            .map { |path_file| Shellwords.escape(path_file) }
            .include?(file)
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
      message = +"#### #{heading}\n\n"

      message << "File | Line | Reason |\n"
      message << "| --- | ----- | ----- |\n"

      results.each do |r|
        filename = r['file'].split('/').last
        line = r['line']
        reason = r['reason']

        message << "#{filename} | #{line} | #{reason} \n"
      end

      message
    end

    # Send inline comment with danger's warn or fail method
    #
    # @return [void]
    def send_inline_comment(results, method)
      dir = "#{Dir.pwd}/"
      results.each do |r|
        filename = r['file'].gsub(dir, '')
        send(method, r['reason'], file: filename, line: r['line'])
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
  end
end
