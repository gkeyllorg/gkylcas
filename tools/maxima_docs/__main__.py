"""Command-line interface for the local Maxima documentation index."""

from __future__ import annotations

import argparse
import sqlite3
import sys

from .index import build, search, show
from .source import choose_source, installed_version


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Build and search a local Maxima manual index")
    commands = parser.add_subparsers(dest="command", required=True)
    builder = commands.add_parser("build", help="build an index from matching local or official HTML")
    builder.add_argument("--source", help="local HTML file or directory (for offline use)")
    finder = commands.add_parser("search", help="find relevant manual entries")
    finder.add_argument("query")
    finder.add_argument("--limit", type=int, default=5)
    finder.add_argument("--version", help="search a specific indexed Maxima version")
    reader = commands.add_parser("show", help="read a complete documented entry")
    reader.add_argument("id")
    args = parser.parse_args(argv)
    try:
        if args.command == "build":
            source = choose_source(args.source)
            path, version, count = build(source)
            print(f"Indexed {count} Maxima {version} entries and sections: {path}")
            print(f"Source: {'official online HTML' if source.online else source.files[0].parent if len(source.files) > 1 else source.files[0]}")
            return 0
        if args.command == "search":
            version, results = search(args.query, args.limit, version=args.version)
            current = installed_version()
            if current and current != version:
                print(
                    f"WARNING: manual {version} differs from installed Maxima {current}; "
                    "verify behavior in the installed interpreter.", file=sys.stderr
                )
            if not results:
                print("No matching manual entries found.")
                return 0
            for result in results:
                print(f"{result['id']}  {result['kind']}: {result['title']}  [Maxima {version}]")
                print(f"Section: {result['section']}")
                print(f"Source: {result['source']}")
                print(result["excerpt"])
                print()
            return 0
        result = show(args.id)
        current = installed_version()
        if current and current != result["version"]:
            print(
                f"WARNING: manual {result['version']} differs from installed Maxima {current}; "
                "verify behavior in the installed interpreter.", file=sys.stderr
            )
        print(f"{result['kind']}: {result['title']}  [Maxima {result['version']}]")
        print(f"Section: {result['section']}")
        print(f"Source: {result['source']}\n")
        print(result["text"])
        return 0
    except (FileNotFoundError, KeyError, OSError, RuntimeError, ValueError, sqlite3.Error) as error:
        if isinstance(error, sqlite3.OperationalError) and "fts5" in str(error).lower():
            print("maxima_docs: Python's SQLite must include FTS5 support.", file=sys.stderr)
            return 1
        print(f"maxima_docs: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
