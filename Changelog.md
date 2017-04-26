# Changelog

## Current Master

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
