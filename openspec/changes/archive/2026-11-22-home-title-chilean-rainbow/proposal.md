# Proposal

## Why

The home hero's title rendered as plain text plus a generic rainbow
span. The owner wants the title to read as Chilean: the site's identity
line — "忍者 開発者 Ninjas.cl", Japanese for "ninja developers" — dressed
in the Chilean flag's colors, the same colors the 🇨🇱 emoji carries.

## What Changes

- The full title renders through a **banded gradient clipped to the
  text** — the same technique as retrostrap's `rs-rainbow`
  (`background-clip: text`, transparent fill, no per-character markup)
  — carrying the **🇨🇱 emoji's flag palette** (twemoji's flag-cl):
  blue `#1f429b`, white `#eee`, red `#d42d27`.
- The bands run **top to bottom** in the flag's own order — blue at the
  top, white through the middle, red at the bottom — so every glyph
  reads horizontally intact; the first iteration's left-to-right bands
  sliced the wide kanji mid-stroke and were hard to read.
- One span, one rule: the hero's `h1` wraps the title text in a single
  `cl-rainbow` span, styled in `static/style.css`; the previous
  `rs-rainbow` usage (which colored only "Ninjas.cl") is gone.
- The "Software from 🇨🇱 with ❤️" tagline beneath the title is the
  palette's on-page reference.

Out of scope:

- No changes to the hero's structure, logo, tagline, or note.
- No color changes elsewhere on the site.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-masthead`: the home hero's title gains a presentation
  requirement — the Chilean tricolor via the banded gradient technique.
