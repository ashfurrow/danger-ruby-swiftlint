# Changelog

## Current Master

- Add new versioning schema which will mirror swiftlint application, now should
  be easier to predict which version of swiftlint will be installed. See [#25](https://github.com/ashfurrow/danger-swiftlint/issues/25)

- Adds swiftlint installation as part of the gem install process, should make
  it easier to track which upstream fixes should or shouldn't be done by
  danger-swiftlint. See [#25](https://github.com/ashfurrow/danger-swiftlint/issues/25)

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
