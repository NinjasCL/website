# Spec Delta

## Purpose

Defines the site's text-size floor: every rendered element reads at a sixteen-pixel minimum, from the restored body base to the chrome that used to style itself smaller.

## ADDED Requirements

### Requirement: Site text renders at a sixteen-pixel minimum
All text the site renders SHALL be at least sixteen pixels at the default root size: the base body text restores the font ladder's size-3 step over the cosmic theme's shrink, and no rendered element styles itself below that step.

#### Scenario: The body base restores the 16px step
- **WHEN** the site's stylesheet is inspected
- **THEN** the cosmic theme's body font size is overridden back to the ladder's size-3 step, so every inheriting element — paragraphs, lists, the footer, the marquee — reads at sixteen pixels

#### Scenario: The chrome lifts to the floor
- **WHEN** the site's stylesheet is inspected
- **THEN** the navbar links, the hero note, figure captions, the back-to-top link, the post list's fine print, and the language options row all carry the size-3 step — none of the ten- or thirteen-pixel ladder steps the base chrome used

#### Scenario: Nothing above the floor shrinks
- **WHEN** the rendered sizes above the floor are inspected
- **THEN** the section titles keep their enlarged size-5 step, the buttons keep the large variant's size, and headings are unchanged
