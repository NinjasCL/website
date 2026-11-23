# Spec Delta

## MODIFIED Requirements

### Requirement: Post content is rendered as pages
The system SHALL load djot posts with required frontmatter from the configured post source and render each post as a site page using the configured post template and routing convention.

#### Scenario: Post page is generated from source content
- **WHEN** the site is generated with a valid post containing required frontmatter and body content
- **THEN** a corresponding post page is generated at the configured route and includes the post's rendered content and metadata defined by the template

## ADDED Requirements

### Requirement: Blog content is written in djot
The site's content syntax SHALL be djot: every post under the configured content directory is a djot source file (`.djot` or `.dj`), and markdown, asciidoc, or any other format SHALL be converted to djot rather than added — the content directory holds no non-djot post sources.

#### Scenario: The shipped post is djot
- **WHEN** the content directory is inspected
- **THEN** the post's source is a djot file whose body uses djot syntax, and no markdown source remains

#### Scenario: Djot renders through the native engine
- **WHEN** the site is generated
- **THEN** the post's djot body — headings, links, and single-asterisk strong — renders via blogatto's djot source format

#### Scenario: The content references ship in the repo
- **WHEN** a contributor needs the djot syntax or the engine's documentation
- **THEN** the djot reference is available at `examples/djot/doc` — the cheatsheet, the full syntax guide, and the quickstart for markdown users
- **AND** the blogatto documentation is available at `examples/blogatto/docs`
