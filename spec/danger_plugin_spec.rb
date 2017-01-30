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
          .with('swiftlint lint --quiet --reporter json --path "spec/fixtures/SwiftFile.swift"')
          .and_return('[]')

        expect(@swiftlint.status_report[:markdowns].first).to be_nil
      end

      describe :lint_files do
        before do
          # So it doesn't try to install on your computer
          allow(@swiftlint).to receive(:`).with("which swiftlint").and_return("/bin/wheverever/swiftlint")

          # Set up our stubbed JSON response
          @swiftlint_response = '[{ "rule_id" : "force_cast", "reason" : "Force casts should be avoided.", "character" : 19, "file" : "/Users/me/this_repo/spec//fixtures/SwiftFile.swift", "severity" : "Error", "type" : "Force Cast", "line" : 13 }]'
        end

        it 'handles a known SwiftLint report with give files' do
          allow(@swiftlint).to receive(:`).with('(swiftlint lint --quiet --reporter json --path "spec/fixtures/SwiftFile.swift")').and_return(@swiftlint_response)

          # Do it
          @swiftlint.lint_files("spec/fixtures/*.swift")

          output = @swiftlint.status_report[:markdowns].first.to_s

          expect(output).to_not be_empty

          # A title
          expect(output).to include("SwiftLint found issues")
          # A warning
          expect(output).to include("SwiftFile.swift | 13 | Force casts should be avoided.")
        end

        it 'handles no given files by looking up the git diff' do
          allow(@swiftlint.git).to receive(:modified_files).and_return(['spec/fixtures/SwiftFile.swift'])
          allow(@swiftlint.git).to receive(:added_files).and_return([])

          allow(@swiftlint).to receive(:`).with('(swiftlint lint --quiet --reporter json --path "spec/fixtures/SwiftFile.swift")').and_return(@swiftlint_response)

          @swiftlint.lint_files

          expect(@swiftlint.status_report[:markdowns].first.to_s).to_not be_empty
        end

        it 'uses a config file generated on the fly by removing the "included" values from the given one' do
          fake_temp_file = Tempfile.new('fake.yml')

          begin
            allow(Tempfile).to receive(:open) { |&block| block.call(fake_temp_file) }

            @swiftlint.config_file = 'spec/fixtures/some_config.yml'

            expect(YAML.load_file(@swiftlint.config_file)['included']).to_not be_nil

            allow(@swiftlint).to receive(:`).with('(swiftlint lint --quiet --reporter json --config ' + fake_temp_file.path + ' --path "spec/fixtures/SwiftFile.swift")') do
              # The tempfile lifetime is limited to the execution of the lint
              # command, as such if we were to assert it after the command has
              # run the file wouldn't exist anymore.
              #
              # By injecting the assertion here, whithin the method execution,
              # we access the file while it still exists.
              expect(YAML.load_file(fake_temp_file.path)['included']).to be_nil

              @swiftlint_response
            end

            @swiftlint.lint_files("spec/fixtures/*.swift")

            expect(@swiftlint.status_report[:markdowns].first.to_s).to_not be_empty
          ensure
            fake_temp_file.close
            fake_temp_file.unlink
          end
        end

        it 'uses a custom directory' do
          @swiftlint.directory = 'some_dir'
          allow(@swiftlint).to receive(:`).with('(cd some_dir && swiftlint lint --quiet --reporter json)').and_return(@swiftlint_response)

          @swiftlint.lint_files

          expect(@swiftlint.status_report[:markdowns].first.to_s).to_not be_empty
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
          response = ''
          allow(@swiftlint).to receive(:`).with('(swiftlint lint --quiet --reporter json --path "spec/fixtures/SwiftFile.swift")').and_return(response)

          @swiftlint.lint_files("spec/fixtures/*.swift")

          output = @swiftlint.status_report[:markdowns].first.to_s

          # If we get to this point then we haven't crashed, happy days
          expect(output).to be_empty
        end

        it 'does not lint files in the excluded paths' do
          allow(@swiftlint.git).to receive(:modified_files).and_return(['spec/fixtures/SwiftFile.swift', 'spec/fixtures/excluded_dir/SwiftFileThatShouldNotBeIncluded.swift'])
          allow(@swiftlint.git).to receive(:added_files).and_return([])

          fake_temp_file = Tempfile.new('fake.yml')

          begin
            allow(Tempfile).to receive(:open) { |&block| block.call(fake_temp_file) }

            # The only call that should be received is this one, if @swiftlint
            # will be called with any other param the test will fail
            allow(@swiftlint).to receive(:`).with('(swiftlint lint --quiet --reporter json --config ' + fake_temp_file.path + ' --path "spec/fixtures/SwiftFile.swift")').and_return(@swiftlint_response)

            @swiftlint.config_file = 'spec/fixtures/some_config.yml'
            @swiftlint.lint_files
          ensure
            fake_temp_file.close
            fake_temp_file.unlink
          end
        end
      end
    end
  end
end
