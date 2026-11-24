import io
import json
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import optimize  # noqa: E402


def encoded_image(image_format: str, size=(24, 12), color=(120, 80, 40)) -> bytes:
    image = Image.new("RGB", size, color)
    buffer = io.BytesIO()
    if image_format == "PNG":
        image.save(buffer, format=image_format, compress_level=0)
    else:
        image.save(buffer, format=image_format)
    return buffer.getvalue()


def animated_gif() -> bytes:
    frames = [
        Image.new("RGB", (16, 16), color)
        for color in ((255, 0, 0), (0, 0, 255))
    ]
    buffer = io.BytesIO()
    frames[0].save(
        buffer,
        format="GIF",
        save_all=True,
        append_images=frames[1:],
        duration=[100, 200],
        loop=0,
    )
    return buffer.getvalue()


class OptimizerTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        (self.root / "blog").mkdir()
        logo = self.root / "static" / "img" / "Ninjas.png"
        logo.parent.mkdir(parents=True)
        logo.write_bytes(encoded_image("PNG"))
        (self.root / "website-manifest.json").write_text(
            json.dumps(optimize.new_manifest()), encoding="utf-8"
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_post(self, slug: str, featured: str, body: str = "") -> Path:
        directory = self.root / "blog" / slug
        directory.mkdir(parents=True, exist_ok=True)
        post = directory / "index.djot"
        post.write_text(
            "---\n"
            f"featured_image: {featured}\n"
            "---\n\n"
            + body
            + "\n",
            encoding="utf-8",
        )
        return post

    def test_every_supported_format_optimizes_and_reopens(self) -> None:
        samples = {
            "PNG": encoded_image("PNG"),
            "JPEG": encoded_image("JPEG"),
            "WEBP": encoded_image("WEBP"),
            "AVIF": encoded_image("AVIF"),
            "GIF": animated_gif(),
        }
        for image_format, source in samples.items():
            with self.subTest(image_format=image_format):
                optimized = optimize.optimize_image_bytes(source, image_format)
                with Image.open(io.BytesIO(optimized)) as image:
                    self.assertEqual(image.format, image_format)
                if image_format == "GIF":
                    with Image.open(io.BytesIO(optimized)) as image:
                        self.assertEqual(getattr(image, "n_frames", 1), 2)

    def test_manifest_records_first_run_and_skips_the_second(self) -> None:
        image = self.root / "blog" / "slug" / "cover.png"
        image.parent.mkdir(parents=True)
        original = encoded_image("PNG")
        image.write_bytes(original)

        first = optimize.run(self.root)
        self.assertGreaterEqual(first.optimized, 1)
        optimized = image.read_bytes()
        self.assertNotEqual(optimized, original)

        manifest = optimize.load_manifest(self.root / "website-manifest.json")
        self.assertEqual(manifest["images"]["blog/slug/cover.png"], optimize.sha256_bytes(optimized))

        second = optimize.run(self.root)
        self.assertEqual(second.optimized, 0)
        self.assertGreaterEqual(second.skipped, 1)
        self.assertEqual(image.read_bytes(), optimized)
        self.assertEqual(
            optimize.load_manifest(self.root / "website-manifest.json"), manifest
        )

    def test_cover_derivative_is_1280x720_and_center_focused(self) -> None:
        image = Image.new("RGB", (200, 100), (255, 255, 255))
        ImageDraw.Draw(image).rectangle((95, 45, 105, 55), fill=(0, 0, 0))
        buffer = io.BytesIO()
        image.save(buffer, format="PNG", compress_level=0)

        cover = optimize.render_cover_bytes(buffer.getvalue(), "PNG")
        with Image.open(io.BytesIO(cover)) as rendered:
            self.assertEqual(rendered.size, (1280, 720))
            self.assertEqual(rendered.getpixel((640, 360)), (0, 0, 0))

    def test_svg_cover_is_rasterized_to_png(self) -> None:
        svg = (
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">'
            '<rect width="100" height="100" fill="#ff0000"/></svg>'
        )
        cover = optimize.render_cover_bytes(svg.encode("utf-8"), "SVG")
        with Image.open(io.BytesIO(cover)) as rendered:
            self.assertEqual(rendered.format, "PNG")
            self.assertEqual(rendered.size, (1280, 720))
            self.assertEqual(rendered.convert("RGB").getpixel((640, 360)), (255, 0, 0))

    def test_remote_references_are_localized_once(self) -> None:
        cover_url = "https://example.org/pictures/cover.png"
        inline_url = "https://example.org/pictures/diagram.png"
        post = self.write_post(
            "story",
            cover_url,
            "![Diagram](" + inline_url + ")",
        )
        calls: list[str] = []

        def downloader(url: str) -> bytes:
            calls.append(url)
            return encoded_image("PNG")

        manifest = optimize.new_manifest()
        context = optimize.Context(self.root, manifest, False, downloader)
        optimize.localize_references(context)

        text = post.read_text(encoding="utf-8")
        self.assertIn("featured_image: /blog/story/cover.png", text)
        self.assertIn("![Diagram](diagram.png)", text)
        self.assertEqual(sorted(calls), sorted([cover_url, inline_url]))
        self.assertTrue((self.root / "blog" / "story" / "cover.png").is_file())
        self.assertTrue((self.root / "blog" / "story" / "diagram.png").is_file())

        def forbidden(_url: str) -> bytes:
            self.fail("a localized image was downloaded again")

        second = optimize.Context(self.root, manifest, False, forbidden)
        optimize.localize_references(second)
        self.assertEqual(post.read_text(encoding="utf-8"), text)

    def test_welcome_logo_is_copied_without_touching_static(self) -> None:
        source = self.root / "static" / "img" / "Ninjas.png"
        original = source.read_bytes()
        post = self.write_post(optimize.WELCOME_SLUG, "/img/Ninjas.png")

        def forbidden(_url: str) -> bytes:
            self.fail("the copied logo should not be downloaded")

        context = optimize.Context(
            self.root, optimize.new_manifest(), False, forbidden
        )
        optimize.copy_welcome_logo(context)

        copied = self.root / "blog" / optimize.WELCOME_SLUG / "Ninjas.png"
        self.assertEqual(copied.read_bytes(), original)
        self.assertEqual(source.read_bytes(), original)
        self.assertIn(
            f"featured_image: /blog/{optimize.WELCOME_SLUG}/Ninjas.png",
            post.read_text(encoding="utf-8"),
        )

    def test_check_reports_pending_work_without_writing(self) -> None:
        image = self.root / "blog" / "slug" / "cover.png"
        image.parent.mkdir(parents=True)
        original = encoded_image("PNG")
        image.write_bytes(original)
        manifest_path = self.root / "website-manifest.json"
        before = manifest_path.read_text(encoding="utf-8")

        stats = optimize.run(self.root, check_only=True)
        self.assertGreater(stats.pending, 0)
        self.assertEqual(image.read_bytes(), original)
        self.assertEqual(manifest_path.read_text(encoding="utf-8"), before)

        output = io.StringIO()
        with redirect_stdout(output):
            code = optimize.main(["--root", str(self.root), "--check"])
        self.assertEqual(code, 1)
        self.assertIn("Pending work:", output.getvalue())

        output = io.StringIO()
        with redirect_stdout(output):
            code = optimize.main(["--root", str(self.root), "--dry-run"])
        self.assertEqual(code, 0)
        self.assertIn("Would process:", output.getvalue())

    def test_full_run_creates_local_cover_derivative(self) -> None:
        source = encoded_image("PNG")
        (self.root / "blog" / "story" / "cover.png").parent.mkdir(parents=True)
        (self.root / "blog" / "story" / "cover.png").write_bytes(source)
        post = self.write_post("story", "/blog/story/cover.png")

        optimize.run(self.root)
        text = post.read_text(encoding="utf-8")
        self.assertIn(
            "featured_image: /blog/story/cover-1280x720.png", text
        )
        derivative = self.root / "blog" / "story" / "cover-1280x720.png"
        with Image.open(derivative) as image:
            self.assertEqual(image.size, (1280, 720))
        manifest = optimize.load_manifest(self.root / "website-manifest.json")
        self.assertEqual(
            manifest["covers"]["blog/story/cover.png"],
            "blog/story/cover-1280x720.png",
        )

    def test_ftp_cache_survives_an_optimization_run(self) -> None:
        manifest = optimize.new_manifest()
        manifest["ftp"]["files"]["index.html"] = "md5-of-last-upload"
        (self.root / "website-manifest.json").write_text(
            json.dumps(manifest, ensure_ascii=False), encoding="utf-8"
        )
        (self.root / "blog" / "slug").mkdir()
        (self.root / "blog" / "slug" / "cover.png").write_bytes(encoded_image("PNG"))

        optimize.run(self.root)

        saved = optimize.load_manifest(self.root / "website-manifest.json")
        self.assertEqual(saved["ftp"]["files"], {"index.html": "md5-of-last-upload"})


if __name__ == "__main__":
    unittest.main()
