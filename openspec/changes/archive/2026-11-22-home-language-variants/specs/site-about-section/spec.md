# Spec Delta

## MODIFIED Requirements

### Requirement: The about section presents Ninjas in its own voice
The about section's copy SHALL introduce Ninjas in the site's own first-person voice — crediting `@CLSource` as the founder — carrying the values line and closing with the GitHub find-us link, rendered in the home page's language: the Spanish copy on the default home, each translated home carrying its own translation.

#### Scenario: First-person introduction
- **WHEN** the default home's about section is rendered
- **THEN** the text opens with "Ninjas es un grupo experimental de desarrollo de software de Chile 🇨🇱 fundado por @CLSource. Participamos en proyectos de videojuegos, software y otras actividades relacionadas."
- **AND** the former third-person opening "Ninja Systems es un grupo" no longer appears

#### Scenario: Values line
- **WHEN** the default home's about section is rendered
- **THEN** the text includes "Nos gusta crear artefactos hermosos y pensados en las personas. Valoramos lo humano en los proyectos tecnológicos."

#### Scenario: GitHub find-us link
- **WHEN** the default home's about section is rendered
- **THEN** the closing paragraph reads "Ninjas.cl nació el 2015. Puedes encontrarnos en GitHub."
- **AND** the GitHub label links to `https://github.com/ninjascl`

#### Scenario: A translated home's about copy
- **WHEN** a translated home's about section is rendered
- **THEN** its paragraphs carry that language's translation of the introduction, values line, and closing find-us link, crediting `@CLSource` and linking `https://github.com/ninjascl`
- **AND** no Spanish paragraph remains in the section
