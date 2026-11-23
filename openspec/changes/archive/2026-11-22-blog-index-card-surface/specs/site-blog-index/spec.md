# Spec Delta

## ADDED Requirements

### Requirement: Index entry cards carry a distinct darker surface
Each index entry block SHALL render on a background darker than the
page's main background, and every entry except the first of the page's
list SHALL carry top padding that gives the results breathing room.

#### Scenario: Blocks stand off the background
- **WHEN** a visitor opens an index page
- **THEN** each entry block renders on a background darker than the page's main background, so the blocks differentiate from it

#### Scenario: Breathing room except before the first result
- **WHEN** an index page lists more than one entry
- **THEN** every entry except the page's first carries top padding
- **AND** the page's first entry carries none, staying flush at the top of the list
