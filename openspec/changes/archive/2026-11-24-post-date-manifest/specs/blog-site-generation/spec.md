# Spec Delta

## ADDED Requirements

### Requirement: The build records post dates in the root manifest

The production build SHALL record each default-language post's last-update date in the root `website-manifest.json`, keyed by post slug and ordered newest first. It SHALL also name the newest post and its date in a `latest_post` section. Dates SHALL be normalized to UTC RFC 3339 so ordering is chronological regardless of the source offset. Recomputing the sections SHALL be idempotent, and the image optimizer and FTP planner SHALL preserve both sections when they rewrite the manifest.

#### Scenario: A build records every post's date
- **WHEN** the production build completes with posts in the content directory
- **THEN** the manifest contains a `posts` section with one entry per default-language post
- **AND** entries are ordered from newest to oldest by normalized date

#### Scenario: The newest post is named explicitly
- **WHEN** post dates have been recorded
- **THEN** `latest_post` names the newest slug and its date
- **AND** a reader does not have to rely on JSON object key order to find it

#### Scenario: Dates with offsets are comparable
- **WHEN** two posts carry dates with different timezone offsets
- **THEN** both recorded dates are UTC RFC 3339 values and their lexical order is chronological

#### Scenario: Rebuilding does not duplicate sections
- **WHEN** the build runs twice without content changes
- **THEN** the `posts` and `latest_post` sections appear exactly once with identical values

#### Scenario: Other manifest sections survive
- **WHEN** the optimizer or FTP planner rewrites the manifest after the build
- **THEN** the `posts` and `latest_post` sections remain unchanged alongside the image hashes and FTP cache
