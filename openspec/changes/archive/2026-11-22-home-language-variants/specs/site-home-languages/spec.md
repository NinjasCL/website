# Spec Delta

## Purpose

The home page in the site's four languages: one home per declared language at its own URL, every home-owned string rendered in that language, a language options row linking the four homes, and the head fields that declare each home's language.

## ADDED Requirements

### Requirement: The home page ships in the site's four languages
The site SHALL render one home page per declared site language: the human-written Spanish default at `/`, and the translated homes at `/en/`, `/ja/`, and `/pt/`, each registered as an ordinary blogatto config route so it generates `<route>/index.html` and joins the sitemap. Every home renders the same page structure — masthead hero, marquee, about, posts, projects, books, games, banner wall, footer.

#### Scenario: Four home routes generate
- **WHEN** the site is generated
- **THEN** the output carries the home page at each of the four routes — the default at `/` and the translated homes at `/en/`, `/ja/`, and `/pt/`

#### Scenario: A translated home keeps the page structure
- **WHEN** a translated home page is rendered
- **THEN** it carries the same sections as the default home — the hero with its logo and brand title, the marquee, the about, posts, projects, books, and games sections, the banner wall, and the footer

#### Scenario: The translated homes join the sitemap
- **WHEN** the generated sitemap is inspected
- **THEN** the `/en/`, `/ja/`, and `/pt/` home URLs are listed beside the default home's

### Requirement: Home copy renders in the page's language
Every home page SHALL render its home-owned copy in the page's language — the marquee, the about paragraphs, each section's title and intro, the showcase cards' descriptions and "Desde …" captions, and the empty-state note — with the Spanish home's copy exactly today's strings and each translated home carrying its own. The hero's brand title "忍者 開発者 Ninjas.cl" stays verbatim on every home.

#### Scenario: The Spanish home keeps its copy
- **WHEN** the default home page is rendered
- **THEN** its copy is exactly today's Spanish strings — the marquee's "★ Bienvenido a Ninjas.cl …", the "Sobre nosotros", "Entradas del blog", "Proyectos", "Libros", and "Juegos" titles, and the showcase cards' Spanish descriptions

#### Scenario: A translated home reads in its language
- **WHEN** a translated home page is rendered
- **THEN** its section titles, intro paragraphs, card descriptions, and caption prefix render in that language — no Spanish sentence remains in the page body

#### Scenario: The brand title stays
- **WHEN** any home page is rendered
- **THEN** the hero title keeps the "忍者 開発者 Ninjas.cl" brand text with its Chilean tricolor treatment

### Requirement: Every home links its sibling variants
Every home page SHALL render the posts' language options row, linking the four home URLs — the current language as plain text marked the current page, the others as links — labeled in the page's language ("Idiomas:" on Spanish, "Languages:" on English, "言語:" on Japanese, "Idiomas:" on Portuguese), so each home is reachable from the others.

#### Scenario: The Spanish home links the translated homes
- **WHEN** the default home page is rendered
- **THEN** its options row reads "Idiomas:" and links `/en/`, `/ja/`, and `/pt/` with the language configuration's names, the "Español" entry plain text marked the current page

#### Scenario: A translated home links back
- **WHEN** a translated home page is rendered
- **THEN** its options row is labeled in its own language, its own language renders as the plain-text current entry, and the row links the default home at `/`

### Requirement: A home page's head declares its language
Each home page's head SHALL declare its language: `lang` on the html element (es-CL on the default home, the variant's own code on translated homes), `og:locale` from the language configuration, the translated site description in the meta description and its og/twitter mirrors, and `og:url` pointing at that home's own URL.

#### Scenario: The default home keeps the site defaults
- **WHEN** the default home page is rendered
- **THEN** the html element declares es-CL, `og:locale` carries es_CL, and the description fields carry the Spanish site description

#### Scenario: A translated home declares its own language
- **WHEN** a translated home page is rendered
- **THEN** the html element declares that language, `og:locale` carries that language's locale from the configuration, and the description fields carry that language's translated site description with the home's own URL in `og:url`

### Requirement: Translated homes carry no machine-translation warning
The translated home pages SHALL NOT render the machine-translation warning the translated post variants carry: the home pages are site chrome, not post content, so no translation warning text appears on any home.

#### Scenario: No warning on a translated home
- **WHEN** a translated home page is rendered
- **THEN** none of the configured translation-warning texts (Spanish, English, Japanese, or Portuguese) appears on the page
