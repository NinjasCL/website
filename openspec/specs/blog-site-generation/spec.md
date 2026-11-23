# blog-site-generation Specification

## Purpose

Define the core static blog/site generation behavior for Ninjas.cl using blogatto so the repository can produce a working site from configured content, templates, and routes.

## Requirements

### Requirement: Site build generates static output
The system SHALL generate the static site into the configured output directory when invoked through the project entrypoint using the Ninjas.cl blogatto configuration.

#### Scenario: Successful build
- **WHEN** the project build is run with a valid Ninjas.cl site configuration, post source, and required content
- **THEN** the configured output directory contains the generated site pages without reporting a build error

### Requirement: Site configuration reflects Ninjas.cl identity
The production build SHALL configure site generation with `https://ninjas.cl/` as the base URL, plus the Ninjas.cl title, description, and Spanish (Chile) default language context.

#### Scenario: Generated pages use configured site identity
- **WHEN** the production site is generated from the Ninjas.cl configuration
- **THEN** generated pages reflect `https://ninjas.cl/` as the site URL context, the Ninjas.cl site title, site description, and default language context

#### Scenario: Production absolute URLs use Ninjas.cl
- **WHEN** a production page links to another site page
- **THEN** the generated absolute URL uses `https://ninjas.cl/`

### Requirement: Home route lists available posts
The system SHALL expose a home route that renders a page listing available blog posts from the configured post source.

#### Scenario: Home page includes a published post
- **WHEN** the site is generated with at least one valid post in the configured post source
- **THEN** the generated home page includes an entry for that post with navigation to its post page

### Requirement: Post content is rendered as pages
The system SHALL load djot posts with required frontmatter from the configured post source and render each post as a site page using the configured post template and routing convention.

#### Scenario: Post page is generated from source content
- **WHEN** the site is generated with a valid post containing required frontmatter and body content
- **THEN** a corresponding post page is generated at the configured route and includes the post's rendered content and metadata defined by the template

### Requirement: Build uses project content and asset conventions
The system SHALL read posts from the configured content directory and copy static assets from the configured static directory as part of core site generation.

#### Scenario: Static assets are included in output
- **WHEN** the site is generated with files present in the configured static asset directory
- **THEN** those assets are available in the generated site output according to the configured static asset handling

### Requirement: The site description presents Ninjas' identity
The site's description SHALL present Ninjas' identity in Spanish, crediting the founder by handle: "Ninjas es un grupo desarrollador de software experimental de Chile 🇨🇱. Participa en diversos proyectos tecnológicos, tales como videojuegos, software y otras actividades relacionadas. Ninjas.cl fue fundado en 2015 (¡11 años programando ❤️!) por @CLSource."

#### Scenario: The hero's description note
- **WHEN** the home page is rendered
- **THEN** the hero's description note shows the description text

#### Scenario: The home page's meta description
- **WHEN** the generated home page's markup is inspected
- **THEN** its meta description carries the description text

### Requirement: Blog content is written in djot
The site's content syntax SHALL be djot: every post under the configured content directory is a djot source file (`.djot` or `.dj`), and markdown, asciidoc, or any other format SHALL be converted to djot rather than added — the content directory holds no non-djot post sources.

#### Scenario: The shipped post is djot
- **WHEN** the content directory is inspected
- **THEN** the post's source is a djot file whose body uses djot syntax, and no markdown source remains

#### Scenario: Djot renders through the native engine
- **WHEN** the site is generated
- **THEN** the post's djot body — headings, links, and single-asterisk strong — renders via blogatto's djot source format

#### Scenario: The content references ship in the repo
- **WHEN** a contributor needs the djot syntax or the engine's documentation
- **THEN** the djot reference is available at `examples/djot/doc` — the cheatsheet, the full syntax guide, and the quickstart for markdown users
- **AND** the blogatto documentation is available at `examples/blogatto/docs`

### Requirement: The build generates a sitemap
The configured build SHALL generate a `sitemap.xml` at the output root listing every static route and every post URL at the site's absolute URLs, so search engines can discover the site's pages.

#### Scenario: Sitemap lists the routes and posts
- **WHEN** the site is generated with at least one post
- **THEN** the output contains `sitemap.xml` whose entries include the home route and the post's URL at the site's absolute URL

### Requirement: The build generates robots.txt
The configured build SHALL generate a `robots.txt` at the output root that points crawlers at the sitemap and allows all of them site-wide.

#### Scenario: Robots points at the sitemap and allows all
- **WHEN** the generated site's `robots.txt` is inspected
- **THEN** it carries the sitemap pointer at the site's absolute sitemap URL
- **AND** a `User-agent: *` policy allowing `/`

### Requirement: The build generates Atom and RSS feeds
The configured build SHALL generate four Atom 1.0 feeds and an RSS 2.0 feed from the blog posts: `/atom.xml` contains only the Spanish default variants (`post.language == None`), while `/en/atom.xml`, `/ja/atom.xml`, and `/pt/atom.xml` contain only their respective language's variants. Every feed carries the Ninjas.cl title and the Spanish site description, with `@CLSource` as the Atom author and the es-CL language on the RSS channel.

#### Scenario: Both feeds ship with the site identity
- **WHEN** the site is generated with at least one post
- **THEN** the output contains `atom.xml`, `en/atom.xml`, `ja/atom.xml`, `pt/atom.xml`, and `rss.xml`, each carrying the site title and description and the post's matching-language variant as an entry

#### Scenario: Atom feeds contain only their own language
- **WHEN** a post ships Spanish, English, Japanese, and Portuguese variants
- **THEN** each Atom feed lists exactly that language's variant of the post
- **AND** the default `atom.xml` lists the Spanish variant, whose language is absent from the post metadata

#### Scenario: Atom feeds identify their own language
- **WHEN** the generated Atom feeds are inspected
- **THEN** each feed has an absolute id pointing to its own feed URL and a `self` link carrying the matching language

#### Scenario: The feeds regenerate on every build
- **WHEN** the build runs again (including the dev build the live server re-runs)
- **THEN** all feeds are rewritten, each Atom feed's updated stamp reflecting the build time

### Requirement: Post-adjacent files ship with the post
The build SHALL copy the files that sit beside a post's source — images, code, and data files that are not post sources — into that post's output directory by base name, so they are served at the post's URL.

#### Scenario: The migrated post's files ship beside its page
- **WHEN** the site is generated with a post directory that contains a cover image, an input data file, and a source code file beside its djot sources
- **THEN** those files are present in the post's output directory at the post's URL, and the post's featured image resolves there

#### Scenario: The post body references its adjacent files relatively
- **WHEN** a post's body references one of its adjacent files by a relative path
- **THEN** the reference resolves from the post page's URL to the copied file

### Requirement: Collapsible solution code blocks
A fenced code block whose info string carries a `summary` attribute (`{summary="…"}`) SHALL render as a working collapsible toggle — a `details`/`summary` element wrapping that block's code — with its highlighting unaffected.

#### Scenario: The summary attribute renders a working toggle
- **WHEN** a post carries a fenced code block like ` ```go {summary="Mostrar solución"} `
- **THEN** the generated page wraps that block's highlighted code inside a `details` element whose `summary` carries the declared text, so the toggle opens and closes over the code

#### Scenario: The toggle keeps its highlighting
- **WHEN** a summary-carrying code block is rendered
- **THEN** its code still renders with the smalto token spans and the bare language class, exactly like an untagged block

#### Scenario: Blocks without the attribute stay uncollapsible
- **WHEN** a fenced code block carries no `summary` attribute
- **THEN** it renders as a plain (highlighted) code block with no toggle

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

### Requirement: Post pages render their tags
Every post page whose frontmatter declares a `tags` field SHALL render those tags as a row of small rounded labels below the post's date, led by the Bookmark icon.

#### Scenario: Tags render as labels below the date
- **WHEN** a post with a `tags` frontmatter field is rendered
- **THEN** the page shows each tag as a rounded label, positioned between the date line and the description

#### Scenario: Posts without tags render no row
- **WHEN** a post has no `tags` frontmatter field
- **THEN** no tags row renders between the date and the description

### Requirement: Post pages navigate to adjacent entries
Every post page with neighbors SHALL render navigation to its adjacent entries in the newest-first post list — "Anterior" linking the previous entry (the newer post) and "Siguiente" linking the next entry (the older post) — each rendered as the site's large retrostrap icon button with its direction icon, and each targeting the neighbor's variant in the page's own language. The direction icons SHALL be the Win95 `Msow10_32x32_4.png` hand, which points up in the pack: the "Anterior" button rotates it a quarter turn counter-clockwise to point left, and the "Siguiente" button rotates it a quarter turn clockwise to point right.

#### Scenario: A middle post links both neighbors
- **WHEN** a post with a newer and an older neighbor is rendered
- **THEN** the page renders both icon buttons, each carrying its neighbor's title and URL — the counter-clockwise-rotated "Anterior" hand pointing left and the clockwise-rotated "Siguiente" hand pointing right

#### Scenario: The end posts link their single neighbor
- **WHEN** the newest or the oldest post is rendered
- **THEN** the page renders only the one button that has a neighbor — "Siguiente" for the newest, "Anterior" for the oldest

#### Scenario: Navigation stays in the reader's language
- **WHEN** a translated variant page is rendered
- **THEN** its navigation buttons target the same language's variant of the neighbors

#### Scenario: A lone post renders no navigation
- **WHEN** a site with a single post renders its page
- **THEN** no navigation element renders

### Requirement: Post pages list random other entries
Every post page with entries beyond its navigation SHALL render, before the footer, a list of up to five entries picked at random at build time from the default-language catalog — the current post and its navigation neighbors (the previous and next entries) excluded — each resolved to the reader's current language variant.

#### Scenario: A large catalog lists five random entries
- **WHEN** a post is rendered with more than five entries left after excluding the current post and its neighbors
- **THEN** the list shows exactly five of them — a fresh random set each build — and never the current, previous, or next post

#### Scenario: A small catalog lists the remaining others
- **WHEN** fewer than five entries remain after the exclusions
- **THEN** the list shows every one of them

#### Scenario: The list stays in the reader's language
- **WHEN** a translated variant page is rendered
- **THEN** every listed entry links to the same language's variant

#### Scenario: Nothing left beyond the navigation renders no list
- **WHEN** a site's every other entry is the page's navigation neighbor or the page itself
- **THEN** no random-entries section renders

### Requirement: Post code blocks are highlighted at build time
Post code blocks tagged with a recognized language SHALL render with build-time syntax highlighting — smalto token spans styled by the site's stylesheet in the Night Owl palette — on a code block background darker than the page, while untagged blocks and unrecognized language tags render as plain code.

#### Scenario: Recognized languages highlight
- **WHEN** a post carries fenced code blocks tagged `go` and `elixir`
- **THEN** the generated pages wrap the blocks' tokens in spans carrying the smalto token classes, with no client-side script involved

#### Scenario: Untagged and unknown stay plain
- **WHEN** a code block is untagged or tagged with a language the highlighter does not know
- **THEN** it renders as plain code with no token spans

#### Scenario: The token styles ship with the stylesheet
- **WHEN** the site's stylesheet is inspected
- **THEN** post code blocks sit on the Night Owl editor background — darker than the page background, framed by the theme's contrast border — and the smalto token classes carry the Night Owl palette colors

### Requirement: Inline code spans render inline
A single-backtick span in a post SHALL render as an inline `code` element within its surrounding prose — never as a block-level code panel — while a fenced code block without a language tag SHALL keep its block-level panel.

#### Scenario: A single-backtick mention stays in its sentence
- **WHEN** a post carries an inline code span such as `~/.config/emacs` in a paragraph
- **THEN** the generated page renders a bare `<code>` element in that paragraph, with no `<pre>` wrapper and no line break around the span

#### Scenario: An untagged fence still renders as a block
- **WHEN** a post carries a fenced block with no language tag
- **THEN** the generated page still wraps its code in a `<pre>` panel, and tagged blocks, summary toggles, and embed fences keep their existing structure

### Requirement: Post body typography
The post body text SHALL render at the font ladder's size-3 step — 16px at the default root size, honoring the reader's browser font preferences — and post code, both blocks and inline spans, SHALL use the JetBrains Mono family with the site's mono stack as fallback, the font loaded from Google Fonts in every generated page's head. Inline code spans SHALL be highlighted with light text (`#fafafa`) on the site's violet (`#7540bd`).

#### Scenario: The post body reads at the 16px step
- **WHEN** the site's stylesheet is inspected
- **THEN** the post body carries the ladder's size-3 font size — one step up from the cosmic theme's 13px body

#### Scenario: Post code uses JetBrains Mono
- **WHEN** the site's stylesheet is inspected
- **THEN** post code blocks and inline code spans carry the JetBrains Mono family with the retrostrap mono stack as fallback

#### Scenario: The font ships from Google Fonts on every page
- **WHEN** any generated page's head is inspected
- **THEN** it carries the preconnect to `fonts.googleapis.com`, the crossorigin preconnect to `fonts.gstatic.com`, and the JetBrains Mono stylesheet link with `display=swap`

#### Scenario: Inline spans carry the violet highlight
- **WHEN** the site's stylesheet is inspected
- **THEN** inline code spans carry `color: #fafafa` on `background-color: #7540bd`, distinguishing them from fenced code panels

### Requirement: Plain-text post URLs render as clickable links
Every bare `http(s)://` URL in a post's body prose SHALL render as a clickable anchor whose href and visible text are the URL itself, in every language variant of the post.

#### Scenario: A bare URL in prose becomes an anchor
- **WHEN** a post's body prose carries a bare `http(s)://` URL — mid-sentence, as a list item, or on its own line
- **THEN** the generated page renders it as an `<a>` whose href is the URL and whose visible text is the URL

#### Scenario: Trailing punctuation stays outside the link
- **WHEN** a bare URL ends a sentence or a reference entry with trailing `.,;:!?`
- **THEN** the anchor covers the URL only and the punctuation renders outside the link

#### Scenario: A URL's balanced trailing parenthesis stays inside
- **WHEN** a bare URL contains an unmatched `(` that its trailing `)` closes, as a parenthesized Wikipedia title
- **THEN** the anchor covers the URL including that trailing `)`
- **AND** a trailing `)` with no opening `(` inside the URL stays outside the link

#### Scenario: Code and embed payloads stay unchanged
- **WHEN** a URL appears inside a fenced code block, an inline code span, an embed fence payload (`github`, `youtube`, `ninjas`, `embed`), or raw HTML in the post
- **THEN** it renders exactly as before, with no added anchor

#### Scenario: Existing links and metadata stay unchanged
- **WHEN** a URL already serves as a `[text](url)` link's text or target, an image target, an existing `<…>` autolink, or a frontmatter value such as `featured_image`
- **THEN** the rendered output is unchanged

#### Scenario: Every language variant renders the anchor
- **WHEN** a post's Spanish, English, Japanese, and Portuguese variants carry the same bare URL in prose
- **THEN** each variant's generated page renders it as an anchor

### Requirement: Post descriptions link bare URLs
A post page's description paragraph and the home page's featured-post description SHALL render each bare `http(s)://` URL in the post's `description` frontmatter as an anchor whose href and visible text are the URL, with the surrounding prose as plain text.

#### Scenario: The post page description links its URLs
- **WHEN** a post's `description` frontmatter carries a bare `http(s)://` URL
- **THEN** the post page's description paragraph renders the URL as an `<a>` linking itself, inline with the description's prose

#### Scenario: The featured row links its URLs
- **WHEN** the featured post's `description` frontmatter carries a bare `http(s)://` URL
- **THEN** the home page's featured-post description renders the URL as an `<a>` linking itself

#### Scenario: Trailing punctuation and unbalanced parens stay outside
- **WHEN** a description's URL run ends in `.,;:!?`, or in a `)` that closes no `(` inside the URL
- **THEN** those trailing characters render outside the anchor

#### Scenario: Index entry cards keep descriptions plain
- **WHEN** the blog index renders a post whose `description` carries a bare URL
- **THEN** the entry card's description stays plain text — the card is one link, and anchors cannot nest — with no anchor to the URL anywhere on the index page

#### Scenario: Meta descriptions keep the raw text
- **WHEN** a post page's meta description attributes (name, OpenGraph, Twitter) carry the description
- **THEN** they carry the raw frontmatter text with no anchor markup
