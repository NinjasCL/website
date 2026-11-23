# Spec Delta

## MODIFIED Requirements

### Requirement: Showcase action buttons use the large retrostrap size
The view and code buttons on every showcase card — "Ver" / "Código" on the Spanish home, "View" / "Code" on English, "見る" / "コード" on Japanese, "Ver" / "Código" on Portuguese; revised 2026-11-22 from the bilingual "Ver / View" and "Código / Code" labels by the site owner — SHALL render at retrostrap's large button size, carried by the `rs-btn--large` variant: a label size of 1.125rem (`--rs-font-size-4`, ≈1.8× the 0.625rem small-button default) with retrostrap's large padding. Revised 2026-11-20: the owner tuned the buttons down one ladder step from the initial "at least twice as large" floor (1.25rem) after visual review. Revised 2026-11-22: the restored Jasonelle card makes thirteen showcase cards, so the count reads twenty-six buttons per home.

#### Scenario: Large variant in the markup
- **WHEN** any home page's markup is inspected
- **THEN** every showcase button carries retrostrap's `rs-btn--large` variant alongside `rs-btn--icon`

#### Scenario: Every card's buttons enlarged
- **WHEN** a home page is rendered
- **THEN** all twenty-six showcase buttons carry the enlarged presentation, and no showcase button keeps retrostrap's small variant

#### Scenario: One word per language
- **WHEN** any home page is rendered
- **THEN** each showcase button's label is a single word in the page's language — never the bilingual "Ver / View" or "Código / Code" form

### Requirement: View and Code buttons carry matching icons
Each showcase button SHALL carry an icon matching its action from the site's own static icon assets, rendering beside its single-word label in the page's language: the view button ("Ver" on Spanish, "View" on English, "見る" on Japanese, "Ver" on Portuguese) shows the Internet Explorer globe icon (revised 2026-11-20 from the initial Quick View pick by the site owner), and the code button ("Código" on Spanish, "Code" on English, "コード" on Japanese, "Código" on Portuguese) shows the script icon.

#### Scenario: View icon beside the label
- **WHEN** any home page is rendered
- **THEN** every view button shows the Internet Explorer globe icon (`/icons/win95/Shdocvw257_32x32_8.png`) beside its single-word label in the page's language

#### Scenario: Code icon beside the label
- **WHEN** any home page is rendered
- **THEN** every code button shows the script icon (`/icons/win95/Wscript100_32x32_4.png`) beside its single-word label in the page's language

#### Scenario: Icon assets ship with the site
- **WHEN** the site is generated
- **THEN** the button icon files from the configured static asset directory are included in the generated site output
