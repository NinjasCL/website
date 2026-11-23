# Spec Delta

## ADDED Requirements

### Requirement: Game capture assets ship with the generated site
The four "Juegos" showcase images SHALL be part of the site's static assets so the generated site serves them itself: the Rolplay manual cover, the Profesor Rossa capture, the ¡Qué Chaucha! menu, and the Munsta Jump! capture — stored as downloaded, the animated GIFs included.

#### Scenario: Game capture files present in the static assets
- **WHEN** the site's static asset directory is inspected
- **THEN** the four game image files (`rolplay-manual.png`, `rossa.gif`, `quechaucha.jpg`, `munstajump.gif`) exist as valid images

#### Scenario: Game captures included in the site output
- **WHEN** the site is generated
- **THEN** the game image files from the configured static asset directory are included in the generated site output

### Requirement: The masthead hero logo keeps its source
The switch to local assets SHALL leave the masthead hero logo at its current source.

#### Scenario: Hero logo unchanged
- **WHEN** the home page or a post page is rendered
- **THEN** the masthead hero logo keeps its current source, unaffected by the showcase switch

## MODIFIED Requirements

### Requirement: Showcase images are served from the site's own assets
The home page's showcase images — in the "Proyectos", "Libros", and "Juegos" sections — SHALL be served from the site's own static assets under `/img/` — no remote image host in any showcase section.

#### Scenario: Projects images resolve locally
- **WHEN** the home page is rendered
- **THEN** each "Proyectos" card image (Elixir Chile, Joy of ProcessWire, Proyecto Chaucha, Ninja Systems) loads from a local `/img/…` path

#### Scenario: Books images resolve locally
- **WHEN** the home page is rendered
- **THEN** each "Libros" card image (Super Club Net, Elixir Full Stack, Wren Libro, Las Aventuras de Quirquincho) loads from a local `/img/…` path

#### Scenario: No remote image hosts in proyectos or libros
- **WHEN** the generated home page's markup is inspected
- **THEN** the projects and books sections reference no remote image host: no `avatars.githubusercontent.com`, no `raw.githubusercontent.com/ElixirCL`, and no `ninjas.cl/covers`

#### Scenario: Games images resolve locally
- **WHEN** the home page is rendered
- **THEN** each "Juegos" card image (Rolplay Manual, Profesor Rossa, ¡Qué Chaucha!, Munsta Jump!) loads from a local `/img/…` path

#### Scenario: No remote image hosts in juegos
- **WHEN** the generated home page's markup is inspected
- **THEN** the games section references no remote image host: no `ninjas.cl/blog` path and no `raw.githubusercontent.com` capture

## REMOVED Requirements

### Requirement: Images outside proyectos and libros keep their sources
**Reason**: The site owner extended the local-serving convention to the Juegos section, so this guard's games clause is reversed: games images are now governed by the "Showcase images are served from the site's own assets" requirement above.
**Migration**: Only the masthead hero logo keeps its remote source, protected by the new "The masthead hero logo keeps its source" requirement; nothing else outside the showcase sections changes.
