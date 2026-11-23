# Proposal

## Why

The old site rendered its Liquid tags as **full OpenGraph cards** —
`old/sources/templates/tags/embed.html` wraps a link around a framed
panel carrying `og.title`, `og.description`, `og.site_name`, and
`og.image` (two columns: text left, image right), and
`old/sources/templates/partials/og.html.eex` names the fields.
`tags/youtube.html` rendered the player **full width** (`width="100%"`,
capped at 640px, inside the dashed frame). Today's components are
minimal: the GitHub card shows the banner gif and a bare repo name, the
ninjas card shows only the title, external `{% embed %}` targets have no
component at all, and the YouTube player is a fixed 560×315 iframe. The
owner wants the full embeds — image, title, and text — restored.

## What Changes

- The three embed renderers in `src/ninjas/highlight.gleam` grow into
  **full OG cards** (the old `tags/embed.html` structure, restyled into
  the site's dashed violet frame): site name, title, description, and
  image, the whole card one link.
  - ```` ```github ```` carries `owner/repo | description` — the link,
    title, and site name derive from the repo; the image is GitHub's
    deterministic social card,
    `https://opengraph.githubassets.com/1/owner/repo`, so no data beyond
    the description is authored.
  - ```` ```ninjas ```` carries `slug | Post title | description |
    image` — the card links `https://ninjas.cl/blog/slug/` and shows
    the post's cover.
  - ```` ```embed ```` (new) carries `url | title | description |
    image` — the old `{% embed URL %}` form for external websites, the
    site name derived from the URL's host.
  - ```` ```youtube ```` keeps its URL-or-id content but renders the
    old full-width player: a 100%-width iframe (16:9, max 640px tall)
    inside the dashed frame, with the old template's `allow` list.
- All existing fences sweep to the new grammar (github descriptions for
  all 37 repos, the two ninjas fences extended), the migration recipe
  (`migrate-old-catalog` design.md) records the new fence forms for the
  remaining tranches, and AGENTS.md follows.
- `static/style.css` replaces the minimal `.embed-card` rules with the
  full-card `.embed-full` styles and the `.embed-video` frame.

Out of scope:

- No live OG/oEmbed fetching at build time — the cards render from
  static authored fence data; the network stays out of the build.
- No change to real code blocks, `{summary}` toggles, or highlighting.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `blog-site-generation`: MODIFIED "Content tags render as embed
  components" — the cards carry image, title, and text; the external
  `embed` fence joins the set; the YouTube player is full width.

## Impact

- `src/ninjas/highlight.gleam`: the four embed renderers (github,
  youtube, ninjas, embed) over one shared OG-card builder.
- `static/style.css`: `.embed-full` (card) and `.embed-video` (player
  frame) replace `.embed-card`.
- `test/ninjas_test.gleam`: the embed component test asserts the full
  card structure and the full-width player.
- `blog/*/index*.djot`: the fence sweep (descriptions on github fences,
  the two ninjas fences extended) — identical across variants, embeds
  never translate.
- AGENTS.md and the migration recipe record the new fence grammar.
