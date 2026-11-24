# Proposal

## Why

The site's Japanese posts have no way to reach Qiita, so they must be copied and reformatted by hand. A dedicated command should export the right post from its djot source and publish it without disturbing the site build.

## What Changes

- Add a `qiita` command that generates a local `qiita.toml` for a Japanese post and, only when explicitly asked, publishes that generated file to Qiita.
- Generate the latest Japanese post by default; allow one post to be selected by slug or path, or the whole catalog with `--all`.
- Convert the Japanese djot body to CommonMark, keeping fenced code intact and making site-root asset URLs absolute.
- Keep generation and publication separate: generation never contacts Qiita; publication requires a token and never regenerates the file.
- Store the returned Qiita item id in the generated file so later publications update the same item.

Out of scope: changing the site's post pages, feeds, or languages; translating content; scheduling or automatic publication on build; editing an existing Qiita item by any id supplied on the command line.

## Capabilities

### New Capabilities

- `qiita-publisher`: generating export files from Japanese posts and publishing them to Qiita.

### Modified Capabilities

None.

## Impact

- New Gleam entrypoint and Erlang CLI/environment shim; new unit tests.
- Two new declared dependencies (`gleam_json`, `tom`) for request and export parsing.
- `Taskfile.yml` and `env.txt` gain generate/publish tasks and a `QIITA_TOKEN` template entry.
- Uses `gleam/time` for the RFC 3339 date conversion and `simplifile` for file access; no blogatto route or template changes.
