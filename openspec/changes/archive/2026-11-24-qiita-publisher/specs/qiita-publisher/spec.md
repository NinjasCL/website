# Spec Delta

## Purpose

Exports the site's Japanese posts to Qiita as generated TOML files and publishes those files through the Qiita API, keeping generation and publication independent.

## ADDED Requirements

### Requirement: Generate a Qiita export from a Japanese post

The command SHALL write a `qiita.toml` beside the selected post's Japanese source. With no selector it SHALL use the most recently updated post that has a Japanese source. A selector MAY be a post slug, a post directory, or a path to the Japanese source, and `--all` SHALL export every post that has a Japanese source. Generation SHALL NOT make any network request.

#### Scenario: Default generation selects the latest Japanese post
- **WHEN** the command runs with no selector and no mode flag
- **THEN** it writes one `qiita.toml` for the most recently updated Japanese post
- **AND** it does not contact Qiita

#### Scenario: One post is selected explicitly
- **WHEN** a slug, post path, or Japanese source path is supplied
- **THEN** that post's `qiita.toml` is written and no other post is touched

#### Scenario: The whole catalog is selected
- **WHEN** `--all` is supplied without a selector
- **THEN** a `qiita.toml` is written for every post with a Japanese source
- **AND** posts without a Japanese source are skipped

#### Scenario: Unknown or conflicting arguments are rejected
- **WHEN** `--all` is combined with a selector, two selectors are given, or an unknown option is used
- **THEN** the command reports the error and prints usage without writing any file

### Requirement: Generated export carries publishable metadata and converted body

A generated file SHALL contain the post title, a CommonMark body, tags, source-tracking fields, and an empty Qiita item id. The body SHALL be converted from the Japanese djot source, with fenced code preserved and site-root asset URLs made absolute. The recorded update time SHALL be the post date normalized to UTC RFC 3339.

#### Scenario: Metadata is read from the Japanese source
- **WHEN** the Japanese source has title, slug, date, and tags in its frontmatter
- **THEN** the generated file records those values, with the date in UTC RFC 3339 form
- **AND** its source URL points at that post's Japanese page

#### Scenario: The body is converted for Qiita
- **WHEN** the Japanese source contains djot emphasis, strong text, and fenced code with attributes
- **THEN** the generated body uses CommonMark delimiters and drops fence attributes Qiita cannot render
- **AND** site-root asset destinations are absolute URLs under the production site

#### Scenario: A new export has no remote identity
- **WHEN** a file is generated for a post that has never been published
- **THEN** its Qiita item id is empty

### Requirement: Publication sends an existing export to Qiita

Publication SHALL read a token from the repository's `.env` file first and fall back to the process environment. It SHALL use an already-generated `qiita.toml` without regenerating it. A file with no item id SHALL create a new Qiita item; a file with an item id SHALL update that item. The id returned by Qiita SHALL be stored back in the file on first publication.

#### Scenario: Token resolution prefers the environment file
- **WHEN** `.env` has a non-empty `QIITA_TOKEN` and the environment also has one
- **THEN** the value from `.env` is used
- **AND** a blank `.env` value is ignored so the environment token can be used

#### Scenario: First publication creates an item
- **WHEN** a generated file has an empty item id and a valid token is available
- **THEN** the command creates a new Qiita item and writes the returned id into the file

#### Scenario: Later publication updates the same item
- **WHEN** a generated file already has an item id
- **THEN** the command updates that item and leaves the stored id unchanged

#### Scenario: Publication never regenerates
- **WHEN** `--publish` runs for a post whose djot source has changed since generation
- **THEN** the stored `qiita.toml` body is sent as-is

#### Scenario: Missing token or rejected request is reported
- **WHEN** no token is available or Qiita rejects the request
- **THEN** the command reports the failure and does not store an item id
