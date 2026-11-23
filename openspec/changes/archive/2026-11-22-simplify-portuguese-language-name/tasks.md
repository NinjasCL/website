# Tasks

## 1. Display name

- [x] 1.1 Change the Portuguese `name` to "Português" in `SiteLanguage` and `BlogIndexText` in `src/site.gleam`, and in `HomeText` in `src/ninjas/home.gleam`.
- [x] 1.2 Update the post options-row test expectation in `test/ninjas_test.gleam` and the two source doc comments that say "Portuguese (Brazil)".

## 2. Verification

- [x] 2.1 Search the repository and confirm no live "Português (Brasil)" remains outside archived OpenSpec records.
- [x] 2.2 Run `gleam format src test` and `gleam format --check src test` so formatting stays green in CI.
- [x] 2.3 Run `gleam test` and confirm the whole suite passes.
- [x] 2.4 Rebuild with `gleam run` and confirm the generated site renders "Português" and no old label.
- [x] 2.5 Run `openspec validate 2026-11-22-simplify-portuguese-language-name` and confirm the change artifacts are valid.

## Workflow follow-up

- Sync the delta spec into main specs.
- Archive the change after verification.
