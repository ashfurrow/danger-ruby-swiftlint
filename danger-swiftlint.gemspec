# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = 'danger-swiftlint'
  spec.version       = DangerSwiftlint::VERSION
  spec.authors       = ['Ash Furrow', 'David Grandinetti', 'Orta Therox', 'Thiago Felix', 'Giovanni Lodi']
  spec.email         = ['ash@ashfurrow.com', 'dbgrandi@gmail.com', 'orta.therox@gmail.com', 'thiago@thiagofelix.com', 'gio@mokacoding.com']
  spec.description   = 'A Danger plugin for linting Swift with SwiftLint.'
  spec.summary       = 'A Danger plugin for linting Swift with SwiftLint.'
  spec.homepage      = 'https://github.com/ashfurrow/danger-ruby-swiftlint'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\0").select { |f| f.end_with?('rb') || f.end_with?('sh') }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.extensions    = %w[ext/swiftlint/Rakefile]
  spec.executables   = ['danger-swiftlint']
  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'danger'
  spec.add_dependency 'thor', '~> 1.4'
  spec.add_dependency 'rake', '> 10'

  # General ruby development
  spec.add_development_dependency 'bundler', '~> 1.3'

  #  Testing support
  spec.add_development_dependency 'rspec', '~> 3.4'

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency 'guard', '~> 2.19'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'

  # If you want to work on older builds of ruby
  spec.add_development_dependency 'listen', '3.0.7'

  # This gives you the chance to run a REPL inside your test
  # via
  #    binding.pry
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency 'pry'
end
