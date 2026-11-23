# Spec Delta

## Purpose

Defines the presentation contract for the home page's section headers — "Sobre nosotros" among them — so every section title renders prominently, at the retrostrap `--rs-font-size-5` type-ladder step (1.5rem), clearly larger than the panel-title default.

## ADDED Requirements

### Requirement: Section headers are enlarged to the size-5 ladder step
The home page's section headers SHALL render with a computed font size of 1.5rem — retrostrap's `--rs-font-size-5` type-ladder step, ≈1.85× the 0.8125rem (`--rs-font-size-2`) panel-title default they replace.

#### Scenario: Enlarged header size in the stylesheet
- **WHEN** the home page's shipped stylesheet is inspected
- **THEN** the rule applied to the section headers sets a font size that computes to 1.5rem (`--rs-font-size-5`, ≈1.85× the 0.8125rem panel-title default)

#### Scenario: Sobre nosotros header reads as a heading
- **WHEN** the home page is viewed in a browser
- **THEN** the "Sobre nosotros" header renders visibly larger than before the change, at the enlarged size

### Requirement: Every home page section header shares the enlarged presentation
The enlarged header presentation SHALL apply uniformly to all home page sections: about ("Sobre nosotros"), posts, projects, books, games, and contact.

#### Scenario: All sections enlarged
- **WHEN** the home page is rendered
- **THEN** the headers of the posts, projects, books, games, and contact sections carry the same enlarged presentation as the "Sobre nosotros" header

### Requirement: Other headings keep their sizes
Headings other than the section headers SHALL keep their existing sizes: the single post page's title, the masthead hero's site title, headings inside section bodies (such as showcase card titles), and footer text.

#### Scenario: Showcase card titles unchanged
- **WHEN** the home page is rendered
- **THEN** the projects, books, and games showcase card titles keep their existing sizes, unaffected by the section header enlargement

#### Scenario: Post page headings unchanged
- **WHEN** a single post page is rendered
- **THEN** the post title and the masthead hero's site title keep their existing sizes
