# Proposal

## Why

The blog index (`/blog/page/{n}/`) already exposes the Atom/RSS feed with an
icon beside its "Blog" title, but the home page's "Entradas del blog" section
heading does not — readers on the home page have no visible link to subscribe.
Both blog panels also sit flush with the page container's left edge, so the
floating section titles hug the border while the rest of the layout has breathing
room.

## What Changes

- Add the same feed icon link (`/atom.xml`) next to the home page's "Entradas
  del blog" section heading, on all four home languages.
- Reuse the existing feed-link presentation (`.blog-feed` / `/img/feed.svg`)
  instead of introducing a second icon treatment.
- Give the home "Entradas del blog" panel (`#posts`) and the blog index title
  panel (`#blog`) a small left margin (8px, retrostrap's `--rs-space-3`).
- Out of scope: new feed formats or routes, feed configuration changes, margins
  on other home sections, and changes to the post cards or pagination.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `site-section-headers`: home section headers gain the feed icon link on the
  posts section, matching the blog index's title section.
- `site-section-spacing`: the posts and blog index panels gain a small left
  inset.

## Impact

`src/ninjas/home.gleam` (home section header rendering), `src/site.gleam`
(shared feed-link markup used by the blog index and home), and
`static/style.css` (`#posts` / `#blog` rules). No blogatto configuration,
content files, routes, or dependencies change; the site is still built with
Lustre's `html`/`attribute` element helpers and retrostrap's existing spacing
tokens.
