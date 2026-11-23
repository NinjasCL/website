# Proposal

## Why

The home page's "Más entradas" list carries every non-featured entry — with
the current 100+ post catalog that is an unbounded wall of list rows before a
visitor ever reaches the projects, books, and games sections. The site owner
asked for the list trimmed to a fresh sample and given the same icon-led
presentation the rest of the home page uses, with a clear path to the full
catalog.

## What Changes

- The "Más entradas" heading leads with an inline Win95 icon, like every
  other heading on the home page: the stack-of-documents Files icon
  (`/icons/win95/Files_32x32_4.png`).
- The list is trimmed: it shows at most **ten** of the remaining
  default-language entries, picked at random at build time with the same
  Fisher–Yates `site.shuffle` the featured post and the post pages'
  random-entries list already use — a fresh set on every build.
- A "Ver Todos" button follows the list: a large icon button in the site's
  established style (`rs-btn--icon rs-btn--large`), led by the Shdocvw
  document-view icon (`/icons/win95/Shdocvw257_32x32_8.png`) — the same icon
  every existing "Ver / View" button uses — linking the site's blog index
  at `/blog` (the navbar's own Blog target, which redirects to
  `/blog/page/1/`). It renders whenever the "Más entradas" list renders, so
  the full catalog is always one click away, trimmed or not.
- Small catalogs keep their behavior: fewer than ten remaining entries list
  them all, and a lone post still renders no list and no button.

Out of scope:

- No changes to the featured post's row, the featured pick's randomness, the
  empty-state note, or the blog index itself.
- No new CSS, dependencies, or content files — the list reuses the existing
  `rs-list rs-list--stars` rows and retrostrap button styles.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-featured-post`: the "Más entradas" list changes from "every
  remaining entry, newest-first" to "up to ten random remaining entries, with
  an icon-led heading and a Ver Todos button linking the blog index" — the
  requirements covering the featured pick's remainder and the section's
  presentation are updated.

## Impact

- `src/ninjas/home.gleam`: `more_posts` — icon on the heading, shuffle +
  `list.take(…, 10)` for the picks, the Ver Todos button after the list.
- `test/ninjas_test.gleam`: order-agnostic tests for the ten-entry cap, the
  heading icon, the button, the small-catalog and lone-post edges; the
  existing random-featured test keeps passing.
- No dependency, content, or stylesheet changes.
