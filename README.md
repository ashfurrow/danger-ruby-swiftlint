[![CircleCI](https://circleci.com/gh/ashfurrow/danger-swiftlint.svg?style=svg)](https://circleci.com/gh/ashfurrow/danger-swiftlint)

# Danger SwiftLint

A [Danger](https://github.com/danger/danger) plugin for [SwiftLint](https://github.com/realm/SwiftLint) that runs on macOS.

## Installation

Add this line to your Gemfile:

```rb
gem 'danger-swiftlint'
```

SwiftLint also needs to be installed before you run Danger, which you can do [via Homebrew](https://github.com/realm/SwiftLint#installation) or a [Brewfile](https://github.com/Homebrew/homebrew-bundle).

## Usage

The easiest way to use is just add this to your Dangerfile:

```rb
swiftlint.lint_files
```

That's going to lint all your Swift files. It would be better to only lint the changed or added ones, which is complicated due. Check out [this issue](https://github.com/ashfurrow/danger-swiftlint/issues/16) for more details.

```rb
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files
```

If you want the lint result shows in diff instead of comment, you can use `inline_mode` option. Violations that out of the diff will show in danger's fail or warn section.

```rb
swiftlint.lint_files inline_mode: true
```


## Attribution

Original structure, sequence, and organization of repo taken from [danger-prose](https://github.com/dbgrandi/danger-prose) by [David Grandinetti](https://github.com/dbgrandi/).

## License

MIT
