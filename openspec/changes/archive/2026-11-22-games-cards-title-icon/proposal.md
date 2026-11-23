# Proposal

## Why

The games cards on the home page render bare titles, unlike the projects
and books cards whose titles lead with their period-correct Win95 icons.
The owner wants every games card — starting with "Rolplay Manual" — to
lead its title with `Mmsys108_32x32_4.png`, the pack's media-player glyph,
so the Juegos section matches the icon-led card chrome.

## What Changes

- Each of the four games cards ("Rolplay Manual", "Profesor Rossa",
  "¡Qué Chaucha!", "Munsta Jump!") sets `icon` to
  `/icons/win95/Mmsys108_32x32_4.png`; `showcase_card` already renders
  `item.icon` before the title through `title_with_icon`, so no template
  change is needed.
- The icon is decorative, empty alt, and shares the existing `.site-icon`
  presentation. No card image, caption, description, link, or layout
  changes.

Out of scope: the Juegos section heading keeps its WinMine icon; the
projects and books card icons stay as they are; no new assets (the icon
already ships in `static/icons/win95/`), no emoji-to-icon manifest entry
(no emoji is being replaced), and no dependency or routing changes.

## Capabilities

### New Capabilities

None.

### Modified Capabilities
- `site-showcase-cards`: new requirement that games card titles lead with
  the games icon.

## Impact

- `src/ninjas/home.gleam`: four `icon:` values in `games_section`.
- `test/ninjas_test.gleam`: one render test asserting the icon precedes
  each of the four game titles.
- No other files.
