# FTP deployment tools

`tools/ftp/` contains two Erlang escripts that split deployment into planning
and transfer:

| Tool | Purpose |
| --- | --- |
| `ftp-sync` | Decides which `dist/` files are new, changed, or deleted and records the hashes of the last successful upload. |
| `ftp-upload` | Applies that change list to the remote SFTP route. |

They are used together by `task upload`. Both compile their `.erl` source at
runtime, so there is no separate build step; Erlang/OTP must be on `PATH`.

## Why hashes instead of timestamps

A rebuild rewrites every file in `dist/`, so comparing modification times or a
raw directory diff uploads the whole site again. `ftp-sync` instead stores MD5
content hashes in the `ftp.files` section of the root
[`website-manifest.json`](../../website-manifest.json):

```json
{
  "ftp": {
    "files": {
      "index.html": "md5-of-the-last-uploaded-bytes"
    }
  }
}
```

Keys are paths relative to `dist/`. A file uploads when:

- it is not in the cache (`A`, added),
- its current hash differs from the cached hash (`M`, modified), or
- it is in the cache but no longer exists in `dist/` (`D`, deleted).

If the bytes are unchanged, a fresh build produces no changes even though the
file's timestamp changed. Deletions still ship because the cached path list is
compared with the current tree.

Build-only noise is removed before hashing so a rebuild does not look like a
content change:

- post pages drop the random `Otras entradas` recommendations section, per
  language;
- home pages drop their random posts section;
- Atom feeds drop their `<updated>` build timestamp.

Real template or content edits still change the hash and upload normally.
`.DS_Store` files and symlinks are ignored.

## Recommended usage

Run these from the repository root:

```sh
cp env.txt .env   # fill in the credentials once
task upload       # optimize images, build, plan, upload, then commit
```

`task upload` does the following:

1. `task optimize` localizes and optimizes post images.
2. `task build` regenerates `dist/` from scratch.
3. `tools/ftp/ftp-sync --dist dist plan` writes the change list to a temporary
   file.
4. If the list is empty, it prints `ftp-sync: no changes to upload` and stops.
5. Otherwise `tools/ftp/ftp-upload` applies the list.
6. Only after a successful upload, `tools/ftp/ftp-sync --dist dist commit`
   advances the cached hashes.

The delayed `commit` is important: if the transfer fails, the cache still
describes the last successful upload, so the next run retries the same files.

## `ftp-sync`

```sh
tools/ftp/ftp-sync plan
tools/ftp/ftp-sync commit
tools/ftp/ftp-sync seed
```

Options:

| Option | Default | Meaning |
| --- | --- | --- |
| `--root PATH` | parent of `tools/ftp` | Repository root; the manifest is `<root>/website-manifest.json`. |
| `--dist PATH` | `<root>/dist` | Generated site to hash. |
| `--snapshot PATH` | `<root>/.ftp-upload-dist` | Legacy snapshot used by `seed`. |

### `plan`

Prints one change per line on stdout, sorted by path:

```text
A<TAB>blog/en/new-post/index.html
M<TAB>index.html
D<TAB>old/file.gif
```

The first field is separated from the path by a real tab character. This output
is the stdin contract for `ftp-upload`. The planner emits only `A`, `M`, and
`D`; the uploader also understands `T` for compatibility.

`plan` does not modify the manifest. If `dist/` does not exist, it fails rather
than treating every file as deleted.

### `commit`

Replaces `ftp.files` with the current hashes of every file in `dist/`. Run it
only after `ftp-upload` succeeds. It preserves the manifest's `images`,
`downloads`, and `covers` sections.

### `seed`

One-time migration that copies hashes from a legacy `.ftp-upload-dist/`
snapshot into an empty `ftp.files` cache. It refuses to run when the cache is
already populated. The old snapshot is no longer used by `task upload`.

## `ftp-upload`

`ftp-upload` reads the change list from stdin and connects over SFTP (SSH),
not plain FTP:

```sh
tools/ftp/ftp-sync --dist dist plan > /tmp/changes
tools/ftp/ftp-upload < /tmp/changes
tools/ftp/ftp-sync --dist dist commit
```

Environment variables are loaded from `.env` by the Taskfile. When invoking the
escript directly, export them yourself:

| Variable | Required | Notes |
| --- | --- | --- |
| `FTP_HOST` | yes | SFTP hostname. |
| `FTP_PORT` | yes | SSH port, usually `22` (not `21`). |
| `FTP_USER` | yes | SFTP username. |
| `FTP_ROUTE` | yes | Absolute remote directory, such as `/home/user/public_html`. If the account is chrooted, use `/public_html`. |
| `FTP_PASSWORD` | no | Empty means key-based authentication. |

The uploader:

- rejects unsafe change paths (absolute paths, `..`, or empty components), so
  nothing can escape `dist/` or `FTP_ROUTE`;
- creates missing remote directories one component at a time;
- overwrites existing files and streams data in 64 KiB chunks;
- deletes removed files, tolerating files already missing remotely;
- prints progress and a final uploaded/deleted count.

If stdin is empty, it prints `ftp-upload: no changes to upload` and exits
without connecting.

## Files

| Path | Role |
| --- | --- |
| `ftp-sync` | Executable CLI for `plan`, `commit`, and `seed`. |
| `ftp_sync.erl` | Planner logic: walking, stable hashing, manifest I/O. |
| `ftp-upload` | Executable CLI wrapper. |
| `ftp_upload.erl` | Uploader logic: config, change parsing, directories, streaming, progress. |
| `ftp_upload_sftp.erl` | Production backend calling `ssh_sftp` and `ssh`. |
| `tests/run_tests.escript` | Runs all FTP EUnit suites. |
| `tests/ftp_upload_fake.erl` | Fake backend used to test uploads without a server. |

## Tests

```sh
tools/ftp/tests/run_tests.escript
```

The suite covers both tools: hash stability and manifest handling for
`ftp-sync`, and config parsing, path safety, directory creation, chunked
streaming, deletes, and error handling for `ftp-upload`. No real FTP server or
credentials are needed.
