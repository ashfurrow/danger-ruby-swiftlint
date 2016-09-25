require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe DangerSwiftlint do
    it 'is a plugin' do
      expect(Danger::DangerSwiftlint < Danger::Plugin).to be_truthy
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @swiftlint = testing_dangerfile.swiftlint

        @swiftlint.config_file = nil
      end

      it "handles swiftlint not being installed" do
        allow(@swiftlint).to receive(:`).with("which swiftlint").and_return("")
        expect(@swiftlint.swiftlint_installed?).to be_falsy
      end

      it "handles swiftlint being installed" do
        allow(@swiftlint).to receive(:`).with("which swiftlint").and_return("/bin/wherever/swiftlint")
        expect(@swiftlint.swiftlint_installed?).to be_truthy
      end

      it 'does not markdown an empty message' do
        allow(@swiftlint).to receive(:`)
          .with('swiftlint lint --quiet --reporter json')
          .and_return('[]')
        
        expect(@swiftlint.status_report[:markdowns].first).to be_nil
      end

      describe :lint_files do
        before do
          # So it doesn't try to install on your computer
          allow(@swiftlint).to receive(:`).with("which swiftlint").and_return("/bin/wheverever/swiftlint")

          # Set up our stubbed JSON response
          @swiftlint_response = '[{"reason": "Force casts should be avoided.", "file": "/User/me/this_repo/spec/fixtures/SwiftFile.swift", "line": 13, "severity": "Error" }]'
        end

        it 'handles a known SwiftLint report' do
          allow(@swiftlint).to receive(:`).with('(swiftlint lint --quiet --reporter json)').and_return(@swiftlint_response)

          # Do it
          @swiftlint.lint_files

          output = @swiftlint.status_report[:markdowns].first.to_s

          expect(output).to_not be_empty

          # A title
          expect(output).to include("SwiftLint found issues")
          # A warning
          expect(output).to include("SwiftFile.swift | 13 | Force casts should be avoided.")
        end

        it 'handles no files' do
          allow(@swiftlint).to receive(:`).with('(swiftlint lint --quiet --reporter json)').and_return(@swiftlint_response)

          @swiftlint.lint_files

          expect(@swiftlint.status_report[:markdowns].first.to_s).to_not be_empty
        end

        it 'uses a config file' do
          @swiftlint.config_file = 'some_config.yml'
          allow(@swiftlint).to receive(:`).with('(swiftlint lint --quiet --reporter json --config some_config.yml)').and_return(@swiftlint_response)

          @swiftlint.lint_files

          expect(@swiftlint.status_report[:markdowns].first.to_s).to_not be_empty
        end

        it 'uses a custom directory' do
          @swiftlint.directory = 'some_dir'
          allow(@swiftlint).to receive(:`).with('(cd some_dir && swiftlint lint --quiet --reporter json)').and_return(@swiftlint_response)

          @swiftlint.lint_files

          expect(@swiftlint.status_report[:markdowns].first.to_s).to_not be_empty
        end
      end
    end
  end
end
