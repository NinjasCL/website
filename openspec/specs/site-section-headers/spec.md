# site-section-headers Specification

## Purpose

Defines the presentation contract for the home page's section headers — "Sobre nosotros" among them — so every section title renders prominently, at the retrostrap `--rs-font-size-5` type-ladder step (1.5rem), clearly larger than the panel-title default.

## Requirements

### Requirement: Section headers are enlarged to the size-5 ladder step
The home page's section headers SHALL render with a computed font size of 1.5rem — retrostrap's `--rs-font-size-5` type-ladder step, ≈1.85× the 0.8125rem (`--rs-font-size-2`) panel-title default they replace.

#### Scenario: Enlarged header size in the stylesheet
- **WHEN** the home page's shipped stylesheet is inspected
- **THEN** the rule applied to the section headers sets a font size that computes to 1.5rem (`--rs-font-size-5`, ≈1.85× the 0.8125rem panel-title default)

#### Scenario: Sobre nosotros header reads as a heading
- **WHEN** the home page is viewed in a browser
- **THEN** the "Sobre nosotros" header renders visibly larger than before the change, at the enlarged size

### Requirement: Every home page section header shares the enlarged presentation
The enlarged header presentation SHALL apply uniformly to all home page sections that carry a header: about ("Sobre nosotros"), posts, projects, books, and games. Revised 2026-11-20: contact is dropped from the enumeration — the banner-wall change removed the Contacto section's header along with its navbar link, leaving the untitled banner panel at `#contact`.

#### Scenario: All sections enlarged
- **WHEN** the home page is rendered
- **THEN** the headers of the posts, projects, books, and games sections carry the same enlarged presentation as the "Sobre nosotros" header
- **AND** the untitled banner panel at `#contact` renders no section header

### Requirement: Other headings keep their sizes
Headings other than the section headers SHALL keep their existing sizes: the single post page's title, the masthead hero's site title, headings inside section bodies (such as showcase card titles), and footer text.

#### Scenario: Showcase card titles unchanged
- **WHEN** the home page is rendered
- **THEN** the projects, books, and games showcase card titles keep their existing sizes, unaffected by the section header enlargement

#### Scenario: Post page headings unchanged
- **WHEN** a single post page is rendered
- **THEN** the post title and the masthead hero's site title keep their existing sizes

### Requirement: Posts section header links the syndication feed
The home page's "Entradas del blog" section header SHALL carry the same feed
icon link to the current language's Atom feed as that language's blog index
title section: `/atom.xml` on the Spanish home and `/{lang}/atom.xml` on the
English, Japanese, and Portuguese homes.

#### Scenario: Home posts header shows the feed link
- **WHEN** a visitor opens any home page language
- **THEN** the posts section heading displays the feed icon linking that language's Atom feed

#### Scenario: Feed link matches the blog index
- **WHEN** a home posts header's feed link and its language's blog index title's feed link are compared
- **THEN** both use the same feed icon image, the same alt text, and the same destination
