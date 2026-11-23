# Spec Delta

## ADDED Requirements

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
