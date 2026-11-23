# Spec Delta

## Purpose

Defines how the home page's "Proyectos" and "Libros" showcase images are served: from the site's own static assets under `/img/`, keeping those two sections free of remote image hosts.

## ADDED Requirements

### Requirement: Showcase images are served from the site's own assets
The home page's "Proyectos" and "Libros" showcase images SHALL be served from the site's own static assets under `/img/` — no remote image host in either section.

#### Scenario: Projects images resolve locally
- **WHEN** the home page is rendered
- **THEN** each "Proyectos" card image (Elixir Chile, Joy of ProcessWire, Proyecto Chaucha, Ninja Systems) loads from a local `/img/…` path

#### Scenario: Books images resolve locally
- **WHEN** the home page is rendered
- **THEN** each "Libros" card image (Super Club Net, Elixir Full Stack, Wren Libro, Las Aventuras de Quirquincho) loads from a local `/img/…` path

#### Scenario: No remote image hosts in proyectos or libros
- **WHEN** the generated home page's markup is inspected
- **THEN** the projects and books sections reference no remote image host: no `avatars.githubusercontent.com`, no `raw.githubusercontent.com/ElixirCL`, and no `ninjas.cl/covers`

### Requirement: Cover assets ship with the generated site
The four book covers SHALL be part of the site's static assets so the generated site serves them itself.

#### Scenario: Cover files present in the static assets
- **WHEN** the site's static asset directory is inspected
- **THEN** the four cover files (`superclubnet.jpg`, `elixir-fullstack.jpg`, `wren-libro.jpg`, `quirquincho.jpg`) exist as valid images

#### Scenario: Covers included in the site output
- **WHEN** the site is generated
- **THEN** the cover files from the configured static asset directory are included in the generated site output

### Requirement: Showcase presentation and alts are preserved
Switching the showcase images to local sources SHALL NOT change the showcase presentation: the card layout, the retrostrap figure sizing, and the image alt texts stay as they are.

#### Scenario: Alt texts unchanged
- **WHEN** the home page is rendered
- **THEN** each showcase image keeps its existing alt text (for example "Logo de Elixir Chile", "Portada de Super Club Net")

#### Scenario: Showcase figures keep their sizing
- **WHEN** the home page is rendered
- **THEN** the projects and books figures keep their existing showcase sizing, unaffected by the local image sources

### Requirement: Images outside proyectos and libros keep their sources
The switch to local assets SHALL apply only to the projects and books showcases; the games showcase images and the masthead hero logo SHALL keep their current sources.

#### Scenario: Games images unchanged
- **WHEN** the home page is rendered
- **THEN** the games card images keep their current remote URLs, unaffected by the projects and books switch

#### Scenario: Hero logo unchanged
- **WHEN** the home page or a post page is rendered
- **THEN** the masthead hero logo keeps its current source, unaffected by the showcase switch
