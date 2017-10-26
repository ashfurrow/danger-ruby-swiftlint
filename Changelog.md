# Changelog

## Current Master

- Nothing yet!

## 0.11.0

- Allows setting the maximum number of issues being reported in a PR. See [#65](https://github.com/ashfurrow/danger-swiftlint/pull/65).

## 0.10.2

- Integrates Rubocop linter to ensure code quality. See [#61](https://github.com/ashfurrow/danger-swiftlint/pull/61).
- Fixes issue where `directory` variable was not escaped. See [62](https://github.com/ashfurrow/danger-swiftlint/issues/62).

## 0.10.1

- Expands config paths to be absolute when passed to `swiftlint`.
- Adds verbose logging option.

## 0.10.0

- Adds `additional_swiftlint_args` option. See[#57](https://github.com/ashfurrow/danger-swiftlint/issues/57).

## 0.9.0

- Fixes linting of superfluous files in subdirectories. See [#53](https://github.com/ashfurrow/danger-swiftlint/pull/53).

## 0.8.0

- Fixes Directory not found error. See [#51](https://github.com/ashfurrow/danger-swiftlint/pull/51).
- Fixes issue with missing `.swiftlint.yml` file. See [#52](https://github.com/ashfurrow/danger-swiftlint/pull/52).
- Adds `fail_on_error` option. See [#55](https://github.com/ashfurrow/danger-swiftlint/pull/55)

## 0.7.0

- Bump managed SwiftLint version to 0.20.1

## 0.6.0

- Fixes problem with differing swiftlint paths. See [#44](https://github.com/ashfurrow/danger-swiftlint/issues/44).

## 0.5.1

- Fixed excluded files containing characters that need escaping. See [#40](https://github.com/ashfurrow/danger-swiftlint/pull/40).

## 0.5.0

- Bump managed SwiftLint version to 0.18.1

## 0.4.1

- Fixes deleted files being added to the list of files to lint. See [#34](https://github.com/ashfurrow/danger-swiftlint/pull/34).

## 0.4.0

- Support for inline comments. See [#29](https://github.com/ashfurrow/danger-swiftlint/issues/28)

- Adds SwiftLint installation as part of the gem install process, should make
  it easier to track which upstream fixes should or shouldn't be done by
  danger-swiftlint. See [#25](https://github.com/ashfurrow/danger-swiftlint/issues/25)

- Add `danger-swiftlint` CLI, with `swiftlint_version` command to print the version of the SwiftLint binary installed by the plugin. See [#32](https://github.com/ashfurrow/danger-swiftlint/pull/32)

## 0.3.0

- Adds selective linting, now SwiftLint will only run on the PR added and modified files. See [#23](https://github.com/ashfurrow/danger-swiftlint/pull/23)

## 0.2.1

- Adds support for specifying a directory in which to run SwiftLint. See [#19](https://github.com/ashfurrow/danger-swiftlint/pull/19).

## 0.1.2

- Adds support for files with spaces in their names. See [#9](https://github.com/ashfurrow/danger-swiftlint/issues/9).

## 0.1.1

- Fixes double-escaped newline characters. See [#11](https://github.com/ashfurrow/danger-swiftlint/issues/11).

## 0.1.0

- Initial release.
