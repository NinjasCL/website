# Spec Delta

## Purpose

Define the core static blog/site generation behavior for Ninjas.cl using blogatto so the repository can produce a working site from configured content, templates, and routes.

## ADDED Requirements

### Requirement: Site build generates static output
The system SHALL generate the static site into the configured output directory when invoked through the project entrypoint using the Ninjas.cl blogatto configuration.

#### Scenario: Successful build
- **WHEN** the project build is run with a valid Ninjas.cl site configuration, post source, and required content
- **THEN** the configured output directory contains the generated site pages without reporting a build error

### Requirement: Site configuration reflects Ninjas.cl identity
The system SHALL configure site generation with the Ninjas.cl base URL, title, description, and Spanish (Chile) default language context.

#### Scenario: Generated pages use configured site identity
- **WHEN** the site is generated from the Ninjas.cl configuration
- **THEN** generated pages reflect the configured site URL context, site title, site description, and default language context

### Requirement: Home route lists available posts
The system SHALL expose a home route that renders a page listing available blog posts from the configured post source.

#### Scenario: Home page includes a published post
- **WHEN** the site is generated with at least one valid post in the configured post source
- **THEN** the generated home page includes an entry for that post with navigation to its post page

### Requirement: Post content is rendered as pages
The system SHALL load Markdown posts with required frontmatter from the configured post source and render each post as a site page using the configured post template and routing convention.

#### Scenario: Post page is generated from source content
- **WHEN** the site is generated with a valid post containing required frontmatter and body content
- **THEN** a corresponding post page is generated at the configured route and includes the post's rendered content and metadata defined by the template

### Requirement: Build uses project content and asset conventions
The system SHALL read posts from the configured content directory and copy static assets from the configured static directory as part of core site generation.

#### Scenario: Static assets are included in output
- **WHEN** the site is generated with files present in the configured static asset directory
- **THEN** those assets are available in the generated site output according to the configured static asset handling
