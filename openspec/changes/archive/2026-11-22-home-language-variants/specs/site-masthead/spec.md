# Spec Delta

## MODIFIED Requirements

### Requirement: Navbar links resolve from any page
The navbar SHALL keep its home page section links functional from every page, SHALL only mark the home link as the current page on the home pages, and SHALL render its labels in the page's language on the translated homes — "Home" / "Blog" / "About us" / "Projects" / "Books" / "Games" on English, "ホーム" / "ブログ" / "私たちについて" / "プロジェクト" / "書籍" / "ゲーム" on Japanese, "Início" / "Blog" / "Sobre nós" / "Projetos" / "Livros" / "Jogos" on Portuguese — while the default home and every non-home page keep the Spanish labels. Each home's own URL is that page's home-link target: `/` on the Spanish home and the language's route on the translated homes.

#### Scenario: Section links from a post page
- **WHEN** the navbar is rendered on a page other than a home page
- **THEN** links that target home page sections point at the default home page (for example `/#projects`) instead of in-page anchors
- **AND** the home link does not carry the current-page marker (`aria-current`)

#### Scenario: Section links on the home page
- **WHEN** the navbar is rendered on the Spanish home page
- **THEN** the section links are in-page anchors (for example `#projects`) and the labels read "Inicio", "Blog", "Nosotros", "Proyectos", "Libros", "Juegos"
- **AND** the "Inicio" link carries the current-page marker (`aria-current`)

#### Scenario: Section links and labels on a translated home page
- **WHEN** the navbar is rendered on a translated home page
- **THEN** the section links are in-page anchors (for example `#projects`) and the labels read in that home's language
- **AND** the home link carries the current-page marker (`aria-current`) and points at that home's own URL (`/en/`, `/ja/`, or `/pt/`)

### Requirement: Per-page masthead hero
The masthead SHALL render a hero area provided by the page, so hero content can differ between pages while the navbar stays shared. The home hero's description note and tagline SHALL render in the home's language — the Spanish description and today's "Software from 🇨🇱 with ❤️" tagline on the default home, the translated description and tagline on the translated homes — beside the verbatim "忍者 開発者 Ninjas.cl" brand title.

#### Scenario: Home page hero
- **WHEN** a home page is rendered
- **THEN** the masthead hero shows the site logo, the site title with its tagline, and the description note in the home's language, followed by the marquee
- **AND** no call-to-action links render in the hero

#### Scenario: Single post page hero
- **WHEN** a single post page is rendered from the post template
- **THEN** the masthead renders the navbar with no hero elements — no site logo image, no "忍者 開発者 Ninjas.cl" site title text, and no marquee
- **AND** the masthead's whole area is filled by the post's cover background instead

#### Scenario: Not-found page hero
- **WHEN** the not-found page is rendered
- **THEN** the masthead renders the navbar alone, with no hero elements
