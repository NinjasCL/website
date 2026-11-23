# Spec Delta

## MODIFIED Requirements

### Requirement: The featured post is a build-time random pick
The home page's featured post SHALL be one randomly selected entry from the default-language posts, picked fresh at each build, with the "Más entradas" list showing up to ten of the remaining entries — also picked fresh at random at each build.

#### Scenario: A random entry is featured
- **WHEN** the home page is rendered with multiple posts
- **THEN** the featured row shows one of the default-language entries — a fresh pick at each build — and the "Más entradas" list shows up to ten of the remaining entries, a fresh random set each build

#### Scenario: A large catalog lists ten random entries
- **WHEN** the home page is rendered with more than eleven posts
- **THEN** the "Más entradas" list shows exactly ten of the entries left after the featured one — never more, whatever the catalog's size

#### Scenario: A small catalog lists the remaining entries
- **WHEN** the home page renders eleven or fewer posts, leaving at most ten entries after the featured one
- **THEN** the list shows every one of them

#### Scenario: A lone post is the featured one
- **WHEN** the home page is rendered with a single post
- **THEN** that post is the featured entry and no "Más entradas" list renders

### Requirement: The rest of the posts section keeps its presentation
The featured post's row structure and its button SHALL apply only to the featured post; the "Entrada destacada" heading and the empty-state note SHALL keep their current presentation, and the "Más entradas" remainder SHALL render in its own presentation — the heading led by its icon, the entries in the existing compact star list, and, whenever the list renders, a "Ver Todos" button after it.

#### Scenario: The Más entradas heading leads with its icon
- **WHEN** the home page renders its "Más entradas" list
- **THEN** the heading leads with the stack-of-documents icon (`/icons/win95/Files_32x32_4.png`), matching the icon-led headings across the home page

#### Scenario: More posts list unchanged
- **WHEN** the home page is rendered with more than one post
- **THEN** the listed entries render as the existing compact star list, unaffected by the featured post's row

#### Scenario: The Ver Todos button follows the list
- **WHEN** the "Más entradas" list renders, trimmed or not
- **THEN** a large icon button labeled "Ver Todos" follows it, led by the site's document-view icon (`/icons/win95/Shdocvw257_32x32_8.png`) — the same icon every existing Ver / View button uses — linking the blog index at `/blog`

#### Scenario: Empty state unchanged
- **WHEN** the home page is rendered with no posts
- **THEN** the section shows the existing "Todavía no hay entradas publicadas." note instead of a row
