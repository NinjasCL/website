# Proposal

## Why

The old site rendered its Liquid tags as rich embeds — `{% github %}` as a
framed GitHub card (checked against the archived
`old/docs/blog/chilean-birds` output: a link wrapping a titled panel),
`{% youtube %}` as a video player, `{% ninjas %}` as a card linking the
blog post (title and all). The migration degraded them to plain links.
The owner wants the embeds back — as real components, like the code-block
component.

## What Changes

- The site's content-block component (today's code component) learns
  three embed languages, authored as djot fences:
  - ```` ```github ```` with `owner/repo` — a GitHub embed card: the
    site's retro `github.gif` banner, the repo name, linked to
    `https://github.com/owner/repo`.
  - ```` ```youtube ```` with a URL or video id — a single-element
    YouTube `<iframe>` (watch, youtu.be, and bare-id forms all parse).
  - ```` ```ninjas ```` with `slug | Post title` — a card linking the
    site's own blog post, carrying its title.
- To let embeds render outside the code panel, the `pre` component
  becomes a pass-through and the code component takes over the full
  structure: real code blocks render their own `<pre>` panel (Night Owl
  styling untouched), and the `{summary}` toggles restructure to
  `<details><summary>…</summary><pre><code>…` — the toggle now sits
  outside the panel, which is the semantically correct form.
- All migrated plain-link conversions sweep to the new fences
  (one perl pass), and the migration recipe records embed fences as
  the conversion for every Liquid tag from here on. AGENTS.md follows.
- A `.embed-card` CSS rule gives the cards the site's dashed violet
  frame treatment.

Out of scope:

- No live oEmbed/OG fetching at build time — the cards render from
  static authored data (repo, title, id); the network stays out of the
  build.
- No embeds for non-fenced content; no new languages beyond the three.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: ADDED "Content tags render as embed
  components" — the three fence languages and their cards.

## Impact

- `src/ninjas/highlight.gleam`: the component gains the embed
  renderers and takes over `pre` structure; `src/ninjas/blog.gleam`:
  the pass-through `pre` override.
- `static/style.css`: `.embed-card` and its pieces.
- `test/ninjas_test.gleam`: embed component tests, updated
  toggle-structure assertions.
- The migrated posts' plain links sweep to fences; future tranches
  use the fences directly.
