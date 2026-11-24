#!/usr/bin/env python3
"""Localize, optimize, and normalize ninjas.cl blog images.

Run from the repository root through ``task optimize`` or the nested
``tools/optimize/Taskfile.yml``. The tool only ever reads from ``static/``;
every write goes to ``blog/`` or the root website manifest. The manifest's
SFTP cache is left intact for the upload planner.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
import re
import sys
import tempfile
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable

from PIL import Image, ImageOps

REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
BLOG_DIRECTORY = REPOSITORY_ROOT / "blog"
STATIC_DIRECTORY = REPOSITORY_ROOT / "static"
MANIFEST_PATH = REPOSITORY_ROOT / "website-manifest.json"

COVER_SIZE = (1280, 720)
COVER_MARKER = "-1280x720"
WELCOME_SLUG = "bienvenidos-a-ninjas-cl"
LOGO_RELATIVE_PATH = "img/Ninjas.png"
USER_AGENT = "Mozilla/5.0 (compatible; ninjas.cl image optimizer)"

FORMAT_BY_EXTENSION = {
    ".avif": "AVIF",
    ".gif": "GIF",
    ".jpeg": "JPEG",
    ".jpg": "JPEG",
    ".png": "PNG",
    ".webp": "WEBP",
}

FEATURED_RE = re.compile(r"^(featured_image:\s*)(\S+)(\s*(?:#.*)?)$", re.MULTILINE)
INLINE_IMAGE_RE = re.compile(r"!\[([^\]]*)\]\((https?://[^\s)]+)\)")
COVER_FILE_RE = re.compile(
    r"^(?P<stem>.*)" + re.escape(COVER_MARKER) + r"\.(?P<ext>png|jpe?g|webp|avif|gif)$",
    re.IGNORECASE,
)

Downloader = Callable[[str], bytes]


@dataclass
class Stats:
    downloaded: int = 0
    copied: int = 0
    optimized: int = 0
    covers: int = 0
    rewritten: int = 0
    skipped: int = 0
    pending: int = 0


@dataclass
class Context:
    root: Path
    manifest: dict
    check_only: bool
    downloader: Downloader
    stats: Stats = field(default_factory=Stats)
    optimized_paths: set[str] = field(default_factory=set)


def new_manifest() -> dict:
    return {
        "version": 1,
        "images": {},
        "downloads": {},
        "covers": {},
        "posts": {},
        "latest_post": {},
        "ftp": {"files": {}},
    }


def load_manifest(path: Path) -> dict:
    if not path.exists():
        return new_manifest()
    manifest = json.loads(path.read_text(encoding="utf-8"))
    if manifest.get("version") != 1:
        raise ValueError(f"unsupported manifest version in {path}")
    for key in ("images", "downloads", "covers", "posts", "latest_post"):
        manifest.setdefault(key, {})
    ftp = manifest.setdefault("ftp", {})
    ftp.setdefault("files", {})
    return manifest


def save_manifest(path: Path, manifest: dict) -> None:
    ordered = {
        "version": manifest["version"],
        "images": dict(sorted(manifest["images"].items())),
        "downloads": dict(sorted(manifest["downloads"].items())),
        "covers": dict(sorted(manifest["covers"].items())),
        # The build writes post dates newest first; keep that order intact.
        "posts": dict(manifest["posts"].items()),
        "latest_post": dict(manifest["latest_post"].items()),
        "ftp": {"files": dict(sorted(manifest["ftp"]["files"].items()))},
    }
    atomic_write_text(path, json.dumps(ordered, indent=2, ensure_ascii=False) + "\n")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def atomic_write_bytes(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(data)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def atomic_write_text(path: Path, text: str) -> None:
    atomic_write_bytes(path, text.encode("utf-8"))


def repository_relative(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def public_path(relative: str) -> str:
    return "/" + relative.lstrip("/")


def format_for_path(path: Path) -> str | None:
    return FORMAT_BY_EXTENSION.get(path.suffix.lower())


def is_cover_derivative(path: Path) -> bool:
    return COVER_FILE_RE.match(path.name) is not None


def is_derivative_reference(value: str) -> bool:
    return COVER_FILE_RE.match(Path(urllib.parse.urlsplit(value).path).name) is not None


def cover_derivative_path(original: Path) -> Path:
    extension = original.suffix.lower()
    if extension == ".svg":
        extension = ".png"
    return original.with_name(f"{original.stem}{COVER_MARKER}{extension}")


def save_settings(image_format: str) -> dict:
    if image_format == "PNG":
        return {"optimize": True, "compress_level": 9}
    if image_format == "JPEG":
        return {"quality": 85, "optimize": True, "progressive": True, "subsampling": 2}
    if image_format == "WEBP":
        return {"quality": 85, "method": 6}
    if image_format == "AVIF":
        return {"quality": 60, "speed": 6}
    if image_format == "GIF":
        return {"optimize": True}
    raise ValueError(f"unsupported image format: {image_format}")


def as_saveable(image: Image.Image, image_format: str) -> Image.Image:
    if image_format != "JPEG" or image.mode in ("RGB", "L"):
        return image
    if "A" in image.getbands() or "transparency" in image.info:
        rgba = image.convert("RGBA")
        background = Image.new("RGB", rgba.size, (255, 255, 255))
        background.paste(rgba, mask=rgba.getchannel("A"))
        return background
    return image.convert("RGB")


def encode_image(image: Image.Image, image_format: str) -> bytes:
    buffer = io.BytesIO()
    as_saveable(image, image_format).save(buffer, format=image_format, **save_settings(image_format))
    return buffer.getvalue()


def optimize_image_bytes(data: bytes, image_format: str) -> bytes:
    with Image.open(io.BytesIO(data)) as image:
        image.load()
        if image_format != "GIF":
            return encode_image(image, image_format)

        frames: list[Image.Image] = []
        durations: list[int] = []
        for index in range(getattr(image, "n_frames", 1)):
            image.seek(index)
            frames.append(image.copy())
            durations.append(int(image.info.get("duration", 100)))

        loop = image.info.get("loop", 0)
        disposal = image.info.get("disposal")
        options = save_settings("GIF") | {
            "save_all": True,
            "append_images": frames[1:],
            "duration": durations,
            "loop": loop,
        }
        if isinstance(disposal, int):
            options["disposal"] = disposal

        buffer = io.BytesIO()
        frames[0].save(buffer, format="GIF", **options)
        return buffer.getvalue()


def render_cover_bytes(data: bytes, image_format: str) -> bytes:
    if image_format == "SVG":
        return render_svg_cover_bytes(data)
    with Image.open(io.BytesIO(data)) as image:
        image.load()
        source = image
        if source.mode not in ("RGB", "RGBA"):
            has_alpha = "A" in source.getbands() or "transparency" in source.info
            source = source.convert("RGBA" if has_alpha else "RGB")
        fitted = ImageOps.fit(
            source,
            COVER_SIZE,
            method=Image.Resampling.LANCZOS,
            centering=(0.5, 0.5),
        )
        return encode_image(fitted, image_format)


def parse_svg_size(svg: str) -> tuple[float, float]:
    root = ET.fromstring(svg)
    view_box = root.attrib.get("viewBox")
    if view_box:
        parts = [float(part) for part in re.split(r"[,\s]+", view_box.strip()) if part]
        if len(parts) >= 4 and parts[2] > 0 and parts[3] > 0:
            return parts[2], parts[3]

    def length(value: str | None) -> float | None:
        if value is None:
            return None
        match = re.match(r"^(\d+(?:\.\d+)?)(?:px)?$", value.strip())
        return float(match.group(1)) if match else None

    width = length(root.attrib.get("width"))
    height = length(root.attrib.get("height"))
    if width and height:
        return width, height
    raise ValueError("SVG has no usable viewBox or width/height")


def render_svg_cover_bytes(data: bytes) -> bytes:
    try:
        from resvg_py import svg_to_bytes
    except ImportError as error:  # pragma: no cover - dependency is pinned
        raise RuntimeError("resvg-py is required to rasterize SVG covers") from error

    svg = data.decode("utf-8")
    width, height = parse_svg_size(svg)
    scale = max(COVER_SIZE[0] / width, COVER_SIZE[1] / height)
    rendered = svg_to_bytes(
        svg_string=svg,
        width=max(1, round(width * scale)),
        height=max(1, round(height * scale)),
    )
    return render_cover_bytes(rendered, "PNG")


def post_files(root: Path) -> list[Path]:
    return sorted((root / "blog").glob("*/index*.djot"))


def remote_urls(text: str) -> list[str]:
    found = set(url for _, url in INLINE_IMAGE_RE.findall(text))
    for line in text.splitlines():
        match = FEATURED_RE.match(line)
        if match and match.group(2).startswith(("http://", "https://")):
            found.add(match.group(2))
    return sorted(found)


def local_filename(url: str, slug: str, used_names: set[str]) -> str:
    parsed = urllib.parse.urlsplit(url)
    name = Path(urllib.parse.unquote(parsed.path)).name or "image"
    name = re.sub(r"[^A-Za-z0-9._-]+", "-", name)
    stem, extension = os.path.splitext(name)
    stem = stem or "image"
    extension = extension or ".img"
    candidate = f"{stem}{extension}"
    if candidate in used_names:
        candidate = f"{stem}-{sha256_bytes(url.encode('utf-8'))[:8]}{extension}"
    used_names.add(candidate)
    return f"blog/{slug}/{candidate}"


def download_bytes(url: str) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read()


def ensure_local_download(context: Context, url: str, slug: str, relative: str | None) -> str | None:
    if relative is None:
        if context.check_only:
            context.stats.pending += 1
            return None
        used_names = {
            Path(value).name
            for value in context.manifest["downloads"].values()
            if value.startswith(f"blog/{slug}/")
        }
        relative = local_filename(url, slug, used_names)
        context.manifest["downloads"][url] = relative

    local = context.root / relative
    if not local.exists():
        if context.check_only:
            context.stats.pending += 1
            return relative
        atomic_write_bytes(local, context.downloader(url))
        context.stats.downloaded += 1
    return relative


def localize_references(context: Context) -> None:
    for post in post_files(context.root):
        slug = post.parent.name
        text = post.read_text(encoding="utf-8")
        updated = text

        for url in remote_urls(text):
            relative = ensure_local_download(
                context, url, slug, context.manifest["downloads"].get(url)
            )
            if relative is None:
                continue
            site_path = public_path(relative)
            filename = Path(relative).name
            updated = FEATURED_RE.sub(
                lambda match: (
                    match.group(1) + site_path + match.group(3)
                    if match.group(2) == url
                    else match.group(0)
                ),
                updated,
            )
            updated = INLINE_IMAGE_RE.sub(
                lambda match: (
                    f"![{match.group(1)}]({filename})"
                    if match.group(2) == url
                    else match.group(0)
                ),
                updated,
            )

        if updated != text:
            if context.check_only:
                context.stats.pending += 1
            else:
                atomic_write_text(post, updated)
                context.stats.rewritten += 1


def copy_welcome_logo(context: Context) -> None:
    relative = f"blog/{WELCOME_SLUG}/{Path(LOGO_RELATIVE_PATH).name}"
    source = context.root / "static" / LOGO_RELATIVE_PATH
    target = context.root / relative
    if not source.is_file():
        raise FileNotFoundError(f"static logo is missing: {source}")

    if not target.exists():
        if context.check_only:
            context.stats.pending += 1
        else:
            atomic_write_bytes(target, source.read_bytes())
            context.stats.copied += 1

    for post in sorted((context.root / "blog" / WELCOME_SLUG).glob("index*.djot")):
        text = post.read_text(encoding="utf-8")
        updated = FEATURED_RE.sub(
            lambda match: (
                match.group(1) + public_path(relative) + match.group(3)
                if match.group(2) == public_path(LOGO_RELATIVE_PATH)
                else match.group(0)
            ),
            text,
        )
        if updated != text:
            if context.check_only:
                context.stats.pending += 1
            else:
                atomic_write_text(post, updated)
                context.stats.rewritten += 1


def optimize_images(context: Context) -> None:
    for path in sorted((context.root / "blog").rglob("*")):
        if not path.is_file() or is_cover_derivative(path):
            continue
        image_format = format_for_path(path)
        if image_format is None:
            continue

        relative = repository_relative(path, context.root)
        original = path.read_bytes()
        digest = sha256_bytes(original)
        if context.manifest["images"].get(relative) == digest:
            context.stats.skipped += 1
            continue
        if context.check_only:
            context.stats.pending += 1
            continue

        optimized = optimize_image_bytes(original, image_format)
        if optimized == original:
            final_digest = digest
        else:
            atomic_write_bytes(path, optimized)
            final_digest = sha256_bytes(optimized)
        context.manifest["images"][relative] = final_digest
        context.optimized_paths.add(relative)
        context.stats.optimized += 1


def resolve_cover_original(value: str, slug: str) -> str:
    path = urllib.parse.urlsplit(value).path
    if path.startswith(("http://", "https://")):
        raise ValueError(f"cover is still remote: {value}")
    if path.startswith("/"):
        relative = path.lstrip("/")
        if relative.startswith("blog/"):
            return relative
        if relative == LOGO_RELATIVE_PATH:
            return f"blog/{WELCOME_SLUG}/{Path(LOGO_RELATIVE_PATH).name}"
        raise ValueError(f"cover path is outside the blog content: {value}")
    return f"blog/{slug}/{Path(urllib.parse.unquote(path)).name}"


def ensure_covers(context: Context) -> None:
    for post in post_files(context.root):
        slug = post.parent.name
        lines = post.read_text(encoding="utf-8").splitlines(keepends=True)
        changed = False

        for index, line in enumerate(lines):
            body = line.rstrip("\r\n")
            match = FEATURED_RE.match(body)
            if match is None or is_derivative_reference(match.group(2)):
                continue
            if match.group(2).startswith(("http://", "https://")):
                if context.check_only:
                    context.stats.pending += 1
                    continue
                raise ValueError(f"cover is still remote: {match.group(2)}")

            original_relative = resolve_cover_original(match.group(2), slug)
            original = context.root / original_relative
            if not original.is_file():
                if context.check_only:
                    context.stats.pending += 1
                    continue
                raise FileNotFoundError(f"cover source is missing: {original}")

            derivative_relative = context.manifest["covers"].get(original_relative)
            if derivative_relative is None:
                derivative_relative = cover_derivative_path(Path(original_relative)).as_posix()
            derivative = context.root / derivative_relative

            image_format = format_for_path(original)
            if image_format is None and original.suffix.lower() == ".svg":
                image_format = "SVG"
            if image_format is None:
                raise ValueError(f"unsupported cover source: {original}")

            derivative_missing = not derivative.is_file()
            derivative_stale = (
                not derivative_missing
                and context.manifest["images"].get(derivative_relative) != sha256_file(derivative)
            )
            source_stale = original_relative in context.optimized_paths
            if derivative_missing or derivative_stale or source_stale:
                if context.check_only:
                    context.stats.pending += 1
                else:
                    cover_bytes = render_cover_bytes(original.read_bytes(), image_format)
                    atomic_write_bytes(derivative, cover_bytes)
                    context.manifest["images"][derivative_relative] = sha256_bytes(cover_bytes)
                    context.manifest["covers"][original_relative] = derivative_relative
                    context.stats.covers += 1

            site_path = public_path(derivative_relative)
            if match.group(2) != site_path:
                if context.check_only:
                    context.stats.pending += 1
                else:
                    ending = line[len(body):]
                    lines[index] = match.group(1) + site_path + match.group(3) + ending
                    changed = True
                    context.stats.rewritten += 1

        if changed and not context.check_only:
            atomic_write_text(post, "".join(lines))


def run(
    root: Path,
    *,
    check_only: bool = False,
    downloader: Downloader | None = None,
) -> Stats:
    context = Context(
        root=root,
        manifest=load_manifest(root / MANIFEST_PATH.name),
        check_only=check_only,
        downloader=downloader or download_bytes,
    )
    copy_welcome_logo(context)
    localize_references(context)
    optimize_images(context)
    ensure_covers(context)
    if not check_only:
        save_manifest(root / MANIFEST_PATH.name, context.manifest)
    return context.stats


def print_summary(stats: Stats, *, check_only: bool) -> None:
    verb = "Would process" if check_only else "Processed"
    print(
        f"{verb}: {stats.downloaded} downloads, {stats.copied} copies, "
        f"{stats.optimized} optimized images, {stats.covers} covers, "
        f"{stats.rewritten} reference rewrites"
    )
    if check_only:
        print(f"Pending work: {stats.pending}")
    else:
        print(f"Skipped already-optimized images: {stats.skipped}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=REPOSITORY_ROOT)
    parser.add_argument("--check", action="store_true", help="report pending work without writing")
    parser.add_argument("--dry-run", action="store_true", help="alias for --check with exit 0")
    arguments = parser.parse_args(argv)

    try:
        stats = run(arguments.root, check_only=arguments.check or arguments.dry_run)
    except Exception as error:
        print(f"error: {error}", file=sys.stderr)
        return 2

    print_summary(stats, check_only=arguments.check or arguments.dry_run)
    if arguments.check and stats.pending:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
