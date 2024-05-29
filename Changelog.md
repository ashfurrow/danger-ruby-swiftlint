# Changelog

## Current Master

- Nothing yet!

## 0.36.1

- Fix missing SwiftLint installation error due to bad hash

## 0.36.0

- Updates Swiftlint to 0.55.1. (use `additional_swiftlint_args: "--baseline additional_swiftlint_args: path/to/baseline.json")`
- Add a readme on How To Update Swiftlint version for this repository.

## 0.35.0

- Updates Thor to 1.0.0. 

## 0.34.0

- Updates SwiftLint version to 0.54.0.

## 0.33.0

- Updates SwiftLint version to 0.51.0.

## 0.32.0

- Updates SwiftLint version to 0.50.3.

## 0.31.0

- Updates SwiftLint version to 0.50.0. See [#188](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/188).

## 0.30.2

- Fixes a bug in `git_modified_lines` that would cause the tool to not report all lint violations. See [#181](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/181).

## 0.30.1

- Fixes problem with previous release. See [#179](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/179).

## 0.30.0

- Updates SwiftLint version to 0.46.2. See [#176](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/176).

## 0.29.4

- Fixes issues running the plugin on Linux. See [#174](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/174)

## 0.29.3

- Fixes `Rake aborted` error with status 127. See [#173](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/173).

## 0.29.2

- ~Fixes `Rake aborted` error with status 127. See [#173](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/173).~

## 0.29.1

- ~Fixes `Rake aborted` error with status 127. See [#172](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/172).~

## 0.29.0

- Adds integrity verification when downloading SwiftLint. See [#162](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/162).

## 0.28.0

- Fixes a crash caused by renamed files in a pull request. See [#168](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/168).

## 0.27.0

- Update SwiftLint to 0.43.1 for inclusive_language allowance list support. See [#165](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/165).

## 0.26.0

- No longer infers `config_file` parameter if unspecified. See [#160](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/160).

## 0.25.0

- **Possible Breaking Change**: Changes the plugin so that it does not change the current working directory when using the `directory` option. That is to say, calling `Swiftlint.lint(directory: ...)` no longer changes the return value of `Dir.pwd`, which could inadvertently affect subsequent Dangerfile execution. See [#157](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/157).

## 0.24.5

- Fixes incompatibility with SwiftLint 0.41.0's `--config` flag and nested
  configs handling
  [#154](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/154).

## 0.24.4

- Updates to SwiftLint
  [0.40.1](https://github.com/realm/SwiftLint/releases/tag/0.40.1).

## 0.24.3

- Fix `filter_issues_in_diff` mode when diff contains removed lines above a violation. See [#147](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/147)

## 0.24.2

- Updates to SwiftLint
  [0.39.1](https://github.com/realm/SwiftLint/releases/tag/0.39.1).

## 0.24.1

- Improves performance for large code bases. See
  [#141](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/141).

## 0.24.0

- Update SwiftLint to 0.38.0

## 0.23.0

- Migrates from individual SwiftLint invocations to using the
  `--use-script-input-files` option. See
  [#135](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/135).

## 0.22.0

- Adds support to filter issues found in git diff. See
  [#132](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/132).

## 0.21.1

- Performance improvements when `lint_all_files` is `true`. See
  [#131](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/131).

## 0.21.0

- Adds `no_comment` option. See
  [#130](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/130).

## 0.20.1

- Adds `strict` option. See
  [#128](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/128).

## 0.20.0

- Adds ability to filter out violation reports with a block. See
  [#127](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/127).

## 0.19.2

- Fix gem installation when installation path contains spaces. See
  [#126](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/126).

## 0.19.1

- Updates to SwiftLint
  [0.31.0](https://github.com/realm/SwiftLint/releases/tag/0.31.0).

## 0.19.0

- Adds the rule ID and filename:line to GitHub comments. See
  [#122](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/122).

## 0.18.2

- Fixes incorrect specifying of the `--force-exclude` option, which leads to the
  `No lintable files found at path` error. See
  [#87](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/87)
  discussion.

## 0.18.1

- Fixes problem with unary plus operator. See
  [#119](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/119).

## 0.18.0

- Add `lint_all_files` option. This will lint all existing files (instead of
  just the added/modified ones). However, nested configurations works when this
  option is enabled.

## 0.17.5

- Updates to SwiftLint
  [0.28.1](https://github.com/realm/SwiftLint/releases/tag/0.28.1).

## 0.17.4

- Updates to SwiftLint
  [0.27.0](https://github.com/realm/SwiftLint/releases/tag/0.27.0).

## 0.17.3

- Fix use of `return` in native extension `Rakefile`. See
  [#106](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/106).
- Add `DANGER_` prefix to `DANGER_SKIP_SWIFTLINT_INSTALL`. See
  [#106](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/106).

## 0.17.2

- Add support for skipping installation of SwiftLint tool. (See
  [#106](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/106))

## 0.17.1

- Updates to SwiftLint
  [0.26.0](https://github.com/realm/SwiftLint/releases/tag/0.26.0).

## 0.17.0

- Updates to SwiftLint 0.25.1.
- Forces exclusion for files specified as excluded in `.swiftlint.yml`. (See
  [#87](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/87).)

## 0.16.0

- Add support for Environment variables which are supported in Swiftlint since
  [0.21.0](https://github.com/realm/SwiftLint/releases/tag/0.21.0) (See
  https://github.com/realm/SwiftLint/issues/1512).
- Added logging for excluded and included paths to improve debugging this
  functionality.
- Removed unneeded extra files logging in while using verbose

## 0.15.0

- **Breaking Change**: for anyone using `inline_mode: true`, we now respect
  `fail_on_error`, which is `false` by default. Set `fail_on_error: true` to
  restore previous behaviour. See
  [#91](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/91).
- Refactors to use symbols instead of strings for `send` function.

## 0.14.0

- Updated to SwiftLint version
  [0.25.0](https://github.com/realm/SwiftLint/releases/tag/0.25.0)

## 0.13.1

- Fixes Danger crashing on `fail_on_error: true`. See
  [#90](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/90).

## 0.13.0

- Fixes problem with frozen string literals by requiring Ruby 2.3 or higher. See
  [#88](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/88).

## 0.12.1

- Fixes compatibility with Ruby 2.2.x and older. See
  [#83](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/83).

## 0.12.0

- Utilize `included` rule when finding files. See
  [#79](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/79).

## 0.11.1

- Removes test fixtures from gemspec.
- Fixes [#68](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/68),
  specifying a config file directly should work again.
- Fixes issue with non-escaping paths. Reverts
  [#63](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/63).

## 0.11.0

- Allows setting the maximum number of issues being reported in a PR. See
  [#65](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/65).

## 0.10.2

- Integrates Rubocop linter to ensure code quality. See
  [#61](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/61).
- Fixes issue where `directory` variable was not escaped. See
  [62](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/62).

## 0.10.1

- Expands config paths to be absolute when passed to `swiftlint`.
- Adds verbose logging option.

## 0.10.0

- Adds `additional_swiftlint_args` option.
  See[#57](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/57).

## 0.9.0

- Fixes linting of superfluous files in subdirectories. See
  [#53](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/53).

## 0.8.0

- Fixes Directory not found error. See
  [#51](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/51).
- Fixes issue with missing `.swiftlint.yml` file. See
  [#52](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/52).
- Adds `fail_on_error` option. See
  [#55](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/55)

## 0.7.0

- Bump managed SwiftLint version to 0.20.1

## 0.6.0

- Fixes problem with differing swiftlint paths. See
  [#44](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/44).

## 0.5.1

- Fixed excluded files containing characters that need escaping. See
  [#40](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/40).

## 0.5.0

- Bump managed SwiftLint version to 0.18.1

## 0.4.1

- Fixes deleted files being added to the list of files to lint. See
  [#34](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/34).

## 0.4.0

- Support for inline comments. See
  [#29](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/28)

- Adds SwiftLint installation as part of the gem install process, should make it
  easier to track which upstream fixes should or shouldn't be done by
  danger-swiftlint. See
  [#25](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/25)

- Add `danger-swiftlint` CLI, with `swiftlint_version` command to print the
  version of the SwiftLint binary installed by the plugin. See
  [#32](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/32)

## 0.3.0

- Adds selective linting, now SwiftLint will only run on the PR added and
  modified files. See
  [#23](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/23)

## 0.2.1

- Adds support for specifying a directory in which to run SwiftLint. See
  [#19](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/19).

## 0.1.2

- Adds support for files with spaces in their names. See
  [#9](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/9).

## 0.1.1

- Fixes double-escaped newline characters. See
  [#11](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/11).

## 0.1.0

- Initial release.
