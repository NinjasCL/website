# Proposal

## Why

A post's `description` frontmatter renders as plain text — the post page's
description paragraph and the home page's featured-post row emit it through
`element.text` — so a URL in a description stays unclickable even after the
body-prose conversion (the autolink-post-urls change). The one live case:
`wren-playground`'s description carries `https://runjs.app/` in all four
variants and renders as plain text on its post page today.

## What Changes

- Render the post page's description paragraph (`src/site.gleam`'s
  `post_template`, the `<em>` inside `.post-description`) and the home
  featured row's description paragraph (`src/ninjas/home.gleam`) through a
  small shared helper that links each bare `http(s)://` URL as an anchor
  (href = visible text = the URL), the surrounding prose as text.
- Mirror the body-prose conversion's boundary rules: a URL's run ends at
  the next space or end of text, trailing `.,;:!?` and a `)` closing no `(`
  inside the URL stay outside the link.
- Leave every other description consumer raw by design: the blog index
  entry cards' description (the whole card is a single link — anchors
  cannot nest), the page's meta/OG/Twitter description attributes, and the
  feeds.
- No new dependency: a hand-rolled string splitter in `src/site.gleam`
  (the same rules the source conversion used), exported for
  `home.gleam`'s featured row.

Out of scope: djot-rendering descriptions (they are metadata, not body
prose), linkifying inside code or embed payloads (descriptions hold none),
and any change to the frontmatter values themselves.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `blog-site-generation`: one added requirement — post descriptions link
  bare URLs on the two standalone description sites — covering the anchor
  rendering, the boundary rules, and the consumers that stay raw.

## Impact

- Code: `src/site.gleam` gains `linkified_text` plus private helpers and
  uses it in `post_template`; `src/ninjas/home.gleam` uses it in the
  featured row. No template structure, routing, or dependency changes.
- Output: the rebuilt site links the wren-playground description URL on
  its post page in all four variants; every other page is unchanged.
- Tests: new gleeunit tests for the post page, the featured row, the
  index card's plain text, and the raw meta description.
