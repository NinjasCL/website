# Proposal

## Why

Finding the most recently updated post currently means opening post sources or scanning generated pages. The root manifest already aggregates build metadata, so it should also record when each post was last updated and name the newest one.

## What Changes

- Record every default-language post's last-update date in `website-manifest.json`, keyed by slug and ordered newest first.
- Add a `latest_post` section naming the newest post and its date explicitly, independent of JSON object ordering.
- Calculate both sections during the production build from the djot frontmatter, normalizing dates to UTC RFC 3339.
- Preserve both sections when the image optimizer or FTP planner rewrites the manifest.

Out of scope: changing post page rendering, feeds, or language variants; changing the image or FTP cache formats; exposing the dates in templates or APIs.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `blog-site-generation`: add a requirement for build-time post-date recording and manifest preservation in `website-manifest.json`.

## Impact

- New Gleam manifest module called from the production build entrypoint; new unit tests.
- `tools/optimize/optimize.py` and `tools/ftp/ftp_sync.erl` gain the two sections in their manifest round trips, with matching tests.
- Reuses `gleam/time` and `gleam/json`, already present through the dependency tree; no new dependency and no blogatto route or template change.
