# Spec Delta

## MODIFIED Requirements

### Requirement: The offered tiles match the shipped pattern sets
The picker's offered list SHALL consider the three shipped pattern sets — the numbered macOS set (`macos9`), the named Windows 3.1 set (`win3.1`), and the custom set (`custom`) for owner-added tiles — offering exactly the PNG files those sets ship and nothing else; non-image files (such as the macOS set's LICENSE) are not offered.

#### Scenario: Both sets offered
- **WHEN** the shipped background script is inspected
- **THEN** tiles from the macos9 set, tiles from the win3.1 set, and tiles from the custom set appear in the offered list

#### Scenario: Every offered tile exists
- **WHEN** the offered list is checked against the static pattern directories
- **THEN** each offered tile names an existing shipped PNG

#### Scenario: Every shipped PNG is offered
- **WHEN** the static pattern directories are checked against the offered list
- **THEN** each shipped PNG appears in the offered list, and non-image files are not offered
