# Spec Delta

## ADDED Requirements

### Requirement: The featured post is a build-time random pick
The home page's featured post SHALL be one randomly selected entry from the default-language posts, picked fresh at each build, with the remaining entries rendering in the "Más entradas" list.

#### Scenario: A random entry is featured
- **WHEN** the home page is rendered with multiple posts
- **THEN** the featured row shows one of the default-language entries — a fresh pick at each build — and the "Más entradas" list shows the remaining ones

#### Scenario: A lone post is the featured one
- **WHEN** the home page is rendered with a single post
- **THEN** that post is the featured entry and no "Más entradas" list renders
