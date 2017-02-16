
class Swiftlint
  class << self
    # Runs swiftlint
    # @param key (Symbol) the key which is used as command paramters or key in the fastlane tools
    # @param env_name (String) the name of the environment variable, which is only used if no other values were found
    # @param description (String) A description shown to the user
    # @param sensitive (Boolean) Set if the variable is sensitive, such as a password or API token, to prevent echoing when prompted for the parameter
    def run(cmd='lint', options={})

      # change pwd before run swiftlint
      if options.has_key? :pwd
        Dir.chdir options.delete(:pwd)
      end

      # run swiftlint with provided options
      `#{swiftlint_path} #{cmd} #{swiftlint_arguments(options)}`
    end

    # Shortcut for running the lint command
    def lint(options)
      run('lint', options)
    end

    # Return true if swiftlint is installed or false otherwise
    def is_installed?
      File.exist?(swiftlint_path)
    end

    private

    # Parse options into shell arguments how swift expect it to be
    # more information: https://github.com/Carthage/Commandant
    # @param options (Hash) hash containing swiftlint options
    def swiftlint_arguments options
      options.
        # filter not null
        select {|key, value| !value.nil?}.
        # map booleans arguments equal true
        map { |key, value| value.is_a?(TrueClass) ? [key, ''] : [key, value] }.
        # map booleans arguments equal false
        map { |key, value| value.is_a?(FalseClass) ? ["no-#{key}", ''] : [key, value] }.
        # replace underscore by hyphen
        map { |key, value| [key.to_s.tr('_', '-'), value] }.
        # prepend '--' into the argument
        map { |key, value| ["--#{key}", value] }.
        # reduce everything into a single string
        reduce('') { |args, option| "#{args} #{option[0]} #{option[1]}" }.
        # strip leading spaces
        strip
    end

    # Path where swiftlint should be found
    def swiftlint_path
      File.expand_path(File.join(File.dirname(__FILE__), 'bin', 'swiftlint'))
    end
  end
end
