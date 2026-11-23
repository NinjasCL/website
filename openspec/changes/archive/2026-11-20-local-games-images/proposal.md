# Proposal

## Why

The `local-showcase-images` change brought the Proyectos and Libros showcase images into `static/img/`, but deliberately left the Juegos images remote (four URLs across `raw.githubusercontent.com` and `ninjas.cl/blog`) — the home page still depends on third-party availability for its games cards. The site owner now extends the same convention to Juegos: download the four captures and serve them from the site's own static assets.

## What Changes

- The four "Juegos" images are downloaded into `static/img/` and repointed to local `/img/…` paths: the Rolplay manual cover (`rolplay-manual.png`, from the production blog path), the Profesor Rossa capture (`rossa.gif`), the ¡Qué Chaucha! menu (`quechaucha.jpg`), and the Munsta Jump! capture (`munstajump.gif`). Files are stored exactly as downloaded — the two animated GIFs stay animated.
- `site-showcase-images` is restructured to match: the served-from-own-assets requirement now covers all three showcase sections, a new requirement records the game assets shipping with the site, and the old "images outside proyectos and libros keep their sources" guard is removed — only the masthead hero logo keeps its remote source, protected by a new narrower requirement.
- Out of scope:
  - The masthead hero logo — keeps its current absolute production URL.
  - The games images themselves — no renaming beyond the local filenames, no resizing or format conversion (GIFs stay GIFs).
  - Any presentation change: the cards keep the row structure and the uniform Super Club Net image boxes (`site-showcase-cards` owns those).
  - Any new dependency — the download is a one-time `curl` fetch, and blogatto already copies `static/` verbatim.

## Capabilities

### New Capabilities

None.

### Modified Capabilities
- `site-showcase-images`: The "served from the site's own assets" requirement extends to the Juegos section (with new games scenarios); a new requirement covers the game capture assets shipping with the site; the "images outside proyectos and libros keep their sources" guard is removed and replaced by a hero-logo-only guard, since the games clause is reversed.

## Impact

- `static/img/`: four added files, verified as valid images with the expected types.
- `src/site.gleam`: the four `image:` fields in `games_section` change from remote URLs to `/img/…` paths; alts, captions, and the hero stay untouched.
- `test/ninjas_test.gleam`: the home-view test gains the four local games paths; its rossa remote-URL guard flips to absence assertions (no `raw.githubusercontent.com` and no `ninjas.cl/blog` anywhere in the markup); the hero URL assertion stays.
- No `gleam.toml`, `manifest.toml`, or CI changes.
