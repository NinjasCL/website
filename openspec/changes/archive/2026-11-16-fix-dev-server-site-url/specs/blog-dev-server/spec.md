# Spec Delta

## MODIFIED Requirements

### Requirement: Build and dev server share configuration
The system SHALL use the same blogatto site structure and content configuration for production builds and for the development server, except that each build uses its environment-appropriate site URL.

#### Scenario: Build uses shared configuration
- **WHEN** the production build entrypoint runs
- **THEN** it generates the site using the same output directory, static directory, post paths, routes, templates, and content as the dev server, with the production site URL

#### Scenario: Dev build uses local site URL
- **WHEN** the development server rebuilds the site
- **THEN** generated absolute URLs use `http://127.0.0.1:3000/`

#### Scenario: Production build uses production site URL
- **WHEN** the production build runs
- **THEN** generated absolute URLs use `https://ninjas.cl/`
