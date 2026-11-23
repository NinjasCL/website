# Spec Delta

## MODIFIED Requirements

### Requirement: Showcase images are served from the site's own assets
The home page's showcase images — in the "Proyectos", "Libros", and "Juegos" sections — SHALL be served from the site's own static assets under `/img/` — no remote image host in any showcase section.

#### Scenario: Projects images resolve locally
- **WHEN** the home page is rendered
- **THEN** each "Proyectos" card image (Elixir Chile, Jasonelle, Joy of ProcessWire, Proyecto Chaucha, Ninjas.cl) loads from a local `/img/…` path

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
