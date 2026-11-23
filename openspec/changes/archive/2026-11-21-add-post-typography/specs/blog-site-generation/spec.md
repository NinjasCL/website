# Spec Delta

## ADDED Requirements

### Requirement: Post body typography
The post body text SHALL render at the font ladder's size-3 step — 16px at the default root size, honoring the reader's browser font preferences — and post code, both blocks and inline spans, SHALL use the JetBrains Mono family with the site's mono stack as fallback, the font loaded from Google Fonts in every generated page's head.

#### Scenario: The post body reads at the 16px step
- **WHEN** the site's stylesheet is inspected
- **THEN** the post body carries the ladder's size-3 font size — one step up from the cosmic theme's 13px body

#### Scenario: Post code uses JetBrains Mono
- **WHEN** the site's stylesheet is inspected
- **THEN** post code blocks and inline code spans carry the JetBrains Mono family with the retrostrap mono stack as fallback

#### Scenario: The font ships from Google Fonts on every page
- **WHEN** any generated page's head is inspected
- **THEN** it carries the preconnect to `fonts.googleapis.com`, the crossorigin preconnect to `fonts.gstatic.com`, and the JetBrains Mono stylesheet link with `display=swap`
