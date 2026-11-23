# Spec Delta

## MODIFIED Requirements

### Requirement: SEO and social fields mirror each page
Every page's head SHALL carry a single meta description (the page's own), the fixed site-level keywords, and Open Graph plus Twitter fields that mirror the page: `og:title`, `og:description`, `og:url`, and `og:locale` carry the page's title, description, canonical URL, and locale — alongside the fixed site-level `og:type` (website), `og:image`, `twitter:card` (summary_large_image), and `twitter:image`. `og:locale` and the description follow the page's language: the site's `es_CL` and the Spanish site description on default pages — the default home, default-language post pages, and the not-found page — and each translated page's own locale and description from the site's language configuration, on both the translated post variants and the translated home pages.

#### Scenario: The home mirrors the site identity
- **WHEN** the default home page is rendered
- **THEN** og:title, og:description, and og:url carry the site title, the Spanish site description, and the site URL, with their Twitter counterparts matching

#### Scenario: A translated home mirrors its language
- **WHEN** a translated home page is rendered
- **THEN** og:title carries the site title, og:description and the meta description carry that language's translated site description, og:url carries that home's own URL, and og:locale carries that language's locale

#### Scenario: A post page mirrors the post
- **WHEN** a post page is rendered from the post template
- **THEN** og:title, og:description, and og:url carry the post's title, description, and post URL, and the page keeps exactly one meta description

#### Scenario: The not-found page mirrors its title
- **WHEN** the not-found page is rendered
- **THEN** og:title carries "404 — Ninjas.cl" and og:url carries the site's `404.html`

#### Scenario: Default pages carry the site locale
- **WHEN** the default home page, a default-language post page, or the not-found page is rendered
- **THEN** og:locale carries the site's `es_CL`

#### Scenario: Translated variants carry their own locale
- **WHEN** a post's translated variant page or a translated home page is rendered
- **THEN** og:locale carries that language's own locale from the site's language configuration
