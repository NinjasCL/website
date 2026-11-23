# Spec Delta

## ADDED Requirements

### Requirement: GitHub OpenGraph data is cached during the build
The build SHALL cache GitHub repository page HTML and social-card images in the git-ignored `.opengraph/` directory, keyed by the MD5 hash of the repository URL. A cache hit SHALL reuse the stored files without another network request; a cache miss SHALL fetch the page once and store its HTML as `{md5}.html.cache` and its image as `{md5}.png`.

#### Scenario: First build warms the cache
- **WHEN** a post first renders a `github` fence for `owner/repo`
- **THEN** the build fetches `https://github.com/owner/repo` and its social-card image
- **AND** writes `.opengraph/{md5}.html.cache` and `.opengraph/{md5}.png`

#### Scenario: Later builds use the cache
- **WHEN** the same repository appears again in the same build or in a later build
- **THEN** the existing HTML and image files are reused without another GitHub request

#### Scenario: Cache files stay out of version control
- **WHEN** the repository state is inspected
- **THEN** `.opengraph/` is git-ignored and no cached HTML or image files are committed

### Requirement: Cached GitHub images are served from the site
The build SHALL copy each cached GitHub image into the generated site at `/opengraph/{md5}.png` and reference that path from the repository card. If fetching or copying the image fails, the card SHALL use `https://opengraph.githubassets.com/1/owner/repo` instead and the build SHALL still complete.

#### Scenario: A warmed cache produces a local image
- **WHEN** a `github` fence has a cached image
- **THEN** the build copies it into `dist/opengraph/{md5}.png`
- **AND** the rendered card points at `/opengraph/{md5}.png`

#### Scenario: Fetches fail or the image is unavailable
- **WHEN** the HTML or image fetch fails, or the cache cannot be copied into the generated site
- **THEN** the rendered card uses `https://opengraph.githubassets.com/1/owner/repo` as its image
- **AND** the build still completes with a valid card

## MODIFIED Requirements

### Requirement: Content tags render as embed components
A fenced content block whose info string is `github`, `youtube`, `ninjas`, or `embed` SHALL render as its embed instead of a code panel: a full OpenGraph card (site name, title, description, and image, the whole card one link) for `github`, `ninjas`, and external-website `embed` fences, and a full-width YouTube player for `youtube` fences.

#### Scenario: The GitHub fence renders a repository card
- **WHEN** a post carries a ```` ```github ```` fence with `owner/repo | description`
- **THEN** the page renders a full embed card linking `https://github.com/owner/repo`, carrying the repository name as its title, the given description as its text, the site name GitHub, and the cached site-local image `/opengraph/{md5}.png` when the cache is available
- **AND** the card uses `https://opengraph.githubassets.com/1/owner/repo` only when the cache cannot be produced

#### Scenario: The YouTube fence renders a player
- **WHEN** a post carries a ```` ```youtube ```` fence with a watch URL, a youtu.be URL, or a bare video id
- **THEN** the page renders the video's embedded YouTube player at full content width, 16:9 and at most 640px tall, inside the site's dashed frame, with the old template's allow list (`accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share`)

#### Scenario: The ninjas fence renders a blog post card
- **WHEN** a post carries a ```` ```ninjas ```` fence with `slug | Post title | description | image`
- **THEN** the page renders a full embed card linking `https://ninjas.cl/blog/slug/`, carrying the given title, description, and image, with the site name Ninjas.cl

#### Scenario: The embed fence renders a full external-website card
- **WHEN** a post carries a ```` ```embed ```` fence with `url | title | description | image`
- **THEN** the page renders a full embed card linking the given URL, carrying the given title, description, and image, with the site name derived from the URL's host

#### Scenario: Real code keeps its panel
- **WHEN** a fenced block carries a code language (or none)
- **THEN** it still renders inside the Night Owl code panel, with highlighting and the `{summary}` toggle behavior unchanged in substance
