# Proposal

## Why

Post images are currently a mix of unoptimized local files and external URLs: 17
remote images across 7 posts are fetched from GitHub or dev.to at page view, and
`featured_image` values point at arbitrary sizes (one cover is 11 MiB). Posts
should be self-contained and served from ninjas.cl, and covers should have a
predictable 1280x720 presentation.

## What Changes

- Add `tools/optimize/`: a Python 3.14+ / Pillow tool with its own
  `tools/optimize/Taskfile.yml` for installing dependencies and running it.
- Download every remote post image into `blog/<slug>/` and repoint the 28
  affected djot files' `featured_image` and inline `![](...)` references at the
  local files. There are 17 distinct remote images.
- Optimize every image under `blog/` in place with conservative web settings.
  Leave every file under `static/` byte-for-byte verbatim.
- For each `featured_image`, add a `<stem>-1280x720.<ext>` center-cropped
  derivative beside the optimized original and repoint `featured_image` to it.
  Inline images keep using the original. The single SVG cover gets a
  one-off rasterized PNG derivative.
- Copy `static/img/Ninjas.png` into the welcome post as its original and
  derivative so the shared logo can be cropped for that post without modifying
  the static original.
- Keep a root-level `optimize-manifest.json` of content hashes so downloaded,
  optimized, and derivative files are never processed twice.
- Wire a root `task optimize` to the nested Taskfile and make deployment run
  optimize before build. Document the tool in `AGENTS.md`.
- Out of scope: changes to `static/`, Gleam templates/routes, CI, video embeds,
  YouTube/archive.org iframes, and image formats not present in the posts.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `blog-site-generation`: post-adjacent images become locally sourced,
  optimized once, and tracked by a content-hash manifest; static assets stay
  verbatim.
- `site-featured-post`: the featured figure uses a standardized 1280x720
  center-cropped derivative while preserving natural proportions.

## Impact

- New `tools/optimize/` directory and root `optimize-manifest.json`.
- 17 downloaded binaries, 28 djot files with rewritten references, 404
  `featured_image` lines repointed to derivatives.
- Root `Taskfile.yml` gains an `optimize` task and changes `upload` ordering;
  `AGENTS.md` documents the new tool.
- Build behavior stays blogatto-based: post-adjacent files continue to be
  served at the post URL by base name, and `site.featured_image(post)` keeps
  returning the frontmatter value. No Gleam or CI changes are required.
