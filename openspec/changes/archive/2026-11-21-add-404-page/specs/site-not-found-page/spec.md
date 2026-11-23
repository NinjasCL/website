# Spec Delta

## Purpose

Defines the site's not-found (404) page: the Sad Mac image and the "otro castillo" message under the shared navbar and footer, shipped by the build as a root-level `404.html` so static hosts serve it as the site's error page.

## ADDED Requirements

### Requirement: The not-found page ships at the output root as 404.html
The site build SHALL write the not-found page to the output root as `404.html` — the static-host convention that serves the file for unknown URLs — regenerating it on every build, production and dev alike, so the live dev server's rebuilds keep it current.

#### Scenario: Built site carries the file
- **WHEN** the site build completes successfully
- **THEN** the output directory contains `404.html` at its root

#### Scenario: Dev builds regenerate it
- **WHEN** the dev build runs (including the live server's rebuild command)
- **THEN** `404.html` is rewritten alongside the regenerated output

### Requirement: The not-found page keeps the site chrome
The not-found page SHALL render the shared primary navbar and the site footer, treating itself as a non-home page: section links point at the home page (`/#…`) and the "Inicio" link carries no current-page marker.

#### Scenario: Navbar present
- **WHEN** the not-found page is rendered
- **THEN** it shows the primary navbar with its six icon links

#### Scenario: Non-home navbar semantics
- **WHEN** the not-found page's navbar is inspected
- **THEN** the section links are home-prefixed fragments and "Inicio" carries no `aria-current` marker

#### Scenario: Footer present
- **WHEN** the not-found page is rendered
- **THEN** it closes with the site footer — the copyright line and the "^ volver arriba ^" back-to-top link targeting the masthead anchor

### Requirement: The not-found page shows the Sad Mac and the message
The not-found page's content SHALL show the Sad Mac image served from the site's own static assets (`/img/sad_mac.png`) with the message "La página que buscabas está en otro castillo" as the page's main heading.

#### Scenario: Sad Mac image
- **WHEN** the not-found page is rendered
- **THEN** the page shows the Sad Mac image served from `/img/sad_mac.png`

#### Scenario: The message is the main heading
- **WHEN** the not-found page is rendered
- **THEN** the page's single main heading reads "La página que buscabas está en otro castillo"
