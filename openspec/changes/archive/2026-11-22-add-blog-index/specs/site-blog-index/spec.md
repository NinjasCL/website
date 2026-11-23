# Spec Delta

## Purpose

The paginated Spanish-language blog index: pages of OpenGraph-style post
cards at `/blog/page/{n}/`, ordered newest first, with the `/blog/` URL
redirecting to the first page.

## ADDED Requirements

### Requirement: Blog index lists default-language posts paginated
The site SHALL render an index page at `/blog/page/{n}/` for every page
number up to the page count, listing only the default-language (Spanish)
posts in descending date order, newest first, 25 posts per page.

#### Scenario: First page lists the newest posts
- **WHEN** the site is built with at least 25 default-language posts
- **THEN** `/blog/page/1/` lists the 25 newest default-language posts in descending date order
- **AND** no machine-translated variant appears as a list entry

#### Scenario: Later pages continue the same order
- **WHEN** a visitor opens `/blog/page/2/`
- **THEN** the page lists default-language posts 26 through 50 of the same newest-first order

#### Scenario: Last page holds the remainder
- **WHEN** the default-language post count is not a multiple of 25
- **THEN** the last page lists the remaining posts, fewer than 25

### Requirement: Index entries are post cards with the header image
Each index entry SHALL render as one card linking the post's page,
carrying the post's featured image (header image), title, description,
date, tags, and links to the post's translated variants.

#### Scenario: Entry card shows the post's cover
- **WHEN** an index page lists a post whose frontmatter carries a `featured_image`
- **THEN** the entry card displays that image, the post's title and description, and links the post's page

#### Scenario: Entry card falls back to the site image
- **WHEN** a listed post carries no `featured_image`
- **THEN** the entry card displays the site's default image (`/img/Ninjas.png`)

#### Scenario: Entry card links the post's translations
- **WHEN** an index page lists a post that ships the English, Japanese, and Portuguese variants
- **THEN** the entry card carries a link to each variant's page inside the block

#### Scenario: Entry card shows the post's tags
- **WHEN** an index page lists a post whose frontmatter carries `tags`
- **THEN** the entry card displays the post's tags

### Requirement: Index pagination navigates between pages
Each index page SHALL render pagination navigation — a link to the
previous page when one exists, a link to the next page when one exists,
and an `n / total` counter — plus the page count SHALL follow the
catalog: `ceil(default-language posts / 25)` pages, regenerated on every
build.

#### Scenario: Middle page links both neighbors
- **WHEN** a visitor opens a page between the first and the last
- **THEN** the page links both the previous and the next page and shows its `n / total` counter

#### Scenario: First and last pages have one neighbor each
- **WHEN** a visitor opens `/blog/page/1/` or the last page
- **THEN** the first page links only the next page and the last page links only the previous page

#### Scenario: Pagination follows the catalog on rebuild
- **WHEN** posts are added or removed and the site is rebuilt
- **THEN** the page count and pagination links reflect the new catalog on every build without manual steps

### Requirement: The blog URL redirects to the first index page
The site SHALL serve `/blog/` as a redirect page pointing at
`/blog/page/1/`.

#### Scenario: Blog URL resolves
- **WHEN** a visitor opens `/blog/`
- **THEN** the page redirects to `/blog/page/1/`

### Requirement: Blog index renders with the site chrome
Each index page SHALL render with the site's shared navigation menu,
masthead header, and site footer — the same components the other site
pages use.

#### Scenario: Menu, header and footer ride along
- **WHEN** a visitor opens any index page
- **THEN** the page carries the site navigation menu, the masthead header, and the site footer

### Requirement: Index title section links the syndication feed
Each index page's title section SHALL carry an RSS link with the feed
icon, pointing at the site's syndication feed.

#### Scenario: Title section shows the feed link
- **WHEN** a visitor opens an index page
- **THEN** the title section displays the feed icon linking the site's syndication feed

### Requirement: Index pages are discoverable
The generated sitemap SHALL include every `/blog/page/{n}/` route and
SHALL NOT include the `/blog/` redirect route.

#### Scenario: Sitemap lists the index pages
- **WHEN** the sitemap is generated
- **THEN** every index page route appears in it
- **AND** the `/blog/` redirect route does not
