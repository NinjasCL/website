# Image optimizer

Localizes, optimizes, and standardizes the images shipped with blog posts.
It never touches `static/`: assets there stay byte-for-byte verbatim.

## Requirements

- Python 3.14 or newer
- [`uv`](https://docs.astral.sh/uv/)

Dependencies (Pillow and `resvg-py`) are pinned in `pyproject.toml` and
installed into the tool's local `.venv`.

## Commands

Run these from the repository root:

```sh
task optimize          # install deps, then process images
task -d tools/optimize test    # run the Python unit tests
task -d tools/optimize check   # fail if any work is pending
task -d tools/optimize dry-run # report pending work without writing
```

The nested Taskfile also supports `task -d tools/optimize install`,
`task -d tools/optimize run`, and `task -d tools/optimize` (the default run).

## What it does

1. Downloads every remote image referenced by a post into `blog/<slug>/` and
   rewrites `featured_image` and inline `![...](...)` references to local
   paths.
2. Copies `static/img/Ninjas.png` into the welcome post so the shared logo can
   have a post-local cover without modifying the static original.
3. Optimizes every supported raster image under `blog/` in place. SVG sources
   stay unchanged.
4. Writes `<stem>-1280x720.<ext>` center-cropped cover derivatives beside each
   `featured_image` original and repoints frontmatter at them. SVG covers get
   a PNG derivative rendered with `resvg-py`.
5. Records content hashes in `website-manifest.json` at the repository root.
   A recorded image is skipped on later runs; changed bytes are processed
   again. The manifest's `ftp` section is preserved untouched.

## Manifest

`website-manifest.json` lives beside the project's `manifest.toml`:

```json
{
  "version": 1,
  "images": {
    "blog/example/cover.jpg": "sha256-of-the-final-bytes"
  },
  "downloads": {
    "https://example.org/image.png": "blog/example/image.png"
  },
  "covers": {
    "blog/example/cover.jpg": "blog/example/cover-1280x720.jpg"
  },
  "ftp": {
    "files": {
      "index.html": "md5-of-the-last-uploaded-bytes"
    }
  }
}
```

All three image maps are keyed by repository-relative paths, except
`downloads`, whose keys are the original remote URLs. `ftp.files` is keyed by
paths relative to `dist/` and holds MD5 hashes of the last successful upload;
generated post pages are hashed per language without their random
recommendations section, home pages without their random posts section, and
feeds without their build timestamp. It is maintained by `tools/ftp/ftp-sync`
and `tools/ftp/ftp_sync.erl`, not by the optimizer. The manifest is
committed so a fresh clone skips work that has already been done. `check` and
`dry-run` verify it without writing or downloading anything.
