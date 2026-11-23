# Proposal

## Why

The blog index's entry cards render their images in a 40%-wide column
that stops at the card's link row — the tags and translation-links
region below stays uncovered, portrait images stretch the card instead
of cropping, and the 300px height cap leaves a strip of empty navy
under tall rows. The entry titles and dates are also plain text without
the icons the posts' own pages use, the consecutive frames sit a
collapsed 4px apart, and the index's title panel crowds the navbar
because its floating "Blog" title eats the panel's whole 16px top
margin.

## What Changes

- The entry card's image becomes a **full-height cover column**: the
  same 40% width, but spanning the card's entire height — top edge to
  bottom edge — with the image zoomed and cropped (never distorted) to
  fill it; the card's height now follows its text, never the image.
- The card **title** leads with the post page's mail-news icon
  (`/icons/win95/Mailnews8_32x32_4.png`) and the **date** with its
  calendar icon (`/icons/win95/Timedate_32x32_4.png`) — the same icons
  the post's own page title and date row use, rendered through the
  same `title_with_icon`/`icon` helpers.
- Each entry frame gets a **bottom margin** (16px — retrostrap's
  `--rs-space-4`) so consecutive results read as separate blocks; the
  previous 10% top-padding breathing room inside the frames is
  removed — separation now lives between the frames, where it reads.
- The index's **title panel gets top margin** (32px — `--rs-space-5`)
  so the floating "Blog" title clears the navigation menu instead of
  touching it.

Out of scope:

- No changes to pagination, feeds, the sitemap, or the entry's links,
  tags, and translation links.
- No changes to the in-post OpenGraph embed cards (`embed-full` inside
  post bodies) — the cover column and its layout rules are scoped to
  the index cards under `.blog-entry`.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-blog-index`: the entry card presentation — full-height cover
  images, the title and date icons, frame-to-frame spacing by bottom
  margin (replacing the in-frame top padding), and the title panel's
  top margin below the navigation menu.

## Impact

- `src/site.gleam`: `blog_entry_card` gains the two icons (through the
  existing `title_with_icon` and `icon` helpers — no new Lustre
  patterns); its doc comments updated to describe the card.
- `static/style.css`: the `.blog-entry` rules — the cover column, the
  reserved right column for text and meta, the bottom margin — plus a
  `#blog` top margin rule.
- No new dependencies; no changes to `gleam.toml`, routes, or content
  files.
