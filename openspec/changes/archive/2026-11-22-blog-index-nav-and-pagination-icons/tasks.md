# Tasks

## 1. Translated index navigation menu

- [x] 1.1 Add a `nav: NavLabels` field to `BlogIndexText` with per-language records (Spanish reusing `nav_labels`, en/ja/pt with their home-page translations).
- [x] 1.2 Pass `text.nav` to `masthead` in `blog_index_page` instead of the default `nav_labels`.
- [x] 1.3 Add `blog_index_navbar_speaks_its_language_test` covering all four languages' navbar labels and aria-label, and verify with `gleam test`.

## 2. Pagination pointing hands

- [x] 2.1 Replace the `ArrowLeft`/`ArrowRight` sprites in `pagination_nav` with the `Msow10_32x32_4.png` hand and the `post-nav__hand--left`/`--right` classes.
- [x] 2.2 Add `blog_index_pagination_uses_post_navigation_hands_test` covering first, middle, and last pages, and verify with `gleam test`.

## 3. Verification

- [x] 3.1 Run `gleam format src test` and `gleam format --check src test` so formatting stays green in CI.
- [x] 3.2 Run `gleam test` and confirm the whole suite passes.
- [x] 3.3 Run `openspec validate 2026-11-22-blog-index-nav-and-pagination-icons` and confirm the change artifacts are valid.

## Workflow follow-up

- Sync the delta spec into main specs.
- Archive the change after verification.
