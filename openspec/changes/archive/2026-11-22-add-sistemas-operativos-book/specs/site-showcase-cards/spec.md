# Spec Delta

## ADDED Requirements

### Requirement: Books showcase includes Conceptos de Sistemas Operativos
The "Libros" section SHALL present a "Conceptos de Sistemas Operativos" card with a two-line summary of the book and a link to its published site and source repository, in each of the site's languages.

#### Scenario: Card appears in the books section
- **WHEN** the home page is rendered in Spanish
- **THEN** the "Libros" section includes a "Conceptos de Sistemas Operativos" card whose summary describes operating-system concepts and whose links point to `https://ninjascl.github.io/sistemas-operativos/` and `https://github.com/NinjasCL/sistemas-operativos`

#### Scenario: Summary is translated
- **WHEN** the home page is rendered in English, Japanese, or Portuguese
- **THEN** the "Conceptos de Sistemas Operativos" card shows its summary in that language and keeps the same two-line scope as the Spanish original

#### Scenario: Existing cards keep their place
- **WHEN** the home page is rendered
- **THEN** the other book, project, and game cards keep their existing titles, copy, and links
