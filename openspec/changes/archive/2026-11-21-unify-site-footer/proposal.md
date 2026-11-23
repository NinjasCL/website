# Proposal

## Why

Single post pages close with a minimal "Ninjas.cl — Desde 2015" footer
line instead of the site footer the home and not-found pages carry, so the
pages disagree. And the footer's copyright line hardcodes its end year
("© 2015–2026"), which goes stale the moment a new year starts.

## What Changes

- The single post template renders the shared site footer — the copyright
  line and the "^ volver arriba ^" back-to-top link — replacing its minimal
  "Ninjas.cl — Desde 2015" footer.
- The copyright line's end year is always the current year, computed at
  build time from the system clock (the site regenerates on every build, so
  the footer stays current on each regeneration). The line reads
  "Copyright 🥷🏽 Ninjas.cl © 2015–<current year> · All rights and lefts
  preserved".
- The home page and not-found page footers are otherwise unchanged; the
  404 page already renders the shared footer.

Out of scope:

- No footer layout or style changes — the post page reuses the existing
  `rs-footer` presentation as-is.
- No `og:image`/`twitter:image`, feed, sitemap, or robots changes.
- No change to the JSON-LD block's `datePublished` — that is a publication
  date, not the copyright year.
- No client-side (JavaScript) year computation — the site keeps its
  no-JavaScript content contract.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-footer`: the copyright/back-to-top requirement broadens from the
  home page to every generated page (single post pages join the home and
  not-found pages) and its end year becomes the build's current year; the
  decorative-blocks requirement's scenario pinning the post page's distinct
  "Desde 2015" line drops that line, which no longer exists anywhere.

## Impact

- `src/site.gleam`: `post_template` renders `site_footer()`; the copyright
  line's year comes from a new `gleam/time`-based helper
  (`timestamp.system_time` → calendar year), joining the existing
  `format_date` usage of the same API.
- `test/ninjas_test.gleam`: the footer assertions compute the expected year
  with the same `gleam/time` API and cover the post page's shared footer.
- No routing, content-file, or dependency changes; no new blogatto or Gleam
  package needed.
