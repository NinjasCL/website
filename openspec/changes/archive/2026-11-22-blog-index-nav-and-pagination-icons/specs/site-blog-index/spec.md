# Spec Delta

## MODIFIED Requirements

### Requirement: Language index pages render in their language
Each language index page SHALL declare its language — the html `lang` attribute and the OpenGraph locale — and render its own copy in it: the page title, the panel heading, the meta description, the panel intro, the pagination button labels, the options row's label, and the shared navigation menu's six link labels plus its aria-label. The masthead and footer ride along in the site's default presentation, as on post pages.

#### Scenario: The Japanese page declares and speaks Japanese
- **WHEN** a visitor opens `/blog/ja/page/1/`
- **THEN** the page carries the Japanese html `lang` value and OpenGraph locale
- **AND** the page title, panel heading, intro, and pagination buttons render in Japanese

#### Scenario: The default index keeps its Spanish presentation
- **WHEN** a visitor opens `/blog/page/1/`
- **THEN** the page renders exactly as before — the Spanish title, intro, pagination, and navigation menu, the `es-CL` language — unchanged by the language versions

#### Scenario: Shared chrome rides along
- **WHEN** a visitor opens a language index page
- **THEN** the page carries the same masthead header and site footer as the default index

#### Scenario: The navigation menu speaks the page's language
- **WHEN** a visitor opens a language index page
- **THEN** the six navbar link labels and the navigation region's aria-label render in that page's language, matching the translated home pages
- **AND** no default-language navbar label remains

### Requirement: Index pagination navigates between pages
Each index page SHALL render pagination navigation — a link to the previous page when one exists, a link to the next page when one exists, and an `n / total` counter — plus the page count SHALL follow the catalog: `ceil(default-language posts / 25)` pages, regenerated on every build. Both direction links SHALL use the same Win95 `Msow10_32x32_4.png` pointing hand as the post navigation buttons, rotated a quarter turn counter-clockwise for the previous page and clockwise for the next page — never the former arrow sprites.

#### Scenario: Middle page links both neighbors
- **WHEN** a visitor opens a page between the first and the last
- **THEN** the page links both the previous and the next page and shows its `n / total` counter

#### Scenario: First and last pages have one neighbor each
- **WHEN** a visitor opens `/blog/page/1/` or the last page
- **THEN** the first page links only the next page and the last page links only the previous page

#### Scenario: Pagination follows the catalog on rebuild
- **WHEN** posts are added or removed and the site is rebuilt
- **THEN** the page count and pagination links reflect the new catalog on every build without manual steps

#### Scenario: Pagination points with the post navigation hand
- **WHEN** an index page renders its previous and next page buttons
- **THEN** each button carries the Win95 `Msow10_32x32_4.png` hand with the same `post-nav__hand--left` / `post-nav__hand--right` rotation classes the post navigation buttons use
- **AND** neither the `ArrowLeft_32x32_4.png` nor the `ArrowRight_32x32_4.png` sprite appears in the pagination
