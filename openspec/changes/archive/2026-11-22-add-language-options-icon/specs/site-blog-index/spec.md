# Spec Delta

## MODIFIED Requirements

### Requirement: Index pages link their sibling language versions
Every index page — the default and each language version — SHALL carry a language options row: the current language as plain text marked as the current page, every other language linking its index's same page number, in the site's declared language order, the row's label led by the site's languages icon.

#### Scenario: The default index links the language indexes
- **WHEN** a visitor opens `/blog/page/1/`
- **THEN** the options row links `/blog/en/page/1/`, `/blog/ja/page/1/`, and `/blog/pt/page/1/`
- **AND** Español renders as the current page, not a link

#### Scenario: A language index links back to the default
- **WHEN** a visitor opens `/blog/en/page/2/`
- **THEN** the options row links the default `/blog/page/2/` and the Japanese and Portuguese second pages
- **AND** English renders as the current page, not a link

#### Scenario: The row's label leads with the languages icon
- **WHEN** an index page renders its language options row
- **THEN** the label leads with the languages icon (`/icons/win95/Intl101_32x32_4.png`) through the shared inline presentation — decorative, empty alt — ahead of the row's label word
