require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe DangerSwiftlint do
    it 'is a plugin' do
      expect(Danger::DangerSwiftlint < Danger::Plugin).to be_truthy
    end

    describe 'with Dangerfile' do
      before do
        @swiftlint = testing_dangerfile.swiftlint
      end

      it "handles swiftlint not being installed" do
        allow(Swiftlint).to receive(:is_installed?).and_return(false)
        expect { @swiftlint.lint_files }.to raise_error("swiftlint is not installed")
      end

      it 'does not markdown an empty message' do
        allow(Swiftlint).to receive(:lint).and_return('[]')
        expect(@swiftlint.status_report[:markdowns].first).to be_nil
      end

      describe :lint_files do
        before do
          allow(Swiftlint).to receive(:is_installed?).and_return(true)
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([])

          @swiftlint_response = '[{ "rule_id" : "force_cast", "reason" : "Force casts should be avoided.", "character" : 19, "file" : "/Users/me/this_repo/spec//fixtures/SwiftFile.swift", "severity" : "Error", "type" : "Force Cast", "line" : 13 }]'
        end

        it 'accept files as arguments' do
          expect(Swiftlint).to receive(:lint)
            .with(hash_including(:path => 'spec/fixtures/SwiftFile.swift'))
            .and_return(@swiftlint_response)

          @swiftlint.lint_files("spec/fixtures/*.swift")

          output = @swiftlint.status_report[:markdowns].first.to_s
          expect(output).to include("SwiftLint found issues")
          expect(output).to include("SwiftFile.swift | 13 | Force casts should be avoided.")
        end

        it 'uses git diff when files are not provided' do
          allow(@swiftlint.git).to receive(:modified_files).and_return(['spec/fixtures/SwiftFile.swift'])
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(Swiftlint).to receive(:lint)
            .with(hash_including(:path => 'spec/fixtures/SwiftFile.swift'))
            .and_return(@swiftlint_response)

          @swiftlint.lint_files

          output = @swiftlint.status_report[:markdowns].first.to_s
          expect(output).to_not be_empty
        end

        it 'uses a custom directory' do
          @swiftlint.directory = 'some_dir'

          allow(Swiftlint).to receive(:lint)
            .with(hash_including(:pwd => @swiftlint.directory))
            .and_return(@swiftlint_response)

          @swiftlint.lint_files("spec/fixtures/*.swift")

          output = @swiftlint.status_report[:markdowns].first.to_s
          expect(output).to_not be_empty
        end

        it 'does not crash if JSON reporter returns an empty string rather than an object' do
          # This can occurr if for some reson there is no file at the give path.
          # In such a case SwiftLint will write to stderr:
          #
          #   Could not read contents of `path/to/file`
          #   No lintable files found at path 'path/to/file'
          #
          # and exit with code 1.
          #
          # To our code this would simply look like an empty result, which
          # would then become an empty string, which cannot be parsed into a
          # JSON object.

          allow(Swiftlint).to receive(:lint).and_return('')

          expect { @swiftlint.lint_files }.not_to raise_error
        end

        it 'does not lint files in the excluded paths' do
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
            'spec/fixtures/SwiftFile.swift',
            'spec/fixtures/excluded_dir/SwiftFileThatShouldNotBeIncluded.swift'
          ])

          expect(Swiftlint).to receive(:lint)
            .with(hash_including(:path => 'spec/fixtures/SwiftFile.swift'))
            .and_return(@swiftlint_response)
            .once

          @swiftlint.config_file = 'spec/fixtures/some_config.yml'
          @swiftlint.lint_files
        end
      end
    end
  end
end
