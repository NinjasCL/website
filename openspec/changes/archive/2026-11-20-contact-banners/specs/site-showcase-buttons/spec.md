# Spec Delta

## REMOVED Requirements

### Requirement: Buttons outside the showcase cards keep their presentation
**Reason**: The banner-wall change removed the contact mailto button, shrinking this exclusion's scope to the footer controls alone — its "Contact button unchanged" scenario no longer has a subject.
**Migration**: Replaced by the ADDED requirement "Showcase presentation excludes only the footer controls" below, which restates the footer exclusion without the removed contact button.

## ADDED Requirements

### Requirement: Showcase presentation excludes only the footer controls
The enlargement and icons SHALL apply only to the showcase card buttons; the footer controls SHALL keep their current classes and sizing.

#### Scenario: Footer buttons unchanged
- **WHEN** the home page is rendered
- **THEN** the footer badge buttons keep their current presentation, unaffected
