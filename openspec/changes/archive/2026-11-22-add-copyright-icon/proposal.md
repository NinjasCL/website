# Proposal

## Why

The footer's copyright line is the last labeled line of the site's chrome
that renders as bare text. Every other label — the navbar, sections, post
titles, dates, tags, language options — leads with a period-correct icon
from the static packs, so the copyright line looks unadorned by comparison.
Leading it with the Win95 document-and-pencil icon (authorship, the source
of a copyright) completes the icon-led chrome in the pack's own style.

## What Changes

- The footer's copyright line leads with the authorship icon
  (`/icons/win95/FilePencil_32x32_4.png`) through the shared inline icon
  presentation — decorative, empty alt — before the verbatim
  "Copyright 🥷🏽 Ninjas.cl © 2015–{year} ·" text.
- The icon renders wherever the shared footer renders: home pages, post
  pages, blog index pages, and the not-found page.
- The line's wording, its kept 🥷🏽 emoji, the rights clause in every
  language, the current build year, and the back-to-top link are unchanged.

Out of scope: no emoji is replaced (the ninja stays an emoji per the site
owner), no new icon assets, no `emoji-matches.json` entry, no per-post
title icon (`site-post-icons`), and no change to the footer's other
elements or the removed decorative blocks.

## Capabilities

### New Capabilities

None.

### Modified Capabilities
- `site-footer`: "The footer renders the copyright line and the back-to-top
  link" — the copyright line now leads with the authorship icon.

## Impact

- `src/site.gleam`: one `copyright_icon` constant and one `icon(...)`
  element at the head of `site_footer`'s copyright paragraph.
- `test/ninjas_test.gleam`: one render test asserting the icon precedes the
  "Copyright 🥷🏽" text on the home, post, and index pages; the existing
  footer tests stay green unchanged.
- No routing, content, or dependency changes.
