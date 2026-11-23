# Spec Delta

## MODIFIED Requirements

### Requirement: Every home links its sibling variants
Every home page SHALL render the posts' language options row, linking the four home URLs — the current language as plain text marked the current page, the others as links — labeled in the page's language ("Idiomas:" on Spanish, "Languages:" on English, "言語:" on Japanese, "Idiomas:" on Portuguese), the label led by the site's languages icon, so each home is reachable from the others.

#### Scenario: The Spanish home links the translated homes
- **WHEN** the default home page is rendered
- **THEN** its options row reads "Idiomas:" and links `/en/`, `/ja/`, and `/pt/` with the language configuration's names, the "Español" entry plain text marked the current page

#### Scenario: A translated home links back
- **WHEN** a translated home page is rendered
- **THEN** its options row is labeled in its own language, its own language renders as the plain-text current entry, and the row links the default home at `/`

#### Scenario: The row's label leads with the languages icon
- **WHEN** a home page renders its language options row
- **THEN** the label leads with the languages icon (`/icons/win95/Intl101_32x32_4.png`) through the shared inline presentation — decorative, empty alt — ahead of the page language's label word
