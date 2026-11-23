# Spec Delta

## Purpose

Defines the featured post's presentation on the home page's "Entradas del blog" section: the Sobre nosotros-style row — figure left at natural proportions with a placeholder fallback, text right — and its "Leer entrada" large icon button.

## ADDED Requirements

### Requirement: The featured post follows the Sobre nosotros row structure
The featured post SHALL lay out its figure and its text side by side in a single row, mirroring the "Sobre nosotros" structure: the figure in a left column of about one-third of the card's content width, separated from the text by a column gap of 2% of that width, with the linked title, date, description, and button in a right column of about two-thirds.

#### Scenario: Figure left, text right
- **WHEN** the home page is rendered with at least one post
- **THEN** the featured post shows its figure and its text on the same row — figure on the left at about one-third of the card's content width, a 2% gap between them, and the title, date, description, and "Leer entrada" button on the right at about two-thirds

#### Scenario: Stacked on narrow viewports
- **WHEN** the featured post is viewed on a viewport narrower than the site's two-column breakpoint
- **THEN** the row collapses to a single column with the figure first and the text below

### Requirement: The figure is the post's featured image with a placeholder fallback
The featured post's figure SHALL show the post's `featured_image` frontmatter value at natural proportions — the image fills the column's width with its displayed height following its intrinsic aspect ratio — and SHALL fall back to the Ninjas logo (`/img/Ninjas.png`) when the post has no featured image, so the row structure always renders.

#### Scenario: The post's own image renders
- **WHEN** the featured post carries a `featured_image` in its frontmatter
- **THEN** that image fills the left column at its natural proportions

#### Scenario: The placeholder renders
- **WHEN** the featured post has no featured image
- **THEN** the Ninjas logo fills the left column instead, keeping the row structure intact

#### Scenario: Natural proportions
- **WHEN** the featured post's figure is rendered
- **THEN** the image is neither stretched, squashed, nor cropped — its intrinsic aspect ratio is preserved

### Requirement: The Leer entrada button is a large icon button
The featured post's "Leer entrada" button SHALL carry retrostrap's `rs-btn--large` size with the `rs-btn--icon` layout, leading with the ReaderOpened icon from the site's static assets beside its label, and SHALL link to the post.

#### Scenario: Large icon button
- **WHEN** the home page is rendered with at least one post
- **THEN** the "Leer entrada" button carries the `rs-btn--large` variant with the ReaderOpened icon (`/icons/ReaderOpened_32x32_4.png`) beside the label, linking to the post

### Requirement: The rest of the posts section keeps its presentation
The row structure and the button change SHALL apply only to the featured post; the "Entrada destacada" heading, the "Más entradas" list, and the empty-state note SHALL keep their current presentation.

#### Scenario: More posts list unchanged
- **WHEN** the home page is rendered with more than one post
- **THEN** the posts after the featured one render as the existing compact list, unaffected by the featured post's row

#### Scenario: Empty state unchanged
- **WHEN** the home page is rendered with no posts
- **THEN** the section shows the existing "Todavía no hay entradas publicadas." note instead of a row
