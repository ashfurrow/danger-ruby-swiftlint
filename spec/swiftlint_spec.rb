require File.expand_path('../spec_helper', __FILE__)
require_relative '../ext/swiftlint/swiftlint'

describe Swiftlint do
  it 'is_installed? works based on bin/swiftlint file' do
    expect(File).to receive(:exist?).with(/bin\/swiftlint/).and_return(true)
    expect(Swiftlint.is_installed?).to be_truthy

    expect(File).to receive(:exist?).with(/bin\/swiftlint/).and_return(false)
    expect(Swiftlint.is_installed?).to be_falsy
  end

  it 'runs lint by default with options being optional' do
    expect(Swiftlint).to receive(:`).with(including('swiftlint lint'))
    Swiftlint.run()
  end

  it 'runs accepting symbolized options' do
    cmd = 'swiftlint lint --no-use-stdin  --cache-path /path --enable-all-rules'
    expect(Swiftlint).to receive(:`).with(including(cmd))

    Swiftlint.run('lint',
                  use_stdin: false,
                  cache_path: '/path',
                  enable_all_rules: true)
  end
end

