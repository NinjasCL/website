# Spec Delta

## ADDED Requirements

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
