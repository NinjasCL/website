# Spec Delta

## MODIFIED Requirements

### Requirement: Site configuration reflects Ninjas.cl identity
The production build SHALL configure site generation with `https://ninjas.cl/` as the base URL, plus the Ninjas.cl title, description, and Spanish (Chile) default language context.

#### Scenario: Generated pages use configured site identity
- **WHEN** the production site is generated from the Ninjas.cl configuration
- **THEN** generated pages reflect `https://ninjas.cl/` as the site URL context, the Ninjas.cl site title, site description, and default language context

#### Scenario: Production absolute URLs use Ninjas.cl
- **WHEN** a production page links to another site page
- **THEN** the generated absolute URL uses `https://ninjas.cl/`
