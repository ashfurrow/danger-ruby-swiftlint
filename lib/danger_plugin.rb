module Danger

  # Lint Swift files inside your projects.
  # This is done using the [SwiftLint](https://github.com/realm/SwiftLint) tool.
  # Results are passed out as a table in markdown.
  #
  # @example TODO: Specifying custom CocoaPods installation options
  #
  #          # Runs a linter with comma style disabled
  #          proselint.disable_linters = [“misc.scare_quotes”, "misc.tense_present"]
  #          proselint.lint_files “_posts/*.md”
  #
  #          # Runs a linter with all styles, on modified and added markpown files in this PR
  #          proselint.lint_files
  #
  # @see  artsy/eigen
  # @tags swift
  #
  class DangerSwiftlint < Plugin

    # Allows you to specify a config file location for swiftlint.
    attr_accessor :config_file

    # Lints Swift files. Will fail if `swiftlint` cannot be installed correctly.
    # Generates a `markdown` list of warnings for the prose in a corpus of .markdown and .md files. 
    #
    # @param   [String] files
    #          A globbed string which should return the files that you want to lint, defaults to nil.
    #          if nil, modified and added files from the diff will be used.
    # @return  [void]
    #
    def lint_files(files=nil)
      # Installs a prose checker if needed
      system "brew install swiftlint" unless swiftlint_installed?

      # Check that this is in the user's PATH after installing
      unless swiftlint_installed?
        fail "swiftlint is not in the user's PATH, or it failed to install"
        return
      end

      # Either use files provided, or use the modified + added
      swift_files = files ? Dir.glob(files) : (modified_files + added_files)
      swift_files.select! do |line| line.end_with?(".swift") end

      swiftlint_command = "swiftlint lint --quiet --reporter json"
      swiftlint_command += " --config #{config_file}" if config_file

      require 'json'
      result_json = swift_files.uniq.collect { |f| JSON.parse(`#{swiftlint_command} --path #{f}`.strip).flatten }.flatten

      # Convert to swiftlint results
      warnings = result_json.flatten.select do |results| 
        results['severity'] == 'Warning'
      end
      errors = result_json.select do |results| 
        results['severity'] == 'Error' 
      end

      message = ''

      # We got some error reports back from swiftlint
      if warnings.count > 0 || errors.count > 0
        message = '### SwiftLint found issues\n\n'
      end

      message << parse_results(warnings, 'Warnings') unless warnings.empty?
      message << parse_results(errors, 'Errors') unless errors.empty?

      markdown message
    end

    def parse_results (results, heading)
      message = "#### #{heading}\n\n"

      message << 'File | Line | Reason |\n'
      message << '| --- | ----- | ----- |\n'

      results.each do |r|
        filename = r['file'].split('/').last
        line = r['line']
        reason = r['reason']

        message << "#{filename} | #{line} | #{reason} \n"
      end

      message
    end

    # Determine if swiftlint is currently installed in the system paths.
    # @return  [Bool]
    #
    def swiftlint_installed?
      `which swiftlint`.strip.empty? == false
    end
  end
end
