# Spec Delta

## Purpose

Defines the main page container's surface presentation: the old ninjas.cl stylesheet's `.violet-frame` recipe — the deep-violet translucent wash (about 5% transparency) over the patterned body, edged with the old scheme's dashed violet border — with the theme's text presentation untouched.

## ADDED Requirements

### Requirement: The main container uses the old scheme's violet-frame presentation
The main page container SHALL render the old ninjas.cl stylesheet's `.violet-frame` recipe: the translucent deep-violet wash — `rgba(33, 4, 49, 0.945)`, about 5% transparency — instead of the solid theme background, edged with a dashed border in the old scheme's violet (`#7540bd`), so the patterned body shows through the surface and the frame reads like the old website's panels.

#### Scenario: Wash and dashed border in the stylesheet
- **WHEN** the home page's shipped stylesheet is inspected
- **THEN** the cosmic-themed main container background is the translucent `rgba(33, 4, 49, 0.945)` wash and its border is dashed in the old scheme's violet (`#7540bd`) — not the solid theme background and its bevel border

#### Scenario: Pattern ghosts through the container
- **WHEN** the home page is viewed in a browser
- **THEN** the random tile pattern behind the container is faintly visible through the container's surface

### Requirement: Only the container surface changes
The container's wash and dashed border SHALL NOT change any theme token, text, link, or heading color, and SHALL NOT touch any other element's border; the wash's darkness stays close to the replaced solid background so the cosmic theme's light text keeps its contrast.

#### Scenario: No token, text, or other-border changes
- **WHEN** the change's stylesheet additions are inspected
- **THEN** they set only the container's background and border — no `--rs-*` token override, no text or link color, and no panel or figure border is touched
