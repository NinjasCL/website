# [Ninjas.cl](https://ninjas.cl) Software Development Group

![](https://avatars1.githubusercontent.com/u/15203190)
![](https://img.shields.io/badge/Ninjas-CL-green.svg?style=flat-square)

Gleam source for the [ninjas.cl](https://ninjas.cl/) site, built with
[blogatto](https://blogat.to/).

## Development

Task shortcuts:

```sh
task setup    # Verify Gleam/Erlang and install dependencies
task build    # Generate the static site into ./dist
task optimize # Localize, optimize, and normalize blog images
task dev      # Start the dev server at http://127.0.0.1:3000
task upload   # Optimize, build, and upload changed dist/ files over SFTP
```

Running `task` with no arguments runs `build`. Short aliases are available:
`task s` for `setup`, `task b` for `build`, `task o` for `optimize`, `task d`
for `dev`, and `task u` for `upload`.

## Uploading

Copy `env.txt` to `.env` and fill in the FTP credentials:

```sh
FTP_USER=...
FTP_PASSWORD=...
FTP_HOST=...
FTP_PORT=22
FTP_ROUTE=/home/user/public_html
```

The Taskfile loads `.env` automatically. `FTP_ROUTE` is the absolute remote
directory that receives the contents of `dist/`. `FTP_PASSWORD` may be left
empty to use key-based authentication. `FTP_PORT` must be the SSH/SFTP port
(usually `22`); using the plain-FTP port `21` makes the connection time out.

`task upload` optimizes post images, builds the site, and asks
`tools/ftp/ftp-sync` to compare the new `dist/` with the MD5 content hashes of
the last uploaded files in `website-manifest.json`. Each generated post page
is hashed per language with its random "Otras entradas" section removed; home
pages drop their random posts section and Atom feeds drop their build
timestamp. Real content or template edits still upload, but a fresh random
sample or build clock does not, so deleting `dist/` and rebuilding uploads
nothing while the site is unchanged. Only added, modified, and deleted paths
go to `tools/ftp/ftp-upload`. That Erlang escript uses OTP's `ssh_sftp` client to
create any missing remote directories, upload the changed files in chunks, and
delete removed files. The manifest's `ftp.files` cache is advanced only after
a successful upload, so a failed deploy is retried on the next run. See
`tools/ftp/README.md` for the full usage guide. The planner, uploader, and their
EUnit tests live in `tools/ftp/`; run the tests with
`tools/ftp/tests/run_tests.escript`.

## Images

Post images are local to each post. `task optimize` downloads any remote image
referenced by a post into `blog/<slug>/`, optimizes every supported raster
image under `blog/`, and writes a `<stem>-1280x720.<ext>` center-cropped
derivative for every `featured_image`. The original stays for inline figures;
frontmatter points at the derivative. SVG covers get a raster PNG derivative.
Nothing under `static/` is changed.

The tool lives in `tools/optimize/` and needs Python 3.14+ and `uv`. Its nested
Taskfile installs pinned dependencies and exposes `test`, `check`, and
`dry-run`:

```sh
task -d tools/optimize test
task -d tools/optimize check
task -d tools/optimize dry-run
```

`website-manifest.json` at the repository root records content hashes so an
already optimized image is skipped on later runs, plus the MD5 hashes of the
last uploaded files used by `task upload`. Keep it committed. The build also
records each post's last-update date under `posts` (keyed by slug, newest first)
and names the most recent one in `latest_post`. See `tools/optimize/README.md`
for the image sections and `tools/ftp/ftp_sync.erl` for the upload cache.

Underlying Gleam commands:

```sh
gleam deps download   # Install dependencies
gleam run             # Build the static site into ./dist
gleam run -m dev      # Start the dev server at http://127.0.0.1:3000
gleam test            # Run tests
gleam format src test # Format source and test files
```

The dev server watches `src/`, `blog/`, and `static/`, rebuilds the site on
changes, and live-reloads connected browsers.

Production builds use `https://ninjas.cl/` as the site URL. The dev server
builds with `http://127.0.0.1:3000/` so generated links stay local.

## Content

Posts live under `blog/<slug>/index.md` with blogatto frontmatter
(`title`, `date`, and `description` are required; `slug`, `featured_image`,
and other keys are optional). Static assets live in `static/` and are copied
into the generated `dist/` output.

## 🤩 Credits

<p>
  Made with <i class="fa fa-heart">&#9829;</i> by
  <a href="https://ninjas.cl">
    Ninjas.cl
  </a>.
</p>
