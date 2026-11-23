# Spec Delta

## ADDED Requirements

### Requirement: Language display names omit the country
Every declared language's display name SHALL be its plain language name without a country qualifier — "Español", "English", "日本語", and "Português" — wherever the site renders a language options row: on post pages, home pages, and blog index pages. The Portuguese entry SHALL read "Português" with no "(Brasil)" suffix, while its route code, `lang` value, and `og:locale` remain unchanged.

#### Scenario: Portuguese options entry drops the country
- **WHEN** any page renders its language options row
- **THEN** the Portuguese entry reads "Português"
- **AND** no "Português (Brasil)" label appears anywhere in the generated site

#### Scenario: Other language names stay unchanged
- **WHEN** a language options row renders
- **THEN** the Spanish, English, and Japanese entries read "Español", "English", and "日本語"

#### Scenario: Portuguese locale fields stay intact
- **WHEN** a Portuguese page is rendered
- **THEN** its route stays `/blog/pt/…` or `/pt/`, its `lang` attribute stays `pt`, and its `og:locale` stays `pt_BR`
