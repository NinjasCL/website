# Proposal

## Why

blogatto 8 parses post bodies with two source formats: Markdown (`.md`) and Djot (`.dj`/`.djot`, via the `jot` parser already in the lock). The site's only post ships as `.md` with markdown-flavored syntax, and nothing tells a contributor which syntax to write — so the content directory can drift into mixed formats. The owner has picked djot as the single content syntax; the djot reference is already vendored in the repo at `examples/djot/doc` (cheatsheet, full syntax, and a quickstart for markdown users).

## What Changes

- The site's content syntax is djot, documented for contributors: AGENTS.md records the convention — posts under `blog/` are djot (`.djot` source files), any markdown, asciidoc, or other format is converted to djot rather than added, the djot syntax reference lives at `examples/djot/doc`, and the blogatto engine documentation lives at `examples/blogatto/docs`.
- The shipped post converts: `blog/bienvenidos-a-ninjas-cl/index.md` becomes `index.djot` with its body in djot syntax — the only markdown-flavored construct is the bold `**Ninjas.cl**`, which becomes djot strong `*Ninjas.cl*`; the heading, links, paragraphs, and frontmatter are already djot-valid (frontmatter is parsed format-agnostically before the body render).
- The spec follows: `blog-site-generation`'s loading requirement drops "Markdown posts" for djot, and gains a requirement pinning the djot-only content rule with the conversion duty and the vendored documentation locations.
- Tests pin the conversion: the featured-image frontmatter assertion reads the new file, the post body carries djot strong (no markdown `**`), and no `.md` source remains.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `blog-site-generation`: the post-rendering requirement loads djot posts, and a new requirement makes djot the only content syntax under `blog/` with the convert-don't-add rule.

## Impact

- `blog/bienvenidos-a-ninjas-cl/`: `index.md` renamed to `index.djot` with the bold construct converted to djot strong.
- `AGENTS.md`: the tech-stack table records the content syntax row (djot, `.djot`, convert-don't-add, djot reference at `examples/djot/doc`, blogatto docs at `examples/blogatto/docs`).
- `test/ninjas_test.gleam`: the frontmatter assertion's path updates to `index.djot`, plus the djot-content assertions.
- No `src/` change and no new dependency: blogatto's djot source format (extensions `.dj`/`.djot`, parsed via `jot`) is a native feature — this change only selects it.

## Out of scope

- New djot content — only the shipped post converts; future posts simply follow the convention.
- djot extensions or custom rendering beyond blogatto's native renderer.
- The `examples/djot` vendor itself — already shipped in the repo; this change only references its `doc/` directory.
