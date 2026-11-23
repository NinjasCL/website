# Tasks

## 1. Tool scaffold and manifest

- [x] 1.1 Create `tools/optimize/pyproject.toml` with `requires-python = ">=3.14"`, pinned Pillow and `resvg-py`, plus `tools/optimize/Taskfile.yml` with `install`, `run` (default), `test`, and `check`; verify `uv sync --project tools/optimize` succeeds and the venv reports Python 3.14+.
- [x] 1.2 Add the committed root `optimize-manifest.json` with version 1 and empty `images`, `downloads`, and `covers` maps; verify it parses as JSON and document its schema in `tools/optimize/README.md`.

## 2. Optimizer implementation and unit tests

- [x] 2.1 Implement the `blog/` image scan and conservative optimization for PNG, JPEG, WebP, AVIF, and GIF; add unit tests for each supported format's settings and verify `task -d tools/optimize test` passes.
- [x] 2.2 Implement content-hash skip logic against the root manifest so recorded files are left untouched and changed files are reprocessed; add a two-run unit test and verify it passes.
- [x] 2.3 Implement 1280x720 center-filled cover derivatives with LANCZOS resampling, including SVG rasterization via `resvg-py` and GIF frame handling; add tests for exact dimensions, center focus, and SVG output, and verify they pass.
- [x] 2.4 Implement remote image localization for `featured_image` and inline `![...](...)` references, with deterministic local filenames and a fake downloader in tests; verify both reference kinds are rewritten and reruns do not refetch.
- [x] 2.5 Implement the welcome-post copy of `static/img/Ninjas.png` into `blog/bienvenidos-a-ninjas-cl/` and repoint that post's `featured_image` to its derivative; add a test proving the static original is never modified, and verify it passes.
- [x] 2.6 Add `--check` and `--dry-run` reporting with a nonzero exit when work is pending; verify unit tests cover both modes and `task -d tools/optimize test` passes.

## 3. Content migration

- [x] 3.1 Run the optimizer once against the repository; verify 17 remote images are downloaded, 28 djot files are rewritten, derivatives exist for every `featured_image`, and the root manifest records all image, download, and cover entries.
- [x] 3.2 Verify no remote image URLs remain in `blog/**/index*.djot` and every `featured_image` resolves to a local 1280x720 raster derivative; verify with a script scan and `python tools/optimize/optimize.py --check`.
- [x] 3.3 Verify every optimized original still exists beside its derivative and `git diff --exit-code -- static` reports no changes; verify inline references in the seven localized posts point at their local originals.
- [x] 3.4 Run the optimizer a second time; verify it reports zero pending work and `git diff --exit-code` shows no further content changes.

## 4. Integration, documentation, and checks

- [x] 4.1 Wire a root `task optimize` alias to the nested Taskfile and change `upload` to call `optimize` then `build` in order; verify `task --list` shows the task and `task -n upload` shows the ordered commands.
- [x] 4.2 Update `AGENTS.md` and `README.md` with the new tool, root command, manifest, and "static is verbatim" rule; verify the documented commands match the Taskfiles.
- [x] 4.3 Run `task build`, `gleam format --check src test`, `gleam test`, and `openspec validate optimize-blog-images`; verify all pass and generated HTML serves post images from local paths.

## Workflow follow-up

- Sync the delta specs into the main specs after implementation and verification.
- Archive the change once apply, sync, and all checks are complete.
