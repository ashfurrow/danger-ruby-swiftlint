# frozen_string_literal: true

require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe DangerSwiftlint do
    it 'is a plugin' do
      expect(Danger::DangerSwiftlint < Danger::Plugin).to be_truthy
    end

    describe 'with Dangerfile' do
      before do
        @swiftlint = testing_dangerfile.swiftlint
        allow(@swiftlint.git).to receive(:deleted_files).and_return([])
      end

      it 'handles swiftlint not being installed' do
        allow_any_instance_of(Swiftlint).to receive(:installed?).and_return(false)
        expect { @swiftlint.lint_files }.to raise_error('swiftlint is not installed')
      end

      it 'does not markdown an empty message' do
        allow_any_instance_of(Swiftlint).to receive(:lint).and_return('[]')
        expect(@swiftlint.status_report[:markdowns].first).to be_nil
      end

      context 'with binary_path' do
        let(:binary_path) { '/path/to/swiftlint' }
        it 'passes binary_path to constructor' do
          @swiftlint.binary_path = binary_path
          swiftlint = double('swiftlint')
          allow(Swiftlint).to receive(:new).with(binary_path).and_return(swiftlint)

          expect(@swiftlint.swiftlint).to eql(swiftlint)
        end
      end

      describe :lint_files do
        before do
          allow_any_instance_of(Swiftlint).to receive(:installed?).and_return(true)
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([])

          @swiftlint_response = '[{ "rule_id" : "force_cast", "reason" : "Force casts should be avoided.", "character" : 19, "file" : "/Users/me/this_repo/spec//fixtures/SwiftFile.swift", "severity" : "Error", "type" : "Force Cast", "line" : 13 }]'
        end

        after(:each) do
          ENV['ENVIRONMENT_EXAMPLE'] = nil
        end

        it 'specifies --force-exclude when invoking SwiftLint' do
          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(force_exclude: ''), '')
            .and_return(@swiftlint_response)

          @swiftlint.lint_files('spec/fixtures/*.swift')

          output = @swiftlint.status_report[:markdowns].first.to_s
          expect(output).to include('SwiftLint found issues')
          expect(output).to include('SwiftFile.swift | 13 | Force casts should be avoided.')
        end

        it 'accept files as arguments' do
          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .and_return(@swiftlint_response)

          @swiftlint.lint_files('spec/fixtures/*.swift')

          output = @swiftlint.status_report[:markdowns].first.to_s
          expect(output).to include('SwiftLint found issues')
          expect(output).to include('SwiftFile.swift | 13 | Force casts should be avoided.')
        end

        it 'sets maxium number of violations' do
          swiftlint_response = '[{ "rule_id" : "force_cast", "reason" : "Force casts should be avoided.", "character" : 19, "file" : "/Users/me/this_repo/spec//fixtures/SwiftFile.swift", "severity" : "Error", "type" : "Force Cast", "line" : 13 }, { "rule_id" : "force_cast", "reason" : "Force casts should be avoided.", "character" : 19, "file" : "/Users/me/this_repo/spec//fixtures/SwiftFile.swift", "severity" : "Error", "type" : "Force Cast", "line" : 14 }]'
          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .and_return(swiftlint_response)

          @swiftlint.max_num_violations = 1
          @swiftlint.lint_files('spec/fixtures/*.swift')

          output = @swiftlint.status_report[:markdowns].first.to_s
          expect(output).to include('SwiftLint found issues')
          expect(output).to include('SwiftFile.swift | 13 | Force casts should be avoided.')
          expect(output).to include('SwiftLint also found 1 more violation with this PR.')
          expect(output).to_not include('SwiftFile.swift | 14 | Force casts should be avoided.')
        end

        it 'accepts additional cli arguments' do
          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '--lenient')
            .and_return(@swiftlint_response)

          @swiftlint.lint_files('spec/fixtures/*.swift', additional_swiftlint_args: '--lenient')
        end

        it 'uses git diff when files are not provided' do
          allow(@swiftlint.git).to receive(:modified_files).and_return(['spec/fixtures/SwiftFile.swift'])
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .and_return(@swiftlint_response)

          @swiftlint.lint_files

          output = @swiftlint.status_report[:markdowns].first.to_s
          expect(output).to_not be_empty
        end

        it 'uses a custom directory' do
          @swiftlint.directory = 'spec/fixtures/some_dir'

          allow_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(pwd: File.expand_path(@swiftlint.directory)), '')
            .and_return(@swiftlint_response)

          @swiftlint.lint_files(['spec/fixtures/some_dir/SwiftFile.swift'])

          output = @swiftlint.status_report[:markdowns].first.to_s
          expect(output).to_not be_empty
        end

        it 'uses escaped pwd when directory is not set' do
          allow_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(pwd: File.expand_path('.')), '')
            .and_return(@swiftlint_response)

          @swiftlint.lint_files(['spec/fixtures/some\ dir/SwiftFile.swift'])

          output = @swiftlint.status_report[:markdowns].first.to_s
          expect(output).to_not be_empty
        end

        it 'only lint files specified in custom dir' do
          @swiftlint.directory = 'spec/fixtures/some_dir'

          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/some_dir/SwiftFile.swift',
                                                                         'spec/fixtures/SwiftFile.swift'
                                                                       ])

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/some_dir/SwiftFile.swift')), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.lint_files
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

          allow_any_instance_of(Swiftlint).to receive(:lint).and_return('')

          expect { @swiftlint.lint_files }.not_to raise_error
        end

        it 'does not lint files in the excluded paths' do
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/SwiftFile.swift',
                                                                         'spec/fixtures/excluded_dir/SwiftFileThatShouldNotBeIncluded.swift',
                                                                         'spec/fixtures/excluded_dir/SwiftFile WithEscaped+CharactersThatShouldNotBeIncluded.swift'
                                                                       ])

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.config_file = 'spec/fixtures/some_config.yml'
          @swiftlint.lint_files
        end

        it 'lints files in the included paths' do
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/SwiftFile.swift',
                                                                         'spec/fixtures/some_dir/SwiftFile.swift'
                                                                       ])

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.config_file = 'spec/fixtures/another_config.yml'
          @swiftlint.lint_files
        end

        it 'does not crash when excluded is nil' do
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/SwiftFile.swift'
                                                                       ])

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.config_file = 'spec/fixtures/empty_excluded.yml'
          @swiftlint.lint_files
        end

        it 'does not crash when included is nil' do
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/SwiftFile.swift'
                                                                       ])

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.config_file = 'spec/fixtures/empty_included.yml'
          @swiftlint.lint_files
        end

        it 'default config is nil, unspecified' do
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/SwiftFile.swift'
                                                                       ])

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(config: nil), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.lint_files
        end

        it 'expands default config file (if present) to absolute path' do
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/SwiftFile.swift'
                                                                       ])
          expect(File).to receive(:file?).and_return(true)
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:open).and_return(StringIO.new)
          expect(YAML).to receive(:safe_load).and_return({})

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(config: File.expand_path('.swiftlint.yml')), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.lint_files
        end

        it 'expands specified config file to absolute path' do
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/SwiftFile.swift'
                                                                       ])

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(config: 'spec/fixtures/some_config.yml'), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.config_file = 'spec/fixtures/some_config.yml'
          @swiftlint.lint_files
        end

        it 'does not lint deleted files paths' do
          # Danger (4.3.0 at the time of writing) returns deleted files in the
          # modified fiels array, which kinda makes sense.
          # At linting time though deleted files should not be linted because
          # they'd result in file not found errors.
          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/SwiftFile.swift',
                                                                         'spec/fixtures/DeletedFile.swift'
                                                                       ])
          allow(@swiftlint.git).to receive(:deleted_files).and_return([
                                                                        'spec/fixtures/DeletedFile.swift'
                                                                      ])

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.lint_files
        end

        it 'generates errors/warnings instead of markdown when use inline mode' do
          allow_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .and_return(@swiftlint_response)

          @swiftlint.lint_files('spec/fixtures/*.swift', inline_mode: true, additional_swiftlint_args: '')

          status = @swiftlint.status_report
          expect(status[:errors] + status[:warnings]).to_not be_empty
          expect(status[:markdowns]).to be_empty
        end

        it 'generate errors in inline_mode when fail_on_error' do
          allow_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .and_return(@swiftlint_response)

          @swiftlint.lint_files('spec/fixtures/*.swift', inline_mode: true, fail_on_error: true, additional_swiftlint_args: '')

          status = @swiftlint.status_report
          expect(status[:errors]).to_not be_empty
        end

        it 'generate only warnings in inline_mode when fail_on_error is false' do
          allow_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .and_return(@swiftlint_response)

          @swiftlint.lint_files('spec/fixtures/*.swift', inline_mode: true, fail_on_error: false, additional_swiftlint_args: '')

          status = @swiftlint.status_report
          expect(status[:warnings]).to_not be_empty
          expect(status[:errors]).to be_empty
        end

        it 'parses environment variables set within the swiftlint config' do
          ENV['ENVIRONMENT_EXAMPLE'] = 'excluded_dir'

          allow(@swiftlint.git).to receive(:added_files).and_return([])
          allow(@swiftlint.git).to receive(:modified_files).and_return([
                                                                         'spec/fixtures/SwiftFile.swift',
                                                                         'spec/fixtures/excluded_dir/SwiftFileThatShouldNotBeIncluded.swift',
                                                                         'spec/fixtures/excluded_dir/SwiftFile WithEscaped+CharactersThatShouldNotBeIncluded.swift'
                                                                       ])

          expect_any_instance_of(Swiftlint).to receive(:lint)
            .with(hash_including(path: File.expand_path('spec/fixtures/SwiftFile.swift')), '')
            .once
            .and_return(@swiftlint_response)

          @swiftlint.config_file = 'spec/fixtures/environment_variable_config.yml'
          @swiftlint.lint_files
        end
      end
    end
  end
end
