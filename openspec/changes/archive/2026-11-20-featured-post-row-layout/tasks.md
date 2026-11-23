# Tasks

## 1. Content

- [x] 1.1 Add `featured_image: /img/Ninjas.png` to `blog/bienvenidos-a-ninjas-cl/index.md`'s frontmatter; verify with the content test added in 4.1.

## 2. Featured post row

- [x] 2.1 Rework `featured_post` in `src/site.gleam` into the Sobre nosotros-style row: a `post__cols` grid of the figure (the post's `featured_image` or the Ninjas placeholder via a small helper, at natural proportions with a meaningful alt) and the text column (linked title, date, description); verify with the tests added in 4.1.
- [x] 2.2 Make the "Leer entrada" button a large icon button: class `rs-btn rs-btn--icon rs-btn--large` with the `icon()` helper's ReaderOpened icon beside the label (dropping the trailing arrow); verify with the tests added in 4.1.

## 3. Styles

- [x] 3.1 Add the `.post__cols` grid rule to `static/style.css` (mirroring the about values: `3fr 6fr`, `--rs-space-2` gap, `2%` column gap) with a cross-referencing comment, join it to the shared `@media (max-width: 639px)` collapse, and extend the about figure-fill selectors to cover `.post__cols .rs-figure` (and its img) — the natural-proportions treatment, not the showcase ratio box; verify with the tests added in 4.1.

## 4. Tests

- [x] 4.1 Add tests in `test/ninjas_test.gleam`: with a post fixture carrying `featured_image: Some("/img/superclubnet.jpg")` the home page renders the `post__cols` row (figure before the title, the large icon button, the button icon before its label); with a fixture without an image the Ninjas placeholder renders; `static/style.css` carries the `.post__cols` rule and the grouped natural-proportions selectors; and `blog/bienvenidos-a-ninjas-cl/index.md` contains `featured_image: /img/Ninjas.png`; verify with `gleam test`.

## 5. Checks

- [x] 5.1 Run `gleam format src test` and confirm `gleam format --check src test` passes (CI parity).
- [x] 5.2 Run `gleam test` and confirm the whole suite passes.
- [x] 5.3 Run `openspec validate featured-post-row-layout` and confirm it passes.

## Workflow follow-up

- Eyeball the home page in a browser (`gleam run`): the featured post shows its image left (Ninjas logo today), text right, and the large ReaderOpened "Leer entrada" button; keep the dev server out of committed changes.
- Archive the change after review requirements are satisfied: `openspec archive featured-post-row-layout`.
