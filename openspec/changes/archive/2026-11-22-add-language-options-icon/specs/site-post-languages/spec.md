# Spec Delta

## MODIFIED Requirements

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
