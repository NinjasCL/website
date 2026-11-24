# draft-workflow Specification

## Purpose

Defines how unpublished post drafts are created, kept out of every production publisher, previewed with the site's own rendering, and promoted into the published catalog after translations are generated.

## Requirements

### Requirement: Unpublished drafts stay outside production outputs

Posts under the drafts root SHALL be invisible to production builds, Qiita exports, feeds, sitemaps, manifest post dates, blog pagination, and image optimization. A draft becomes publishable only when its directory is moved into the published content root.

#### Scenario: A draft is not rendered by the production build
- **WHEN** a valid draft exists under the drafts root and the production build runs
- **THEN** no post page, feed entry, sitemap entry, index listing, or pagination page for that draft is produced

#### Scenario: A draft is not exported to Qiita
- **WHEN** a draft has a Japanese source and the Qiita command runs in any selection mode
- **THEN** no export is generated or published for that draft

#### Scenario: A draft is not recorded by content tooling
- **WHEN** the manifest update, image optimizer, or translation-by-latest command runs
- **THEN** no file under the drafts root is read or recorded as a published post

### Requirement: Draft creation accepts a title and optional slug

The draft command SHALL take a title and an optional explicit slug. With no explicit slug it SHALL derive a lowercase, URL-safe slug from the title, folding accented characters to ASCII. An explicit slug SHALL be accepted only when it uses lowercase letters, digits, or internal hyphens and does not escape the drafts root.

#### Scenario: Slug is derived from the title
- **WHEN** a Spanish title with punctuation and accented characters is supplied without an explicit slug
- **THEN** the created directory name is a lowercase hyphen-separated ASCII slug derived from that title

#### Scenario: Explicit slug is used when valid
- **WHEN** a title and an explicit slug such as `mi-post-123` are supplied
- **THEN** the draft is created under that slug and the source frontmatter repeats it

#### Scenario: Unsafe slug is rejected
- **WHEN** an explicit slug contains uppercase letters, path separators, dots, or leading or trailing hyphens
- **THEN** the command reports an error and creates no directory

#### Scenario: Existing draft is not overwritten
- **WHEN** a draft directory already exists for the resolved slug
- **THEN** the command reports an error and leaves the existing draft unchanged

### Requirement: Draft creation writes a complete djot source

Creating a draft SHALL write a Spanish djot source whose frontmatter contains the title, resolved slug, current date, description, featured image, and tags required by the site, followed by an editable djot body placeholder.

#### Scenario: New draft has valid frontmatter
- **WHEN** the draft creation command succeeds
- **THEN** `index.djot` exists with all six frontmatter fields and the resolved slug matches the directory name

#### Scenario: New draft renders through the site engine
- **WHEN** the new draft is previewed without edits
- **THEN** the generated page renders without a frontmatter date error

### Requirement: A single draft can be previewed in isolation

A preview command SHALL render only the selected draft using the site's post template, code components, embed components, and static assets, writing the result to a dedicated git-ignored preview directory outside the production output.

#### Scenario: Draft preview uses the site's post page
- **WHEN** a draft containing a Spanish source is previewed
- **THEN** the preview output contains that draft's post page with the site's masthead, article layout, highlights, and styles

#### Scenario: No published pages are added to the preview
- **WHEN** the published catalog contains many posts and one draft is previewed
- **THEN** the preview output contains no home page, blog index, feed, sitemap, or published post page from the catalog

#### Scenario: Preview output stays out of version control
- **WHEN** the preview command runs
- **THEN** its output directory is git-ignored and the production output directory is unchanged

### Requirement: Preview server supports hot reload

A preview server SHALL serve the preview output on its own local port, watch the selected draft, Gleam sources, and static assets, rebuild the selected preview when they change, and refresh connected browsers after a successful rebuild.

#### Scenario: Editing a draft refreshes the preview
- **WHEN** a watched draft file changes while the preview server is running
- **THEN** the server rebuilds the selected preview and sends a reload event to connected browsers

#### Scenario: Preview server does not use the production port
- **WHEN** the preview server starts
- **THEN** it serves locally on a port distinct from the production development server

### Requirement: Promotion generates translations before publishing

Promotion SHALL validate the selected draft, generate its English, Japanese, and Brazilian Portuguese variants from the Spanish source, verify that all three files were written, and then move the complete directory into the published content root. Promotion SHALL NOT overwrite an existing published post.

#### Scenario: Promotion publishes a complete post
- **WHEN** a valid draft is promoted and translation succeeds
- **THEN** the published catalog contains the directory with Spanish, English, Japanese, and Portuguese sources and its post-local assets

#### Scenario: Translation failure leaves the draft intact
- **WHEN** translation fails or any expected translated variant is missing
- **THEN** the draft remains under the drafts root and no published directory is created

#### Scenario: Existing published slug is not overwritten
- **WHEN** a published post already uses the draft's slug
- **THEN** promotion reports an error and neither directory is changed
