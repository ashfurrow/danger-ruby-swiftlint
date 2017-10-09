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

      config = if config_file
        File.expand_path(config_file)
      elsif File.file?('.swiftlint.yml')
        File.expand_path('.swiftlint.yml')
      else
        nil
      end
      log "Using config file: #{config}"

      dir_selected = directory ? File.expand_path(directory) : Dir.pwd
      log "Swiftlint will be run from #{dir_selected}"

      # Extract excluded paths
      excluded_paths = excluded_files_from_config(config)

      # Extract swift files (ignoring excluded ones)
      files = find_swift_files(dir_selected, files, excluded_paths)
      log "Swiftlint will lint the following files: #{files.join(', ')}"

      # Prepare swiftlint options
      options = {
        config: config,
        reporter: 'json',
        quiet: true,
        pwd: dir_selected
      }
      log "linting with options: #{options}"

      # Lint each file and collect the results
      issues = run_swiftlint(files, options, additional_swiftlint_args)
      log "Received from Swiftlint: #{issues}"

      # Filter warnings and errors
      warnings = issues.select { |issue| issue['severity'] == 'Warning' }
      errors = issues.select { |issue| issue['severity'] == 'Error' }

      if inline_mode
        # Report with inline comment
        send_inline_comment(warnings, 'warn')
        send_inline_comment(errors, 'fail')
      elsif warnings.count.positive? || errors.count.positive?
        # Report if any warning or error
        message = +"### SwiftLint found issues\n\n"
        message << markdown_issues(warnings, 'Warnings') unless warnings.empty?
        message << markdown_issues(errors, 'Errors') unless errors.empty?
        markdown message

        # Fail Danger on errors
        if fail_on_error && errors.count.positive?
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
    def find_swift_files(dir_selected, files = nil, excluded_paths = [])
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
        map { |file| Shellwords.escape(file) }.
        # Remove dups
        uniq
           .map { |file| File.expand_path(file) }.
        # Ensure only files in the selected directory
        select { |file| file.start_with?(dir_selected) }.
        # Reject files excluded on configuration
        reject do |file|
        excluded_paths.any? do |excluded_path|
          Find.find(excluded_path)
              .map { |excluded_file| Shellwords.escape(excluded_file) }
              .include?(file)
        end
      end
    end

    # Parses the configuration file and return the excluded files
    #
    # @return [Array] list of files excluded
    def excluded_files_from_config(filepath)
      config = if filepath
                 YAML.load_file(filepath)
               else
                 { 'excluded' => [] }
               end

      excluded_paths = config['excluded'] || []

      # Extract excluded paths
      excluded_paths
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
