# site-masthead Specification

## Purpose

Defines the site masthead: a global primary navbar rendered on every generated page, plus a hero area whose content can change per page.

## Requirements

### Requirement: Masthead on every page
The site SHALL render the masthead — the header containing the primary navbar — on every generated page, including single post pages, with the `masthead` anchor id that in-page "back to top" links target.

#### Scenario: Home page includes the masthead
- **WHEN** the home page is rendered
- **THEN** the page includes the masthead with the primary navbar and the `masthead` anchor id

#### Scenario: Single post page includes the masthead
- **WHEN** a single post page is rendered from the post template
- **THEN** the page includes the same primary navbar and the `masthead` anchor id, instead of a back-link-only header

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
The masthead SHALL render a hero area provided by the page, so hero content can differ between pages while the navbar stays shared. The home hero's description note and tagline SHALL render in the home's language — the Spanish description and the "Software de 🇨🇱 con ❤️" tagline on the default home (revised 2026-11-22: the owner translated the tagline from the former English "Software from 🇨🇱 with ❤️", which remains the English home's own tagline), the translated description and tagline on the translated homes — beside the verbatim "忍者 開発者 Ninjas.cl" brand title.

#### Scenario: Home page hero
- **WHEN** a home page is rendered
- **THEN** the masthead hero shows the site logo, the site title with its tagline, and the description note in the home's language, followed by the marquee
- **AND** no call-to-action links render in the hero

#### Scenario: Single post page hero
- **WHEN** a single post page is rendered
- **THEN** the masthead renders the navbar with no hero elements — no site logo image, no "忍者 開発者 Ninjas.cl" site title text, and no marquee
- **AND** the masthead's whole area is filled by the post's cover background instead

#### Scenario: Not-found page hero
- **WHEN** the not-found page is rendered
- **THEN** the masthead renders the navbar alone, with no hero elements

### Requirement: Post masthead cover background
The single post masthead SHALL fill its entire area with a cover background image instead of hero content.

#### Scenario: Cover image from the post frontmatter
- **WHEN** a post that declares a `featured_image` frontmatter value is rendered
- **THEN** the masthead carries that image as its background, sized and positioned to cover the whole masthead area

#### Scenario: Default cover image
- **WHEN** a post that declares no `featured_image` frontmatter value is rendered
- **THEN** the masthead carries the site's Ninjas logo image (`/img/Ninjas.png`) as its cover background

#### Scenario: Only the navbar rides the cover
- **WHEN** a single post masthead is rendered
- **THEN** the shared navbar renders over the cover background
- **AND** no other content renders inside the masthead

### Requirement: Home hero title carries the Chilean tricolor
The home hero's site title — "忍者 開発者 Ninjas.cl" — SHALL render in the
Chilean flag's colors: the blue, white, and red of the 🇨🇱 emoji,
applied through a banded gradient clipped to the text (no
per-character markup), with the bands running top to bottom in the
flag's own order so every glyph reads horizontally intact.

#### Scenario: Title colors come from the Chilean flag
- **WHEN** the home page is generated
- **THEN** the hero title renders its characters in the Chilean flag's blue, white, and red — the 🇨🇱 emoji's palette

#### Scenario: The tricolor is one clipped gradient, not per-character markup
- **WHEN** the home page's hero title is rendered
- **THEN** the whole title text sits in one span whose gradient, clipped to the text, paints the colors
- **AND** no per-character color markup wraps the title's characters

#### Scenario: The bands read top to bottom
- **WHEN** a visitor looks at the hero title
- **THEN** the gradient's bands run from the top of the text to the bottom — blue at the top, white through the middle, red at the bottom
- **AND** the title's glyphs, including the kanji, read horizontally intact rather than sliced mid-stroke by left-to-right bands
