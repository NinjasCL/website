# Design

## Context

See `proposal.md` for motivation. Current state, verified today:

- `static/patterns/` holds two sets: `macosx/` — 74 numbered PNGs plus a LICENSE file, byte-for-byte the same tile names the old flat list offered (verified by diff) — and `win3.1/` with 18 named PNGs never offered before.
- `background.js` is an IIFE that splits a hardcoded comma-separated tile list, picks one at random, and sets `--random-pattern` to `` url("/patterns/${pattern}") ``. Its list still uses bare filenames (e.g. `128.png`), so every pick now hits `/patterns/<file>` — a location that no longer exists.
- `static/style.css` seeds `--random-pattern: url("/patterns/128.png")` as the no-JavaScript fallback — broken by the move the same way.
- Nothing else references `/patterns/` (verified across `src/` and `test/`); only these two static files do.

Routing, content files, and templates are unaffected: blogatto copies `static/` verbatim and both files ship as-is. No new dependency — `simplifile` (dev) already covers the tests.

## Goals / Non-Goals

**Goals:**

- Every offered tile URL resolves against the shipped layout, with the set's subdirectory carried by each list entry (`macosx/128.png`, `win3.1/arcade.png`).
- The picker considers both sets — 92 tiles — exactly the PNGs those sets ship.
- The no-JavaScript fallback resolves.

**Non-Goals:**

- No changes inside `patterns/` (no renaming or moving; LICENSE stays out of the picker).
- No change to the random-pick mechanism, the tint layering, or any Gleam code.

## Decisions

1. **Keep the hardcoded-list design; regenerate its contents.** Each entry carries the subdirectory prefix, so the existing `` url("/patterns/${pattern}") `` template keeps working unchanged. The 92-entry list is generated from the actual `ls` output of both directories during implementation — a hand-typed 92-item string invites transcription errors. Alternatives rejected: fetching a directory listing at runtime (static hosting serves no listings); generating the script from Gleam (turns a copied static asset into a template for zero behavioral gain).
2. **The win3.1 set joins the picker.** The reorganization deliberately grouped the tiles into two themed sets, and the request is to "consider the new images" — so the 18 named tiles become candidates alongside the 74 numbered ones, one list, same treatment.
3. **A test locks the picker to the shipped files.** It reads `background.js`, extracts the list string (the first quoted string in the file), and compares it against `simplifile.read_directory` of both pattern directories — PNG-only, prefixed with the set name, sorted. Any rename, addition, or removal inside `patterns/` that the script misses fails CI loudly. A second test pins the stylesheet fallback to `/patterns/macosx/128.png`.

## Risks / Trade-offs

- [A 92-entry hardcoded list can drift from the directories again] → Mitigated directly: the test compares the list against the directories on every run, so drift fails CI until the script is updated.
- [win3.1 tiles differ in style from the numbered set] → Accepted: both are deliberate pattern packs, and mixing them in the random rotation is the point of considering the new images.
- [The list string is long] → It stays one line, matching the existing file's shape; the header comment explains the structure.

## Migration Plan

1. Regenerate the offered list from both directories and rewrite `background.js` (list + header comment).
2. Update the `--random-pattern` fallback in `style.css`.
3. Add the picker-to-directory and fallback tests.
4. Verify: `gleam format src test`, `gleam test`, `openspec validate update-background-pattern-picker`.

Rollback: revert both static files; no other state persists.
