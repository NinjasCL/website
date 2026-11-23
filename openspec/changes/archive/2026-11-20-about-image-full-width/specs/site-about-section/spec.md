# Spec Delta

## Purpose

Defines the rendering behavior of the home page's "Sobre nosotros" (about) section: the portrait and the section text sharing one row — portrait left at about 30% of the content width, a gap of about 10%, text right at about 60% — with the portrait served from the site's own static assets at its natural proportions and its caption preserved.

## ADDED Requirements

### Requirement: About portrait and text share one row
The home page's about section SHALL lay out its portrait and its text side by side in a single row: the portrait in a left column taking about 30% of the section's content width, separated from the text by a gap of about 10% of that width, with the text in a right column taking about 60%.

#### Scenario: Portrait left, text right
- **WHEN** the home page is rendered on a viewport wide enough for two columns
- **THEN** the portrait and the section text occupy the same row, with the portrait on the left at about 30% of the section's content width, a gap of about 10% between them, and the text on the right at about 60%

#### Scenario: Stacked on narrow viewports
- **WHEN** the home page is viewed on a viewport narrower than the site's two-column breakpoint
- **THEN** the about row collapses to a single column with the portrait first and the text below, each spanning the section's full width

### Requirement: About portrait fills its column at natural proportions
The about section's portrait SHALL fill its column's width, with the displayed height determined by the portrait's intrinsic proportions.

#### Scenario: Portrait fills the column
- **WHEN** the home page is rendered
- **THEN** the portrait occupies the full width of its column
- **AND** the portrait's displayed height follows its intrinsic aspect ratio, so the image is neither stretched, squashed, nor cropped

#### Scenario: No fixed square box
- **WHEN** the generated home page's markup is inspected
- **THEN** the portrait is not pinned to a fixed 250×250 presentation, so its size adapts to its column

### Requirement: About text and caption are preserved in the right column
The about section's text SHALL render in the right column, beside the portrait, with the figure caption preserved.

#### Scenario: Text beside the image
- **WHEN** the home page is rendered on a viewport wide enough for two columns
- **THEN** the about section's paragraphs appear in the right column, beside the portrait

#### Scenario: Caption preserved
- **WHEN** the about section is rendered
- **THEN** the portrait still carries its caption identifying Camilo Castro as a Software Engineer

### Requirement: About portrait is served from local site assets
The about section's portrait SHALL be served from the site's own static assets rather than a remote host.

#### Scenario: Local portrait src
- **WHEN** the generated home page's markup is inspected
- **THEN** the portrait's `src` points at the site's own asset path (`/img/camilo.jpg`) instead of a remote `https://` URL

#### Scenario: Portrait asset ships with the site
- **WHEN** the site is generated
- **THEN** the portrait file from the configured static asset directory is included in the generated site output

### Requirement: Other home page figures keep their sizing
The about row presentation SHALL apply only to the about section; figures in the rest of the home page SHALL keep their existing sizing behavior.

#### Scenario: Showcase figures unchanged
- **WHEN** the home page is rendered
- **THEN** the projects, books, and games showcase figures retain their current sizing, unaffected by the about section's row presentation
