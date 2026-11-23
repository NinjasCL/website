# Spec Delta

## ADDED Requirements

### Requirement: Post-adjacent files ship with the post
The build SHALL copy the files that sit beside a post's source — images, code, and data files that are not post sources — into that post's output directory by base name, so they are served at the post's URL.

#### Scenario: The migrated post's files ship beside its page
- **WHEN** the site is generated with a post directory that contains a cover image, an input data file, and a source code file beside its djot sources
- **THEN** those files are present in the post's output directory at the post's URL, and the post's featured image resolves there

#### Scenario: The post body references its adjacent files relatively
- **WHEN** a post's body references one of its adjacent files by a relative path
- **THEN** the reference resolves from the post page's URL to the copied file
