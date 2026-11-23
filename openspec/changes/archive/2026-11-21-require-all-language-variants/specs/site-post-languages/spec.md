# Spec Delta

## MODIFIED Requirements

### Requirement: Site language configuration
The site SHALL declare its post languages — Spanish as the default, human-written language (the plain `index.djot` source) plus English, Japanese, and Portuguese (Brazil) as machine-translated languages (the `index-{lang}.djot` sources) — every post SHALL ship a variant for each declared language, and the home page SHALL list default-language posts only so translated variants do not duplicate its entries.

#### Scenario: The shipped post carries its variants
- **WHEN** the content directory is inspected
- **THEN** every post ships its default Spanish source beside English, Japanese, and Portuguese djot variants — the Spanish source human-written, the rest machine translations — each variant an independent post with its own translated frontmatter and the same slug

#### Scenario: The home page lists default-language posts only
- **WHEN** the home page is rendered with a post that has translated variants
- **THEN** the entries list the default-language variant once, with no translated duplicate
