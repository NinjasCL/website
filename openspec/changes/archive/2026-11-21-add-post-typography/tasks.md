# Tasks

## 1. Post typography and font loading

- [x] 1.1 Add the Google Fonts trio to the shared head in `page()` (`src/site.gleam`) before the stylesheets — the `preconnect` to `fonts.googleapis.com`, the crossorigin `preconnect` to `fonts.gstatic.com`, and the JetBrains Mono stylesheet (400/500/600/700, `display=swap`); verify `gleam test` passes with the head-suite test extended to assert the three links on every page.
- [x] 1.2 Add the typography rules to `static/style.css`: `.post-body { font-size: var(--rs-font-size-3); }` (the 16px ladder step, up from the cosmic theme's 13px body) and `.post-body pre, .post-body code { font-family: 'JetBrains Mono', var(--rs-font-mono); }` with the retrostrap mono stack as fallback; verify with stylesheet assertions in the test (the presentation contract lives in the static asset, like the Night Owl panel's).

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate add-post-typography` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm the post pages' heads carry the font links before the stylesheets, and the stylesheet carries the 16px post body rule and the JetBrains Mono family rule.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-post-typography`).
- Archive the change (`openspec archive add-post-typography`) and verify the archived result.
