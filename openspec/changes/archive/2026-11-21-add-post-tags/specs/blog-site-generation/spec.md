# Spec Delta

## ADDED Requirements

### Requirement: Post pages render their tags
Every post page whose frontmatter declares a `tags` field SHALL render those tags as a row of small rounded labels below the post's date, led by the Bookmark icon.

#### Scenario: Tags render as labels below the date
- **WHEN** a post with a `tags` frontmatter field is rendered
- **THEN** the page shows each tag as a rounded label, positioned between the date line and the description

#### Scenario: Posts without tags render no row
- **WHEN** a post has no `tags` frontmatter field
- **THEN** no tags row renders between the date and the description
