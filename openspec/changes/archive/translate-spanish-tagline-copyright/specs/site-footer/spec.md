# Spec Delta

## MODIFIED Requirements

### Requirement: The footer renders the copyright line and the back-to-top link
The site footer SHALL render on every generated page — the home pages, single post pages, and the not-found page — carrying the copyright line, "Copyright 🥷🏽 Ninjas.cl © 2015–" plus the current year, with its rights clause in the page's language (revised 2026-11-22: the owner translated the Spanish site's clause from the former English-only line): "Todos los derechos e izquierdos reservados" on the site's Spanish pages — the default home, single post pages, the blog index, and the not-found page — and the English "All rights and lefts preserved" on the translated homes, the "Copyright 🥷🏽 Ninjas.cl © 2015–{year} ·" prefix verbatim on every page. The back-to-top link targets the `#masthead` anchor, labeled in the page's language on the home pages — "^ volver arriba ^" on Spanish, "^ back to top ^" on English, "^ 上に戻る ^" on Japanese, "^ voltar ao topo ^" on Portuguese — while post pages and the not-found page keep the Spanish label.

#### Scenario: Copyright and back-to-top render
- **WHEN** the default home page is rendered
- **THEN** the footer carries the copyright line with its 🥷🏽 emoji and its "Todos los derechos e izquierdos reservados" clause
- **AND** the "^ volver arriba ^" link points at the masthead anchor

#### Scenario: A translated home keeps the verbatim copyright, translated back-to-top
- **WHEN** a translated home page is rendered
- **THEN** the copyright line reads verbatim — the English "All rights and lefts preserved" clause — while the Spanish pages carry theirs in Spanish
- **AND** the back-to-top link carries that language's label and points at the masthead anchor

#### Scenario: Single post page footer
- **WHEN** a single post page is rendered
- **THEN** it closes with the same site footer — the copyright line with its Spanish clause and the "^ volver arriba ^" back-to-top link
- **AND** its former "Ninjas.cl — Desde 2015" footer line no longer exists

#### Scenario: The copyright year is always the current year
- **WHEN** the site is rendered in a given year
- **THEN** the copyright line's end year is that current year, never a stale hardcoded one

#### Scenario: The footer element keeps its identity
- **WHEN** any generated home page's markup is inspected
- **THEN** the footer element keeps its `rs-footer` class
