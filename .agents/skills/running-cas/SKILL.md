---
name: running-cas
description: How to run CAS scripts.
---

# Instructions

* Use these instructions to run CAS (e.g. Maxima) scripts.

# Running Maxima scripts.

## maxima CLI.

1. One can initialize Maxima simply by typing `maxima` in the terminal. Inside Maxima, one can then run script by loading it, e.g.

```bash
load("my_script.mac");
```

2. One can also run a Maxima script directly from the terminal with

```bash
maxima --quiet -b script.mac
```
