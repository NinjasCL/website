# Proposal

## Why

Every page ships an Open Graph suite but no `og:locale`, so social platforms
and crawlers cannot tell which language a page is in — the new English and
Japanese post variants most of all, since their URLs differ only by the
language path segment.

## What Changes

- Every page's head gains an `og:locale` meta carrying the page's locale in
  Open Graph's `language_TERRITORY` form: `es_CL` for the default Spanish
  pages (home, default posts, not-found) and the variant's own locale on
  translated post pages — `en_US` and `ja_JP`.
- The locale values are declared in the existing `SiteLanguage` configuration
  (`src/site.gleam`), the same single source of truth that drives the html
  `lang` attribute, the options row, and the translation warnings; `page()`
  gains the locale as a parameter beside `language`.

Out of scope:

- No `og:locale:alternate` entries and no `hreflang` alternate links —
  follow-ups if the site wants to advertise sibling variants to crawlers.
- No Twitter counterpart (the Twitter summary card has no locale field) and
  no changes to any other head field.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-head-meta`: the "SEO and social fields mirror each page" requirement
  extends — the Open Graph fields include `og:locale`, carrying the site's
  `es_CL` on default pages and the variant's locale on translated post
  pages, from the site's language configuration.

## Impact

- `src/site.gleam`: an `og_locale` field on `SiteLanguage` (`es_CL`, `en_US`,
  `ja_JP`); an `og_locale` parameter on `page()` passed from the language
  configuration at all three call sites; one new meta in the head's Open
  Graph block.
- `test/ninjas_test.gleam`: the head-meta suite asserts the locale on every
  page, and a per-variant test pins `es_CL`/`en_US`/`ja_JP`.
- No dependency, routing, content, or blogatto configuration changes.
