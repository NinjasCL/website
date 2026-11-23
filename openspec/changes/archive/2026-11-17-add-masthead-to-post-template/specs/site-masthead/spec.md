# Spec Delta

## Purpose

Defines the site masthead: a global primary navbar rendered on every generated page, plus a hero area whose content can change per page.

## ADDED Requirements

### Requirement: Masthead on every page
The site SHALL render the masthead — the header containing the primary navbar — on every generated page, including single post pages, with the `masthead` anchor id that in-page "back to top" links target.

#### Scenario: Home page includes the masthead
- **WHEN** the home page is rendered
- **THEN** the page includes the masthead with the primary navbar and the `masthead` anchor id

#### Scenario: Single post page includes the masthead
- **WHEN** a single post page is rendered from the post template
- **THEN** the page includes the same primary navbar and the `masthead` anchor id, instead of a back-link-only header

### Requirement: Navbar links resolve from any page
The navbar SHALL keep its home page section links functional from every page, and SHALL only mark the home link as the current page on the home page.

#### Scenario: Section links from a post page
- **WHEN** the navbar is rendered on a page other than the home page
- **THEN** links that target home page sections point to the home page (for example `/#projects`) instead of in-page anchors
- **AND** the "Inicio" link does not carry the current-page marker (`aria-current`)

#### Scenario: Section links on the home page
- **WHEN** the navbar is rendered on the home page
- **THEN** the section links are in-page anchors (for example `#projects`)
- **AND** the "Inicio" link carries the current-page marker (`aria-current`)

### Requirement: Per-page masthead hero
The masthead SHALL render a hero area provided by the page, so hero content can differ between pages while the navbar stays shared.

#### Scenario: Home page hero
- **WHEN** the home page is rendered
- **THEN** the masthead hero shows the site logo, site title, description note, and call-to-action links, followed by the marquee

#### Scenario: Single post page hero
- **WHEN** a single post page is rendered
- **THEN** the masthead hero is a compact variant showing the site logo and site title, without the description note, call-to-action links, or marquee
