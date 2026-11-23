# Spec Delta

## MODIFIED Requirements

### Requirement: Index entries are post cards with the header image
Each index entry SHALL render as one card linking the post's page, carrying the post's featured image (header image), title, description, date, tags, and links to the post's variants in every other language — the title led by the post page's mail-news icon and the date by its calendar icon, the same icons the post's own page uses.

#### Scenario: Entry card shows the post's cover
- **WHEN** an index page lists a post whose frontmatter carries a `featured_image`
- **THEN** the entry card displays that image, the post's title and description, and links the post's page

#### Scenario: Entry card falls back to the site image
- **WHEN** a listed post carries no `featured_image`
- **THEN** the entry card displays the site's default image (`/img/Ninjas.png`)

#### Scenario: Entry card links the post's translations
- **WHEN** the default index lists a post that ships the English, Japanese, and Portuguese variants
- **THEN** the entry card carries a link to each variant's page inside the block

#### Scenario: Translated index cards link the original and the other translations
- **WHEN** the English index lists a post that ships all four variants
- **THEN** the entry card's language row links the Spanish original and the Japanese and Portuguese variants
- **AND** the row carries no link to the English page the card itself already links

#### Scenario: Entry card shows the post's tags
- **WHEN** an index page lists a post whose frontmatter carries `tags`
- **THEN** the entry card displays the post's tags

#### Scenario: Title carries the post's mail icon
- **WHEN** an index page lists a post
- **THEN** the entry card's title leads with the mail-news icon the post's own page title uses

#### Scenario: Date carries the calendar icon
- **WHEN** an index page lists a post
- **THEN** the entry card's date leads with the calendar icon the post's own page date row uses

## ADDED Requirements

### Requirement: Language blog indexes list their language's posts paginated
The site SHALL render a blog index at `/blog/{lang}/page/{n}/` for each translated language — English, Japanese, and Portuguese — listing only that language's post variants in descending date order, newest first, 25 per page, with the same pagination navigation as the default index linking the same language's pages.

#### Scenario: Language index lists the language's variants
- **WHEN** a visitor opens `/blog/en/page/1/`
- **THEN** the page lists the newest English variants, newest first, 25 per page
- **AND** no default-language post or other-language variant appears as a list entry

#### Scenario: Language pagination stays in language
- **WHEN** a visitor opens a language index page between the first and the last
- **THEN** the previous and next links target the same language's index pages

#### Scenario: Language indexes join the sitemap
- **WHEN** the sitemap is generated
- **THEN** every language index route appears in it, like the default index pages

### Requirement: Language index pages render in their language
Each language index page SHALL declare its language — the html `lang` attribute and the OpenGraph locale — and render its own copy in it: the page title, the panel heading, the meta description, the panel intro, the pagination button labels, and the options row's label. The shared chrome — navigation menu, masthead, footer — rides along in the site's default presentation, as on post pages.

#### Scenario: The Japanese page declares and speaks Japanese
- **WHEN** a visitor opens `/blog/ja/page/1/`
- **THEN** the page carries the Japanese html `lang` value and OpenGraph locale
- **AND** the page title, panel heading, intro, and pagination buttons render in Japanese

#### Scenario: The default index keeps its Spanish presentation
- **WHEN** a visitor opens `/blog/page/1/`
- **THEN** the page renders exactly as before — the Spanish title, intro, and pagination, the `es-CL` language — unchanged by the language versions

#### Scenario: Shared chrome rides along
- **WHEN** a visitor opens a language index page
- **THEN** the page carries the same navigation menu, masthead header, and site footer as the default index

### Requirement: Index pages link their sibling language versions
Every index page — the default and each language version — SHALL carry a language options row: the current language as plain text marked as the current page, every other language linking its index's same page number, in the site's declared language order.

#### Scenario: The default index links the language indexes
- **WHEN** a visitor opens `/blog/page/1/`
- **THEN** the options row links `/blog/en/page/1/`, `/blog/ja/page/1/`, and `/blog/pt/page/1/`
- **AND** Español renders as the current page, not a link

#### Scenario: A language index links back to the default
- **WHEN** a visitor opens `/blog/en/page/2/`
- **THEN** the options row links the default `/blog/page/2/` and the Japanese and Portuguese second pages
- **AND** English renders as the current page, not a link
