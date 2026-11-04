"""Offline website/data/security checks. Standard library; no downloads."""
import hashlib
import importlib.util
import json
import re
import subprocess
import tempfile
import threading
import unittest
import urllib.error
import urllib.request
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parent
from project_paths import require_addon, source_matches
spec = importlib.util.spec_from_file_location("rxp_website_server", ROOT / "tools/serve.py")
serve = importlib.util.module_from_spec(spec)
spec.loader.exec_module(serve)


class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []
        self.ids = []

    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key in ("href", "src") and value and not value.startswith("#"):
                self.links.append(value)
            if key == "id":
                self.ids.append(value)
            if key.startswith("on"):
                raise AssertionError("Inline executable event attribute")


class WebsiteChecks(unittest.TestCase):
    def test_manifest_and_outputs(self):
        manifest = json.loads((ROOT / "data/manifest.json").read_text(encoding="utf-8"))
        self.assertRegex(manifest["sourceRevision"], r"^[a-f0-9]{40}$")
        self.assertIn("updates/modules not applied", manifest["scope"])
        actual = {p.relative_to(ROOT / "data").as_posix() for p in (ROOT / "data").rglob("*") if p.is_file() and p.name != "manifest.json"}
        self.assertEqual(actual, set(manifest["files"]))
        for name, expected in manifest["files"].items():
            self.assertNotIn("..", Path(name).parts)
            self.assertEqual(hashlib.sha256((ROOT / "data" / name).read_bytes()).hexdigest(), expected, name)
        for name, expected in manifest["generator"].items():
            self.assertTrue(source_matches(name, expected), name)
        catalogue = json.loads((ROOT / "data/catalogue.json").read_text())
        for name, expected in catalogue["sources"].items():
            self.assertTrue(source_matches(name, expected), name)
        self.assertIn("goto", catalogue["directives"])
        self.assertEqual(catalogue["maps"]["Durotar"], 1411)
        for kind in ("quests", "npcs", "items", "objects"):
            rows = json.loads((ROOT / "data" / (kind + ".json")).read_text(encoding="utf-8"))
            self.assertEqual(len(rows), manifest["counts"][kind])
            self.assertEqual(len(rows), len({row[0] for row in rows}))
            self.assertTrue(all(isinstance(row[0], int) and isinstance(row[1], str) for row in rows))
        for path in (ROOT / "data/quests").glob("*.json"):
            for key, detail in json.loads(path.read_text(encoding="utf-8")).items():
                self.assertEqual(int(key) // 1000, int(path.stem))
                self.assertNotIn("clientObjectiveIndex", detail)

    def test_local_links_and_no_external_dependencies(self):
        for path in ROOT.rglob("*.html"):
            parser = Links()
            parser.feed(path.read_text(encoding="utf-8"))
            self.assertEqual(len(parser.ids), len(set(parser.ids)), path.name)
            for link in parser.links:
                if link.startswith("https://"):
                    self.assertEqual(urlsplit(link).netloc, "www.wowhead.com")
                    self.assertTrue(urlsplit(link).path.startswith("/wotlk"))
                    continue
                self.assertNotRegex(link, r"^(?:https?:)?//", path.name)
                target = (path.parent / link.split("#")[0].split("?")[0]).resolve()
                self.assertTrue(target.is_relative_to(ROOT))
                self.assertTrue(target.exists(), str(target.relative_to(ROOT)))
        for path in (ROOT / "guide-editor").glob("*.js"):
            source = path.read_text(encoding="utf-8")
            self.assertNotRegex(source, r"\b(?:eval|Function)\s*\(")
            self.assertNotIn(".innerHTML", source)
            self.assertNotRegex(source, r"fetch\(\s*['\"]https?:")
        html = (ROOT / "guide-editor/index.html").read_text(encoding="utf-8")
        self.assertIn("connect-src 'self' https://nether.wowhead.com", html)
        app = (ROOT / "guide-editor/app.js").read_text(encoding="utf-8")
        self.assertNotIn("../data/quests", app)
        self.assertNotIn("../data/' + type", app)
        # This orphan branch contains no addon release machinery. The static
        # payload allowlist/rejection checks live in test_site_package.py.
        self.assertFalse((REPO / 'RXPGuides.toc').exists())

    def test_data_excludes_private_fields(self):
        for path in (ROOT / "data").rglob("*.json"):
            value = json.loads(path.read_text(encoding="utf-8"))
            def inspect(obj):
                if isinstance(obj, dict):
                    for key, child in obj.items():
                        self.assertNotIn(key.lower(), ("password", "account", "username", "guid", "connectionstring", "localpath"))
                        inspect(child)
                elif isinstance(obj, list):
                    for child in obj:
                        inspect(child)
            inspect(value)

    def test_scoped_loopback_server(self):
        for prefix in ("/", "/RXPGuides/"):
            httpd = serve.server(0, prefix)
            thread = threading.Thread(target=httpd.serve_forever, daemon=True)
            thread.start()
            base = f"http://127.0.0.1:{httpd.server_port}"
            try:
                for route in ("", "guide-editor/", "guide-editor/model.js", "data/quests.json", "help.html"):
                    with urllib.request.urlopen(base + prefix + route) as response:
                        self.assertEqual(response.status, 200)
                        self.assertEqual(response.headers["X-Content-Type-Options"], "nosniff")
                with urllib.request.urlopen(base + prefix + "guide-editor") as response:
                    self.assertEqual(response.url, base + prefix + "guide-editor/")
                for route in ("../.git/config", "%2e%2e/.git/config", "%252e%252e/.git/config", "tools/serve.py", "data/"):
                    with self.assertRaises(urllib.error.HTTPError) as error:
                        urllib.request.urlopen(base + prefix + route)
                    self.assertIn(error.exception.code, (403, 404))
                with self.assertRaises(urllib.error.HTTPError) as error:
                    urllib.request.urlopen(urllib.request.Request(base + prefix, b"upload", method="POST"))
                self.assertEqual(error.exception.code, 501)
            finally:
                httpd.shutdown()
                httpd.server_close()
                thread.join()

    def test_existing_sql_reader_fixture(self):
        spec = importlib.util.spec_from_file_location("rxp_sql_fixture", require_addon() / "tools/extract_hardcore_quest_facts335.py")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        with tempfile.TemporaryDirectory() as scratch:
            path = Path(scratch) / "fixture.sql"
            path.write_text("CREATE TABLE `fixture` (\n `id` int,\n `name` text,\n `other` int\n);\n(7,'O\\'Brien',NULL),\n(8,'Café',-2);\n", encoding="utf-8")
            rows = list(module.read_rows(path, lambda _: True))
            self.assertEqual(rows, [{"id": 7, "name": "O'Brien", "other": None}, {"id": 8, "name": "Café", "other": -2}])


if __name__ == "__main__":
    unittest.main()
