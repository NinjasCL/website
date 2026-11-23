# Tasks

## 1. Masthead cover rendering and tests

- [x] 1.1 Extend `masthead()` in `src/site.gleam` with a `cover: Option(String)` parameter — `option.Some(url)` renders `class="masthead masthead--cover"` plus the inline `background-image: url('…')` style, `option.None` renders today's plain header — and update the home and not-found call sites to pass `option.None`; verify `gleam test` keeps the home and not-found masthead assertions passing unchanged.
- [x] 1.2 In `post_template`, pass `cover: option.Some(featured_image(post))` with no hero children (reusing the existing `/img/Ninjas.png` placeholder resolution) and delete the now-unused `post_hero()`; verify by extending `post_template_renders_masthead_test` — a post without `featured_image` renders the `/img/Ninjas.png` cover background, a post with one renders that image, and the post page shows no hero logo and no "忍者 開発者" text.
- [x] 1.3 Add the `.masthead--cover` rule to `static/style.css` — `background-size: cover`, `background-position: center`, `background-repeat: no-repeat`, and the adjustable `min-height: 240px`; verify with style.css assertions in the extended test (the presentation contract lives in the static asset, like the banner wall's).

## 2. Verification

- [x] 2.1 Run `gleam format src test` and confirm it completes.
- [x] 2.2 Run `gleam test` and confirm every test passes.
- [x] 2.3 Run `gleam format --check src test` and confirm it passes.
- [x] 2.4 Run `openspec validate add-post-masthead-cover` and confirm it passes.
- [x] 2.5 Regenerate the site (`task build`) and confirm `dist/blog/bienvenidos-a-ninjas-cl/index.html` carries the cover background in its masthead with no hero logo or site-title text.

## Workflow follow-up

- Sync the delta spec into the main specs (`openspec sync add-post-masthead-cover`).
- Archive the change (`openspec archive add-post-masthead-cover`) and verify the archived result.
