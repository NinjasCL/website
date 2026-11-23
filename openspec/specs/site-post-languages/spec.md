# site-post-languages Specification

## Purpose

Defines the site's post languages: the default human-written Spanish, the machine-translated English and Japanese variants, how a post page presents its language options, and the translation and staleness warnings translated variants carry.

## Requirements

### Requirement: Site language configuration
The site SHALL declare its post languages — Spanish as the default, human-written language (the plain `index.djot` source) plus English, Japanese, and Portuguese (Brazil) as machine-translated languages (the `index-{lang}.djot` sources) — every post SHALL ship a variant for each declared language, and the home page SHALL list default-language posts only so translated variants do not duplicate its entries.

#### Scenario: The shipped post carries its variants
- **WHEN** the content directory is inspected
- **THEN** every post ships its default Spanish source beside English, Japanese, and Portuguese djot variants — the Spanish source human-written, the rest machine translations — each variant an independent post with its own translated frontmatter and the same slug

#### Scenario: The home page lists default-language posts only
- **WHEN** the home page is rendered with a post that has translated variants
- **THEN** the entries list the default-language variant once, with no translated duplicate

### Requirement: Language display names omit the country
Every declared language's display name SHALL be its plain language name without a country qualifier — "Español", "English", "日本語", and "Português" — wherever the site renders a language options row: on post pages, home pages, and blog index pages. The Portuguese entry SHALL read "Português" with no "(Brasil)" suffix, while its route code, `lang` value, and `og:locale` remain unchanged.

#### Scenario: Portuguese options entry drops the country
- **WHEN** any page renders its language options row
- **THEN** the Portuguese entry reads "Português"
- **AND** no "Português (Brasil)" label appears anywhere in the generated site

#### Scenario: Other language names stay unchanged
- **WHEN** a language options row renders
- **THEN** the Spanish, English, and Japanese entries read "Español", "English", and "日本語"

#### Scenario: Portuguese locale fields stay intact
- **WHEN** a Portuguese page is rendered
- **THEN** its route stays `/blog/pt/…` or `/pt/`, its `lang` attribute stays `pt`, and its `og:locale` stays `pt_BR`

### Requirement: Language options on post pages
Every post page with more than one language variant SHALL render a language options row linking the post's sibling variants, with the current language marked as the current page, and the row's label SHALL be the page language's own word for languages, from the site's language configuration, led by the site's languages icon.

#### Scenario: Options on a multi-variant post
- **WHEN** a post page is rendered for a post with default, English, and Japanese variants
- **THEN** the options row shows one entry per variant, in the site's declared language order
- **AND** the current language's entry is plain text marked as the current page, while every other entry links to its variant's URL

#### Scenario: The row's label follows the page's language
- **WHEN** a post page is rendered in a given language
- **THEN** the options row is labeled with that language's own word for languages from the site's language configuration — "Idiomas" on the Spanish and Portuguese (Brazil) pages, "Languages" on English, "言語" on Japanese

#### Scenario: The row's label leads with the languages icon
- **WHEN** a post page renders its language options row
- **THEN** the label leads with the languages icon (`/icons/win95/Intl101_32x32_4.png`) through the shared inline presentation — decorative, empty alt — ahead of the page language's label word

#### Scenario: No options on a single-variant post
- **WHEN** a post page is rendered for a post with no translated variants
- **THEN** no language options row renders

### Requirement: Machine-translated warning on non-Spanish variants
Every non-Spanish post variant SHALL render a warning stating that the page is a machine translation of the original Spanish post, worded in that variant's language.

#### Scenario: English variant warns in English
- **WHEN** a post's English variant page is rendered
- **THEN** a machine-translated warning renders in English

#### Scenario: Japanese variant warns in Japanese
- **WHEN** a post's Japanese variant page is rendered
- **THEN** a machine-translated warning renders in Japanese

#### Scenario: The default variant carries no translation warning
- **WHEN** a post's default Spanish page is rendered
- **THEN** no machine-translated warning renders

### Requirement: Staleness warning on old posts
Every post whose date is older than 365 days from the current day at render time SHALL render a staleness warning on every one of its language variants, worded in the rendered variant's language from the site's language configuration, with the elapsed days in place of the warning's day-count placeholder.

#### Scenario: Post older than a year warns with the day count
- **WHEN** a post dated more than 365 days before the render's current day is rendered
- **THEN** the staleness warning renders in the page's language with the elapsed day count in place of the day-count placeholder

#### Scenario: Translated variants warn in their own language
- **WHEN** a stale post's English, Japanese, or Portuguese page is rendered
- **THEN** the staleness warning is worded in that language, with no Spanish wording on the page

#### Scenario: Fresh post carries no staleness warning
- **WHEN** a post dated within the last 365 days is rendered
- **THEN** no staleness warning renders

### Requirement: Variant-aware page language
The post page's `lang` attribute SHALL follow the variant being rendered: the site's default language value for the Spanish variant and the variant's own language code for translated variants.

#### Scenario: Default variant keeps the site language
- **WHEN** a post's default Spanish page is rendered
- **THEN** the page's `lang` attribute is the site's `es-CL` value

#### Scenario: Translated variants carry their language code
- **WHEN** a post's English or Japanese variant page is rendered
- **THEN** the page's `lang` attribute is `en` or `ja` respectively

### Requirement: Migrated English-origin posts
Posts from the old catalog that were originally written in English SHALL migrate with their Spanish translation as the default variant — carrying no translation warning — and their original English content as the English variant, carrying the standard machine-translated warning like every non-default language.

#### Scenario: The migrated Advent of Code post follows the rule
- **WHEN** the migrated post's default Spanish page is rendered
- **THEN** it carries no machine-translated warning and lists the English variant in its language options row
- **WHEN** the migrated post's English page is rendered
- **THEN** it carries the machine-translated warning in English and links the Spanish default back
