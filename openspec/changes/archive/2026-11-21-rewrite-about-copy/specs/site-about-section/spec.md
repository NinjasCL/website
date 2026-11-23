# Spec Delta

## MODIFIED Requirements

### Requirement: About text and caption are preserved in the right column
The about section's text SHALL render in the right column, beside the portrait, with the figure caption preserved.

#### Scenario: Text beside the image
- **WHEN** the home page is rendered on a viewport wide enough for two columns
- **THEN** the about section's paragraphs appear in the right column, beside the portrait

#### Scenario: Caption preserved
- **WHEN** the about section is rendered
- **THEN** the portrait carries its caption "@CLSource — Software Engineer", crediting the site owner's handle
- **AND** the former "Camilo Castro — Software Engineer" caption no longer appears

## ADDED Requirements

### Requirement: The about section presents Ninjas in its own voice
The about section's copy SHALL introduce Ninjas in the site's own first-person voice — crediting `@CLSource` as the founder — carrying the values line and closing with the GitHub find-us link.

#### Scenario: First-person introduction
- **WHEN** the about section is rendered
- **THEN** the text opens with "Ninjas es un grupo experimental de desarrollo de software de Chile 🇨🇱 fundado por @CLSource. Participamos en proyectos de videojuegos, software y otras actividades relacionadas."
- **AND** the former third-person opening "Ninja Systems es un grupo" no longer appears

#### Scenario: Values line
- **WHEN** the about section is rendered
- **THEN** the text includes "Nos gusta crear artefactos hermosos y pensados en las personas. Valoramos lo humano en los proyectos tecnológicos."

#### Scenario: GitHub find-us link
- **WHEN** the about section is rendered
- **THEN** the closing paragraph reads "Ninjas.cl nació el 2015. Puedes encontrarnos en GitHub."
- **AND** the GitHub label links to `https://github.com/ninjascl`
