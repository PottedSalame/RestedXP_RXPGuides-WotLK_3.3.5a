"""Run real browser tests with an already installed Chrome/Edge; no packages."""
import argparse
import functools
import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
import threading
from html.parser import HTMLParser
from http.server import ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parent
from project_paths import require_addon
spec = importlib.util.spec_from_file_location("rxp_preview", ROOT / "tools/serve.py")
serve = importlib.util.module_from_spec(spec)
spec.loader.exec_module(serve)


class Results(HTMLParser):
    def __init__(self):
        super().__init__()
        self.capture = False
        self.text = ""
        self.status = "missing"

    def handle_starttag(self, tag, attrs):
        values = dict(attrs)
        if tag == "pre" and values.get("id") == "test-results":
            self.capture = True
            self.status = values.get("data-status", "missing")

    def handle_endtag(self, tag):
        if tag == "pre":
            self.capture = False

    def handle_data(self, data):
        if self.capture:
            self.text += data


def run(browser, lua_command=None, live_wowhead=False):
    addon = require_addon()
    corpus = []
    for name in ("Guides/RestedXP Horde 1-13 Troll-Orc.lua", "Guides/Deathknight.lua", "Guides/WotLK/Horde-Leveling.lua"):
        corpus.append({"name": name, "text": (addon / name).read_bytes().decode("utf-8")})
    for path in sorted((addon / "Guides/Hardcore").glob("*.lua")):
        corpus.append({"name": path.relative_to(addon).as_posix(), "text": path.read_bytes().decode("utf-8")})
    payload = json.dumps(corpus, ensure_ascii=False).encode("utf-8")

    class FixtureHandler(serve.Handler):
        def do_GET(self):
            if urlsplit(self.path).path == self.prefix + "tests/corpus.json":
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Content-Length", str(len(payload)))
                self.end_headers()
                self.wfile.write(payload)
            else:
                super().do_GET()

    scratch_root = REPO / "build/website-tests"
    scratch_root.mkdir(parents=True, exist_ok=True)
    scratch = Path(tempfile.mkdtemp(prefix="browser-", dir=scratch_root)).resolve()
    success = False
    try:
        for index, prefix in enumerate(("/", "/RXPGuides/")):
            httpd = ThreadingHTTPServer(("127.0.0.1", 0), functools.partial(FixtureHandler, prefix=prefix))
            thread = threading.Thread(target=httpd.serve_forever, daemon=True)
            thread.start()
            url = f"http://127.0.0.1:{httpd.server_port}{prefix}tests/?corpus=1"
            if live_wowhead:
                url += "&live=1"
            try:
                command = [str(browser), "--headless", "--disable-gpu", "--no-first-run", "--no-default-browser-check",
                    "--disable-background-networking", "--disable-component-update", "--disable-sync", "--disable-extensions",
                    "--metrics-recording-only", "--user-data-dir=" + str(scratch / ("profile-" + str(index))),
                    "--dump-dom", "--virtual-time-budget=30000", url]
                result = subprocess.run(command, capture_output=True, timeout=120)
                html = result.stdout.decode("utf-8", errors="replace")
                (scratch / f"browser-{index}.html").write_text(html, encoding="utf-8")
                (scratch / f"browser-{index}.stderr.txt").write_bytes(result.stderr)
                parsed = Results()
                parsed.feed(html)
                if result.returncode or parsed.status not in ("passed", "failed"):
                    raise RuntimeError(f"Browser did not finish: exit={result.returncode}, state={parsed.status}")
                report = json.loads(parsed.text)
                print(f"{prefix}: {len(report['passed'])} passed; {len(report['failed'])} failed", flush=True)
                for failure in report["failed"]:
                    print(failure, flush=True)
                if report["failed"]:
                    raise RuntimeError("Browser regressions failed")
                companion = scratch / "Guide.lua"
                companion.write_text(report["companion"]["lua"], encoding="utf-8", newline="\n")
                if lua_command:
                    # The existing platform runner is explicitly provided, never downloaded.
                    result = subprocess.run([str(lua_command), str(ROOT / "tests/production-parser.lua"), str(addon), str(companion)], capture_output=True, timeout=60)
                    print(result.stdout.decode("utf-8", errors="replace"), end="", flush=True)
                    if result.returncode:
                        raise RuntimeError(result.stderr.decode("utf-8", errors="replace"))
            finally:
                httpd.shutdown()
                httpd.server_close()
                thread.join()
        success = True
    finally:
        if success:
            # Only our uniquely allocated child, never caller-owned files.
            if scratch.parent != scratch_root.resolve() or not scratch.name.startswith("browser-") or scratch.is_symlink() or scratch.is_junction():
                raise RuntimeError("Unsafe cleanup target")
            # The verified child can exceed MAX_PATH inside Chrome's profile.
            # Ignore only files Chrome already removed during shutdown.
            def disappeared(function,path,error):
                if not isinstance(error,FileNotFoundError):raise error
            cleanup=str(scratch)
            if os.name=='nt':cleanup='\\\\?\\UNC\\'+cleanup[2:] if cleanup.startswith('\\\\') else '\\\\?\\'+cleanup
            shutil.rmtree(cleanup,onexc=disappeared)
        else:
            print("Failure diagnostics retained in " + scratch.relative_to(REPO).as_posix(), flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--browser", type=Path, required=True)
    parser.add_argument("--lua-command", type=Path)
    parser.add_argument("--live-wowhead", action="store_true", help="Opt in to four live WotLK ID requests per origin; default tests stay offline")
    args = parser.parse_args()
    run(args.browser.resolve(), args.lua_command.resolve() if args.lua_command else None, args.live_wowhead)
