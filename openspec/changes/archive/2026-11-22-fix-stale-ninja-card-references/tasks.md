# Tasks

## 1. Reference alignment

- [x] 1.1 Update the failing assertion in
  `test/ninjas_test.gleam`'s `emojis_render_as_static_icons_test` from
  "🥷 Ninja Systems" to "🥷 Ninjas.cl", and the "Ninja Systems card"
  comment in `banner_wall_is_unlinked_test` to "Ninjas.cl card"
- [x] 1.2 Update the ShowcaseItem doc comment in
  `src/ninjas/home.gleam` ("like the 🥷 Ninja Systems card" → "like the
  🥷 Ninjas.cl card")
- [x] 1.3 Update the 🛸 kept-emoji reason in
  `static/icons/win95/emoji-matches.json` ("Ninja Systems card" →
  "Ninjas.cl card"), keeping the JSON valid

## 2. Checks

- [x] 2.1 Run `gleam format --check src test` and `gleam test` — the
  suite must be green (58 passed, 0 failures), with
  `emojis_render_as_static_icons_test` passing on the "🥷 Ninjas.cl"
  assertion
- [x] 2.2 Run `openspec validate fix-stale-ninja-card-references`

## Workflow follow-up

- Sync the delta specs into the main specs and archive the change
  (`openspec sync`, then `openspec archive fix-stale-ninja-card-references`)
