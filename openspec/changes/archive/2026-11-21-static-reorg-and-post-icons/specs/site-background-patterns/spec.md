# Spec Delta

## MODIFIED Requirements

### Requirement: Random background tile resolves at the shipped pattern paths
The site SHALL pick the home page's background tile at random on each page load from the tile files shipped under `/patterns/`, addressing each tile with its set's subdirectory path so every offered tile resolves.

#### Scenario: Tiles resolve at their new paths
- **WHEN** the shipped background script is inspected
- **THEN** every offered tile path includes its set's subdirectory (for example `/patterns/macos9/128.png`, `/patterns/win3.1/arcade.png`), matching the shipped file layout

#### Scenario: No stale flat paths
- **WHEN** the shipped script and stylesheet are inspected
- **THEN** no tile is referenced at the old flat `/patterns/<file>` location, which no longer exists

### Requirement: The offered tiles match the shipped pattern sets
The picker's offered list SHALL consider both shipped pattern sets — the numbered macOS set and the named Windows 3.1 set — offering exactly the PNG files those sets ship and nothing else; non-image files (such as the macOS set's LICENSE) are not offered.

#### Scenario: Both sets offered
- **WHEN** the shipped background script is inspected
- **THEN** tiles from the macos9 set and tiles from the win3.1 set appear in the offered list

#### Scenario: Every offered tile exists
- **WHEN** the offered list is checked against the static pattern directories
- **THEN** each offered tile names an existing shipped PNG

#### Scenario: Every shipped PNG is offered
- **WHEN** the static pattern directories are checked against the offered list
- **THEN** each shipped PNG appears in the offered list, and non-image files are not offered

### Requirement: The no-JavaScript fallback tile resolves
The stylesheet fallback tile SHALL point at a shipped pattern path so the background still renders when JavaScript is unavailable.

#### Scenario: Fallback at the new path
- **WHEN** the shipped stylesheet is inspected without JavaScript running
- **THEN** the fallback background tile resolves to a shipped file — the macOS 128 tile at `/patterns/macos9/128.png`
