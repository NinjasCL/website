# Proposal

## Why

The owner added a cherry-blossom pattern tile and reworked the background picker's list into a JS array — but the tile landed flat at the patterns root (`/patterns/blossom.png`), which the current spec forbids (every offered tile carries its set's subdirectory; the flat layout is exactly what the "no stale flat paths" scenario guards against), and the new array format broke the test's first-quoted-string parse. The owner picked the resolution: a third `custom/` set under `/patterns/` for owner-added tiles, with blossom as its first entry.

## What Changes

- `static/patterns/blossom.png` moves into a new `static/patterns/custom/` set — the home for owner-added tiles alongside the numbered macOS set and the named Windows 3.1 set.
- `static/background.js`: the blossom entry becomes `custom/blossom.png`, and the picker's comment names the three sets. The array format the owner introduced stays.
- The spec follows: `site-background-patterns`'s offered-tiles requirement considers the three shipped sets, and the test parses the array literal and compares against all three directories.
- No markup, stylesheet, or fallback change rides along.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `site-background-patterns`: the offered-tiles requirement covers the third `custom/` set (scenarios updated; fallback and path requirements untouched).

## Impact

- `static/patterns/`: the tile moves one level down into `custom/`.
- `static/background.js`: one array entry and the comment.
- `test/ninjas_test.gleam`: `background_patterns_match_shipped_files_test` parses the array literal and reads the `custom/` directory; the shipped comparison covers the three sets.
- No dependency or `src/` changes.

## Out of scope

- Renaming or converting the blossom tile itself — it ships as the owner made it.
- The no-JavaScript fallback tile and the stylesheet — untouched.
- Any new picker behavior — the array format is the owner's choice and is simply adopted.
