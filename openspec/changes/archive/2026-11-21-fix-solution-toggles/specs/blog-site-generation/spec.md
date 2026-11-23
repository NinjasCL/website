# Spec Delta

## ADDED Requirements

### Requirement: Collapsible solution code blocks
A fenced code block whose info string carries a `summary` attribute (`{summary="…"}`) SHALL render as a working collapsible toggle — a `details`/`summary` element wrapping that block's code — with its highlighting unaffected.

#### Scenario: The summary attribute renders a working toggle
- **WHEN** a post carries a fenced code block like ` ```go {summary="Mostrar solución"} `
- **THEN** the generated page wraps that block's highlighted code inside a `details` element whose `summary` carries the declared text, so the toggle opens and closes over the code

#### Scenario: The toggle keeps its highlighting
- **WHEN** a summary-carrying code block is rendered
- **THEN** its code still renders with the smalto token spans and the bare language class, exactly like an untagged block

#### Scenario: Blocks without the attribute stay uncollapsible
- **WHEN** a fenced code block carries no `summary` attribute
- **THEN** it renders as a plain (highlighted) code block with no toggle
