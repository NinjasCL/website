# Tasks

## 1. Banner wall and Contacto removal

- [x] 1.1 Add a `banners` const in `src/site.gleam` — 31 `(filename, alt)`
  tuples, one per GIF in `static/banners/` — and rewrite `contact_section/0`
  to render an untitled `html.section` with `id("contact")`, class `rs-panel`
  (no `h2` — the `section()` helper always renders a title, so stop using it)
  and the banners as a `.banner-wall` of plain `html.img` elements
  (`src="/banners/<filename>"`, descriptive alt, `loading("lazy")`), replacing
  the heading, paragraph, mailto button and GitHub link. Verify with `gleam
  test` once 1.3–1.4 land, or by rendering `site.home_view([])` and observing
  the wall markup with no anchor wrapping any banner.
- [x] 1.2 Delete the Contacto entry from `site_nav/1` in `src/site.gleam`,
  leaving six navbar links (Inicio, Blog, Nosotros, Proyectos, Libros,
  Juegos) on every generated page. Verify with `gleam test` once 1.3 lands.
- [x] 1.3 Update and add the markup tests in `test/ninjas_test.gleam`: the
  banner-wall tests cross-check the wall against the shipped files (for every
  `.gif` in `simplifile.read_directory("./static/banners")` the markup
  contains `src="/banners/<file>"`, and the `/banners/` img count equals the
  shipped count), no banner img is wrapped in a link, the former Contacto
  content is absent (no "Contacto" text, "¿Construimos algo juntos?",
  "Escríbenos", `href="https://github.com/ninjascl"` with closing quote, or
  contact mailto after `id="contact"`), no `href="#contact"` or
  `href="/#contact"` exists on home or post pages, and the panel keeps
  `id="contact"`. Rename `home_view_renders_six_section_headers_test` to
  five headers (`list.length(pieces) == 6`) and drop the Globe/🐙 and Mail/✉️
  assertions from `emojis_render_as_static_icons_test`. Verify with
  `gleam test`.
- [x] 1.4 Add the presentation rules to `static/style.css` — a `.banner-wall`
  flex-wrap layout with `--rs-space-3` gaps, centered, plus
  `.banner-wall img { image-rendering: pixelated; }` with no width/height
  forcing (the odd-sized `iframsuc`, `ubuntu-88x31` and `netbsd2` GIFs keep
  natural proportions) — and assert both rules in the banner-wall tests.
  Verify with `gleam test`.

## 2. Icon manifest cleanup

- [x] 2.1 Update `static/icons/emoji-matches.json`: remove the 🐙→Globe
  (GitHub) and ✉️→Mail (Contacto) entries — all of their usages were Contacto
  controls removed by task 1 — leaving ten matches. Update
  `icon_manifest_documents_matches_test` to match (drop the Globe and Mail
  assertions, assert no 🐙 or ✉️ entry remains). Verify with `gleam test`.

## 3. Verification

- [x] 3.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 3.2 Run `gleam test` and confirm the full suite passes.
- [x] 3.3 Run `openspec validate contact-banners` and confirm it passes.

## Workflow follow-up

- After review, archive the change with `openspec archive contact-banners`
  (the delta specs fold into the main specs).
- Summarize what shipped and any follow-up gaps against the specs when
  archiving.
