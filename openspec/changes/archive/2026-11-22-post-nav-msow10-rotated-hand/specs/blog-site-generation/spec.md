# Spec Delta

## MODIFIED Requirements

### Requirement: Post pages navigate to adjacent entries
Every post page with neighbors SHALL render navigation to its adjacent entries in the newest-first post list — "Anterior" linking the previous entry (the newer post) and "Siguiente" linking the next entry (the older post) — each rendered as the site's large retrostrap icon button with its direction icon, and each targeting the neighbor's variant in the page's own language. The direction icons SHALL be the Win95 `Msow10_32x32_4.png` hand, which points up in the pack: the "Anterior" button rotates it a quarter turn counter-clockwise to point left, and the "Siguiente" button rotates it a quarter turn clockwise to point right.

#### Scenario: A middle post links both neighbors
- **WHEN** a post with a newer and an older neighbor is rendered
- **THEN** the page renders both icon buttons, each carrying its neighbor's title and URL — the counter-clockwise-rotated "Anterior" hand pointing left and the clockwise-rotated "Siguiente" hand pointing right

#### Scenario: The end posts link their single neighbor
- **WHEN** the newest or the oldest post is rendered
- **THEN** the page renders only the one button that has a neighbor — "Siguiente" for the newest, "Anterior" for the oldest

#### Scenario: Navigation stays in the reader's language
- **WHEN** a translated variant page is rendered
- **THEN** its navigation buttons target the same language's variant of the neighbors

#### Scenario: A lone post renders no navigation
- **WHEN** a site with a single post renders its page
- **THEN** no navigation element renders
