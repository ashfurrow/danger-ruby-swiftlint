# frozen_string_literal: true

require File.expand_path('../spec_helper', __FILE__)
require_relative '../ext/swiftlint/swiftlint'

describe Swiftlint do
  let(:swiftlint) { Swiftlint.new }
  it 'is_installed? works based on bin/swiftlint file' do
    expect(File).to receive(:exist?).with(/bin\/swiftlint/).and_return(true)
    expect(swiftlint.is_installed?).to be_truthy

    expect(File).to receive(:exist?).with(/bin\/swiftlint/).and_return(false)
    expect(swiftlint.is_installed?).to be_falsy
  end

  context 'with binary_path' do
    let(:binary_path) { '/path/to/swiftlint' }
    let(:swiftlint) { Swiftlint.new(binary_path) }
    it 'is_installed? works based on specific path' do
      expect(File).to receive(:exist?).with(binary_path).and_return(true)
      expect(swiftlint.is_installed?).to be_truthy

      expect(File).to receive(:exist?).with(binary_path).and_return(false)
      expect(swiftlint.is_installed?).to be_falsy
    end
  end

  it 'runs lint by default with options being optional' do
    expect(swiftlint).to receive(:`).with(including('swiftlint lint'))
    swiftlint.run
  end

  it 'runs accepting symbolized options' do
    cmd = 'swiftlint lint --no-use-stdin  --cache-path /path --enable-all-rules'
    expect(swiftlint).to receive(:`).with(including(cmd))

    swiftlint.run('lint',
                  '',
                  use_stdin: false,
                  cache_path: '/path',
                  enable_all_rules: true)
  end
end
