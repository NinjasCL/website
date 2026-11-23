# Spec Delta

## MODIFIED Requirements

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
