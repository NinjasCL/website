# Tasks

## 1. The per-language home copy

- [x] 1.1 In `src/ninjas/home.gleam`, add the `HomeText` record (head fields — language code, `lang` value, og locale, page URL, translated site description, options-row label — plus the visible copy: hero tagline, marquee, section titles and intros, about paragraphs, posts-section labels — featured heading, read button, more-posts heading, view-all button, empty-state note — showcase button labels, caption prefix, month names, nav labels with the navigation aria-label, and the back-to-top label) and the four constants — `spanish_text` byte-for-byte today's strings except "Ver"/"Código" (per the owner's single-word mandate), `english_text`, `japanese_text`, `portuguese_text` with the anchor labels fixed in design.md; change `view` to `view(text: HomeText, posts)` threading the record into the hero, marquee, sections, options row, chrome, and `site.page` (translated description, own URL, own `lang` and og locale); verify `gleam build` passes with the route registrations updated in task 3.1.
- [x] 1.2 Change the showcase `started` strings to a year plus an optional month, and add the per-language caption formatter — "Desde Marzo 2022"/"Desde 2015" (es), "Since March 2022"/"Since 2015" (en), "2022年3月から"/"2015年から" (ja), "Desde Março 2022"/"Desde 2015" (pt) — with per-language month-name lists, confirming the Spanish home's rendered captions are unchanged.
- [x] 1.3 Make each home list its own language's posts: filter the catalog by the page's language (the Spanish home keeps `site.default_language_posts`; translated homes filter `language == Some(code)`) so the featured pick, the ten-entry random sample, and every post link target that language's variant URLs; verify with `gleam test` that the default-home posts tests still pass.

## 2. The shared chrome follows the page's language

- [x] 2.1 In `src/site.gleam`, parameterize the chrome labels: give `site_nav`/`site.masthead` a labels record (the six nav labels plus the navigation aria-label) and the current home's URL for the "Inicio" link target, and `site_footer` the back-to-top label; add the Spanish-defaults value and thread it through the internal callers (post template, blog index, blog redirect, not-found) so those pages render exactly today's chrome; each home then passes its own labels; verify `gleam test` still passes the existing chrome tests.
- [x] 2.2 Add the homes' language options row: each home renders the posts-row presentation (`.post-languages`, label then " · "-joined entries) from the four `HomeText` records — the current language plain text marked `aria-current="page"`, the others linking `/`, `/en/`, `/ja/`, `/pt/`; verify with `gleam test`.

## 3. Routing and build

- [x] 3.1 In `src/ninjas/blog.gleam`, register the three translated homes beside the default — `config.route("/en", …)`, `config.route("/ja", …)`, `config.route("/pt", …)`, each rendering `home.view` with that language's text — so the build writes `en/index.html`, `ja/index.html`, and `pt/index.html`; extend `production_blog_config_test` to assert the three routes; verify `task build` writes the four home pages and the sitemap lists the three translated home URLs.

## 4. Tests

- [x] 4.1 Add per-language home tests in `test/ninjas_test.gleam`: for each translated home — the anchor labels render (nav labels, "View"/"Code" or "見る"/"コード" or "Ver"/"Código" buttons, featured/more/view-all headings and button, back-to-top), no Spanish body sentence remains, the options row links the four homes with the current language marked, the head declares the language (`lang`, og locale, translated description, own `og:url`), the copyright line stays verbatim, no machine-translation warning renders, and a translated home lists that language's post variants (a fixture with en/ja/pt variants) while the Spanish home's tests keep passing unchanged; verify `gleam test`.
- [x] 4.2 Update the label tests that pinned the bilingual forms — `showcase_buttons_carry_icons_test` (single-word labels beside the icons) and any other test asserting "Ver / View" or "Código / Code" — so the Spanish home asserts "Ver"/"Código" and the bilingual strings appear nowhere on any home; verify `gleam test`.

## 5. Verification

- [x] 5.1 Run `gleam format src test` and confirm it completes.
- [x] 5.2 Run `gleam test` and confirm every test passes.
- [x] 5.3 Run `gleam format --check src test` and confirm it passes.
- [x] 5.4 Run `openspec validate home-language-variants` and confirm it passes.
- [x] 5.5 Regenerate the site (`task build`) and confirm: `dist/index.html` (Spanish, byte-identical except the single-word button labels), `dist/en/index.html`, `dist/ja/index.html`, and `dist/pt/index.html` all render the full home structure in their language, and the sitemap lists the three translated homes.

## Workflow follow-up

- Sync the delta specs into the main specs (`openspec sync home-language-variants`).
- Archive the change (`openspec archive home-language-variants`) and verify the archived result.
