# Proposal

## Why

The language options row — "Idiomas: Español · English · 日本語 · …" — is one
of the last labeled rows still rendering a bare text label. Every other
labeled row on the site leads with an icon (the navbar, the section titles,
the tags row, the warnings), so the options row reads unadorned. Leading it
with the Win95 Regional Settings icon (the era's own "international /
languages" indicator) completes the icon-led chrome with a period-correct
pick.

## What Changes

- The language options row's label leads with the languages icon
  (`/icons/win95/Intl101_32x32_4.png`) through the shared inline icon
  presentation — decorative, empty alt — before the page language's own
  word for languages.
- The icon applies to all three rows that render the label, so the chrome
  stays consistent across pages: the post page's options row, the blog
  index pages' options row, and the home pages' options row.
- The label text, the options' order, the current-page markers, and the
  links themselves are unchanged — only the lead icon is added.

Out of scope: no emoji is replaced (no `emoji-matches.json` entry — the row
never carried one), no new icon assets, the per-post `icon` frontmatter
(`site-post-icons`) is untouched, and the row's entries keep their
presentation.

## Capabilities

### New Capabilities

None.

### Modified Capabilities
- `site-post-languages`: "Language options on post pages" — the post page's
  options row's label now leads with the languages icon.
- `site-home-languages`: "Every home links its sibling variants" — the
  homes' options row's label now leads with the languages icon.
- `site-blog-index`: "Index pages link their sibling language versions" —
  the index pages' options row's label now leads with the languages icon.

## Impact

- `src/site.gleam`: a shared `languages_icon` constant; the
  `language_options` (post pages) and `index_language_options` (index
  pages) rows lead their label with it.
- `src/ninjas/home.gleam`: the `home_language_options` row leads its label
  with it.
- `test/ninjas_test.gleam`: one render test covering the three row sites.
- No routing, content, or dependency changes.
