# Spec Delta

## Purpose

Defines the layout of the home page's showcase cards: the "Proyectos", "Libros", and "Juegos" items all follow the "Sobre nosotros" row structure — image left filling its column, text right.

## ADDED Requirements

### Requirement: Showcase cards use the about row structure
Every showcase card — in the "Proyectos", "Libros", and "Juegos" sections — SHALL lay out its image and text side by side in a single row, mirroring the "Sobre nosotros" structure: the figure in a left column of about one-third of the card's content width, separated from the text by a column gap of 2% of that width, with the text in a right column of about two-thirds.

#### Scenario: Image left, text right
- **WHEN** the home page is rendered on a viewport wide enough for two columns
- **THEN** each showcase card shows its figure and its text on the same row — figure on the left at about one-third of the card's content width, a 2% gap between them, and the text on the right at about two-thirds

#### Scenario: Juegos cards in the row
- **WHEN** the home page is rendered
- **THEN** the games cards carry the same row presentation as the projects and books cards — figure left, text right

#### Scenario: Stacked on narrow viewports
- **WHEN** a card is viewed on a viewport narrower than the site's two-column breakpoint
- **THEN** the card collapses to a single column with the figure first and the text below

### Requirement: Card images fill their column without distortion
Each showcase card figure SHALL be block-level within its column, with the image box filling the column's width and the image's natural proportions preserved — never stretched, squashed, or cropped; the figure caption stays under the image box.

#### Scenario: Image box fills the column
- **WHEN** the home page is rendered
- **THEN** each showcase card image box occupies the full width of its column — not shrink-wrapped to its natural pixel size

#### Scenario: Caption preserved under the image
- **WHEN** a showcase card is rendered
- **THEN** the figure keeps its "Desde …" caption under the image

### Requirement: Card image boxes share the Super Club Net height
Every showcase card's image box SHALL be at least as tall as the Super Club Net image container, so the image containers across the "Proyectos", "Libros", and "Juegos" sections present a uniform height; an image whose natural shape is shorter or wider than the Super Club Net cover letterboxes inside that height instead of distorting.

#### Scenario: Uniform image box height
- **WHEN** the home page is rendered
- **THEN** every showcase card image box presents the height the Super Club Net cover has at the same column width, across all three sections

#### Scenario: Shorter images letterbox without distortion
- **WHEN** a card image's natural shape is shorter or wider than the Super Club Net cover (for example a square logo or a wide game capture)
- **THEN** the image letterboxes — centered and undistorted — inside the uniform image box
