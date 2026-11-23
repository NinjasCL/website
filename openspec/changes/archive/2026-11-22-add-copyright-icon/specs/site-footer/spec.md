# Spec Delta

## MODIFIED Requirements

### Requirement: The footer renders the copyright line and the back-to-top link
The site footer SHALL render on every generated page — the home pages, single post pages, and the not-found page — carrying the copyright line, "Copyright 🥷🏽 Ninjas.cl © 2015–" plus the current year, with its rights clause in the page's language (revised 2026-11-22: the owner translated the Spanish site's clause from the former English-only line; revised again the same day: the Spanish mirrors the English's "preserved" as "preservados" instead of the standard "reservados", and the Japanese and Portuguese homes carry their own clauses instead of the English one): "Todos los derechos e izquierdos preservados" on the site's Spanish pages — the default home, single post pages, the blog index, and the not-found page — "All rights and lefts preserved" on the English home, "すべての権利と左派を保全" on the Japanese home, and "Todos os direitos e esquerdos preservados" on the Portuguese home, the "Copyright 🥷🏽 Ninjas.cl © 2015–{year} ·" prefix verbatim on every page. The back-to-top link targets the `#masthead` anchor, labeled in the page's language on the home pages — "^ volver arriba ^" on Spanish, "^ back to top ^" on English, "^ 上に戻る ^" on Japanese, "^ voltar ao topo ^" on Portuguese — while post pages and the not-found page keep the Spanish label. The copyright line SHALL lead with the authorship icon through the shared inline presentation, decorative with empty alt, ahead of the verbatim text.

#### Scenario: Copyright and back-to-top render
- **WHEN** the default home page is rendered
- **THEN** the footer carries the copyright line with its 🥷🏽 emoji and its "Todos los derechos e izquierdos preservados" clause
- **AND** the "^ volver arriba ^" link points at the masthead anchor

#### Scenario: A translated home keeps the verbatim copyright, translated back-to-top
- **WHEN** the English home page is rendered
- **THEN** the copyright line reads verbatim — its own English "All rights and lefts preserved" clause — while the Japanese and Portuguese homes carry theirs in their own languages
- **AND** the back-to-top link carries that language's label and points at the masthead anchor

#### Scenario: The Japanese and Portuguese homes carry their own clauses
- **WHEN** the Japanese or Portuguese home page is rendered
- **THEN** the copyright line keeps the verbatim "Copyright 🥷🏽 Ninjas.cl © 2015–{year} ·" prefix and carries that language's clause — "すべての権利と左派を保全" on Japanese, "Todos os direitos e esquerdos preservados" on Portuguese
- **AND** the English clause appears nowhere on those pages

#### Scenario: Single post page footer
- **WHEN** a single post page is rendered
- **THEN** it closes with the same site footer — the copyright line with its Spanish clause and the "^ volver arriba ^" back-to-top link
- **AND** its former "Ninjas.cl — Desde 2015" footer line no longer exists

#### Scenario: The copyright year is always the current year
- **WHEN** the site is rendered in a given year
- **THEN** the copyright line's end year is that current year, never a stale hardcoded one

#### Scenario: The footer element keeps its identity
- **WHEN** the generated home page's markup is inspected
- **THEN** the footer element keeps its `rs-footer` class

#### Scenario: The copyright line leads with the authorship icon
- **WHEN** any page renders the site footer
- **THEN** the copyright paragraph leads with the icon `/icons/win95/FilePencil_32x32_4.png` through the shared inline presentation — `site-icon` class, empty alt — ahead of the verbatim "Copyright 🥷🏽 Ninjas.cl © 2015–{year} ·" text, on the home pages, post pages, blog index pages, and the not-found page alike
