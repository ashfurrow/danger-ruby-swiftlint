# frozen_string_literal: true

require 'pathname'

ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$LOAD_PATH.unshift((ROOT + 'lib').to_s)
$LOAD_PATH.unshift((ROOT + 'spec').to_s)

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true
end

RSpec::Matchers.define :including do |x|
  match { |actual| actual.include? x }
end

require 'bundler/setup'
require 'pry'

require 'danger'
require 'cork'
require 'danger_plugin'

# These functions are a subset of https://github.com/danger/danger/blob/master/spec/spec_helper.rb
# If you are expanding these files, see if it's already been done ^.

# A silent version of the user interface
def testing_ui
  Cork::Board.new(silent: true)
end

# Example environment (ENV) that would come from
# running a PR on TravisCI
def testing_env
  {
    'HAS_JOSH_K_SEAL_OF_APPROVAL' => 'true',
    'TRAVIS_PULL_REQUEST' => '800',
    'TRAVIS_REPO_SLUG' => 'artsy/eigen',
    'TRAVIS_COMMIT_RANGE' => '759adcbd0d8f...13c4dc8bb61d',
    'DANGER_GITHUB_API_TOKEN' => '123sbdq54erfsd3422gdfio'
  }
end

# A stubbed out Dangerfile for use in tests
def testing_dangerfile
  env = Danger::EnvironmentManager.new(testing_env)
  Danger::Dangerfile.new(env, testing_ui)
end
