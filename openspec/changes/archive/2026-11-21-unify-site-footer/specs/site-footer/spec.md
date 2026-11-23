# Spec Delta

## MODIFIED Requirements

### Requirement: The footer renders the copyright line and the back-to-top link
The site footer SHALL render on every generated page — the home page, single post pages, and the not-found page — carrying the copyright line ("Copyright 🥷🏽 Ninjas.cl © 2015–" plus the current year, " · All rights and lefts preserved") and the "^ volver arriba ^" back-to-top link targeting the `#masthead` anchor.

#### Scenario: Copyright and back-to-top render
- **WHEN** the home page is rendered
- **THEN** the footer carries the copyright line with its 🥷🏽 emoji
- **AND** the "^ volver arriba ^" link points at the masthead anchor

#### Scenario: Single post page footer
- **WHEN** a single post page is rendered
- **THEN** it closes with the same site footer — the copyright line and the "^ volver arriba ^" back-to-top link
- **AND** its former "Ninjas.cl — Desde 2015" footer line no longer exists

#### Scenario: The copyright year is always the current year
- **WHEN** the site is rendered in a given year
- **THEN** the copyright line's end year is that current year, never a stale hardcoded one

#### Scenario: The footer element keeps its identity
- **WHEN** the generated home page's markup is inspected
- **THEN** the footer element keeps its `rs-footer` class

### Requirement: The footer's decorative blocks are removed
The site footer SHALL NOT render its former decorative blocks: the Chile WebRing bar (its name and the "Ir a un sitio aleatorio" link), the "Desde 2015 · Hecho a mano en Chile 🇨🇱" line, and the badge buttons ("source code", "written by human").

#### Scenario: Webring bar gone
- **WHEN** the generated home page's markup is inspected
- **THEN** neither "Chile WebRing" nor "Ir a un sitio aleatorio" appears, and no link to webri.ng remains anywhere on the page

#### Scenario: Since-2015 line gone from the home footer
- **WHEN** the generated pages' markup is inspected
- **THEN** the "Desde 2015 · Hecho a mano en Chile 🇨🇱" line does not appear
- **AND** the single post page's former "Ninjas.cl — Desde 2015" footer line does not appear either

#### Scenario: Badge buttons gone
- **WHEN** the generated home page's markup is inspected
- **THEN** no "source code" or "written by human" badge renders, and no `rs-button88` element remains anywhere on the page
