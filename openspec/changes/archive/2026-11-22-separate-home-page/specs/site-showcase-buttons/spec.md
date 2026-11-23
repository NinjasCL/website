# Spec Delta

## MODIFIED Requirements

### Requirement: Showcase action buttons use the large retrostrap size
The "Ver / View" and "Código / Code" buttons on every showcase card SHALL render at retrostrap's large button size, carried by the `rs-btn--large` variant: a label size of 1.125rem (`--rs-font-size-4`, ≈1.8× the 0.625rem small-button default) with retrostrap's large padding. Revised 2026-11-20: the owner tuned the buttons down one ladder step from the initial "at least twice as large" floor (1.25rem) after visual review. Revised 2026-11-22: the restored Jasonelle card makes thirteen showcase cards, so the count reads twenty-six buttons.

#### Scenario: Large variant in the markup
- **WHEN** the generated home page's markup is inspected
- **THEN** every showcase button carries retrostrap's `rs-btn--large` variant alongside `rs-btn--icon`

#### Scenario: Every card's buttons enlarged
- **WHEN** the home page is rendered
- **THEN** all twenty-six showcase buttons carry the enlarged presentation, and no showcase button keeps retrostrap's small variant
