# Proposal

## Why

The site's machine-translated options cover English and Japanese only.
Portuguese (Brazil) readers — the largest non-Spanish audience in the
region the site writes for and about — have no variant, and the language
configuration has no entry to hang one on.

## What Changes

- Portuguese (Brazil) joins the machine-translated languages in the
  `SiteLanguage` configuration: code `pt` (so the variant file is
  `index-pt.djot`, routed to `/blog/pt/{slug}/`, html `lang="pt"`), display
  name "Português (Brasil)", a Brazilian-Portuguese machine-translation
  warning, and `og_locale: "pt_BR"` — the fourth language, after English
  and Japanese, in the site's declared order.
- The shipped post gains its `index-pt.djot` variant: same slug, date, and
  featured image as the original, with translated title, description, and
  body — so its post page offers all four language options.
- AGENTS.md's site-languages row and blog-content conventions list the new
  language.

Out of scope:

- No other languages, no `og:locale:alternate`, no `hreflang` links.
- No spec change to `site-head-meta` — its (pending) `og:locale`
  requirement is generic over the language configuration by design, so a
  new language needs no head-meta spec edit; `pt_BR` simply flows through
  the config once both changes land.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `site-post-languages`: the "Site language configuration" requirement's
  language set grows — Portuguese (Brazil) joins English and Japanese as
  machine-translated languages, and the shipped post's variants scenario
  covers the new `index-pt.djot` source.

## Impact

- `src/site.gleam`: one new `SiteLanguage` entry in `site_languages`
  (code `pt`, name "Português (Brasil)", machine-translated, pt-BR warning
  text, `og_locale: "pt_BR"` — the field added by the pending
  `add-og-locale-meta` change, which applies first).
- `blog/bienvenidos-a-ninjas-cl/`: `index-pt.djot`.
- `test/ninjas_test.gleam`: the options-row, translation-warning,
  page-language, og:locale, and blog-sources assertions extended to the
  fourth variant.
- `AGENTS.md`: the site-languages row and content conventions.
- No dependency, routing, or blogatto configuration changes.
