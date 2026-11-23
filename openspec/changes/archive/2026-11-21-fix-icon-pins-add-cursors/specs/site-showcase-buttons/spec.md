# Spec Delta

## MODIFIED Requirements

### Requirement: View and Code buttons carry matching icons
Each showcase button SHALL carry an icon matching its action from the site's own static icon assets, rendering beside its label: the "Ver / View" button shows the Internet Explorer globe icon (revised 2026-11-20 from the initial Quick View pick by the site owner), and the "Código / Code" button shows the script icon.

#### Scenario: View icon beside the label
- **WHEN** the home page is rendered
- **THEN** every "Ver / View" button shows the Internet Explorer globe icon (`/icons/win95/Shdocvw257_32x32_8.png`) beside the "Ver / View" label

#### Scenario: Code icon beside the label
- **WHEN** the home page is rendered
- **THEN** every "Código / Code" button shows the script icon (`/icons/win95/Wscript100_32x32_4.png`) beside the "Código / Code" label

#### Scenario: Icon assets ship with the site
- **WHEN** the site is generated
- **THEN** the button icon files from the configured static asset directory are included in the generated site output
