# Spec Delta

## MODIFIED Requirements

### Requirement: Per-page masthead hero
The masthead SHALL render a hero area provided by the page, so hero content can differ between pages while the navbar stays shared.

#### Scenario: Home page hero
- **WHEN** the home page is rendered
- **THEN** the masthead hero shows the site logo, the site title with its "Software from 🇨🇱 with ❤️" tagline, and the description note, followed by the marquee
- **AND** no call-to-action links render in the hero

#### Scenario: Single post page hero
- **WHEN** a single post page is rendered
- **THEN** the masthead hero is a compact variant showing the site logo and the site title, without the tagline, description note, or marquee

#### Scenario: Not-found page hero
- **WHEN** the not-found page is rendered
- **THEN** the masthead renders the navbar alone, with no hero elements
