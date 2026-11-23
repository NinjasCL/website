# Tasks

## 1. Content conversion

- [x] 1.1 Convert the shipped post: rename
  `blog/bienvenidos-a-ninjas-cl/index.md` to `index.djot` and rewrite the
  markdown bold `**Ninjas.cl**` as djot strong `*Ninjas.cl*` — the rest
  of the body (heading, links, paragraphs, emoji) and the frontmatter
  are already djot-valid and stay untouched. Verify by building the site
  (`gleam run`) and confirming the generated post page renders
  `<strong>Ninjas.cl</strong>` plus its heading and links.
- [x] 1.2 Update the featured-image frontmatter assertion in
  `test/ninjas_test.gleam` to read
  `./blog/bienvenidos-a-ninjas-cl/index.djot`, and add a djot-content
  test asserting the post source carries djot strong (`*Ninjas.cl*`),
  no markdown `**` remains in the body, and no `index.md` source is left
  under `blog/`. Verify with `gleam test`.

## 2. Contributor documentation

- [x] 2.1 Add the content-syntax row to the tech-stack table in
  `AGENTS.md`: blog content is djot (`.djot` source files under
  `blog/`), markdown/asciidoc/other formats are converted to djot
  rather than added, and the references ship in the repo — djot syntax
  at `examples/djot/doc` (cheatsheet, full syntax, quickstart for
  markdown users) and the blogatto engine docs at
  `examples/blogatto/docs`. Verify by reading the rendered table.

## 3. Verification

- [x] 3.1 Run `gleam format src test`, then confirm
  `gleam format --check src test` passes.
- [x] 3.2 Run `gleam test` and confirm the full suite passes.
- [x] 3.3 Run `openspec validate adopt-djot-content` and confirm it
  passes.

## Workflow follow-up

- After review, sync/archive the change with the `openspec-archive-change`
  workflow. No `src/` or dependency changes ride along — the engine
  already speaks djot natively.
