# Spec Delta

## Purpose

Defines the head-meta suite rendered on every generated page: the identity chrome (generator, author link, icons, manifest, robots, usage-rights), SEO and social fields that mirror each page's title, description, and URL, the JSON-LD structured-data block, and the static assets that serve them.

## ADDED Requirements

### Requirement: Every page carries the head identity chrome
Every generated page's head SHALL carry the site's identity chrome: the generator credit (blogatto), the author link to `humans.txt`, the icon links — apple-touch-icon (180×180), favicon 32×32 and 16×16 — the site webmanifest, the robots directive (`index,follow`), and the usage-rights declaration (`CC-BY-NC-ND`).

#### Scenario: Chrome on every page
- **WHEN** the home page, a post page, and the not-found page are rendered
- **THEN** each head carries the generator meta, the humans.txt author link, the three icon links, the manifest link, the robots meta, and the usage-rights meta

### Requirement: SEO and social fields mirror each page
Every page's head SHALL carry a single meta description (the page's own), the fixed site-level keywords, and Open Graph plus Twitter fields that mirror the page: `og:title`, `og:description`, `og:url`, `twitter:title`, `twitter:description`, and `twitter:url` carry the page's title, description, and canonical URL — alongside the fixed site-level `og:type` (website), `og:image`, `twitter:card` (summary_large_image), and `twitter:image`.

#### Scenario: The home mirrors the site identity
- **WHEN** the home page is rendered
- **THEN** og:title, og:description, and og:url carry the site title, the site description, and the site URL, with their Twitter counterparts matching

#### Scenario: A post page mirrors the post
- **WHEN** a post page is rendered from the post template
- **THEN** og:title, og:description, and og:url carry the post's title, description, and post URL, and the page keeps exactly one meta description

#### Scenario: The not-found page mirrors its title
- **WHEN** the not-found page is rendered
- **THEN** og:title carries "404 — Ninjas.cl" and og:url carries the site's `404.html`

### Requirement: Every page carries the structured-data block
Every page's head SHALL carry a JSON-LD script (type `application/ld+json`) with the site-level BlogPosting: headline "Ninjas Chile (Ninjas.cl)", the site description, the 2026-11-21 relaunch date, `@CLSource` as author, the og image, and Ninjas.cl as publisher with its logo — served unescaped so the JSON parses.

#### Scenario: The structured-data script ships unescaped
- **WHEN** any generated page's markup is inspected
- **THEN** the ld+json script carries the BlogPosting fields as parseable JSON, with the site description unescaped inside it

### Requirement: The head's assets ship with the site
The head's referenced assets SHALL ship from the site's own static directory: apple-touch-icon.png, favicon-32x32.png, favicon-16x16.png, site.webmanifest, humans.txt, and logo_og.png are included in the generated site output.

#### Scenario: Referenced assets resolve
- **WHEN** the site is generated
- **THEN** every head-referenced asset file is present in the output and resolves at its linked path
