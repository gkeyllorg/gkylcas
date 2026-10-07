"""Behavioral tests for parsing, indexing, and local retrieval."""

from __future__ import annotations

from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from urllib.error import URLError

from . import source
from .index import build, search, show
from .parser import extract


MANUAL = """<!doctype html><html><head><title>Maxima 5.47.0 Manual: Evaluation</title></head>
<body><div class="header"><p>Next: Contents Index</p></div>
<a name="Evaluation"></a><h3>8.1 Evaluation</h3>
<p>Evaluation of expressions can be controlled with quoting.</p>
<a name="quote"></a><dl><dt>Operator: <strong>'</strong></dt>
<dd><p>The single quote prevents evaluation of an expression.</p>
<div class="example"><pre>(%i1) '(f(x));\n(%o1) f(x)</pre></div></dd></dl>
<a name="rat_005fsimp"></a><dl><dt>Function: <strong>ratsimp</strong>
<em>(<var>expr</var>)</em></dt><dd><p>Simplifies a rational expression.</p></dd></dl>
<a name="coeff"></a><dl><dt>Function: <strong>coeff</strong>
<em>(<var>expr</var>, <var>x</var>)</em></dt>
<dd><p>Returns the coefficient of a polynomial term.</p></dd></dl>
<a name="subst"></a><dl><dt>Function: <strong>subst</strong>
<em>(<var>new</var>, <var>old</var>, <var>expr</var>)</em></dt>
<dd><p>Substitutes a value in an expression.</p></dd></dl>
<a name="g_t_0025pi"></a><dl><dt>Constant: <strong>%pi</strong></dt>
<dd><p>The ratio of a circle's circumference to its diameter.</p></dd></dl>
</body></html>"""

ONLINE_MANUAL = """<!doctype html><html><head><title>Maxima 5.49.0 Manual</title></head>
<body><div class="section" id="Integration"><h3>21 Integration</h3>
<p>This section describes symbolic and numerical integration methods.</p>
<span id="integrate"></span><dl class="def">
<dt id="index-integrate"><span class="category">Function: </span>
<span><strong>integrate</strong> <em>(<var>expr</var>, <var>x</var>)</em>
<a class="copiable-anchor" href="#index-integrate">¶</a></span></dt>
<dd><p>Attempts to symbolically compute the integral of expr.</p></dd></dl>
</div></body></html>"""


class MaximaDocsTests(unittest.TestCase):
    def test_extract_preserves_complete_definition_and_anchor(self) -> None:
        version, documents = extract(MANUAL, "https://example.test/manual.html")
        self.assertEqual(version, "5.47.0")
        quote = next(doc for doc in documents if doc.title == "'")
        self.assertEqual(quote.anchor, "quote")
        self.assertIn("prevents evaluation", quote.text)
        self.assertIn("(%i1) '(f(x));", quote.text)
        self.assertNotIn("Next: Contents Index", quote.text)

    def test_exact_symbol_lookup_and_full_entry(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            manual = folder / "manual.html"
            manual.write_text(MANUAL)
            database, version, count = build(source.Source((manual,)), folder)
            self.assertTrue(database.is_file())
            self.assertEqual((version, count), ("5.47.0", 6))
            _, results = search("%pi", folder=folder)
            self.assertEqual(results[0]["title"], "%pi")
            self.assertEqual(results[0]["source"], manual.resolve().as_uri() + "#g_t_0025pi")
            entry = show(results[0]["id"], folder)
            self.assertIn("circumference", entry["text"])
            _, quote_results = search("prevent evaluation", folder=folder)
            self.assertEqual(quote_results[0]["title"], "'")
            _, no_results = search(":=", folder=folder)
            self.assertEqual(no_results, [])
            self.assertEqual(search("ratsimp", folder=folder, version="5.47.0")[1][0]["title"], "ratsimp")
            self.assertEqual(search("extract coefficient", folder=folder)[1][0]["title"], "coeff")
            self.assertEqual(search("substitute expression", folder=folder)[1][0]["title"], "subst")
            self.assertEqual(search("simplify rational expression", folder=folder)[1][0]["title"], "ratsimp")
            with self.assertRaises(FileNotFoundError):
                search("ratsimp", folder=folder, version="5.49.0")

    def test_online_section_and_entry_anchors(self) -> None:
        version, documents = extract(ONLINE_MANUAL, "https://example.test/manual.html")
        self.assertEqual(version, "5.49.0")
        entry = next(doc for doc in documents if doc.title == "integrate")
        section = next(doc for doc in documents if doc.title == "21 Integration")
        self.assertEqual(entry.anchor, "integrate")
        self.assertEqual(section.anchor, "Integration")
        self.assertNotIn("¶", entry.text)

    def test_rebuild_replaces_previous_index(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            manual = folder / "manual.html"
            manual.write_text(MANUAL)
            build(source.Source((manual,)), folder)
            manual.write_text(MANUAL.replace("ratsimp", "factor"))
            build(source.Source((manual,)), folder)
            _, results = search("factor", folder=folder)
            self.assertEqual(results[0]["title"], "factor")
            self.assertNotIn("ratsimp", [result["title"] for result in results])

    def test_online_acquisition_without_local_install(self) -> None:
        class Response:
            def __enter__(self):
                return self

            def __exit__(self, *_args):
                return None

            def read(self, _size):
                return MANUAL.encode()

        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            with patch.object(source, "installed_html", return_value=None), \
                 patch.object(source, "cache_dir", return_value=folder), \
                 patch.object(source, "urlopen", return_value=Response()):
                selected = source.choose_source()
                self.assertTrue(selected.online)
                self.assertTrue(selected.files[0].is_file())
                database, version, count = build(selected, folder)
                self.assertTrue(database.is_file())
                self.assertEqual((version, count), ("5.47.0", 6))

    def test_verified_curl_fallback_for_python_certificate_failure(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            target = Path(temporary) / "manual.html"
            result = type("Result", (), {"stdout": ONLINE_MANUAL.encode()})()
            with patch.object(source, "urlopen", side_effect=URLError("certificate failed")), \
                 patch.object(source.shutil, "which", return_value="/usr/bin/curl"), \
                 patch.object(source.subprocess, "run", return_value=result) as run:
                source._download(target)
            self.assertEqual(target.read_text(), ONLINE_MANUAL)
            self.assertIn("-fLsS", run.call_args.args[0])


if __name__ == "__main__":
    unittest.main()
