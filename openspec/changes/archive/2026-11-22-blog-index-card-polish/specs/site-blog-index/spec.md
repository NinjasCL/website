# Spec Delta

## MODIFIED Requirements

### Requirement: Index entries are post cards with the header image
Each index entry SHALL render as one card linking the post's page,
carrying the post's featured image (header image), title, description,
date, tags, and links to the post's translated variants — the title
led by the post page's mail-news icon and the date by its calendar
icon, the same icons the post's own page uses.

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

#### Scenario: Title carries the post's mail icon
- **WHEN** an index page lists a post
- **THEN** the entry card's title leads with the mail-news icon the post's own page title uses

#### Scenario: Date carries the calendar icon
- **WHEN** an index page lists a post
- **THEN** the entry card's date leads with the calendar icon the post's own page date row uses

## REMOVED Requirements

### Requirement: Index entry cards carry a distinct darker surface
**Reason**: The requirement bundled the darker surface with a
top-padding breathing-room rhythm that full-height cover images
retire — the padding would sit as an empty strip above the image
column's top edge, and the inter-result spacing it faked now lives
between the frames as a real bottom margin.
**Migration**: The darker surface survives unchanged and the spacing
becomes bottom-margin separation in the replacement requirement
below, "Index entry cards stand off the background and apart from
each other".

## ADDED Requirements

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
