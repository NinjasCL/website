# Proposal

## Why

The home page's fifth "Proyectos" card was renamed from "🥷 Ninja
Systems" to "🥷 Ninjas.cl" (its view URL is `https://ninjas.cl/`), but the
rename left the old name behind in the test suite and the docs that
reference the card: `emojis_render_as_static_icons_test` still asserts
`🥷 Ninja Systems` and fails against the current source (the only failing
test), and the ShowcaseItem doc comment, the emoji manifest's 🛸 reason,
and two main-spec requirement texts still describe the card by its old
name. The behavior is correct; the references are stale.

## What Changes

- Align every stale "Ninja Systems" reference with the card's current
  "🥷 Ninjas.cl" title: the failing test assertion, one test comment, the
  `home.gleam` doc comment, and the manifest's 🛸 kept-emoji reason.
- Correct the two main-spec requirement texts that name the card: the
  kept-emojis requirement in `site-inline-icons` and the projects-images
  scenario in `site-showcase-images`.
- No behavior, markup, or content change — the rendered site is
  byte-identical; only tests, comments, and spec prose move.

Out of scope: any change to the card itself, to other cards or sections,
and to the historical negative assertions ("Ninja Systems es un grupo"
must NOT appear) which refer to the old hero text, not the card.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `site-inline-icons`: the kept-emojis requirement's text and "Kept
  emojis render" scenario name the card "Ninjas.cl" instead of "Ninja
  Systems".
- `site-showcase-images`: the "Projects images resolve locally" scenario
  lists the five card images with the card's current title.

## Impact

- Tests: `emojis_render_as_static_icons_test` goes green by asserting
  the current card title; the suite reaches a clean 58/58.
- Docs: one comment in `src/ninjas/home.gleam`, one in the test file, and
  the `emoji-matches.json` 🛸 reason.
- Specs: prose corrections in two main specs, applied through this
  change's delta; no requirement's behavior changes.
