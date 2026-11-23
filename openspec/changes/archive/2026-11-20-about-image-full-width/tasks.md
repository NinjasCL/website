# Tasks

## 1. About section markup and view test

- [x] 1.1 Restructure `about_section` in `src/site.gleam`: wrap the `rs-figure` figure and the text `div` in a two-column row (`about__cols`), figure first (left column) and text second (right column); the portrait keeps no fixed `attribute.width`/`attribute.height` and the caption unchanged. Verify with the test updated in 1.2.
- [x] 1.2 Update the home view test in `test/ninjas_test.gleam` for the row layout: the portrait `src` (`camilo.jpg`) is present, the rendered HTML contains no `width="250"`/`height="250"` attributes, the about row carries the `about__cols` class, the section title precedes the portrait, the section text follows it, and the caption "Camilo Castro — Software Engineer" is still rendered. Verify with `gleam test`.

## 2. Two-column 30/10/60 styling

- [x] 2.1 Update `static/style.css`: set the `.about__cols` grid to a 30/60 split with a `10%` column gap (`grid-template-columns: 3fr 6fr; gap: var(--rs-space-2); column-gap: 10%;`), keeping the `--rs-space-2` row gap for the stacked layout and the single-column collapse below the retrostrap vga breakpoint, and keep the `#about .rs-figure` block-level and `#about .rs-figure img { width: 100%; height: auto; }` rules. Verify by loading the home page in the local dev server (no dev server output committed): the portrait fills the ~30% left column at natural proportions, a ~10% gap separates it from the text, and the text fills the ~60% right column, both on the same row.
- [x] 2.2 Confirm the styling stays scoped: with the new rules in place, the projects, books, and games showcase figures render exactly as before (local visual check; the existing `home_view` assertions for those sections keep passing under `gleam test`).

## 3. Local portrait asset

- [x] 3.1 Download `https://ninjas.cl/img/camilo.jpg` into `static/img/camilo.jpg` (creating the directory) and verify the file exists, is a JPEG, and is roughly 59 KB.
- [x] 3.2 Point the about portrait at the local asset in `src/site.gleam`: change the `img` `src` from the remote URL to `/img/camilo.jpg`, keeping `alt` and the caption unchanged. Verify with the test updated in 3.3.
- [x] 3.3 Update the home view test's portrait assertion in `test/ninjas_test.gleam` from `https://ninjas.cl/img/camilo.jpg` to `/img/camilo.jpg`. Verify with `gleam test`.

## 4. Checks

- [x] 4.1 Format the sources with `gleam format src test` and verify `gleam format --check src test` passes.
- [x] 4.2 Run `gleam test` and verify every test passes.
- [x] 4.3 Run `openspec validate about-image-full-width` and verify the change validates.

## Workflow follow-up

- Archive the change after review and implementation are complete: `openspec archive about-image-full-width`.
- Re-run `openspec validate --all` after archiving to confirm specs and archived change stay healthy.
