# Proposal

## Why

The pattern tiles under `static/patterns/` were reorganized into themed sets: the 74 numbered tiles now live in `patterns/macosx/` (verified — the old flat list matches that directory exactly) and a new `patterns/win3.1/` set adds 18 named tiles. But `background.js` still offers the old flat `/patterns/<file>` paths, so every randomly picked background tile 404s, and the no-JavaScript fallback in `style.css` (`/patterns/128.png`) points at a location that no longer exists.

## What Changes

- `background.js` offers the tiles at their subdirectory paths — `macosx/<file>` and `win3.1/<file>` — considering both pattern sets: the numbered macOS set and the named Windows 3.1 set, 92 tiles in all. The random-pick mechanism (an IIFE setting the `--random-pattern` CSS variable per page load) is unchanged; each list entry simply carries its set's prefix so the existing `/patterns/${pattern}` URL template keeps working.
- The stylesheet fallback tile points at the shipped macosx 128 tile at its new path (`/patterns/macosx/128.png`), so the background still renders without JavaScript.
- Out of scope:
  - The pattern files themselves — no renaming, moving, or converting; the `LICENSE` file inside `macosx/` stays and stays out of the picker.
  - The tint/layering in `style.css` — only the fallback URL changes.
  - Any Gleam source, routing, content, or template change — the script and stylesheet are static assets that blogatto already copies verbatim.
  - Any new dependency — `simplifile`, already a dev dependency, covers the tests.

## Capabilities

### New Capabilities
- `site-background-patterns`: The site's decorative background tile behavior — a no-JavaScript fallback tile plus a randomly selected tile per page load, drawn from the pattern sets shipped under `/patterns/` at their subdirectory paths.

### Modified Capabilities

None. No existing spec (`blog-dev-server`, `blog-site-generation`, `site-about-section`, `site-masthead`, `site-section-headers`, `site-showcase-images`) covers the background tiles.

## Impact

- `static/background.js`: the offered-tile list (regenerated from the actual directory contents, not hand-typed) and its header comment; the URL template stays as-is.
- `static/style.css`: the `--random-pattern` fallback URL.
- `test/ninjas_test.gleam`: new tests reading both static files — the picker's offered list matches the shipped PNGs of both sets exactly (every offered tile exists, every shipped PNG is offered, LICENSE excluded), and the fallback resolves at the new path.
- No `gleam.toml`, `manifest.toml`, or CI changes.
