# Proposal

## Why

The post page's language options row is labeled "Idiomas:" on every
language variant — a Spanish label on the English, Japanese, and Portuguese
pages, inconsistent with the per-language machine-translation warnings and
the variant-aware `lang` attribute those pages already carry.

## What Changes

- The options row's label follows the page's language: "Idiomas" on the
  Spanish and Portuguese (Brazil) pages, "Languages" on English, "言語" on
  Japanese. The label word is declared per language in the existing
  `SiteLanguage` configuration — the same single source of truth as the
  warning text, the `og:locale`, and the display names.
- The row's entries are unchanged: the variants' own-language names in the
  declared order, the current language marked as the current page.

Out of scope:

- No other site chrome translation — the navbar and footer stay Spanish on
  every page, and the staleness warning keeps its pinned Spanish wording.
- No new languages and no changes to the entries themselves.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-post-languages`: the "Language options on post pages" requirement
  extends — the row's label is the page language's own word for languages,
  from the site's language configuration.

## Impact

- `src/site.gleam`: an `options_label` field on `SiteLanguage` ("Idiomas",
  "Languages", "言語", "Idiomas"); `language_options` renders the current
  page's label instead of the hardcoded "Idiomas".
- `test/ninjas_test.gleam`: the options-row test pins the label per page —
  "Idiomas:" on the Spanish and Portuguese pages, "Languages:" on English,
  "言語:" on Japanese — with the Spanish label absent from the en/ja pages.
- No dependency, routing, content, or blogatto configuration changes.
