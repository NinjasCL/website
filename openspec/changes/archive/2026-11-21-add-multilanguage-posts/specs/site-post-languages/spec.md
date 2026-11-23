# Spec Delta

## Purpose

Defines the site's post languages: the default human-written Spanish, the machine-translated English and Japanese variants, how a post page presents its language options, and the translation and staleness warnings translated variants carry.

## ADDED Requirements

### Requirement: Site language configuration
The site SHALL declare its post languages: Spanish as the default, human-written language (the plain `index.djot` source) plus English and Japanese as machine-translated languages (the `index-{lang}.djot` sources), and the home page SHALL list default-language posts only so translated variants do not duplicate its entries.

#### Scenario: The shipped post carries its variants
- **WHEN** the content directory is inspected
- **THEN** the shipped post ships its default Spanish source beside English and Japanese djot variants, each variant an independent post with its own translated frontmatter and the same slug

#### Scenario: The home page lists default-language posts only
- **WHEN** the home page is rendered with a post that has translated variants
- **THEN** the entries list the default-language variant once, with no translated duplicate

### Requirement: Language options on post pages
Every post page with more than one language variant SHALL render a language options row linking the post's sibling variants, with the current language marked as the current page.

#### Scenario: Options on a multi-variant post
- **WHEN** a post page is rendered for a post with default, English, and Japanese variants
- **THEN** the options row shows one entry per variant, in the site's declared language order
- **AND** the current language's entry is plain text marked as the current page, while every other entry links to its variant's URL

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
Every post whose date is older than 365 days from the current day at render time SHALL render the staleness warning "Este contenido puede estar desactualizado ya que han pasado más de {x} días desde su publicación", with `{x}` the elapsed days, on every one of its language variants.

#### Scenario: Post older than a year warns with the day count
- **WHEN** a post dated more than 365 days before the render's current day is rendered
- **THEN** the staleness warning renders with the elapsed day count in place of `{x}`

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
