# Tasks

## 1. The random-entries section

- [x] 1.1 Add `random_posts_section` to `src/site.gleam` — the default-language entries minus the current post and its navigation neighbors (previous and next), shuffled by a Fisher–Yates over the Erlang `rand` external, capped at five, each pick resolved to the reader's language via the existing `in_language`, rendered as an "Otras entradas" `rs-panel` with the home list's `rs-list rs-list--stars` rows — placed after the navigation, before the footer; verify `gleam test` passes with order-agnostic tests: exactly five picks from a seven-entry pool (with the neighbor excluded alongside the current post), the current and neighbor posts never listed, a small catalog listing only its non-neighbor remainder, a pool exhausted by the navigation rendering no section, and the picks linking the reader's language variants.
- [x] 1.2 Add the `rand` external declaration and the shuffle helpers (`shuffle`, `take_at`) with the pool semantics documented; verify via the same tests (the helpers are exercised through the section).

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate add-random-posts-list` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the random-entries behavior on the live pages: with the two-post catalog every other entry is a navigation neighbor, so no page renders the section yet — the exclusion rule working as specified — while the fixture tests cover the five-pick, small-catalog, language, and empty-pool behaviors for the growing catalog.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-random-posts-list`).
- Archive the change (`openspec archive add-random-posts-list`) and verify the archived result.
