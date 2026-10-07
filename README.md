Computer algebra system to generate kernel code for use in Gkeyll solvers.

## Maxima manual search

From the repository root, build a local index and search it with Python 3:

```bash
python3 -m tools.maxima_docs build
python3 -m tools.maxima_docs search 'ratsimp'
python3 -m tools.maxima_docs show ENTRY_ID
```

The build uses HTML documentation matching the installed Maxima version when available. Otherwise it downloads the official single-page HTML manual. Use `build --source PATH` with a local HTML file or directory when offline. The SQLite index and downloaded HTML are stored in the user cache, not in this repository. Search results show the manual version and warn when it differs from the installed Maxima version. Python must include SQLite FTS5 support.

If multiple manual versions have been indexed, search selects the installed Maxima version by default. Use `search --version VERSION QUERY` to inspect another version explicitly.
