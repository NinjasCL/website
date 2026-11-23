# Design

## Context

See `proposal.md` for motivation. Descriptions are metadata rendered in
two standalone prose spots — the post page's `<em>` description
paragraph (`site.gleam`'s `post_template`) and the home featured row's
description paragraph (`home.gleam`) — both plain `<p>`s outside any
anchor, both currently `element.text(post.description)`. Every other
consumer must keep the raw string: the blog index card's description sits
inside the card's single link (anchors cannot nest), the page head's
meta/OG/Twitter attributes are attribute values, and the feeds are XML.

## Goals / Non-Goals

Goals: URLs in descriptions become clickable exactly where the
description renders as standalone prose, with the same boundary rules the
body conversion used. Non-Goals (see proposal): djot-rendering
descriptions, changing frontmatter, any embed/code handling.

## Decisions

### 1. A shared linkify helper over djot-rendering the description

`site.linkified_text(text) -> List(Element(Nil))` splits prose on bare
URLs and returns text runs as `element.text` and each URL as
`html.a([href: url], [text: url])`. Alternatives rejected:

- Rendering the description through jot as djot inlines — descriptions
  are metadata (they feed meta attributes and feeds as raw strings), and
  pulling in the djot parser for one field would blur that contract.
- A renderer feature over the whole page — same "no inline hook" limit
  established in the autolink-post-urls design; here a template-local
  helper is the natural scope.

Anchors inherit the site's global link presentation (style.css's shared
`:is(a, button, …)` rule), so no styling work.

### 2. Boundary rules mirror the body conversion

A URL run starts at `http(s)://` (at the text's start or after a space —
descriptions are single-line prose) and ends at the next space or end of
text; trailing `.,;:!?` and a `)` that closes no `(` inside the URL move
back out of the link. Same rules as the source conversion keeps the two
features coherent (a reader sees identical link extents in a description
URL and the same URL in body prose).

### 3. Hand-rolled splitter, no new dependency

The splitter is ~50 lines of pure Gleam string walking
(`string.starts_with`, `split_once`, `pop_grapheme`, `drop_end`), next to
the file's existing text helpers (`title_with_icon`). Descriptions are
short single-line strings, so a grapheme-walking scan is plenty; no
regex package is added (the repo prefers existing features over new
deps).

### 4. Verification: unit tests over the two views, plus the built site

New gleeunit tests render `site.post_template` and `home.view` with a
URL-carrying description fixture and assert the anchor; the index view
test asserts no anchor to the URL appears on the index page; a meta
assertion keeps the raw description in the head. After the rebuild, the
live wren-playground page is checked in `dist/` for all four variants.

## Risks / Trade-offs

- [A description's URL is skipped by the boundary rule (e.g. glued to a
  word)] → Acceptable: it renders as today's plain text, no corruption;
  descriptions are hand-written frontmatter, so the strict rule favors
  never mangling prose over coverage.
- [The splitter recurses per grapheme] → Descriptions are one line and
  a handful of URLs; negligible. The helper is not used on post bodies.

## Migration Plan

1. Add the helper and switch the two description render sites.
2. Add the tests; run the checks.
3. Rebuild and verify the wren-playground page in `dist/`.
4. Rollback: revert the two render sites and the helper (one commit's
   worth of edits); the frontmatter is untouched throughout.
