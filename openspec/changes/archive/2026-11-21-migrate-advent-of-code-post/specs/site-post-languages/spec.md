# Spec Delta

## ADDED Requirements

### Requirement: Migrated English-origin posts
Posts from the old catalog that were originally written in English SHALL migrate with their Spanish translation as the default variant — carrying no translation warning — and their original English content as the English variant, carrying the standard machine-translated warning like every non-default language.

#### Scenario: The migrated Advent of Code post follows the rule
- **WHEN** the migrated post's default Spanish page is rendered
- **THEN** it carries no machine-translated warning and lists the English variant in its language options row
- **WHEN** the migrated post's English page is rendered
- **THEN** it carries the machine-translated warning in English and links the Spanish default back
