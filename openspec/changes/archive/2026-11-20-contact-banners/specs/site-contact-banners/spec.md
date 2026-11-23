# Spec Delta

## Purpose

Defines the home page's banner wall: every retro banner GIF shipped in the site's static banner directory, displayed as decorative unlinked images at their natural proportions in the untitled panel at the `#contact` anchor — the former Contacto section.

## ADDED Requirements

### Requirement: The banner panel renders the shipped banners
The banner panel — the former Contacto section, now an untitled `rs-panel` at the `#contact` anchor — SHALL render every banner image shipped in the site's static banner directory, as plain decorative images: no anchor, caption, or other control accompanying any banner.

#### Scenario: Every shipped banner appears
- **WHEN** the home page is rendered
- **THEN** every banner file shipped in the static banner directory appears in the banner panel as an `img` served from `/banners/`
- **AND** the rendered banner count equals the shipped file count

#### Scenario: Banners stay decorative
- **WHEN** the generated home page's markup is inspected
- **THEN** no `img` served from `/banners/` is wrapped in a link

#### Scenario: The former Contacto content is gone
- **WHEN** the generated home page's markup is inspected
- **THEN** the panel contains none of the former Contacto content: the "¿Construimos algo juntos?" heading, its paragraph, the "Escríbenos" mailto button, the GitHub link, and the "Contacto" section title
- **AND** no navbar link points at the panel — the navbar's Contacto button is gone from every generated page, so no `#contact` or `/#contact` link exists anywhere on the site
- **AND** the untitled panel keeps its `#contact` anchor so external deep links keep resolving

#### Scenario: Banner assets ship with the site
- **WHEN** the site is generated
- **THEN** the banner files from the static asset directory are included in the generated site output

### Requirement: Banners render at their natural proportions
The banners SHALL render in a wrapping row layout that fits the panel width, each banner at its intrinsic pixel size with crisp (pixelated) scaling — no banner stretched, squeezed, or boxed to a uniform size.

#### Scenario: Wall presentation in the stylesheet
- **WHEN** the home page's shipped stylesheet is inspected
- **THEN** a banner-wall rule lays the banners out in wrapping rows with gaps between them
- **AND** the banners render with pixelated scaling at their natural dimensions

#### Scenario: Odd-sized banners keep their own proportions
- **WHEN** the home page is rendered
- **THEN** every banner keeps its intrinsic proportions, including the ones that deviate from the classic 88×31 button size
