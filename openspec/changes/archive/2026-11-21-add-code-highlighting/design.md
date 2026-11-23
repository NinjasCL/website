# Design

## Context

See proposal.md — Why. blogatto's syntax highlighting is markdown-only:
`internal/builder/post/markdown.gleam` wraps the user's `code` component
with a tokenizer when `post.syntax_highlighting` is configured, but
`internal/builder/post/djot.gleam` calls `ctx.components.code(attrs,
language, [element.text(content)])` directly — the raw code as one text
element, no tokenization (the vendored
`examples/blogatto/docs/syntax-highlighting.md` documents this gap). The
public `blogatto/config/post/code` module exposes everything needed to do
it ourselves: `code.default()` (28 grammars, Go and Elixir included) and
`code.highlight(config, language, source)` (grammar lookup, smalto
tokenization, Lustre span rendering with `smalto-*` classes).

## Goals / Non-Goals

**Goals:**

- djot code blocks highlighted at build time, reusing blogatto's own
  machinery — no new dependency, no custom tokenizer.
- A faithful fallback so nothing renders worse than today.

**Non-Goals:**

- No extra grammars, no custom token renderers, no `pre` wrapper changes
  (proposal.md — out of scope).

## Decisions

1. **The site's `code` component mirrors blogatto's markdown wrapper.**
   A new module `src/ninjas/highlight.gleam` exposes
   `code_component(syntax)`, returning the component closure so the
   `code.default()` grammar table is built once per site configuration in
   `src/ninjas/blog.gleam` — never per code block. The component:
   `Some(lang)` → extract source → `code.highlight` → `<code
   class="language-{lang}">` with the token spans; anything else → the
   plain `<code>` fallback. This is the same shape as
   `internal/builder/post/markdown.gleam`'s `code_component`, keeping the
   two renderers convergent rather than inventing a second highlighting
   approach.

   *Alternative considered:* enabling `post.syntax_highlighting` — no
   effect on djot sources; *considered:* tokenizing inside a rewritten
   djot renderer — impossible without forking blogatto internals.

2. **Source extraction via render-and-unescape.** The djot renderer hands
   the code over as Lustre text elements; `element.to_string` per child
   (avoiding fragment markers), joined, then the same five-entity
   `unescape_html` blogatto uses (`&amp;` last, so `&amp;lt;` round-trips).
   On output, Lustre re-escapes the token text, so entities survive the
   round-trip unchanged — verified by a test feeding `&`, `<`, `>`.

3. **The component takes over the `code` hook via `post.code`.** The djot
   renderer already wraps our output in the components' `pre`, so the
   component returns only the `<code>` element. Fence attributes (the
   renderer passes a dict, empty for plain fences) are not applied — the
   default rendering never used them either.

4. **Class-based tokens via blogatto's setters, colors owned by the
   stylesheet.** smalto's default rendering is inline-styled spans in an
   ANSI-ish light-background palette — unreadable on the site's dark
   theme and invisible to CSS. `syntax_config()` therefore rebuilds the
   token renderers with blogatto's per-type setters (`code.keyword`,
   `code.string`, …), each wrapping the token's text in a span carrying
   its `smalto-*` class. The color rules in `static/style.css` — the
   docs' minimal dark theme — then style the tokens, keeping the markup
   stable and CSS in control.

   *Alternative considered:* shipping smalto's inline defaults — rejected:
   light-theme colors on a dark site; *considered:* a custom
   `smalto_lustre.Config` via `code.smalto_config` — same verbosity but
   requires importing the transitive `smalto_lustre` directly.

5. **No new dependency.** `blogatto/config/post/code` is public API; smalto
   is already locked transitively. The blogatto pin is untouched.

## Risks / Trade-offs

- [A language tag outside the 28 defaults renders plain] → The fallback is
  the previous behavior, not a regression; `code.add_language` is the
  documented extension point when a new grammar is needed.
- [Entity round-trip corrupts exotic code] → The unescape mirrors
  blogatto's own markdown path, and the round-trip test pins `&`, `<`, `>`
  handling; anything houdini escapes is exactly what the unescape undoes.
- [Highlighting cost at build time] → Tokenization is build-time only and
  bounded by the code blocks' size; no runtime effect.

## Migration Plan

None. The component changes rendered markup only — code blocks gain
token spans. Rollback is reverting the commit and rebuilding.
