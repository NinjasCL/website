# site-showcase-images Specification

## Purpose

Defines how the home page's showcase images are served: from the site's own static assets under `/img/` across the "Proyectos", "Libros", and "Juegos" sections, keeping every showcase section free of remote image hosts.

## Requirements

### Requirement: Showcase images are served from the site's own assets
The home page's showcase images — in the "Proyectos", "Libros", and "Juegos" sections — SHALL be served from the site's own static assets under `/img/` — no remote image host in any showcase section.

#### Scenario: Projects images resolve locally
- **WHEN** the home page is rendered
- **THEN** each "Proyectos" card image (Elixir Chile, Jasonelle, Joy of ProcessWire, Proyecto Chaucha, Ninjas.cl) loads from a local `/img/…` path

#### Scenario: Books images resolve locally
- **WHEN** the home page is rendered
- **THEN** each "Libros" card image (Conceptos de Sistemas Operativos, Robótica con Elixir, Super Club Net, Elixir Full Stack, Wren Libro, Las Aventuras de Quirquincho) loads from a local `/img/…` path

#### Scenario: No remote image hosts in proyectos or libros
- **WHEN** the generated home page's markup is inspected
- **THEN** the projects and books sections reference no remote image host: no `avatars.githubusercontent.com`, no `raw.githubusercontent.com/ElixirCL`, and no `ninjas.cl/covers`

#### Scenario: Games images resolve locally
- **WHEN** the home page is rendered
- **THEN** each "Juegos" card image (Rolplay Manual, Profesor Rossa, ¡Qué Chaucha!, Munsta Jump!) loads from a local `/img/…` path

#### Scenario: No remote image hosts in juegos
- **WHEN** the generated home page's markup is inspected
- **THEN** the games section references no remote image host: no `ninjas.cl/blog` path and no `raw.githubusercontent.com` capture

### Requirement: Cover assets ship with the generated site
The book covers SHALL be part of the site's static assets so the generated site serves them itself.

#### Scenario: Cover files present in the static assets
- **WHEN** the site's static asset directory is inspected
- **THEN** the cover files (`niklas-konig-1cTFuvI14J4-unsplash.jpg`, `emilipothese-FTfjMijq-Ws-unsplash.jpg`, `superclubnet.jpg`, `elixir-fullstack.jpg`, `wren-libro.jpg`, `quirquincho.jpg`) exist as valid images

#### Scenario: Covers included in the site output
- **WHEN** the site is generated
- **THEN** the cover files from the configured static asset directory are included in the generated site output

### Requirement: Game capture assets ship with the generated site
The four "Juegos" showcase images SHALL be part of the site's static assets so the generated site serves them itself: the Rolplay manual cover, the Profesor Rossa capture, the ¡Qué Chaucha! menu, and the Munsta Jump! capture — stored as downloaded, the animated GIFs included.

#### Scenario: Game capture files present in the static assets
- **WHEN** the site's static asset directory is inspected
- **THEN** the four game image files (`rolplay-manual.png`, `rossa.gif`, `quechaucha.jpg`, `munstajump.gif`) exist as valid images

#### Scenario: Game captures included in the site output
- **WHEN** the site is generated
- **THEN** the game image files from the configured static asset directory are included in the generated site output

### Requirement: Project logo assets ship with the generated site
The five "Proyectos" showcase images SHALL be part of the site's static assets so the generated site serves them itself: the Elixir Chile logo, the Jasonelle logo, the Joy of ProcessWire logo, the Proyecto Chaucha logo, and the Ninjas.cl logo.

#### Scenario: Project logo files present in the static assets
- **WHEN** the site's static asset directory is inspected
- **THEN** the five project image files (`elixircl.png`, `jasonelle.png`, `joyofpw.png`, `chaucha.png`, `Ninjas.png`) exist as valid images

#### Scenario: Project logos included in the site output
- **WHEN** the site is generated
- **THEN** the project image files from the configured static asset directory are included in the generated site output

### Requirement: Showcase alt texts are preserved
The showcase images' alt texts SHALL be preserved across presentation changes.

#### Scenario: Alt texts unchanged
- **WHEN** the home page is rendered
- **THEN** each showcase image keeps its existing alt text (for example "Logo de Elixir Chile", "Portada de Super Club Net")

#### Scenario: New book cover alt text
- **WHEN** the home page is rendered
- **THEN** the "Conceptos de Sistemas Operativos" cover image uses the alt text "Foto de Niklas König en Unsplash"

### Requirement: The masthead hero logo keeps its source
The switch to local assets SHALL leave the masthead hero logo at its current source.

#### Scenario: Hero logo unchanged
- **WHEN** the home page or a post page is rendered
- **THEN** the masthead hero logo keeps its current source, unaffected by the showcase switch
