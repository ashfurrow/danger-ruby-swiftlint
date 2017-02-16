import 'ext/swiftlint/Rakefile'
require 'bundler/gem_tasks'
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :spec do
  Rake::Task['specs'].invoke
end

task :default => :spec

