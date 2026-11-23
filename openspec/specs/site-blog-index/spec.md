# site-blog-index Specification

## Purpose

The paginated blog index in the site's languages: pages of
OpenGraph-style post cards at `/blog/page/{n}/` for the default Spanish
and `/blog/{lang}/page/{n}/` for each translated language (en, ja, pt),
ordered newest first, with the `/blog/` URL redirecting to the first
page.

## Requirements

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

### Requirement: Index pages link their sibling language versions
Every index page — the default and each language version — SHALL carry a language options row: the current language as plain text marked as the current page, every other language linking its index's same page number, in the site's declared language order, the row's label led by the site's languages icon.

#### Scenario: The default index links the language indexes
- **WHEN** a visitor opens `/blog/page/1/`
- **THEN** the options row links `/blog/en/page/1/`, `/blog/ja/page/1/`, and `/blog/pt/page/1/`
- **AND** Español renders as the current page, not a link

#### Scenario: A language index links back to the default
- **WHEN** a visitor opens `/blog/en/page/2/`
- **THEN** the options row links the default `/blog/page/2/` and the Japanese and Portuguese second pages
- **AND** English renders as the current page, not a link

#### Scenario: The row's label leads with the languages icon
- **WHEN** an index page renders its language options row
- **THEN** the label leads with the languages icon (`/icons/win95/Intl101_32x32_4.png`) through the shared inline presentation — decorative, empty alt — ahead of the row's label word

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

### Requirement: Index pagination navigates between pages
Each index page SHALL render pagination navigation — a link to the
previous page when one exists, a link to the next page when one exists,
and an `n / total` counter — plus the page count SHALL follow the
catalog: `ceil(default-language posts / 25)` pages, regenerated on every
build. Both direction links SHALL use the same Win95 `Msow10_32x32_4.png`
pointing hand as the post navigation buttons, rotated a quarter turn
counter-clockwise for the previous page and clockwise for the next page —
never the former arrow sprites.

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

### Requirement: Index entry cards stand off the background and apart from each other
Each index entry block SHALL render on a background darker than the
page's main background and SHALL carry a bottom margin separating it
from the next result.

#### Scenario: Blocks stand off the background
- **WHEN** a visitor opens an index page
- **THEN** each entry block renders on a background darker than the page's main background, so the blocks differentiate from it

#### Scenario: Bottom margin separates consecutive results
- **WHEN** an index page lists more than one entry
- **THEN** every entry block carries a bottom margin, so consecutive blocks never sit flush against each other

### Requirement: Entry images cover the card's whole height
Each entry card's header image SHALL fill a right-hand column spanning
the card's entire height at a fixed width share, with the image content
zoomed and cropped — never distorted — to cover that column; the card's
text, tags, and translation links SHALL flow in the remaining left
column, and the card's height SHALL follow its text content, never the
image's natural shape.

#### Scenario: Image spans the whole card
- **WHEN** an index page lists a post with a header image
- **THEN** the image column runs the full height of the entry card, from the card's top inner edge to its bottom inner edge

#### Scenario: Zoom to fit keeps the width
- **WHEN** a listed image's natural shape does not match the column's shape
- **THEN** the image zooms and crops to cover the column without distortion, keeping the column's width unchanged

#### Scenario: Card height follows the text
- **WHEN** a listed image is naturally taller than the entry's text needs
- **THEN** the card's height follows its text content and the image crops to that height, instead of the image stretching the card

### Requirement: The index header clears the navigation menu
The blog index's title panel SHALL carry a top margin that separates
it from the masthead's navigation menu.

#### Scenario: Title panel clears the menu
- **WHEN** a visitor opens an index page
- **THEN** the title panel — its floating title included — sits a comfortable margin below the navigation menu, not flush against it
