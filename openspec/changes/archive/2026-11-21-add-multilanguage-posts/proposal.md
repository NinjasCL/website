# Proposal

## Why

The site publishes in Spanish only: blogatto already loads per-language
post variants (`index-{lang}.djot`, each an independent post routed to
`/blog/{lang}/{slug}/`), but the site declares no languages, offers no way
to move between a post's variants, and never discloses that non-Spanish
variants are machine translations. Readers also get no signal when a post
has gone stale.

## What Changes

- A site language configuration: Spanish as the default, human-written
  language (the `index.djot` variant, `language: None`), and English and
  Japanese as machine-translated languages shipped as `index-en.djot` and
  `index-ja.djot` variants — blogatto's native filename convention, no new
  routing.
- Every post page that has more than one language variant renders a
  language options row ("Idiomas: …") linking the post's sibling variants,
  with the current language marked as the current page.
- Every non-Spanish variant renders a machine-translated warning in that
  variant's language (the text lives in the language configuration).
- Every post whose date is older than 365 days from the build's current
  day renders the staleness warning: "Este contenido puede estar
  desactualizado ya que han pasado más de {x} días desde su publicación",
  with `{x}` the elapsed days.
- The page's `lang` attribute follows the variant: `es-CL` for the
  default, `en`/`ja` for the translated variants.
- The home page lists default-language posts only, so variants do not
  duplicate the entries.
- The shipped post gains its English and Japanese variants
  (`index-en.djot`, `index-ja.djot`) with translated title, description,
  and body.

Out of scope:

- No feed changes — blogatto's Atom and RSS entries include every
  variant; filtering them is a follow-up.
- No `og:locale` meta, no navbar/footer translation, and no translation of
  the staleness warning — its wording is pinned in Spanish.
- No new frontmatter fields and no `route_builder` customization.

## Capabilities

### New Capabilities

- `site-post-languages`: the site's post language configuration — the
  default human-written Spanish plus machine-translated English and
  Japanese — the per-post language options row, the machine-translated
  and staleness warnings, and the variant-aware page language.

### Modified Capabilities

- None. blogatto's content and rendering requirements already cover
  variant files (each variant is a djot post rendered as a page).

## Impact

- `src/site.gleam`: a `SiteLanguage` configuration list and helpers; a
  `language` parameter on `page()`; the options row, the two warnings, and
  the home page's default-language filter in the views; days-elapsed math
  via `gleam/time/timestamp.difference` + `gleam/time/duration` (the
  `gleam_time` dependency is already direct for `format_date`).
- `static/style.css`: `.post-languages` and `.post-warning` rules.
- `static/icons/win95/emoji-matches.json`: the `Warning_32x32_4.png` entry
  for the warning icon.
- `blog/bienvenidos-a-ninjas-cl/`: `index-en.djot` and `index-ja.djot`.
- `test/ninjas_test.gleam`: language, warning, options, and home-filter
  coverage.
- No dependency or blogatto configuration changes.
