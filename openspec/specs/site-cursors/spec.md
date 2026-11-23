# site-cursors Specification

## Purpose

Defines the site's retro cursor chrome: the cursor pack served from `/cursors/` and applied by the shipped stylesheet — the arrow cursor as the page default and the hand cursor over interactive controls, with disabled controls falling back to the arrow.

## Requirements

### Requirement: The page chrome uses the retro cursor pack
The site's pages SHALL point with the retro cursor pack from the site's own static assets: the arrow cursor as the page-wide default and the hand cursor over interactive controls (links, buttons, summaries, labels, and role="button" elements), with disabled controls falling back to the custom arrow instead of the system one.

#### Scenario: Arrow cursor by default
- **WHEN** the shipped stylesheet is inspected
- **THEN** the page's default cursor points at the arrow cursor served from `/cursors/arrow.cur`

#### Scenario: Hand cursor on interactive controls
- **WHEN** the shipped stylesheet is inspected
- **THEN** interactive controls point with the hand cursor served from `/cursors/hand.cur`

#### Scenario: Disabled controls fall back to the arrow
- **WHEN** the shipped stylesheet is inspected
- **THEN** disabled interactive controls point with the arrow cursor rather than the hand

#### Scenario: Cursor assets ship with the site
- **WHEN** the site is generated
- **THEN** the cursor files from the configured static asset directory are included in the generated site output
