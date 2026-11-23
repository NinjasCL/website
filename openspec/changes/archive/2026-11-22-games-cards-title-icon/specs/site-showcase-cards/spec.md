# Spec Delta

## ADDED Requirements

### Requirement: Games card titles lead with the games icon
Every card in the home page's "Juegos" section SHALL lead its title with the games icon `/icons/win95/Mmsys108_32x32_4.png` through the shared inline icon presentation — decorative, empty alt — matching the icon-led titles of the projects and books cards. The section heading keeps its own WinMine icon; the games icon applies to the four card titles only.

#### Scenario: Every games card title carries the icon
- **WHEN** the home page is rendered in any of its four languages
- **THEN** each of the four games cards — "Rolplay Manual", "Profesor Rossa", "¡Qué Chaucha!", and "Munsta Jump!" — leads its title with `/icons/win95/Mmsys108_32x32_4.png`

#### Scenario: Other sections keep their cards
- **WHEN** the home page is rendered
- **THEN** the projects and books cards keep their existing icons, and the games section heading keeps its WinMine icon
