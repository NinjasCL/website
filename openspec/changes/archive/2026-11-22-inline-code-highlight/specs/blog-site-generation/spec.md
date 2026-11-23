# Spec Delta

## ADDED Requirements

### Requirement: Inline code spans render inline
A single-backtick span in a post SHALL render as an inline `code` element within its surrounding prose — never as a block-level code panel — while a fenced code block without a language tag SHALL keep its block-level panel.

#### Scenario: A single-backtick mention stays in its sentence
- **WHEN** a post carries an inline code span such as `~/.config/emacs` in a paragraph
- **THEN** the generated page renders a bare `<code>` element in that paragraph, with no `<pre>` wrapper and no line break around the span

#### Scenario: An untagged fence still renders as a block
- **WHEN** a post carries a fenced block with no language tag
- **THEN** the generated page still wraps its code in a `<pre>` panel, and tagged blocks, summary toggles, and embed fences keep their existing structure

## MODIFIED Requirements

### Requirement: Post body typography
The post body text SHALL render at the font ladder's size-3 step — 16px at the default root size, honoring the reader's browser font preferences — and post code, both blocks and inline spans, SHALL use the JetBrains Mono family with the site's mono stack as fallback, the font loaded from Google Fonts in every generated page's head. Inline code spans SHALL be highlighted with light text (`#fafafa`) on the site's violet (`#7540bd`).

#### Scenario: The post body reads at the 16px step
- **WHEN** the site's stylesheet is inspected
- **THEN** the post body carries the ladder's size-3 font size — one step up from the cosmic theme's 13px body

#### Scenario: Post code uses JetBrains Mono
- **WHEN** the site's stylesheet is inspected
- **THEN** post code blocks and inline code spans carry the JetBrains Mono family with the retrostrap mono stack as fallback

#### Scenario: The font ships from Google Fonts on every page
- **WHEN** any generated page's head is inspected
- **THEN** it carries the preconnect to `fonts.googleapis.com`, the crossorigin preconnect to `fonts.gstatic.com`, and the JetBrains Mono stylesheet link with `display=swap`

#### Scenario: Inline spans carry the violet highlight
- **WHEN** the site's stylesheet is inspected
- **THEN** inline code spans carry `color: #fafafa` on `background-color: #7540bd`, distinguishing them from fenced code panels
