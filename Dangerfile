has_app_changes = !git.modified_files.grep(/(bin|ext|lib)/).empty?

warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

warn("Big PR, try to keep changes smaller if you can") if git.lines_of_code > 500

no_changelog_entry = !git.modified_files.include?("Changelog.md")
if has_app_changes && no_changelog_entry
  warn("Any changes to library code should be reflected in the Changelog. Please consider adding a note there.")
end

rubocop.lint
