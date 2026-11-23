# Design

## Context

See `proposal.md` for motivation. `src/site.gleam` owns both the shared masthead (`NavLabels`, `masthead`, `site_nav`) and the blog index views. `BlogIndexText` already carries the index page's translated heading, intro, pagination labels, and options-row label, but not the navbar labels: `blog_index_page` passes the module's Spanish `nav_labels` constant to `masthead`. The `HomeText` records in `src/ninjas/home.gleam` already carry per-language `NavLabels` with the exact translations needed, but `home.gleam` imports `site`, so `site.gleam` cannot import it back to reuse them. No routes, content files, or page templates change.

## Goals / Non-Goals

**Goals:**
- Render the index navbar's six labels and aria-label in the index page's language for es/en/ja/pt.
- Make index pagination point with the same rotated Win95 hand as post navigation, dropping the arrow sprites.
- Keep the default index byte-for-byte Spanish and leave the masthead cover and footer presentation alone.

**Non-Goals:**
- Translating the navbar on post pages or the 404 page (they keep the default chrome, as specified).
- Changing the language options row, card contents, pagination URLs, page count, or any blog content.
- Adding a client-side script or a dependency.

## Decisions

- **Carry nav labels on `BlogIndexText`.** Add a `nav: NavLabels` field with inline per-language records, mirroring `HomeText.nav`. The Spanish record reuses the existing `nav_labels` constant; en/ja/pt repeat the same translations already used on their home pages. Alternative: extracting a shared translation module and refactoring `home.gleam` — rejected as a broader refactor for this focused change; the codebase already accepts per-record translation duplication (`options_label` appears on `SiteLanguage`, `HomeText`, and `BlogIndexText`).
- **Reuse the post-navigation hand directly.** `pagination_nav` renders `Msow10_32x32_4.png` with the existing `post-nav__hand--left` / `--right` classes, so the stylesheet's quarter-turn transforms and pixelated sizing apply unchanged. Alternative: a separate icon or new CSS — unnecessary, since the classes already do the work and the spec now calls for the shared hand.
- **No new dependency.** `site.masthead` already takes `NavLabels`, and the icon file and CSS classes already ship; only the call sites change.

## Risks / Trade-offs

- [Translation drift between home and index navbars] → The strings are identical today and both records follow the same machine-translation convention; tests pin each index's six labels and aria-label so a future divergence is visible.
- [Hand rotation on a button beside a text label] → The `post-nav` CSS already sizes and rotates that sprite in the same button shape, so pagination inherits a proven presentation; regression tests check both rotation classes and the absence of arrow sprites on first, middle, and last pages.
- [CI checks must stay green] → Run `gleam format src test` and `gleam test` before finishing; no dependency or CI version changes.
