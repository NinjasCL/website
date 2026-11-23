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
- **THEN** the masthead renders the navbar with no hero elements — no site logo image, no "忍者 開発者 Ninjas.cl" site title text, and no marquee
- **AND** the masthead's whole area is filled by the post's cover background instead

#### Scenario: Not-found page hero
- **WHEN** the not-found page is rendered
- **THEN** the masthead renders the navbar alone, with no hero elements

## ADDED Requirements

### Requirement: Post masthead cover background
The single post masthead SHALL fill its entire area with a cover background image instead of hero content.

#### Scenario: Cover image from the post frontmatter
- **WHEN** a post that declares a `featured_image` frontmatter value is rendered
- **THEN** the masthead carries that image as its background, sized and positioned to cover the whole masthead area

#### Scenario: Default cover image
- **WHEN** a post that declares no `featured_image` frontmatter value is rendered
- **THEN** the masthead carries the site's Ninjas logo image (`/img/Ninjas.png`) as its cover background

#### Scenario: Only the navbar rides the cover
- **WHEN** a single post masthead is rendered
- **THEN** the shared navbar renders over the cover background
- **AND** no other content renders inside the masthead
