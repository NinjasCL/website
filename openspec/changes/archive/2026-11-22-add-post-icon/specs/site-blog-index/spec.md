# Spec Delta

## MODIFIED Requirements

### Requirement: Index entries are post cards with the header image
Each index entry SHALL render as one card linking the post's page, carrying the post's featured image (header image), title, description, date, tags, and links to the post's variants in every other language — the title led by the post's own title icon (its declared `icon` frontmatter value, or the newspaper icon as its fallback, see `site-post-icons`) and the date by its calendar icon, the same icons the post's own page uses.

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
- **THEN** the entry card's title leads with the post's own title icon — its declared value, or the newspaper icon (`/icons/win95/Mailnews8_32x32_4.png`) when it declares none — the same icon the post's own page title uses

#### Scenario: Date carries the calendar icon
- **WHEN** an index page lists a post
- **THEN** the entry card's date leads with the calendar icon the post's own page date row uses
