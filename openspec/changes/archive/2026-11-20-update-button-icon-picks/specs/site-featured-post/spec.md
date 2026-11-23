# Spec Delta

## MODIFIED Requirements

### Requirement: The Leer entrada button is a large icon button
The featured post's "Leer entrada" button SHALL carry retrostrap's `rs-btn--large` size with the `rs-btn--icon` layout, leading with the Program Manager icon from the site's static assets (revised 2026-11-20 from the initial ReaderOpened pick by the site owner) beside its label, and SHALL link to the post.

#### Scenario: Large icon button
- **WHEN** the home page is rendered with at least one post
- **THEN** the "Leer entrada" button carries the `rs-btn--large` variant with the Program Manager icon (`/icons/Progman25_32x32_4.png`) beside the label, linking to the post
