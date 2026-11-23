# Spec Delta

## ADDED Requirements

### Requirement: Post pages navigate to adjacent entries
Every post page with neighbors SHALL render navigation to its adjacent entries in the newest-first post list — "Anterior" linking the previous entry (the newer post) and "Siguiente" linking the next entry (the older post) — each link targeting the neighbor's variant in the page's own language.

#### Scenario: A middle post links both neighbors
- **WHEN** a post with a newer and an older neighbor is rendered
- **THEN** the page renders both links, each carrying its neighbor's title and URL

#### Scenario: The end posts link their single neighbor
- **WHEN** the newest or the oldest post is rendered
- **THEN** the page renders only the one link that has a neighbor — "Siguiente" for the newest, "Anterior" for the oldest

#### Scenario: Navigation stays in the reader's language
- **WHEN** a translated variant page is rendered
- **THEN** its navigation links target the same language's variant of the neighbors

#### Scenario: A lone post renders no navigation
- **WHEN** a site with a single post renders its page
- **THEN** no navigation element renders
