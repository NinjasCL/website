# Tasks

## 1. Icon resolution helper

- [x] 1.1 Add `post_icon_url` to `src/site.gleam`: read the `icon` key from
  `post.extras`, trim it, strip a leading `/icons/` prefix, reject values
  containing `..`, resolve against `static/icons/` (as given, then
  `win95/`, then `macos9/`) with `simplifile.is_file`, and fall back to
  `/icons/win95/Mailnews8_32x32_4.png` when absent, empty, or unresolved.
  Verify with unit tests: bare win95 name, bare macos9 name, qualified
  name, `/icons/`-prefixed value, unknown name, empty value, and no key.

## 2. Title sites render the post's icon

- [x] 2.1 Switch `post_template`'s `h1` and `blog_entry_card`'s title in
  `src/site.gleam` from the hardcoded newspaper icon to
  `title_with_icon(post_icon_url(post), post.title)`. Verify with a
  `post_template` render test and the existing blog-index card tests.
- [x] 2.2 Switch `featured_post`'s title link in `src/ninjas/home.gleam`
  to `site.title_with_icon(site.post_icon_url(post), post.title)`. Verify
  with a `home.view` render test using a fixture with and without `icon`.
- [x] 2.3 Lead each star-list entry's linked title with its post's icon in
  `site.post_item` (`title_with_icon(post_icon_url(post), post.title)`),
  covering the home "Más entradas" list and the post page's "Otras
  entradas" list. Verify with a `home.view` more-posts render test and a
  `post_template` random-entries render test.

## 3. Content and catalog enforcement

- [x] 3.1 Extend the catalog test in `test/ninjas_test.gleam`: when a
  post's default `index.djot` declares an `icon` value, every language
  variant repeats it. Verify with `gleam test` (green on the current
  catalog, which declares no icons yet).

## 4. Verification

- [x] 4.1 Run `gleam format src test` and `gleam test`; confirm
  `gleam format --check src test` passes.
- [x] 4.2 Run `openspec validate add-post-icon` and confirm all checks
  pass.
