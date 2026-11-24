#!/usr/bin/env python3
"""Plan and commit SFTP uploads using content hashes from website-manifest.json.

``plan`` writes git-diff-style lines to stdout for ``tools/ftp-upload``:

  A<TAB>relative/path   new in dist/
  M<TAB>relative/path   content differs from the last uploaded hash
  D<TAB>relative/path   present in the cache but no longer in dist/

Files whose MD5 matches the last uploaded hash are omitted, so rebuilding
dist/ (even from scratch) never re-uploads unchanged bytes. Generated post
pages are hashed per language with their randomly picked "Otras entradas"
section removed; home pages drop their random posts section and Atom feeds
drop the build timestamp. That keeps each post's stable content and the shared
chrome in the hash without uploading a new random sample on every build.

``commit`` advances the manifest's ``ftp.files`` cache only after a successful
upload. ``seed`` imports hashes from the legacy .ftp-upload-dist/ snapshot
once, so the first deploy after the migration also skips unchanged files.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import tempfile
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
MANIFEST_NAME = "website-manifest.json"
DIST_NAME = "dist"
SNAPSHOT_NAME = ".ftp-upload-dist"
IGNORED_NAMES = {".DS_Store"}
CHUNK_SIZE = 1024 * 1024

# Build-time randomness and clocks: each rebuild reshuffles these blocks,
# so they must not change a post page's upload identity. The patterns match
# only the generated markup, leaving the rest of each page intact.
VOLATILE_HTML = (
    re.compile(rb'<section[^>]*class="rs-panel post-others"[^>]*>.*?</section>', re.DOTALL),
    re.compile(rb'<section[^>]*\bid="posts"[^>]*>.*?</section>', re.DOTALL),
)
UPDATED_TAG = re.compile(rb"<updated>.*?</updated>", re.DOTALL)


def stable_bytes(path: Path, data: bytes) -> bytes:
    """Remove build-only noise before hashing a generated text file."""
    if path.suffix.lower() == ".html":
        for pattern in VOLATILE_HTML:
            data = pattern.sub(b"", data)
    elif path.suffix.lower() == ".xml":
        data = UPDATED_TAG.sub(b"", data)
    return data


def md5_bytes(data: bytes) -> str:
    return hashlib.md5(data, usedforsecurity=False).hexdigest()


def md5_file(path: Path) -> str:
    digest = hashlib.md5(usedforsecurity=False)
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(CHUNK_SIZE), b""):
            digest.update(chunk)
    return digest.hexdigest()


def digest_file(path: Path) -> str:
    if path.suffix.lower() in (".html", ".xml"):
        return md5_bytes(stable_bytes(path, path.read_bytes()))
    return md5_file(path)


def new_manifest() -> dict:
    return {
        "version": 1,
        "images": {},
        "downloads": {},
        "covers": {},
        "ftp": {"files": {}},
    }


def load_manifest(path: Path) -> dict:
    if not path.exists():
        return new_manifest()
    manifest = json.loads(path.read_text(encoding="utf-8"))
    if manifest.get("version") != 1:
        raise ValueError(f"unsupported manifest version in {path}")
    for key in ("images", "downloads", "covers"):
        manifest.setdefault(key, {})
    manifest.setdefault("ftp", {}).setdefault("files", {})
    return manifest


def atomic_write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            handle.write(text)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def save_manifest(path: Path, manifest: dict) -> None:
    ordered = {
        "version": manifest["version"],
        "images": dict(sorted(manifest["images"].items())),
        "downloads": dict(sorted(manifest["downloads"].items())),
        "covers": dict(sorted(manifest["covers"].items())),
        "ftp": {"files": dict(sorted(manifest["ftp"]["files"].items()))},
    }
    text = json.dumps(ordered, indent=2, ensure_ascii=False) + "\n"
    atomic_write_text(path, text)


def digest_files(directory: Path) -> dict[str, str]:
    if not directory.is_dir():
        raise ValueError(f"not a directory: {directory}")
    files: dict[str, str] = {}
    for path in sorted(directory.rglob("*")):
        if not path.is_file() or path.is_symlink() or path.name in IGNORED_NAMES:
            continue
        relative = path.relative_to(directory).as_posix()
        if any(character in relative for character in "\t\r\n"):
            raise ValueError(f"file name cannot be sent to ftp-upload: {relative!r}")
        files[relative] = digest_file(path)
    return files


def plan(root: Path, dist: Path | None = None) -> list[tuple[str, str]]:
    cached = load_manifest(root / MANIFEST_NAME)["ftp"]["files"]
    current = digest_files(dist or root / DIST_NAME)
    changes: list[tuple[str, str]] = []
    for path in sorted(set(cached) | set(current)):
        if path not in current:
            changes.append(("D", path))
        elif path not in cached:
            changes.append(("A", path))
        elif cached[path] != current[path]:
            changes.append(("M", path))
    return changes


def commit(root: Path, dist: Path | None = None) -> int:
    manifest_path = root / MANIFEST_NAME
    manifest = load_manifest(manifest_path)
    files = digest_files(dist or root / DIST_NAME)
    manifest["ftp"]["files"] = files
    save_manifest(manifest_path, manifest)
    return len(files)


def seed(root: Path, snapshot: Path | None = None) -> int:
    manifest_path = root / MANIFEST_NAME
    manifest = load_manifest(manifest_path)
    if manifest["ftp"]["files"]:
        raise ValueError("ftp cache is already populated; refusing to overwrite it")
    files = digest_files(snapshot or root / SNAPSHOT_NAME)
    manifest["ftp"]["files"] = files
    save_manifest(manifest_path, manifest)
    return len(files)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=REPOSITORY_ROOT)
    parser.add_argument("--dist", type=Path, help="output directory (default: <root>/dist)")
    parser.add_argument("--snapshot", type=Path, help="legacy snapshot (default: <root>/.ftp-upload-dist)")
    parser.add_argument("command", choices=("plan", "commit", "seed"))
    arguments = parser.parse_args(argv)

    try:
        if arguments.command == "plan":
            for action, path in plan(arguments.root, arguments.dist):
                print(f"{action}\t{path}")
        elif arguments.command == "commit":
            print(f"ftp-sync: cached {commit(arguments.root, arguments.dist)} file hashes")
        else:
            snapshot = arguments.snapshot or arguments.root / SNAPSHOT_NAME
            print(f"ftp-sync: seeded {seed(arguments.root, snapshot)} file hashes from {snapshot}")
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"ftp-sync: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
