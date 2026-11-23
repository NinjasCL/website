# Design

## Context

The old site fetched OpenGraph data at render time and rendered full
cards — `old/sources/templates/tags/embed.html` (a link wrapping a
`purple-frame` two-column panel: title, description, site name left;
`og.image` right, `max-width: 500px; max-height: 300px`) and
`tags/youtube.html` (`width="100%"`, `max-height: 640px`, the full
`allow` list, inside the dashed frame). The new engine builds
statically — no fetch step — so the add-embed-components change
rendered minimal cards (banner + repo name, title-only ninjas card,
fixed 560×315 player) and left `{% embed %}` targets without a
component. The owner wants the full embeds.

## Goals / Non-Goals

**Goals:**

- Full OG cards — image, title, text, site name — for github, ninjas,
  and external websites, visually faithful to the old card in the new
  site's retro frame.
- The YouTube player at full content width, capped like the old one.

**Non-Goals:**

- No build-time network fetching; the fence carries the data.
- No new dependencies; no change to code blocks or toggles.

## Decisions

1. **The fence carries the OG data; what can be derived, is.** The old
   tags carried only a target — everything else was fetched. The static
   form authors the fetched data in the fence, keeping the established
   `slug | Post title` pipe style:
   - `github`: `owner/repo | description` — url, title, site name
     ("GitHub"), and image all derive from the repo: GitHub's
     social-card endpoint is deterministic
     (`https://opengraph.githubassets.com/1/owner/repo` serves the
     card for any cache key), so only the description is authored.
   - `ninjas`: `slug | Post title | description | image` — the url and
     site name derive from the slug; title, description, and the post's
     cover path are authored (the cover varies per post, so it is
     carried rather than guessed).
   - `embed`: `url | title | description | image` — only the site name
     derives, from the URL's host (the old card showed `og.site_name`;
     the host is the honest static equivalent).
   - `youtube`: unchanged content (watch URL, youtu.be URL, or bare id)
     — the rendering changes, not the fence.
   Parsing splits on `|` and trims each part; a short fence (bare
   `owner/repo`, `slug | title`) still renders a valid card with the
   parts it has — nothing breaks mid-catalog between the sweep and a
   future tranche.

2. **One shared OG-card builder, four thin wrappers.** A single
   `og_card(url, site, title, description, image, image_alt)` renders
   the old structure in the site's frame idiom: `<a
   class="embed-full">` wrapping a text column (site name, title,
   description) and the image — the image keeps the old template's
   `title="og.url"` attribute; the alt carries the title. The wrappers
   parse their fence and fill the derivables.

3. **The player takes the old youtube.html's shape.** A
   `div.embed-video` (the dashed violet frame) wrapping a raw
   `<iframe width="100%">` with the old `allow` list; CSS gives it
   16:9 and `max-height: 640px`, matching the old template's cap (its
   `min-height: 80dvh` only ever served to stretch the height=
   "auto" iframe — the aspect-ratio form reproduces the rendered
   result without the hack).

4. **The sweep rewrites fences, not prose.** A scripted pass over
   `blog/*/index*.djot` (all four variants — embed fences never
   translate) adds a description to every github fence and extends the
   two ninjas fences with their posts' description and cover. The
   descriptions come from each repo's embedding post and known
   taglines; `la-revista-club-nintendo`'s card carries the old
   frontmatter's description and its future local cover path
   (`/blog/la-revista-club-nintendo/cover.png`) — the same
   future-path precedent its fence link already sets, activating when
   that post migrates.

## Risks / Trade-offs

- [Authored data can drift from the live target] → The description is
  a snapshot, like any static migration; the image (github) stays
  live-rendered by GitHub's endpoint.
- [External images add third-party requests] → Same as the old site's
  cards; the player and cards degrade to their text if images fail.
- [Fence grammar grows a third field] → The parser tolerates short
  forms, and the migration recipe records the grammar for the
  remaining tranches.
