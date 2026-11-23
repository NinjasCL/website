# Spec Delta

## MODIFIED Requirements

### Requirement: Per-page masthead hero
The masthead SHALL render a hero area provided by the page, so hero content can differ between pages while the navbar stays shared. The home hero's description note and tagline SHALL render in the home's language — the Spanish description and the "Software de 🇨🇱 con ❤️" tagline on the default home (revised 2026-11-22: the owner translated the tagline from the former English "Software from 🇨🇱 with ❤️", which remains the English home's own tagline), the translated description and tagline on the translated homes — beside the verbatim "忍者 開発者 Ninjas.cl" brand title.

#### Scenario: Home page hero
- **WHEN** a home page is rendered
- **THEN** the masthead hero shows the site logo, the site title with its tagline, and the description note in the home's language, followed by the marquee
- **AND** no call-to-action links render in the hero

#### Scenario: Single post page hero
- **WHEN** a single post page is rendered from the post template
- **THEN** the masthead renders the navbar with no hero elements — no site logo image, no "忍者 開発者 Ninjas.cl" site title text, and no marquee
- **AND** the masthead's whole area is filled by the post's cover background instead

#### Scenario: Not-found page hero
- **WHEN** the not-found page is rendered
- **THEN** the masthead renders the navbar alone, with no hero elements
