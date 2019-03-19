# Danger SwiftLint [![Build Status](https://travis-ci.org/ashfurrow/danger-ruby-swiftlint.svg?branch=master)](https://travis-ci.org/ashfurrow/danger-ruby-swiftlint)

A [Danger Ruby](https://github.com/danger/danger) plugin for [SwiftLint](https://github.com/realm/SwiftLint) that runs on macOS.

## Installation

Add this line to your Gemfile:

```rb
gem 'danger-swiftlint'
```

SwiftLint also needs to be installed before you run Danger, which you can do [via Homebrew](https://github.com/realm/SwiftLint#installation) or a [Brewfile](https://github.com/Homebrew/homebrew-bundle). On CI, this is done for you when the gem is installed.

## Usage

The easiest way to use is just add this to your Dangerfile:

```rb
swiftlint.lint_files
```

By default danger-swiftlint will lint added and modified files. 

```rb
swiftlint.config_file = '.swiftlint.yml'
swiftlint.binary_path = '/path/to/swiftlint'
swiftlint.max_num_violations = 20
swiftlint.lint_files
```

If you want the lint result shows in diff instead of comment, you can use `inline_mode` option. Violations that out of the diff will show in danger's fail or warn section.

```rb
swiftlint.lint_files inline_mode: true
```

If you want different configurations on different directories, you can specify the directory. Note: Run `swiftlint.lint_files` per specified directory then.

```rb
swiftlint.directory = "Directory A"
```

If you want lint errors to fail Danger, you can use `fail_on_error` option.

```rb
swiftlint.lint_files fail_on_error: true
```

If you need to specify options for `swiftlint` that can _only_ be specified by command line arguments, use the `additional_swiftlint_args` option.

```rb
swiftlint.lint_files additional_swiftlint_args: '--lenient'
```

By default, only files that were added or modified are linted.

It's not possible to use [nested configurations](https://github.com/realm/SwiftLint#nested-configurations) in that case, because Danger SwiftLint lints each file on it's own, and by doing that the nested configuration is disabled. If you want to learn more details about this, read the whole issue [here](https://github.com/ashfurrow/danger-swiftlint/issues/4).

However, you can use the `lint_all_files` option to lint all the files. In that case, Danger SwiftLint doesn't lint files individually, which makes nested configuration to work. It'd be the same as you were running `swiftlint` on the root folder:

```ruby
swiftlint.lint_all_files = true
swiftlint.lint_files
```

It's also possible to pass a block to filter out any violations after swiftlint has been run. Here's an example filtering out all violations that didn't occur in the current github PR, using the third party gem `git_diff_parser`:

```ruby
require 'git_diff_parser'

diff = GitDiffParser::Patches.parse(github.pr_diff)
dir = "#{Dir.pwd}/"
swiftlint.lint_files(inline_mode: true) { |violation|
  diff_filename = violation['file'].gsub(dir, '')
  file_patch = diff.find_patch_by_file(diff_filename)
  file_patch != nil && file_patch.changed_lines.any? { |line| line.number == violation['line']}
}
```

You can use the `SWIFTLINT_VERSION` environment variable to override the default version installed via the `rake install` task.

Finally, if something's not working correctly, you can debug this plugin by using setting `swiftlint.verbose = true`.

## Attribution

Original structure, sequence, and organization of repo taken from [danger-prose](https://github.com/dbgrandi/danger-prose) by [David Grandinetti](https://github.com/dbgrandi/).

## License

MIT
