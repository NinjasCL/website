# Tasks

## 1. Shared footer with a current-year copyright line

- [x] 1.1 Add a private `current_year()` helper to `src/site.gleam` reading the calendar year from `timestamp.system_time()` (mirroring `format_date`), and splice it into the copyright line in `site_footer()` — "Copyright 🥷🏽 Ninjas.cl © 2015–" <> current year <> " · All rights and lefts preserved"; verify `gleam test` passes with the home footer assertions updated to compute the expected year through the same `gleam/time` API (including `footer_trims_decorative_blocks_test`).
- [x] 1.2 Replace the post template's minimal footer (`html.footer` with "Ninjas.cl — Desde 2015") in `post_template` with the `site_footer()` call; verify by updating the post-page footer assertions — the post page carries the copyright line and the "^ volver arriba ^" link targeting `#masthead`, and "Ninjas.cl — Desde 2015" appears nowhere.

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate unify-site-footer` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm `dist/blog/bienvenidos-a-ninjas-cl/index.html` and `dist/index.html` both close with the site footer carrying the current year's copyright line and the back-to-top link.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync unify-site-footer`).
- Archive the change (`openspec archive unify-site-footer`) and verify the archived result.
