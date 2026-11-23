# Spec Delta

## MODIFIED Requirements

### Requirement: The featured post is a build-time random pick
Each home page's featured post SHALL be one randomly selected entry from that home's language posts — the default-language posts on the Spanish home, the matching translated variants on the translated homes — picked fresh at each build, linking the picked posts' own variant URLs, with the "Más entradas" list showing up to ten of the remaining entries — also picked fresh at random at each build.

#### Scenario: A random entry is featured
- **WHEN** a home page is rendered with multiple posts in its language
- **THEN** the featured row shows one of that language's entries — a fresh pick at each build — and the more-posts list shows up to ten of the remaining entries, a fresh random set each build

#### Scenario: A large catalog lists ten random entries
- **WHEN** a home page is rendered with more than eleven posts in its language
- **THEN** the more-posts list shows exactly ten of the entries left after the featured one — never more, whatever the catalog's size

#### Scenario: A small catalog lists the remaining entries
- **WHEN** a home page renders eleven or fewer posts in its language, leaving at most ten entries after the featured one
- **THEN** the list shows every one of them

#### Scenario: A lone post is the featured one
- **WHEN** a home page is rendered with a single post in its language
- **THEN** that post is the featured entry and no more-posts list renders

#### Scenario: A translated home lists its own variants
- **WHEN** a translated home page is rendered with the catalog carrying that language's variants
- **THEN** the featured pick and the listed entries are that language's variants, linking their variant URLs — never the default-language pages

### Requirement: The Leer entrada button is a large icon button
The featured post's read button SHALL carry retrostrap's `rs-btn--large` size with the `rs-btn--icon` layout, leading with the Program Manager icon from the site's static assets (revised 2026-11-20 from the initial ReaderOpened pick by the site owner) beside its label — "Leer entrada" on Spanish, "Read post" on English, "記事を読む" on Japanese, "Ler entrada" on Portuguese — and SHALL link to the post.

#### Scenario: Large icon button
- **WHEN** a home page is rendered with at least one post in its language
- **THEN** the read button carries the `rs-btn--large` variant with the Program Manager icon (`/icons/win95/Progman25_32x32_4.png`) beside the page-language label, linking to the post

### Requirement: The rest of the posts section keeps its presentation
The featured post's row structure and its button SHALL apply only to the featured post; the featured heading and the empty-state note SHALL keep their current presentation, and the more-posts remainder SHALL render in its own presentation — the heading led by its icon, the entries in the existing compact star list, and, whenever the list renders, a view-all button after it. The section's headings and labels SHALL render in the home's language: "Entrada destacada" / "Leer entrada" / "Más entradas" / "Ver Todos" and the "Todavía no hay entradas publicadas." note on Spanish, "Featured post" / "Read post" / "More posts" / "View all" and the translated note on English, "注目の記事" / "記事を読む" / "他の記事" / "すべて見る" on Japanese, "Postagem destacada" / "Ler entrada" / "Mais entradas" / "Ver todos" on Portuguese.

#### Scenario: The Más entradas heading leads with its icon
- **WHEN** a home page renders its more-posts list
- **THEN** the heading leads with the stack-of-documents icon (`/icons/win95/Files_32x32_4.png`), matching the icon-led headings across the home page

#### Scenario: More posts list unchanged
- **WHEN** a home page is rendered with more than one post in its language
- **THEN** the listed entries render as the existing compact star list, unaffected by the featured post's row

#### Scenario: The Ver Todos button follows the list
- **WHEN** the more-posts list renders, trimmed or not
- **THEN** a large icon button labeled in the page's language — "Ver Todos", "View all", "すべて見る", or "Ver todos" — follows it, led by the site's document-view icon (`/icons/win95/Shdocvw257_32x32_8.png`), linking the blog index at `/blog`

#### Scenario: Empty state unchanged
- **WHEN** a home page is rendered with no posts in its language
- **THEN** the section shows the page-language "no posts published" note instead of a row
