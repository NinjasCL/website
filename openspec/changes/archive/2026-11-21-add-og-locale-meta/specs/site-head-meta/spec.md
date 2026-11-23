# Spec Delta

## MODIFIED Requirements

### Requirement: SEO and social fields mirror each page
Every page's head SHALL carry a single meta description (the page's own), the fixed site-level keywords, and Open Graph plus Twitter fields that mirror the page: `og:title`, `og:description`, `og:url`, and `og:locale` carry the page's title, description, canonical URL, and locale — alongside the fixed site-level `og:type` (website), `og:image`, `twitter:card` (summary_large_image), and `twitter:image`. `og:locale` is the site's `es_CL` on default pages and the variant's own locale from the site's language configuration on translated post pages.

#### Scenario: The home mirrors the site identity
- **WHEN** the home page is rendered
- **THEN** og:title, og:description, and og:url carry the site title, the site description, and the site URL, with their Twitter counterparts matching

#### Scenario: A post page mirrors the post
- **WHEN** a post page is rendered from the post template
- **THEN** og:title, og:description, and og:url carry the post's title, description, and post URL, and the page keeps exactly one meta description

#### Scenario: The not-found page mirrors its title
- **WHEN** the not-found page is rendered
- **THEN** og:title carries "404 — Ninjas.cl" and og:url carries the site's `404.html`

#### Scenario: Default pages carry the site locale
- **WHEN** the home page, a default-language post page, or the not-found page is rendered
- **THEN** og:locale carries the site's `es_CL`

#### Scenario: Translated variants carry their own locale
- **WHEN** a post's translated variant page is rendered
- **THEN** og:locale carries that variant's own locale from the site's language configuration
