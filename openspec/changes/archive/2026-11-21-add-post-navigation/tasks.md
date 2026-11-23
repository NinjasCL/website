# Tasks

## 1. Post navigation

- [x] 1.1 Add `post_navigation` to `src/site.gleam` — walk the newest-first default-language list around the current post's entry (matched by slug), render "← Anterior: {title}" for the newer neighbor and "Siguiente: {title} →" for the older one, each resolved to the current page's language variant with the neighbor's default entry as fallback, and nothing when a post has no neighbors — wired into `post_template` after the article; verify `gleam test` passes with fixture tests covering a middle post (both links), the two end posts (one link each), a lone post (no nav), and the same-language URL resolution on a translated page.
- [x] 1.2 Add the `.post-nav` flex row rule to `static/style.css`; verify with stylesheet assertions in the test (the presentation contract lives in the static asset, like the options row's).

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate add-post-navigation` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm: the newest post (Bienvenidos) links "Siguiente" to the Advent of Code post and shows no "Anterior"; the Advent post links "Anterior" to Bienvenidos and shows no "Siguiente"; and every translated page's link targets its own language's variant URL (`/blog/{lang}/…`).

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-post-navigation`).
- Archive the change (`openspec archive add-post-navigation`) and verify the archived result.
