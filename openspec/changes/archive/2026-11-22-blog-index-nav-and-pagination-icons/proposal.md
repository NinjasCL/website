# Proposal

## Why

The blog index's translated pages (`/blog/en/page/{n}/`, `/blog/ja/page/{n}/`, `/blog/pt/page/{n}/`) render their pane copy in the reader's language but pass the default Spanish `nav_labels` to the masthead, so the shared navigation menu stays in Spanish. Separately, the index pagination buttons still use the old `ArrowLeft`/`ArrowRight` sprites while the post navigation buttons were switched to the rotated Win95 pointing hand, leaving the two navigation controls visually inconsistent.

## What Changes

- Add per-language `NavLabels` to `BlogIndexText` and pass `text.nav` to the masthead, so the six navbar link labels and the navigation region's aria-label follow the index page's language — matching the translated home pages.
- Switch the index pagination buttons from `ArrowLeft_32x32_4.png`/`ArrowRight_32x32_4.png` to the same `Msow10_32x32_4.png` hand used by post navigation, with the same `post-nav__hand--left`/`post-nav__hand--right` quarter-turn classes.
- Add regression tests for translated index navbars and for the pagination hand icons (first, middle, and last pages).

Out of scope: the masthead cover and footer presentation (they keep the default chrome), post pages' navigation menu (still Spanish, as specified), post navigation itself, the language options row (already translated), navbar links' targets, and any blog content or route changes. No new dependency is introduced.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `site-blog-index`: the language index requirement now includes the navigation menu among the page's translated copy; the pagination requirement now specifies the pointing-hand icons shared with post navigation.

## Impact

- `src/site.gleam` — `BlogIndexText` gains a `nav` field; `blog_index_page` passes `text.nav` to `masthead`; `pagination_nav` swaps the arrow sprites for the rotated hand.
- `test/ninjas_test.gleam` — new navbar-translation and pagination-icon tests.
- Gleam APIs involved: `site.masthead`, `site.NavLabels`, `site.BlogIndexText`, `post.nav`. No blogatto API or version change; no new dependency.
