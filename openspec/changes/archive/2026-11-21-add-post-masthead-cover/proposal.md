# Proposal

## Why

Single post pages repeat the site's identity block — the Ninjas logo image
plus the "忍者 開発者 Ninjas.cl" title — inside the masthead, so every post
opens with the same chrome instead of the post's own visual identity. Posts
already declare a header image in their frontmatter (`featured_image`), and
blogatto loads it into `post.featured_image` (`Option(String)`), but the post
template only reads it for the home page's featured row; the post page itself
ignores it.

## What Changes

- The single post masthead drops its hero elements — the logo image and the
  "忍者 開発者 Ninjas.cl" site title text — so no hero content renders inside
  it.
- Instead, the post's header image fills the masthead as a background that
  covers its whole area (`background-size: cover`).
- The header image is the post's `featured_image` frontmatter value; when a
  post declares none, the masthead defaults to the Ninjas logo image
  (`/img/Ninjas.png`) — the same placeholder the home featured row already
  uses.
- The shared navbar stays in the masthead: it is the primary navigation on
  every page, and retrostrap's `.rs-navbar` carries its own raised bevel
  background, so it stays legible over the cover image.
- `static/style.css` gains a `.masthead--cover` rule with a minimum height so
  the cover reads as a banner; the exact value is an adjustable assumption.

Out of scope:

- No new frontmatter field — the existing `featured_image` field is the
  header image.
- No changes to the home page or not-found mastheads.
- No `og:image`/`twitter:image` changes — the head suite keeps its fixed
  `logo_og.png` image.
- No feed, sitemap, or robots changes.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-masthead`: the "Per-page masthead hero" requirement's single post
  scenario changes — the compact logo-and-title hero is replaced by a
  masthead with no hero elements, and a new requirement pins the post
  masthead's cover background and its `featured_image` → `/img/Ninjas.png`
  default.

## Impact

- `src/site.gleam`: `masthead()` accepts a cover image; `post_template()`
  passes the post's header image and no hero children; `post_hero()` is
  removed. Uses blogatto's `post.featured_image` (already parsed from the
  `featured_image` frontmatter field) and lustre's `attribute.style(s)`.
- `static/style.css`: new `.masthead--cover` presentation rule.
- `test/ninjas_test.gleam`: post masthead assertions updated for the cover
  and the removed hero.
- No dependency or configuration changes.
