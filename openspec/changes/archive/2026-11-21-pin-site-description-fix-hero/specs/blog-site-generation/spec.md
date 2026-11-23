# Spec Delta

## ADDED Requirements

### Requirement: The site description presents Ninjas' identity
The site's description SHALL present Ninjas' identity in Spanish, crediting the founder by handle: "Ninjas es un grupo desarrollador de software experimental de Chile 🇨🇱. Participa en diversos proyectos tecnológicos, tales como videojuegos, software y otras actividades relacionadas. Ninjas.cl fue fundado en 2015 (¡11 años programando ❤️!) por @CLSource."

#### Scenario: The hero's description note
- **WHEN** the home page is rendered
- **THEN** the hero's description note shows the description text

#### Scenario: The home page's meta description
- **WHEN** the generated home page's markup is inspected
- **THEN** its meta description carries the description text
