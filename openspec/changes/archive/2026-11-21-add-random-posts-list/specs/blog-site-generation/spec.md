# Spec Delta

## ADDED Requirements

### Requirement: Post pages list random other entries
Every post page with entries beyond its navigation SHALL render, before the footer, a list of up to five entries picked at random at build time from the default-language catalog — the current post and its navigation neighbors (the previous and next entries) excluded — each resolved to the reader's current language variant.

#### Scenario: A large catalog lists five random entries
- **WHEN** a post is rendered with more than five entries left after excluding the current post and its neighbors
- **THEN** the list shows exactly five of them — a fresh random set each build — and never the current, previous, or next post

#### Scenario: A small catalog lists the remaining others
- **WHEN** fewer than five entries remain after the exclusions
- **THEN** the list shows every one of them

#### Scenario: The list stays in the reader's language
- **WHEN** a translated variant page is rendered
- **THEN** every listed entry links to the same language's variant

#### Scenario: Nothing left beyond the navigation renders no list
- **WHEN** a site's every other entry is the page's navigation neighbor or the page itself
- **THEN** no random-entries section renders
