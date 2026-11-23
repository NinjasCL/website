# Spec Delta

## ADDED Requirements

## MODIFIED Requirements

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
