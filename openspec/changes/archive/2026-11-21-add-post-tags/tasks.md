# Tasks

## 1. Tag rendering

- [x] 1.1 Add `post_tags(post)` to `src/site.gleam` — split the `extras` `tags` field, trim each entry, skip empties, render the Bookmark icon and one rounded label per tag — wired into `post_template` between the date and the description; verify `gleam test` passes with post-template assertions for the tags row, the label treatment, and the empty case.
- [x] 1.2 Add the `.post-tags` and `.post-tag` rules to `static/style.css` (the old site's violet pill recipe sized to the 16px floor) and the Bookmark icon entry to `emoji-matches.json`; verify with stylesheet assertions.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate add-post-tags` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the migrated post pages render their tags as rounded labels below the date, led by the Bookmark icon.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-post-tags`).
- Archive the change (`openspec archive add-post-tags`) and verify the archived result.
