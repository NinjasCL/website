# Spec Delta

## REMOVED Requirements

### Requirement: Showcase presentation and alts are preserved
**Reason**: The uniform showcase card row structure supersedes this presentation-preservation guard. With every showcase section's card layout governed by the `site-showcase-cards` specification, no showcase figure keeps retrostrap's vertical-card sizing, so the games-sizing clause no longer describes any behavior.
**Migration**: Alt texts remain protected by the new "Showcase alt texts are preserved" requirement below; all showcase card presentation is owned by `site-showcase-cards`.

## ADDED Requirements

### Requirement: Showcase alt texts are preserved
The showcase images' alt texts SHALL be preserved across presentation changes.

#### Scenario: Alt texts unchanged
- **WHEN** the home page is rendered
- **THEN** each showcase image keeps its existing alt text (for example "Logo de Elixir Chile", "Portada de Super Club Net")
