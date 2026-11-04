"""Serve only the website on loopback, optionally under a Pages-style prefix."""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]


class Handler(SimpleHTTPRequestHandler):
    extensions_map = {**SimpleHTTPRequestHandler.extensions_map, ".js": "text/javascript; charset=utf-8", ".json": "application/json; charset=utf-8"}

    def __init__(self, *args, prefix="/", **kwargs):
        self.prefix = prefix
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def do_GET(self):
        self.serve_checked(False)

    def do_HEAD(self):
        self.serve_checked(True)

    def serve_checked(self, head):
        path = unquote(urlsplit(self.path).path)
        if not path.startswith(self.prefix):
            self.send_error(404)
            return
        relative = path[len(self.prefix):]
        parts = relative.split("/")
        if any(part.startswith(".") or "\\" in part or ":" in part or "%" in part for part in parts) or relative.startswith("tools/"):
            self.send_error(403)
            return
        target = ROOT.joinpath(*parts)
        if not target.resolve().is_relative_to(ROOT) or any(p.is_symlink() or (hasattr(p, "is_junction") and p.is_junction()) for p in [target, *target.parents] if p != ROOT and p.is_relative_to(ROOT)):
            self.send_error(403)
            return
        if target.is_dir() and not path.endswith("/"):
            self.send_response(301)
            self.send_header("Location", self.prefix + relative + "/")
            self.end_headers()
            return
        self.path = "/" + relative
        if head:
            super().do_HEAD()
        else:
            super().do_GET()

    def list_directory(self, path):
        self.send_error(403, "Directory listing disabled")
        return None

    def end_headers(self):
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()

    def log_message(self, fmt, *args):
        pass  # No browsing logs, uploaded source, or user identifiers.


def server(port=8765, prefix="/"):
    if not prefix.startswith("/") or not prefix.endswith("/") or any(part in (".", "..") for part in prefix.split("/")):
        raise ValueError("Prefix must be an absolute URL path ending in /, without traversal")
    return ThreadingHTTPServer(("127.0.0.1", port), partial(Handler, prefix=prefix))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--prefix", default="/")
    parser.add_argument("--site-root", type=Path, help="Serve a built static-site directory")
    args = parser.parse_args()
    if args.site_root:
        ROOT=args.site_root.resolve()
        if not (ROOT/'index.html').is_file() or not (ROOT/'guide-editor/index.html').is_file():
            raise ValueError('Site root must contain the tools hub and editor')
    with server(args.port, args.prefix) as httpd:
        print(f"RXPGuides Tools: http://127.0.0.1:{httpd.server_port}{args.prefix}", flush=True)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            pass
