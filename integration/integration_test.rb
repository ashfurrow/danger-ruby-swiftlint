require File.expand_path('../../spec/spec_helper', __FILE__)

describe 'DangerSwiftlint Integration' do
  it 'fails' do
    dangerfile = testing_dangerfile
    swiftlint = dangerfile.swiftlint

    swiftlint.config_file = File.dirname(File.expand_path(__FILE__)) + '/.swiftlint.yml.fixed'
    swiftlint.lint_files
  end
end
