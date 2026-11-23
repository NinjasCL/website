# Tasks

## 1. The trimmed Más entradas list

- [x] 1.1 In `src/ninjas/home.gleam`, rework `more_posts`: lead the heading with `site.title_with_icon("/icons/win95/Files_32x32_4.png", "Más entradas")`, render the entries as `list.take(site.shuffle(posts), 10)` in the existing `rs-list rs-list--stars` rows, and append the "Ver Todos" button — a large icon anchor (`rs-btn rs-btn--icon rs-btn--large`, `href="/blog"`, no `target`/`rel`) built with `site.title_with_icon("/icons/win95/Shdocvw257_32x32_8.png", "Ver Todos")` — whenever the list renders; verify a build (`task build`) shows the ten random rows and the button on the home page.

## 2. Tests

- [x] 2.1 Extend `test/ninjas_test.gleam` with an order-agnostic trim test: with a 13-post fixture the "Más entradas" list renders exactly ten `<li>` entries (random subset), the heading leads with the Files icon, and the "Ver Todos" button links `/blog` with the Shdocvw icon; a small-catalog render lists all remaining entries and still shows the button; verify `gleam test` passes including the existing `featured_post_is_a_random_pick_test`.

## 3. Verification

- [x] 3.1 Run `gleam format src test` and confirm it completes.
- [x] 3.2 Run `gleam test` and confirm every test passes.
- [x] 3.3 Run `gleam format --check src test` and confirm it passes.
- [x] 3.4 Run `openspec validate 2026-11-22-trim-home-more-posts` and confirm it passes.
- [x] 3.5 Regenerate the site (`task build`) and confirm the home page's "Más entradas" list shows ten random entries with the icon-led heading and the "Ver Todos" button pointing at the blog index.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync 2026-11-22-trim-home-more-posts`).
- Archive the change (`openspec archive 2026-11-22-trim-home-more-posts`) and verify the archived result.
