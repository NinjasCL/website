# Proposal

## Why

The migrated post ships Onyx and Elixir code blocks, but they render as
plain unstyled text: blogatto's built-in syntax highlighting tokenizes
**markdown** sources only, and this site's content is djot, whose code
blocks reach the user's `code` component untokenized (the vendored docs
state this explicitly in `examples/blogatto/docs/syntax-highlighting.md`).

## What Changes

- A site `code` component that highlights djot code blocks at build time:
  it extracts the block's raw source (Lustre text elements → HTML string →
  unescaped), tokenizes it through blogatto's public `code.highlight` —
  smalto with the default 28-grammar set — and renders the tokens as
  `smalto-*` classed spans, exactly the recipe blogatto's markdown renderer
  uses internally. Untagged blocks and unrecognized language tags fall back
  to the plain `<code>` rendering.
- The component is wired through the existing `post.code` configuration
  setter in `src/ninjas/blog.gleam`, so both current and future djot posts
  highlight automatically.
- `static/style.css` gains the smalto token color rules — the documented
  minimal dark theme — so highlighted tokens are styled with no
  client-side JavaScript.
- AGENTS.md's conventions note the highlighting behavior.

Out of scope:

- No new languages beyond smalto's default 28 (Go and Elixir cover the
  shipped post; more can be added later via `code.add_language`).
- No `pre` wrapper customization and no custom token renderers — the
  default span+class rendering keeps CSS in control.
- No client-side highlighting scripts.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: ADDED "Post code blocks are highlighted at build
  time" — tagged djot code blocks render smalto token spans; untagged and
  unknown tags render plain; the token styles ship in the stylesheet.

## Impact

- `src/ninjas/highlight.gleam`: new module — the code component (source
  extraction + `code.highlight` + plain fallback).
- `src/ninjas/blog.gleam`: builds `code.default()` once and wires the
  component via `post.code`.
- `static/style.css`: the smalto token color rules.
- `test/ninjas_test.gleam`: component tests (highlighting for `go` and
  `elixir`, plain fallback for untagged/unknown, the HTML-entity
  round-trip) plus the stylesheet contract.
- `AGENTS.md`: a content-conventions bullet.
- No new dependencies — `blogatto/config/post/code` (public API) and the
  already-transitive smalto provide everything.
