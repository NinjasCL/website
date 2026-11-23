# Spec Delta

## ADDED Requirements

### Requirement: Home hero title carries the Chilean tricolor
The home hero's site title — "忍者 開発者 Ninjas.cl" — SHALL render in the
Chilean flag's colors: the blue, white, and red of the 🇨🇱 emoji,
applied through a banded gradient clipped to the text (no
per-character markup), with the bands running top to bottom in the
flag's own order so every glyph reads horizontally intact.

#### Scenario: Title colors come from the Chilean flag
- **WHEN** the home page is generated
- **THEN** the hero title renders its characters in the Chilean flag's blue, white, and red — the 🇨🇱 emoji's palette

#### Scenario: The tricolor is one clipped gradient, not per-character markup
- **WHEN** the home page's hero title is rendered
- **THEN** the whole title text sits in one span whose gradient, clipped to the text, paints the colors
- **AND** no per-character color markup wraps the title's characters

#### Scenario: The bands read top to bottom
- **WHEN** a visitor looks at the hero title
- **THEN** the gradient's bands run from the top of the text to the bottom — blue at the top, white through the middle, red at the bottom
- **AND** the title's glyphs, including the kanji, read horizontally intact rather than sliced mid-stroke by left-to-right bands
