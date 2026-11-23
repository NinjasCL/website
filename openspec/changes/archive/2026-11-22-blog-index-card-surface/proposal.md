# Proposal

## Why

The blog index cards render on the page's violet wash with nothing but
their dashed borders — the blocks blend into the main background, and
consecutive entries sit too close to read as distinct results.

## What Changes

- The index entry blocks get a **darker background** — the Night Owl
  navy `#011627`, the site's established darker-than-violet reading
  surface (the same field the post code panels use) — so each block
  differentiates from the page background.
- Every entry gets **10% top padding** for breathing room between
  results, **except the first entry of each page's list**, which stays
  flush at the top.
- Both rules land in `static/style.css` on the existing `.blog-entry`
  frame; no markup, view, or behavior changes — the cards' contents
  (cover, date, title, description, tags, translation links), the
  dashed `#7540bd` border, and the `#e8a33d` hover are untouched.

Out of scope:

- No changes to the entry card's contents, links, or pagination.
- No changes to other site surfaces (post pages, home, code panels).

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-blog-index`: the entry cards gain a presentation requirement —
  a distinct darker surface and a spacing rhythm with breathing room
  between results.
