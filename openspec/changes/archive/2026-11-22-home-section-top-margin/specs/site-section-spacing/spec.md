# Spec Delta

## Purpose

Defines the vertical clearance contract for the home page's section panels: the top margin every section keeps above the content that precedes it, so each section reads as a separate block instead of sitting flush against the one above.

## ADDED Requirements

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
