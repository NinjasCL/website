# Spec Delta

## MODIFIED Requirements

### Requirement: The blog URL redirects to the first index page

The site SHALL resolve every blog landing URL — `/blog/` and `/blog/{lang}/` for English, Japanese, and Portuguese — to that language's first index page. Where the host honors the shipped server-side redirect rules, the response SHALL be an HTTP 301 to `/blog/page/1/` or `/blog/{lang}/page/1/`; where it does not, the generated landing page SHALL immediately redirect with a meta refresh and carry a plain link to the same target.

#### Scenario: Blog URL resolves
- **WHEN** a visitor opens `/blog/`
- **THEN** the page redirects to `/blog/page/1/`

#### Scenario: Server rule resolves the Spanish landing URL
- **WHEN** a visitor requests `/blog` or `/blog/` from a host that applies the shipped redirect rules
- **THEN** the server responds with HTTP 301 and a `Location` of `/blog/page/1/`

#### Scenario: Server rule resolves each translated landing URL
- **WHEN** a visitor requests `/blog/en`, `/blog/ja`, or `/blog/pt` — with or without a trailing slash — from a host that applies the shipped redirect rules
- **THEN** the server responds with HTTP 301 and a `Location` of that language's `/blog/{lang}/page/1/`

#### Scenario: Hosts without the rules still resolve every landing URL
- **WHEN** a host does not apply the shipped redirect rules and a visitor opens any blog landing URL
- **THEN** the generated page immediately refreshes to the same language's first index page
- **AND** the page carries a plain link to that target

### Requirement: Index pages are discoverable

The generated sitemap SHALL include every `/blog/page/{n}/` and `/blog/{lang}/page/{n}/` index route and SHALL NOT include any blog landing redirect route.

#### Scenario: Sitemap lists the index pages
- **WHEN** the sitemap is generated
- **THEN** every default and language index page route appears in it
- **AND** no `/blog/` or `/blog/{lang}/` landing route appears

## ADDED Requirements

### Requirement: Blog landing fallbacks speak the page's language

Each generated blog landing fallback SHALL declare the language of the index it points to and render its title, meta description, and visible link label in that language.

#### Scenario: Spanish landing fallback
- **WHEN** a host without the shipped redirect rules serves `/blog/`
- **THEN** the page declares `es-CL` and carries the Spanish title, description, and `Blog` link to `/blog/page/1/`

#### Scenario: English landing fallback
- **WHEN** a host without the shipped redirect rules serves `/blog/en/`
- **THEN** the page declares `en` and carries the English description and `Blog` link to `/blog/en/page/1/`

#### Scenario: Japanese landing fallback
- **WHEN** a host without the shipped redirect rules serves `/blog/ja/`
- **THEN** the page declares `ja` and carries the Japanese title `ブログ`, description, and link to `/blog/ja/page/1/`

#### Scenario: Portuguese landing fallback
- **WHEN** a host without the shipped redirect rules serves `/blog/pt/`
- **THEN** the page declares `pt` and carries the Portuguese description and `Blog` link to `/blog/pt/page/1/`
