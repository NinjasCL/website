# Spec Delta

## MODIFIED Requirements

### Requirement: The rest of the posts section keeps its presentation
The featured post's row structure and its button SHALL apply only to the featured post; the featured heading and the empty-state note SHALL keep their current presentation, and the more-posts remainder SHALL render in its own presentation — the heading led by its icon, the entries in the existing compact star list with each linked title leading with its post's resolved title icon (see `site-post-icons`), and, whenever the list renders, a view-all button after it. The section's headings and labels SHALL render in the home's language: "Entrada destacada" / "Leer entrada" / "Más entradas" / "Ver Todos" and the "Todavía no hay entradas publicadas." note on Spanish, "Featured post" / "Read post" / "More posts" / "View all" and the translated note on English, "注目の記事" / "記事を読む" / "他の記事" / "すべて見る" on Japanese, "Postagem destacada" / "Ler entrada" / "Mais entradas" / "Ver todos" on Portuguese.

#### Scenario: The Más entradas heading leads with its icon
- **WHEN** a home page renders its more-posts list
- **THEN** the heading leads with the stack-of-documents icon (`/icons/win95/Files_32x32_4.png`), matching the icon-led headings across the home page

#### Scenario: More posts list unchanged
- **WHEN** a home page is rendered with more than one post in its language
- **THEN** the listed entries render as the existing compact star list, unaffected by the featured post's row, each linked title leading with its post's resolved icon — the declared value or the newspaper fallback

#### Scenario: The Ver Todos button follows the list
- **WHEN** the more-posts list renders, trimmed or not
- **THEN** a large icon button labeled in the page's language — "Ver Todos", "View all", "すべて見る", or "Ver todos" — follows it, led by the site's document-view icon (`/icons/win95/Shdocvw257_32x32_8.png`), linking the blog index at `/blog`

#### Scenario: Empty state unchanged
- **WHEN** a home page is rendered with no posts in its language
- **THEN** the section shows the page-language "no posts published" note instead of a row
