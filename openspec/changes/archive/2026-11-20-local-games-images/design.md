# Design

## Context

See `proposal.md` for motivation. Current state, verified today:

- `games_section` in `src/site.gleam` still points its four cards at remote URLs: Rolplay Manual at `https://ninjas.cl/blog/rolplay-un-juego-de-cartas-hecho-en-vb6/assets/manual2.png`, Profesor Rossa at `https://raw.githubusercontent.com/NinjasCL/rossa/master/game.gif`, ¡Qué Chaucha! at `https://raw.githubusercontent.com/proyecto-chaucha/quechaucha/master/data/bgimage/menu.jpg`, and Munsta Jump! at `https://raw.githubusercontent.com/NinjasCL/munstajump/master/game.gif`. All four were fetched this session for dimension checks (899×865 PNG, 256×256 GIF, 960×640 JPEG, 600×150 GIF) — reachable, with two animated GIF captures.
- `static/img/` already serves the local convention: five logos/portrait plus the four book covers, all repointed in the earlier `local-showcase-images` change.
- The archived `site-showcase-images` spec pins two things this change reverses: its served-from-assets requirement covers only Proyectos and Libros, and its guard requires the games images to keep their remote sources. The home-view test pins the rossa URL as the games guard.

Routing, content files, and templates are unaffected: four asset fetches, four `image:` field edits, and test updates — blogatto copies `static/` verbatim. No new dependency.

## Goals / Non-Goals

**Goals:**

- All twelve showcase images serve from `/img/…`; no remote image host anywhere in the three showcase sections.
- The captures keep their nature: animated GIFs stay animated, no resizing or conversion.

**Non-Goals:**

- No change to the hero logo, alts, captions, or any presentation (`site-showcase-cards` owns layout and the uniform image boxes — the wide Munsta capture already letterboxes there).
- No changes to the image files beyond naming.

## Decisions

1. **Local names follow the existing pack conventions**: `rolplay-manual.png`, `rossa.gif`, `quechaucha.jpg`, `munstajump.gif` — lowercase project-flavored basenames like the logos (`elixircl.png`, `joyofpw.png`), extensions preserved so the GIFs stay downloadable-and-serve verbatim. Alternative rejected: keeping the remote basenames (`game.gif` twice — colliding and meaningless locally).
2. **The spec restructure mirrors the `showcase-cards-row-layout` precedent**: the served-from-assets requirement is MODIFIED to the three-section scope keeping its existing scenarios verbatim and adding games scenarios (MODIFIED blocks must keep scenario names; adding new ones is the clean route); the reversed guard is REMOVED (with Reason/Migration) and replaced by an ADDED hero-only guard, because a MODIFIED guard would have to keep its lying "games unchanged" scenario name. At archive time the main spec's `site-showcase-images` Purpose also needs its two-section wording refreshed to the three-section scope — a direct Purpose edit sanctioned by the sync workflow.
3. **The download follows the covers precedent**: plain `curl` with `-f` (an HTTP error fails loudly instead of saving an error page), then `file` type and size verification per asset; the two GIFs must verify as GIF image data.
4. **The test flips its guard into absence assertions**: the rossa-URL presence check becomes `raw.githubusercontent.com` and `ninjas.cl/blog` absent from the entire markup (after this change, nothing in the home view uses `raw.githubusercontent.com`), plus the four local paths present; the hero URL assertion stays as the scoped guard.

## Risks / Trade-offs

- [A capture URL could break between planning and apply] → All four fetched this session; apply verifies type and size per file before repointing code, pausing on any failed fetch.
- [The wide Munsta capture (600×150) adds ~37 KB and the animated GIFs add weight to the repo] → Accepted, the same trade-off already made for the covers; serving locally removes the third-party dependency the owner is closing.
- [The rossa/quechaucha/munsta captures are live-game material that could go stale] → Their sources are pinned in the archived change history; updating a capture is a one-file swap plus a one-line `image:` edit.

## Migration Plan

1. `curl` the four captures into `static/img/` with their local names; verify each file's type and size.
2. Repoint the four `image:` fields in `games_section`.
3. Update the home-view test (local paths present, remote hosts absent, hero guard kept).
4. Verify: `gleam format src test`, `gleam test`, `openspec validate local-games-images`.

Rollback: revert the four `image:` fields and delete the four files; nothing else persists.
