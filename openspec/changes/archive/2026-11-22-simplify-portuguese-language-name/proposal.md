# Proposal

## Why

The site labels its Portuguese variant "Português (Brasil)" in every language options row — on post pages, home pages, and blog index pages. The country qualifier is unnecessary for readers; the site owner wants the plain name "Português". The `pt` route, `pt_BR` OpenGraph locale, and Brazilian-Portuguese warning/description strings stay as they are — only the display name changes.

## What Changes

- Change the Portuguese display name to "Português" in the three places that own it: `site_languages` in `src/site.gleam` (post language options), `portuguese_index_text` in `src/site.gleam` (blog index options), and `portuguese_text` in `src/ninjas/home.gleam` (home options).
- Update the one test expectation that asserts the rendered options row and the two source doc comments that carry the same qualifier.
- Add a regression requirement covering the four plain display names wherever the language options row renders.

Out of scope: the `pt` route segment, `lang="pt"`, `og:locale` `pt_BR`, translation warning and description wording, locale-specific content, and archived change records (left as historical truth). No new dependency and no blogatto API change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `site-post-languages`: add the language display-name requirement used by the post, home, and index options rows.

## Impact

- `src/site.gleam` — Portuguese names in `SiteLanguage` and `BlogIndexText`, plus one doc comment.
- `src/ninjas/home.gleam` — Portuguese name in `HomeText` and one doc comment.
- `test/ninjas_test.gleam` — the post options-row expectation.
- Gleam APIs involved: the language configuration records consumed by the shared language-options helpers; no route or template changes.
