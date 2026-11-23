# Spec Delta

## ADDED Requirements

### Requirement: The build generates a sitemap
The configured build SHALL generate a `sitemap.xml` at the output root listing every static route and every post URL at the site's absolute URLs, so search engines can discover the site's pages.

#### Scenario: Sitemap lists the routes and posts
- **WHEN** the site is generated with at least one post
- **THEN** the output contains `sitemap.xml` whose entries include the home route and the post's URL at the site's absolute URL

### Requirement: The build generates robots.txt
The configured build SHALL generate a `robots.txt` at the output root that points crawlers at the sitemap and allows all of them site-wide.

#### Scenario: Robots points at the sitemap and allows all
- **WHEN** the generated site's `robots.txt` is inspected
- **THEN** it carries the sitemap pointer at the site's absolute sitemap URL
- **AND** a `User-agent: *` policy allowing `/`

### Requirement: The build generates Atom and RSS feeds
The configured build SHALL generate an Atom 1.0 feed (`atom.xml`) and an RSS 2.0 feed (`rss.xml`) from the blog posts, both carrying the site's identity — the Ninjas.cl title and the Spanish site description — with `@CLSource` as the Atom author and the es-CL language on the RSS channel.

#### Scenario: Both feeds ship with the site identity
- **WHEN** the site is generated with at least one post
- **THEN** the output contains `atom.xml` and `rss.xml`, each carrying the site title and description and the post as an entry

#### Scenario: The feeds regenerate on every build
- **WHEN** the build runs again (including the dev build the live server re-runs)
- **THEN** both feeds are rewritten, the Atom feed's updated stamp reflecting the build time
