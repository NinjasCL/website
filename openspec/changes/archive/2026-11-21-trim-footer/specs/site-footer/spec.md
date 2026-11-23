# Spec Delta

## Purpose

Defines the home page footer's content after the trim: the copyright line and the back-to-top link, with the former decorative blocks — the Chile WebRing bar, the "Desde 2015" line, and the badge buttons — removed.

## ADDED Requirements

### Requirement: The footer renders the copyright line and the back-to-top link
The home page footer SHALL render the copyright line ("Copyright 🥷🏽 Ninjas.cl © 2015–2026 · All rights and lefts preserved") and the "^ volver arriba ^" back-to-top link targeting the `#masthead` anchor.

#### Scenario: Copyright and back-to-top render
- **WHEN** the home page is rendered
- **THEN** the footer carries the copyright line with its 🥷🏽 emoji
- **AND** the "^ volver arriba ^" link points at the masthead anchor

#### Scenario: The footer element keeps its identity
- **WHEN** the generated home page's markup is inspected
- **THEN** the footer element keeps its `rs-footer` class

### Requirement: The footer's decorative blocks are removed
The home page footer SHALL NOT render its former decorative blocks: the Chile WebRing bar (its name and the "Ir a un sitio aleatorio" link), the "Desde 2015 · Hecho a mano en Chile 🇨🇱" line, and the badge buttons ("source code", "written by human").

#### Scenario: Webring bar gone
- **WHEN** the generated home page's markup is inspected
- **THEN** neither "Chile WebRing" nor "Ir a un sitio aleatorio" appears, and no link to webri.ng remains anywhere on the page

#### Scenario: Since-2015 line gone from the home footer
- **WHEN** the generated home page's markup is inspected
- **THEN** the "Desde 2015 · Hecho a mano en Chile 🇨🇱" line does not appear
- **AND** the single post page keeps its own distinct footer line ("Ninjas.cl — Desde 2015")

#### Scenario: Badge buttons gone
- **WHEN** the generated home page's markup is inspected
- **THEN** no "source code" or "written by human" badge renders, and no `rs-button88` element remains anywhere on the page
