"""Build and query a versioned SQLite index of Maxima manual entries."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import sqlite3

from .parser import Document, extract
from .source import Source, cache_dir, installed_version


STOP_WORDS = {"a", "an", "and", "are", "can", "do", "for", "how", "i", "in", "is", "of", "the", "to", "use", "with"}
GENERIC_SYMBOL_WORDS = {"code", "expression", "function", "list", "variable"}
SYMBOL_ALIASES = {
    "coefficient": "coeff", "coefficients": "coeff",
    "substitute": "subst", "substitution": "subst", "substituting": "subst",
}


def _id(version: str, document: Document) -> str:
    key = f"{version}\0{document.source}\0{document.anchor}\0{document.kind}\0{document.title}"
    return f"{version}:{hashlib.sha256(key.encode()).hexdigest()[:12]}"


def _passages(text: str, max_chars: int = 3000) -> list[str]:
    blocks = text.split("\n\n")
    result: list[str] = []
    current: list[str] = []
    length = 0
    for block in blocks:
        if current and length + len(block) + 2 > max_chars:
            result.append("\n\n".join(current))
            current, length = [], 0
        current.append(block)
        length += len(block) + 2
    if current:
        result.append("\n\n".join(current))
    return result


def build(source: Source, destination_dir: Path | None = None) -> tuple[Path, str, int]:
    documents: list[Document] = []
    version: str | None = None
    for file in source.files:
        file_version, found = extract(file.read_text(encoding="utf-8", errors="replace"), source.url(file))
        if version is not None and version != file_version:
            raise ValueError(f"Manual versions differ: {version} and {file_version} in {file}")
        version = file_version
        documents.extend(found)
    if version is None or not documents:
        raise ValueError("No Maxima manual entries or sections were found")
    folder = destination_dir or cache_dir()
    folder.mkdir(parents=True, exist_ok=True)
    destination = folder / f"maxima-{version}.sqlite3"
    temporary = folder / f".maxima-{version}.sqlite3.tmp"
    temporary.unlink(missing_ok=True)
    try:
        connection = sqlite3.connect(temporary)
        try:
            connection.executescript(
                """
                CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL);
                CREATE TABLE documents (
                    id TEXT PRIMARY KEY, title TEXT NOT NULL, kind TEXT NOT NULL,
                    symbols TEXT NOT NULL, section TEXT NOT NULL, text TEXT NOT NULL,
                    source_url TEXT NOT NULL, version TEXT NOT NULL
                );
                CREATE TABLE symbols (symbol TEXT NOT NULL, document_id TEXT NOT NULL);
                CREATE INDEX symbols_lookup ON symbols(symbol);
                CREATE VIRTUAL TABLE passages USING fts5(
                    document_id UNINDEXED, title, symbols, section, text,
                    tokenize = 'porter unicode61'
                );
                """
            )
            connection.executemany(
                "INSERT INTO metadata VALUES (?, ?)",
                [("version", version), ("source_sha256", source.checksum()),
                 ("source", "online" if source.online else "local")],
            )
            seen: set[str] = set()
            for document in documents:
                identifier = _id(version, document)
                if identifier in seen:
                    continue
                seen.add(identifier)
                url = document.source + ("#" + document.anchor if document.anchor else "")
                connection.execute(
                    "INSERT INTO documents VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                    (identifier, document.title, document.kind, json.dumps(document.symbols),
                     document.section, document.text, url, version),
                )
                for symbol in document.symbols:
                    connection.execute("INSERT INTO symbols VALUES (?, ?)", (symbol.casefold(), identifier))
                for passage in _passages(document.text):
                    connection.execute(
                        "INSERT INTO passages VALUES (?, ?, ?, ?, ?)",
                        (identifier, document.title, " ".join(document.symbols), document.section, passage),
                    )
            connection.commit()
        finally:
            connection.close()
        temporary.replace(destination)
    except Exception:
        temporary.unlink(missing_ok=True)
        raise
    return destination, version, len(seen)


def database_for_search(folder: Path | None = None, version: str | None = None) -> Path:
    directory = folder or cache_dir()
    if version and not re.fullmatch(r"\d+\.\d+(?:\.\d+)?", version):
        raise ValueError("Invalid Maxima version")
    if version:
        selected = directory / f"maxima-{version}.sqlite3"
        if not selected.is_file():
            raise FileNotFoundError(f"No index for Maxima {version}. Run the build command for that manual.")
        return selected
    version = installed_version()
    if version:
        matching = directory / f"maxima-{version}.sqlite3"
        if matching.is_file():
            return matching
    candidates = sorted(directory.glob("maxima-*.sqlite3"), key=lambda path: path.stat().st_mtime, reverse=True)
    if not candidates:
        raise FileNotFoundError("No Maxima documentation index. Run: python3 -m tools.maxima_docs build")
    return candidates[0]


def database_for_id(identifier: str, folder: Path | None = None) -> Path:
    version = identifier.partition(":")[0]
    if not re.fullmatch(r"\d+\.\d+(?:\.\d+)?", version):
        raise ValueError("Invalid documentation ID")
    database = (folder or cache_dir()) / f"maxima-{version}.sqlite3"
    if not database.is_file():
        raise FileNotFoundError(f"No index for Maxima {version}. Run the build command for that manual.")
    return database


def _terms(query: str) -> list[str]:
    terms = re.findall(r"[A-Za-z0-9_%]+", query.casefold())
    terms = [term for term in terms if re.search(r"[a-z0-9]", term)]
    filtered = [term for term in terms if term not in STOP_WORDS]
    return list(dict.fromkeys(filtered or terms))


def _excerpt(text: str, terms: list[str], width: int = 700) -> str:
    lower = text.casefold()
    positions = [lower.find(term) for term in terms if term and lower.find(term) >= 0]
    start = max(0, min(positions) - 120) if positions else 0
    if start:
        start = text.rfind(" ", 0, start) + 1
    end = min(len(text), start + width)
    if end < len(text):
        cut = text.rfind(" ", start, end)
        if cut > start + width // 2:
            end = cut
    excerpt = text[start:end].strip()
    return ("…" if start else "") + excerpt + ("…" if end < len(text) else "")


def search(
    query: str, limit: int = 5, folder: Path | None = None, version: str | None = None
) -> tuple[str, list[dict[str, str]]]:
    if not query.strip():
        raise ValueError("Search query cannot be empty")
    if not 1 <= limit <= 20:
        raise ValueError("--limit must be between 1 and 20")
    database = database_for_search(folder, version)
    terms = _terms(query)
    with sqlite3.connect(f"file:{database}?mode=ro", uri=True) as connection:
        version = connection.execute("SELECT value FROM metadata WHERE key='version'").fetchone()[0]
        matches: dict[str, str] = {}
        exact = connection.execute(
            "SELECT document_id FROM symbols WHERE symbol = ?", (query.strip().casefold(),)
        ).fetchall()
        for (identifier,) in exact:
            matches[identifier] = ""
        if "rational" in terms and any(term.startswith("simplif") for term in terms):
            for (identifier,) in connection.execute(
                "SELECT document_id FROM symbols WHERE symbol = 'ratsimp'"
            ):
                matches.setdefault(identifier, "")
        for term in terms:
            if term in GENERIC_SYMBOL_WORDS:
                continue
            for symbol in (term, SYMBOL_ALIASES.get(term)):
                if not symbol:
                    continue
                for (identifier,) in connection.execute(
                    "SELECT document_id FROM symbols WHERE symbol = ?", (symbol,)
                ):
                    matches.setdefault(identifier, "")
        if terms and len(matches) < limit:
            quoted = ['"' + term.replace('"', '""') + '"' + ('*' if len(term) >= 4 else '') for term in terms]
            for expression in (" AND ".join(quoted), " OR ".join(quoted)):
                rows = connection.execute(
                    "SELECT passages.document_id, passages.text FROM passages "
                    "JOIN documents ON documents.id = passages.document_id "
                    "WHERE passages MATCH ? "
                    "ORDER BY (documents.kind = 'Section'), bm25(passages, 0, 8, 6, 0.5, 1) LIMIT ?",
                    (expression, max(20, limit * 8)),
                ).fetchall()
                for identifier, passage in rows:
                    matches.setdefault(identifier, passage)
                    if len(matches) >= limit:
                        break
                if len(matches) >= limit:
                    break
        results: list[dict[str, str]] = []
        for identifier, passage in list(matches.items())[:limit]:
            row = connection.execute(
                "SELECT title, kind, section, text, source_url FROM documents WHERE id = ?", (identifier,)
            ).fetchone()
            if row is None:
                continue
            title, kind, section, full_text, source_url = row
            results.append({
                "id": identifier, "title": title, "kind": kind, "section": section,
                "version": version, "source": source_url,
                "excerpt": _excerpt(passage or full_text, terms),
            })
    return version, results


def show(identifier: str, folder: Path | None = None) -> dict[str, str]:
    database = database_for_id(identifier, folder)
    with sqlite3.connect(f"file:{database}?mode=ro", uri=True) as connection:
        row = connection.execute(
            "SELECT title, kind, section, text, source_url, version FROM documents WHERE id = ?", (identifier,)
        ).fetchone()
    if row is None:
        raise KeyError(f"Documentation entry not found: {identifier}")
    title, kind, section, text, source_url, version = row
    return {"id": identifier, "title": title, "kind": kind, "section": section,
            "text": text, "source": source_url, "version": version}
