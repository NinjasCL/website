# site-section-spacing Specification

## Purpose

Defines the vertical clearance contract for the home page's section panels: the top margin every section keeps above the content that precedes it, so each section reads as a separate block instead of sitting flush against the one above.

## Requirements

### Requirement: Home section panels keep top clearance
The home page's section panels — about ("Sobre nosotros"), posts, projects, books, games, and the untitled banner panel — SHALL carry a 32px (`--rs-space-5`) top margin above the content that precedes them, on every home page language.

#### Scenario: Clearance in the stylesheet
- **WHEN** a home page's shipped stylesheet is inspected
- **THEN** the rule covering the home section panels sets a top margin of 32px (`--rs-space-5`)

#### Scenario: Sections read as separate blocks
- **WHEN** a visitor scrolls the home page from one section into the next
- **THEN** the incoming section's panel — its floating title included — sits visibly clear of the previous panel, not nearly touching it

#### Scenario: Banner wall shares the clearance
- **WHEN** the games section is followed by the untitled banner panel
- **THEN** the banner panel carries the same top clearance as the titled sections

#### Scenario: Other pages' panels unchanged
- **WHEN** a single post page or the 404 page is viewed
- **THEN** their panels keep retrostrap's default panel spacing, unaffected by the home sections' clearance rule

### Requirement: Blog panels carry a small left inset
The home page's posts panel (`#posts`) and the blog index's title panel
(`#blog`) SHALL sit 8px (`--rs-space-3`) in from the page container's left edge,
in addition to their existing top clearance.

#### Scenario: Inset in the stylesheet
- **WHEN** a home page or blog index page's shipped stylesheet is inspected
- **THEN** the rules covering `#posts` and `#blog` set a left margin of 8px (`--rs-space-3`)

#### Scenario: Posts panel inset
- **WHEN** a visitor opens the home page in any language
- **THEN** the "Entradas del blog" panel — its floating title included — sits slightly right of the panels above it

#### Scenario: Blog index panel inset
- **WHEN** a visitor opens a blog index page
- **THEN** the title panel sits slightly right of the page container's left edge

#### Scenario: Other panels unchanged
- **WHEN** the other home sections or a single post page are viewed
- **THEN** their panels keep their existing horizontal alignment
