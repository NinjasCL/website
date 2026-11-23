# Spec Delta

## ADDED Requirements

### Requirement: Posts section header links the syndication feed
The home page's "Entradas del blog" section header SHALL carry the same feed
icon link to the site's Atom feed as the blog index's title section, on every
home language.

#### Scenario: Home posts header shows the feed link
- **WHEN** a visitor opens any home page language
- **THEN** the posts section heading displays the feed icon linking `/atom.xml`

#### Scenario: Feed link matches the blog index
- **WHEN** the home posts header's feed link and a blog index title's feed link are compared
- **THEN** both use the same feed icon image, the same alt text, and the same destination
