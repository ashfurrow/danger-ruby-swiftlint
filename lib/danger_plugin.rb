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

    # Lints Swift files. Will fail if `swiftlint` cannot be installed correctly.
    # Generates a `markdown` list of warnings for the prose in a corpus of .markdown and .md files.
    #
    # @param   [String] files
    #          A globbed string which should return the files that you want to lint, defaults to nil.
    #          if nil, modified and added files from the diff will be used.
    # @return  [void]
    #
    def lint_files(files=nil, inline_mode: false)
      # Fails if swiftlint isn't installed
      raise "swiftlint is not installed" unless swiftlint.is_installed?

      config = if config_file
        config_file
      elsif File.file?('.swiftlint.yml')
        '.swiftlint.yml'
      else
        nil
      end

      # Extract excluded paths
      excluded_paths = excluded_files_from_config(config)

      # Extract swift files (ignoring excluded ones)
      files = find_swift_files(files, excluded_paths)

      # Prepare swiftlint options
      options = {
        config: config,
        reporter: 'json',
        quiet: true,
        pwd: directory ? File.expand_path(directory) : Dir.pwd
      }

      # Lint each file and collect the results
      issues = run_swiftlint(files, options)

      # Filter warnings and errors
      warnings = issues.select { |issue| issue['severity'] == 'Warning' }
      errors = issues.select { |issue| issue['severity'] == 'Error' }

      if inline_mode
        # Reprt with inline comment
        send_inline_comment(warnings, "warn")
        send_inline_comment(errors, "fail")
      else
        # Report if any warning or error
        if warnings.count > 0 || errors.count > 0
          message = "### SwiftLint found issues\n\n"
          message << markdown_issues(warnings, 'Warnings') unless warnings.empty?
          message << markdown_issues(errors, 'Errors') unless errors.empty?
          markdown message
        end
      end
    end

    # Run swiftlint on each file and aggregate collect the issues
    #
    # @return [Array] swiftlint issues
    def run_swiftlint(files, options)
      files
        .map { |file| options.merge({path: file})}
        .map { |full_options| swiftlint.lint(full_options)}
        .reject { |s| s == '' }
        .map { |s| JSON.parse(s).flatten }
        .flatten
    end

    # Find swift files from the files glob
    # If files are not provided it will use git modifield and added files
    #
    # @return [Array] swift files
    def find_swift_files(files=nil, excluded_paths=[])
      # Assign files to lint
      files = files ? Dir.glob(files) : (git.modified_files - git.deleted_files) + git.added_files

      # Filter files to lint
      return files.
        # Ensure only swift files are selected
        select { |file| file.end_with?('.swift') }.
        # Make sure we don't fail when paths have spaces
        map { |file| Shellwords.escape(file) }.
        # Remove dups
        uniq.
        map { |file| File.expand_path(file) }.
        # Reject files excluded on configuration
        reject { |file|
          excluded_paths.any? { |excluded_path|
            Find.find(excluded_path).
              map { |excluded_file| Shellwords.escape(excluded_file) }.
              include?(file)
          }
        }
    end

    # Parses the configuration file and return the excluded files
    #
    # @return [Array] list of files excluded
    def excluded_files_from_config(filepath)
      config = if filepath
        YAML.load_file(filepath)
      else
        {"excluded" => []}
      end

      excluded_paths = config['excluded'] || []

      # Extract excluded paths
      return excluded_paths.
        map { |path| File.join(File.dirname(filepath), path) }.
        map { |path| File.expand_path(path) }.
        select { |path| File.exists?(path) || Dir.exists?(path) }
    end

    # Create a markdown table from swiftlint issues
    #
    # @return  [String]
    def markdown_issues (results, heading)
      message = "#### #{heading}\n\n"

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
    def send_inline_comment (results, method)
      dir = "#{Dir.pwd}/"
      results.each do |r|
	filename = r['file'].gsub(dir, "")
	send(method, r['reason'], file: filename, line: r['line'])
      end
    end

    # Make SwiftLint object for binary_path
    #
    # @return [SwiftLint]
    def swiftlint
      Swiftlint.new(binary_path)
    end
  end
end
