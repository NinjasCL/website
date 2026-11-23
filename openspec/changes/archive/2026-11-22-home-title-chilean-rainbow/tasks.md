# Tasks

The implementation shipped with the request; each task is verified
against the current tree.

## 1. Presentation

- [x] 1.1 Render the full hero title in one `cl-rainbow` span in `site.home_hero` — the plain "忍者 開発者" text plus the previous `rs-rainbow`-spanned "Ninjas.cl" replaced by a single span carrying the whole title, with the "Software from 🇨🇱 with ❤️" tagline kept beneath it.
- [x] 1.2 Style `.cl-rainbow` in `static/style.css` with retrostrap's rs-rainbow technique — `background-clip: text`, transparent fill — carrying twemoji's 🇨🇱 flag-cl palette: blue `#1f429b`, white `#eee`, red `#d42d27`.
- [x] 1.3 Run the bands top to bottom in the flag's own order (`linear-gradient(180deg, … 0 33%, … 33% 66%, … 66% 100%)`) after rejecting the first iteration's left-to-right 1ch bands, which sliced the wide kanji mid-stroke; vertical banding keeps every glyph horizontally intact.

## 2. Tests and verification

- [x] 2.1 Update `home_view_renders_homepage_sections_test`: the title assertions pin the new contract — the `cl-rainbow` span with the contiguous title text, and no `rs-rainbow` on the home page.
- [x] 2.2 Add `style_css_chilean_title_rainbow_test`: the stylesheet contract — `.cl-rainbow`, the vertical `linear-gradient(180deg`, the exact emoji-palette stops, `background-clip: text`, and the transparent fill.
- [x] 2.3 Run `gleam format --check src test` and `gleam test`; confirm both pass. (56 passed.)
- [x] 2.4 Run `task build` and confirm the home page carries the single span and `dist/style.css` ships the vertical banded gradient.
- [x] 2.5 Run `openspec validate home-title-chilean-rainbow` and confirm it passes.
