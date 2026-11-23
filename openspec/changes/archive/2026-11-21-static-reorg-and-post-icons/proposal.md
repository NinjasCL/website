# Proposal

## Why

The site's static assets were reorganized on disk: the Win95 icon pack moved from `/icons/` into the `/icons/win95/` subdirectory (a new, as-yet-unused macOS 9 pack joined it), the numbered macOS pattern set renamed `macosx` → `macos9`, and two new retro banners (`No-AI-green.gif`, `Y2K.gif`) shipped. The markup, the background picker, the stylesheet's no-JavaScript fallback, and the tests still address the old locations — three tests fail and every icon URL 404s once the moved files ship. Alongside the move, the blog post's title and date join the site's icon chrome with the owner-picked newspaper and calendar icons.

## What Changes

- Every markup icon reference moves from `/icons/<file>` to `/icons/win95/<file>` (eighteen references across the navbar, section titles, showcase cards, buttons, and the featured-post chrome).
- The blog post's presentation leads its title with the newspaper icon (`Mailnews8_32x32_4.png`) and its date with the calendar icon (`Timedate_32x32_4.png`), in the home page's featured post row and on the post page's article alike — replacing the site owner's partial in-progress edit (an `img` written with `href` instead of `src`, pointing at the Program Manager icon).
- The background picker's offered list and the stylesheet's no-JavaScript fallback move from `/patterns/macosx/…` to `/patterns/macos9/…`; the `win3.1` set is untouched.
- The banner wall gains the two new banners: `No-AI-green.gif` ("No AI") and `Y2K.gif` ("Y2K").
- Tests catch up: icon `src` assertions gain the `/icons/win95/` prefix, the manifest read moves to `static/icons/win95/emoji-matches.json`, the patterns test reads `macos9`, and new assertions pin the title/date icons on both templates.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `site-inline-icons`: gains a requirement — the blog post's title and date lead with the newspaper and calendar icons on both the featured post row and the post page article, served from the reorganized Win95 pack.
- `site-background-patterns`: three requirements updated for the `macosx` → `macos9` rename — the offered tiles resolve at the set's subdirectory, both sets are offered and matched, and the no-JavaScript fallback points at `/patterns/macos9/128.png`.

## Impact

- `src/site.gleam`: the eighteen `/icons/` references; `featured_post/1`'s title and date (fixing the in-progress `href`-on-`img` edit); `post_template/2`'s title and date; the `banners` const gains two entries.
- `static/background.js`: offered tile prefixes `macosx/` → `macos9/`.
- `static/style.css`: the `--random-pattern` fallback URL.
- `test/ninjas_test.gleam`: icon-path assertions, the manifest read path, the patterns directory and fallback assertions, plus the new title/date icon assertions.
- `site-contact-banners` is deliberately not modified: its count-based requirement already covers every shipped banner, so the two new GIFs are implementation work with no delta. No `gleam.toml`, CI, or dependency changes ride along; no blogatto or Lustre API drives the design.

## Out of scope

- The macOS 9 icon pack under `/icons/macos9/` — it ships as a static asset but no markup uses it; no icon chrome switches packs in this change.
- `static/img/sad_mac.png` and the `cursors/` directory — newly present or untouched assets with no markup reference.
- `emoji-matches.json` — the manifest records emoji-to-icon matches; the newspaper and calendar icons replace no emoji, so it gains no entries.
- Archiving the completed `trim-footer` and `rewrite-about-copy` changes — separate workflow steps.
