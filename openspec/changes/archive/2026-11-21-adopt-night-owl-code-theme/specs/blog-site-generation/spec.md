# Spec Delta

## MODIFIED Requirements

### Requirement: Post code blocks are highlighted at build time
Post code blocks tagged with a recognized language SHALL render with build-time syntax highlighting — smalto token spans styled by the site's stylesheet in the Night Owl palette — on a code block background darker than the page, while untagged blocks and unrecognized language tags render as plain code.

#### Scenario: Recognized languages highlight
- **WHEN** a post carries fenced code blocks tagged `go` and `elixir`
- **THEN** the generated pages wrap the blocks' tokens in spans carrying the smalto token classes, with no client-side script involved

#### Scenario: Untagged and unknown stay plain
- **WHEN** a code block is untagged or tagged with a language the highlighter does not know
- **THEN** it renders as plain code with no token spans

#### Scenario: The token styles ship with the stylesheet
- **WHEN** the site's stylesheet is inspected
- **THEN** post code blocks sit on the Night Owl editor background — darker than the page background, framed by the theme's contrast border — and the smalto token classes carry the Night Owl palette colors
