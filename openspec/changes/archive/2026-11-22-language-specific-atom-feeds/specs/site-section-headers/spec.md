# Spec Delta

## ADDED Requirements

## MODIFIED Requirements

### Requirement: Posts section header links the syndication feed
The home page's "Entradas del blog" section header SHALL carry the same feed
icon link to the current language's Atom feed as that language's blog index
title section: `/atom.xml` on the Spanish home and `/{lang}/atom.xml` on the
English, Japanese, and Portuguese homes.

#### Scenario: Home posts header shows the feed link
- **WHEN** a visitor opens any home page language
- **THEN** the posts section heading displays the feed icon linking that language's Atom feed

#### Scenario: Feed link matches the blog index
- **WHEN** a home posts header's feed link and its language's blog index title's feed link are compared
- **THEN** both use the same feed icon image, the same alt text, and the same destination
