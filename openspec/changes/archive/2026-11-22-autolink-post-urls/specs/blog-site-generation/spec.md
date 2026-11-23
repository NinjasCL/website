# Spec Delta

## ADDED Requirements

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
