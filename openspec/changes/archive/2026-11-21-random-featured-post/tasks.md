# Tasks

## 1. Random featured selection

- [x] 1.1 Change `post_list` in `src/site.gleam` to pick the featured entry from `shuffle(posts)` — the site's existing build-time `rand` shuffle — instead of `list.first(posts)`, listing the remaining entries in "Más entradas" in their newest-first order; verify `gleam test` passes with a selection test asserting exactly one featured row with the "Leer entrada" button, the remaining posts in the list, and a lone post always featured (the existing empty-state note unchanged).

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate random-featured-post` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the home page features one of the catalog's default-language entries with the "Más entradas" list carrying the rest, and that rebuilding reshuffles the pick.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync random-featured-post`).
- Archive the change (`openspec archive random-featured-post`) and verify the archived result.
