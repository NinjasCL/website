# [Ninjas.cl](https://ninjas.cl) Software Development Group

![](https://avatars1.githubusercontent.com/u/15203190)
![](https://img.shields.io/badge/Ninjas-CL-green.svg?style=flat-square)

Gleam source for the [ninjas.cl](https://ninjas.cl/) site, built with
[blogatto](https://blogat.to/).

## Development

Task shortcuts:

```sh
task setup   # Verify Gleam/Erlang and install dependencies
task build   # Generate the static site into ./dist
task dev     # Start the dev server at http://127.0.0.1:3000
task upload  # Upload changed dist/ files to the configured SFTP route
```

Running `task` with no arguments runs `build`. Short aliases are available:
`task s` for `setup`, `task b` for `build`, `task d` for `dev`, and `task u`
for `upload`.

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

`task upload` builds the site, compares the new `dist/` with a local snapshot
of the last uploaded output using `git diff --no-index`, and passes only the
added, modified, and deleted files to `tools/ftp-upload`. That Erlang escript
uses OTP's `ssh_sftp` client to create any missing remote directories, upload
the changed files in chunks, and delete removed files. The git-ignored
snapshot (`.ftp-upload-dist/`) is refreshed only after a successful upload, so
a failed deploy is retried in full on the next run. Unchanged files are never
re-uploaded.

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

:ext-relative:
:toc: macro
:toclevels: 4

## 🤩 Credits

<p>
  Made with <i class="fa fa-heart">&#9829;</i> by
  <a href="https://ninjas.cl">
    Ninjas.cl
  </a>.
</p>
