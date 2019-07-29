# frozen_string_literal: true

# A wrapper to use SwiftLint via a Ruby API.
class Swiftlint
  def initialize(swiftlint_path = nil)
    @swiftlint_path = swiftlint_path
  end

  # Runs swiftlint
  def run(cmd = 'lint', additional_swiftlint_args = '', options = {}, env = nil)
    # change pwd before run swiftlint
    Dir.chdir options.delete(:pwd) if options.key? :pwd

    # Add `env` to environment
    update_env(env)
    begin
      # run swiftlint with provided options
      `#{swiftlint_path} #{cmd} #{swiftlint_arguments(options, additional_swiftlint_args)}`
    ensure
      # Remove any ENV variables we might have added
      restore_env()
    end
  end

  # Shortcut for running the lint command
  def lint(options, additional_swiftlint_args, env = nil)
    run('lint', additional_swiftlint_args, options, env)
  end

  # Return true if swiftlint is installed or false otherwise
  def installed?
    File.exist?(swiftlint_path)
  end

  # Return swiftlint execution path
  def swiftlint_path
    @swiftlint_path || default_swiftlint_path
  end

  private

  # Parse options into shell arguments how swift expect it to be
  # more information: https://github.com/Carthage/Commandant
  # @param options (Hash) hash containing swiftlint options
  def swiftlint_arguments(options, additional_swiftlint_args)
    (options.
      # filter not null
      reject { |_key, value| value.nil? }.
      # map booleans arguments equal true
      map { |key, value| value.is_a?(TrueClass) ? [key, ''] : [key, value] }.
      # map booleans arguments equal false
      map { |key, value| value.is_a?(FalseClass) ? ["no-#{key}", ''] : [key, value] }.
      # replace underscore by hyphen
      map { |key, value| [key.to_s.tr('_', '-'), value] }.
      # prepend '--' into the argument
      map { |key, value| ["--#{key}", value] }.
      # reduce everything into a single string
      reduce('') { |args, option| "#{args} #{option[0]} #{option[1]}" } +
      " #{additional_swiftlint_args}").
      # strip leading spaces
      strip
  end

  # Path where swiftlint should be found
  def default_swiftlint_path
    File.expand_path(File.join(File.dirname(__FILE__), 'bin', 'swiftlint'))
  end

  # Adds `env` to shell environment as variables
  # @param env (Hash) hash containing environment variables to add
  def update_env(env)
    return if !env || env.empty?
    # Keep the same @original_env if we've already set it, since that would mean
    # that we're adding more variables, in which case, we want to make sure to
    # keep the true original when we go to restore it.
    @original_env = ENV.to_h if @original_env.nil?
    # Add `env` to environment
    ENV.update(env)
  end

  # Restores shell environment to values in `@original_env`
  # All environment variables not in `@original_env` will be removed
  def restore_env()
    if !@original_env.nil?
      ENV.replace(@original_env)
      @original_env = nil
    end
  end
end
