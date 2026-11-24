import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import ftp_sync  # noqa: E402


class FtpSyncTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        (self.root / "dist").mkdir()
        self.manifest_path = self.root / "website-manifest.json"
        ftp_sync.save_manifest(self.manifest_path, ftp_sync.new_manifest())

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_dist(self, name: str, content: bytes) -> Path:
        path = self.root / "dist" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)
        return path

    def cache(self, files: dict[str, str]) -> None:
        manifest = ftp_sync.load_manifest(self.manifest_path)
        manifest["ftp"]["files"] = files
        ftp_sync.save_manifest(self.manifest_path, manifest)

    def test_plan_emits_only_new_changed_and_deleted_files(self) -> None:
        self.write_dist("same.html", b"same")
        self.write_dist("changed.html", b"new")
        self.write_dist("fresh.gif", b"GIF89a")
        self.cache(
            {
                "same.html": ftp_sync.md5_bytes(b"same"),
                "changed.html": ftp_sync.md5_bytes(b"old"),
                "gone.html": ftp_sync.md5_bytes(b"gone"),
            }
        )

        # Rebuilt files get fresh mtimes; content hashes must still win.
        for path in (self.root / "dist").rglob("*"):
            if path.is_file():
                path.touch()

        self.assertEqual(
            ftp_sync.plan(self.root),
            [
                ("M", "changed.html"),
                ("A", "fresh.gif"),
                ("D", "gone.html"),
            ],
        )
        self.assertEqual(ftp_sync.plan(self.root), ftp_sync.plan(self.root))

    def test_plan_is_empty_when_content_matches_the_cache(self) -> None:
        self.write_dist("index.html", b"<html></html>")
        self.write_dist("blog/cover.gif", b"GIF89a")
        self.cache(
            {
                "index.html": ftp_sync.md5_bytes(b"<html></html>"),
                "blog/cover.gif": ftp_sync.md5_bytes(b"GIF89a"),
            }
        )
        self.assertEqual(ftp_sync.plan(self.root), [])

    def test_commit_replaces_the_cache_with_dist_hashes(self) -> None:
        self.write_dist("index.html", b"page")
        self.cache({"obsolete.html": ftp_sync.md5_bytes(b"old")})

        self.assertEqual(ftp_sync.commit(self.root), 1)
        self.assertEqual(
            ftp_sync.load_manifest(self.manifest_path)["ftp"]["files"],
            {"index.html": ftp_sync.md5_bytes(b"page")},
        )
        self.assertEqual(ftp_sync.plan(self.root), [])

    def test_seed_imports_the_legacy_snapshot_once(self) -> None:
        snapshot = self.root / ".ftp-upload-dist" / "blog"
        snapshot.mkdir(parents=True)
        (snapshot / "cover.gif").write_bytes(b"GIF89a")
        self.write_dist("blog/cover.gif", b"GIF89a")

        self.assertEqual(ftp_sync.seed(self.root), 1)
        self.assertEqual(ftp_sync.plan(self.root), [])
        with self.assertRaises(ValueError):
            ftp_sync.seed(self.root)

    def test_post_page_hash_ignores_random_recommendations(self) -> None:
        page = self.write_dist(
            "blog/en/story/index.html",
            b'<html><h1>Story</h1><section class="rs-panel post-others">'
            b"<ul><li>First pick</li></ul></section></html>",
        )
        cached = ftp_sync.digest_file(page)
        self.cache({"blog/en/story/index.html": cached})
        self.assertEqual(ftp_sync.plan(self.root), [])

        page.write_bytes(
            b'<html><h1>Story</h1><section class="rs-panel post-others">'
            b"<ul><li>Different pick</li></ul></section></html>"
        )
        self.assertEqual(ftp_sync.plan(self.root), [])

        page.write_bytes(
            b'<html><h1>Revised story</h1><section class="rs-panel post-others">'
            b"<ul><li>Different pick</li></ul></section></html>"
        )
        self.assertEqual(
            ftp_sync.plan(self.root), [("M", "blog/en/story/index.html")]
        )

    def test_home_hash_ignores_random_posts_section(self) -> None:
        first = ftp_sync.stable_bytes(
            Path("index.html"),
            b'<div id="hero"></div><section class="rs-panel" id="posts">A</section>',
        )
        second = ftp_sync.stable_bytes(
            Path("index.html"),
            b'<div id="hero"></div><section class="rs-panel" id="posts">B</section>',
        )
        edited = ftp_sync.stable_bytes(
            Path("index.html"),
            b'<div id="hero" data-new></div><section class="rs-panel" id="posts">A</section>',
        )
        self.assertEqual(first, second)
        self.assertNotEqual(first, edited)

    def test_feed_hash_ignores_build_timestamp(self) -> None:
        first = ftp_sync.stable_bytes(
            Path("atom.xml"), b"<feed><updated>2026-01-01T00:00:00Z</updated><entry/></feed>"
        )
        second = ftp_sync.stable_bytes(
            Path("atom.xml"), b"<feed><updated>2026-11-23T12:00:00Z</updated><entry/></feed>"
        )
        edited = ftp_sync.stable_bytes(
            Path("atom.xml"), b"<feed><updated>2026-01-01T00:00:00Z</updated><entry>new</entry></feed>"
        )
        self.assertEqual(first, second)
        self.assertNotEqual(first, edited)

    def test_manifest_keeps_image_sections_when_ftp_cache_changes(self) -> None:
        manifest = ftp_sync.load_manifest(self.manifest_path)
        manifest["images"]["blog/a/cover.png"] = "sha256"
        ftp_sync.save_manifest(self.manifest_path, manifest)
        self.write_dist("index.html", b"page")

        ftp_sync.commit(self.root)
        saved = json.loads(self.manifest_path.read_text(encoding="utf-8"))
        self.assertEqual(saved["images"], {"blog/a/cover.png": "sha256"})
        self.assertEqual(saved["downloads"], {})
        self.assertEqual(saved["covers"], {})


if __name__ == "__main__":
    unittest.main()
