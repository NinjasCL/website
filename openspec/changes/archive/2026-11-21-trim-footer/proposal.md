# Proposal

## Why

The home footer still stacks three decorative blocks — the Chile WebRing bar, the "Desde 2015 · Hecho a mano en Chile 🇨🇱" line, and the 88×31 text badges — under a page that now closes with the banner wall as its retro flourish. The footer's chrome doubles up on nostalgia and buries the two lines that matter; trimming it to copyright + back-to-top lets the banners own the retro voice.

## What Changes

- The footer's Chile WebRing bar (its "Chile WebRing" name and the "Ir a un sitio aleatorio" link) is deleted.
- The "Desde 2015 · Hecho a mano en Chile 🇨🇱" line is deleted.
- The badges paragraph — the "source code" and "written by human" `rs-button88` buttons — is deleted.
- The footer keeps its shell: the `rs-footer` element with the copyright line ("Copyright 🥷🏽 Ninjas.cl © 2015–2026 · All rights and lefts preserved" — revised by the site owner from the initial "All rights preserved" wording) and the "^ volver arriba ^" back-to-top link targeting `#masthead`.
- No stylesheet, asset, or manifest changes ride along: the removed blocks' styles (`rs-webring-bar`, `rs-button88`) ship with retrostrap and fall away with the markup, and the kept emojis survive in the hero, about text, and copyright line.

## Capabilities

### New Capabilities
- `site-footer`: Defines the trimmed home page footer's content — the copyright line and the back-to-top link — with the former decorative blocks absent.

### Modified Capabilities
- `site-showcase-buttons`: The exclusion requirement "Showcase presentation excludes only the footer controls" is removed — the footer badge buttons were its only subject, and this change deletes them. The capability's two showcase-button requirements (large size, matching icons) are unaffected.

## Impact

- `src/site.gleam`: `site_footer/0` drops three child blocks — a plain Lustre markup deletion, no blogatto API or dependency involvement.
- `test/ninjas_test.gleam`: a new footer test pins the trim (removed blocks absent, copyright and back-to-top present, post-page footer untouched); the existing `rs-footer` assertion in `home_view_renders_homepage_sections_test` keeps holding.
- The single post page's own minimal footer ("Ninjas.cl — Desde 2015") is a separate template and stays as-is.

## Out of scope

- The post template's footer — only the home page's `site_footer/0` changes.
- The copyright line and the "volver arriba" back-to-top link — both stay.
- The webring membership itself (external, at webri.ng) — only the site's display of it.
