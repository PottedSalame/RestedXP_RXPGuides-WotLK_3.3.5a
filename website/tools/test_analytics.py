"""Offline checks for the public analytics snippet and narrowly scoped CSP."""
import json
from html.parser import HTMLParser
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
PAGES = ('index.html', 'guide-editor/index.html', 'help.html', 'credits.html')
BEACON = 'https://static.cloudflareinsights.com/beacon.min.js'
TOKEN = '4f34bc88fefc4a22904c1d24c7c7cb99'


class Tags(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tags = []

    def handle_starttag(self, tag, attrs):
        self.tags.append((tag, dict(attrs)))


class AnalyticsChecks(unittest.TestCase):
    def test_one_literal_snippet_per_public_page(self):
        for page in PAGES:
            with self.subTest(page=page):
                source = (ROOT / page).read_text(encoding='utf-8')
                parser = Tags()
                parser.feed(source)
                scripts = [a for tag, a in parser.tags if tag == 'script' and a.get('src') == BEACON]
                self.assertEqual(len(scripts), 1)
                self.assertEqual(scripts[0]['type'], 'module')
                self.assertEqual(json.loads(scripts[0]['data-cf-beacon']), {'token': TOKEN})
                external = [a['src'] for tag, a in parser.tags
                            if tag == 'script' and a.get('src', '').startswith(('http:', 'https:', '//'))]
                self.assertEqual(external, [BEACON])
                self.assertLess(source.index(BEACON), source.index('</body>'))

    def test_security_policy_keeps_other_external_sources_blocked(self):
        for page in PAGES:
            with self.subTest(page=page):
                parser = Tags()
                parser.feed((ROOT / page).read_text(encoding='utf-8'))
                policies = [a['content'] for tag, a in parser.tags
                            if tag == 'meta' and a.get('http-equiv', '').lower() == 'content-security-policy']
                self.assertEqual(len(policies), 1)
                rules = {bits[0]: bits[1:] for part in policies[0].split(';') if (bits := part.split())}
                self.assertEqual(rules['script-src'], ["'self'", 'https://static.cloudflareinsights.com'])
                expected = ["'self'"]
                if page == 'guide-editor/index.html':
                    expected.append('https://nether.wowhead.com')
                expected.append('https://cloudflareinsights.com')
                self.assertEqual(rules['connect-src'], expected)
                self.assertEqual(rules['default-src'], ["'self'"])
                self.assertEqual(rules['object-src'], ["'none'"])
                self.assertEqual(rules['base-uri'], ["'none'"])

    def test_disclosure_reachable_without_editor_data(self):
        for page in PAGES:
            source = (ROOT / page).read_text(encoding='utf-8')
            if page == 'help.html':
                self.assertIn('id="privacy"', source)
                self.assertIn('We do not send guide text, drafts or form values to analytics.', source)
            else:
                prefix = '../' if page.startswith('guide-editor/') else ''
                self.assertIn('href="'+prefix+'help.html#privacy"', source)
        for page in (ROOT / 'tests').rglob('*.html'):
            self.assertNotIn(BEACON, page.read_text(encoding='utf-8'))


if __name__ == '__main__':
    unittest.main()
