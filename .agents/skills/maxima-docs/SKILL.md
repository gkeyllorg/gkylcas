---
name: maxima-docs
description: Look up Maxima manual entries when creating or editing CAS code, especially when syntax, options, or behavior are uncertain.
---

# Maxima documentation

Run these commands from the repository root. If the local index is missing, build it once with `python3 -m tools.maxima_docs build`. This uses HTML documentation matching the installed Maxima when available; `--source PATH` accepts an HTML file or directory for offline builds.

Use `python3 -m tools.maxima_docs search 'query'` to find an entry, then `python3 -m tools.maxima_docs show ID` to read its complete signatures, qualifications, and examples before relying on it in code. Search exact Maxima names when the existing code supplies them. The excerpts are pointers to entries, not sufficient evidence by themselves.

For a new task described in broad terms, try short technical searches and inspect more than one candidate entry when needed. A search result's rank does not establish that a function is appropriate for the script.

Check the manual version shown in each result against `maxima --version`. If they differ, verify any behavior you use in the installed interpreter; do not assume a newer documented feature exists locally. Follow the repository's software-design and running-CAS skills when editing and validating Maxima scripts. Cite the manual entry when explaining a non-obvious Maxima behavior.

Among approaches that produce correct results, prefer the simpler Maxima code. Consider performance next, especially for costly symbolic transformations or kernel generation.
