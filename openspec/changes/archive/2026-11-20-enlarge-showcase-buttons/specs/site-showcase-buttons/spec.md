# Spec Delta

## Purpose

Defines the action buttons on the home page's showcase cards — the "Ver / View" and "Código / Code" links in Proyectos, Libros, and Juegos: their enlarged presentation and the icons they carry from the site's static assets.

## ADDED Requirements

### Requirement: Showcase action buttons use the large retrostrap size
The "Ver / View" and "Código / Code" buttons on every showcase card SHALL render at retrostrap's large button size, carried by the `rs-btn--large` variant: a label size of 1.125rem (`--rs-font-size-4`, ≈1.8× the 0.625rem small-button default) with retrostrap's large padding. Revised 2026-11-20: the owner tuned the buttons down one ladder step from the initial "at least twice as large" floor (1.25rem) after visual review.

#### Scenario: Large variant in the markup
- **WHEN** the generated home page's markup is inspected
- **THEN** every showcase button carries retrostrap's `rs-btn--large` variant alongside `rs-btn--icon`

#### Scenario: Every card's buttons enlarged
- **WHEN** the home page is rendered
- **THEN** all twenty-four showcase buttons carry the enlarged presentation, and no showcase button keeps retrostrap's small variant

### Requirement: View and Code buttons carry matching icons
Each showcase button SHALL carry an icon matching its action from the site's own static icon assets, rendering beside its label: the "Ver / View" button shows the Quick View icon, and the "Código / Code" button shows the script icon.

#### Scenario: View icon beside the label
- **WHEN** the home page is rendered
- **THEN** every "Ver / View" button shows the Quick View icon (`/icons/Quikview1_32x32_4.png`) beside the "Ver / View" label

#### Scenario: Code icon beside the label
- **WHEN** the home page is rendered
- **THEN** every "Código / Code" button shows the script icon (`/icons/Wscript100_32x32_4.png`) beside the "Código / Code" label

#### Scenario: Icon assets ship with the site
- **WHEN** the site is generated
- **THEN** the button icon files from the configured static asset directory are included in the generated site output

### Requirement: Buttons outside the showcase cards keep their presentation
The enlargement and icons SHALL apply only to the showcase card buttons; the contact mailto button and the footer controls SHALL keep their current classes and sizing.

#### Scenario: Contact button unchanged
- **WHEN** the home page is rendered
- **THEN** the contact mailto button keeps its current primary presentation, without the showcase enlargement or icons

#### Scenario: Footer buttons unchanged
- **WHEN** the home page is rendered
- **THEN** the footer badge buttons keep their current presentation, unaffected
