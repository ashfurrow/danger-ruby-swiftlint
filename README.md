[![CircleCI](https://circleci.com/gh/ashfurrow/danger-swiftlint.svg?style=svg)](https://circleci.com/gh/ashfurrow/danger-swiftlint)

# Danger SwiftLint

A [Danger](https://github.com/danger/danger) plugin for [SwiftLint](https://github.com/realm/SwiftLint).

## Installation

Coming soon!

## Usage

The easiest way to use is to just to this to your Dangerfile:

```rb
swiftlint.lint_files
```

That will lint any changed or added Swift files in the PR. You can also set up a config file first.

```rb
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files
```

And finally, you can provide a list of files manually:

``` ruby
# Look through all changed Markdown files
swift_files = (modified_files + added_files).select do |file|
  file.end_with?(".swift")
end

swiftlint.lint_files swift_files
```

## Attribution

Original structure, sequence, and organization of repo taken from [danger-prose](https://github.com/dbgrandi/danger-prose) by [David Grandinetti](https://github.com/dbgrandi/).

## License

MIT
