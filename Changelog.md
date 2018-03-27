# Changelog

## Current Master

- Added logging for excluded and included paths to improve debugging this functionality. 

## 0.15.0

- **Breaking Change**: for anyone using `inline_mode: true`, we now respect `fail_on_error`, which is `false` by default. Set `fail_on_error: true` to restore previous behaviour. See [#91](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/91).
- Refactors to use symbols instead of strings for `send` function.

## 0.14.0

- Updated to SwiftLint version [0.25.0](https://github.com/realm/SwiftLint/releases/tag/0.25.0)

## 0.13.1

- Fixes Danger crashing on `fail_on_error: true`. See [#90](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/90).

## 0.13.0

- Fixes problem with frozen string literals by requiring Ruby 2.3 or higher. See [#88](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/88).

## 0.12.1

- Fixes compatibility with Ruby 2.2.x and older. See [#83](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/83).

## 0.12.0

- Utilize `included` rule when finding files. See [#79](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/79).

## 0.11.1

- Removes test fixtures from gemspec.
- Fixes [#68](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/68), specifying a config file directly should work again.
- Fixes issue with non-escaping paths. Reverts [#63](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/63).

## 0.11.0

- Allows setting the maximum number of issues being reported in a PR. See [#65](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/65).

## 0.10.2

- Integrates Rubocop linter to ensure code quality. See [#61](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/61).
- Fixes issue where `directory` variable was not escaped. See [62](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/62).

## 0.10.1

- Expands config paths to be absolute when passed to `swiftlint`.
- Adds verbose logging option.

## 0.10.0

- Adds `additional_swiftlint_args` option. See[#57](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/57).

## 0.9.0

- Fixes linting of superfluous files in subdirectories. See [#53](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/53).

## 0.8.0

- Fixes Directory not found error. See [#51](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/51).
- Fixes issue with missing `.swiftlint.yml` file. See [#52](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/52).
- Adds `fail_on_error` option. See [#55](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/55)

## 0.7.0

- Bump managed SwiftLint version to 0.20.1

## 0.6.0

- Fixes problem with differing swiftlint paths. See [#44](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/44).

## 0.5.1

- Fixed excluded files containing characters that need escaping. See [#40](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/40).

## 0.5.0

- Bump managed SwiftLint version to 0.18.1

## 0.4.1

- Fixes deleted files being added to the list of files to lint. See [#34](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/34).

## 0.4.0

- Support for inline comments. See [#29](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/28)

- Adds SwiftLint installation as part of the gem install process, should make
  it easier to track which upstream fixes should or shouldn't be done by
  danger-swiftlint. See [#25](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/25)

- Add `danger-swiftlint` CLI, with `swiftlint_version` command to print the version of the SwiftLint binary installed by the plugin. See [#32](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/32)

## 0.3.0

- Adds selective linting, now SwiftLint will only run on the PR added and modified files. See [#23](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/23)

## 0.2.1

- Adds support for specifying a directory in which to run SwiftLint. See [#19](https://github.com/ashfurrow/danger-ruby-swiftlint/pull/19).

## 0.1.2

- Adds support for files with spaces in their names. See [#9](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/9).

## 0.1.1

- Fixes double-escaped newline characters. See [#11](https://github.com/ashfurrow/danger-ruby-swiftlint/issues/11).

## 0.1.0

- Initial release.
