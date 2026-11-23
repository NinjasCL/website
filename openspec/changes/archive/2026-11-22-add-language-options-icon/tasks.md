# Tasks

## 1. The languages icon leads the row

- [x] 1.1 Add `pub const languages_icon` (`/icons/win95/Intl101_32x32_4.png`)
  to `src/site.gleam` and lead the label in `language_options` (post pages)
  and `index_language_options` (index pages) with
  `icon(languages_icon)` before the label text. Verify with a render test
  asserting the icon src precedes the "Idiomas: " label on a post page
  and on a blog index page.
- [x] 1.2 Lead the label in `home_language_options`
  (`src/ninjas/home.gleam`) with `site.icon(site.languages_icon)`. Verify
  with a render test asserting the icon src precedes the label on the
  home page.
- [x] 1.3 Confirm the untouched behavior: the label wording, the options'
  order, the current-page markers, and the links render exactly as before
  (the existing `post_language_options_render_per_variant_test`,
  `blog_index_language_options_row_test`, and the translated-home tests
  stay green with no edits).

## 2. Verification

- [x] 2.1 Run `gleam format src test` and `gleam test`; confirm
  `gleam format --check src test` passes.
- [x] 2.2 Run `openspec validate add-language-options-icon` and confirm
  all checks pass.
