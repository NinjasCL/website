# Spec Delta

## MODIFIED Requirements

### Requirement: Every home page section header shares the enlarged presentation
The enlarged header presentation SHALL apply uniformly to all home page sections that carry a header: about ("Sobre nosotros"), posts, projects, books, and games. Revised 2026-11-20: contact is dropped from the enumeration — the banner-wall change removed the Contacto section's header along with its navbar link, leaving the untitled banner panel at `#contact`.

#### Scenario: All sections enlarged
- **WHEN** the home page is rendered
- **THEN** the headers of the posts, projects, books, and games sections carry the same enlarged presentation as the "Sobre nosotros" header
- **AND** the untitled banner panel at `#contact` renders no section header
