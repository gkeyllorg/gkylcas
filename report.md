# Maxima documentation lookup benchmark pilot

Run date: 2026-10-06. Five Maxima coding tasks, two independent repetitions each, paired with and without the local `maxima-docs` skill/index. The baseline and lookup arms used the same prompt, Codex CLI defaults, clean repository snapshot, and hidden Maxima checks. Only the lookup arm had the local documentation skill and tool. Each run used a fresh working copy; no benchmark edits were applied to the source repository.

| Metric, 10 runs per arm | Baseline | Lookup |
| --- | ---: | ---: |
| Hidden checks passed | 10 | 10 |
| Runs invoking local docs | 0 | 6 |
| Local docs commands | 0 | 18 |
| Input tokens, including cache hits | 1,292,587 | 1,417,289 |
| Cached input tokens (subset of input) | 1,104,384 | 1,204,992 |
| Uncached input tokens | 188,203 | 212,297 |
| Output tokens | 20,810 | 19,173 |
| Agent wall time, seconds | 533.22 | 453.62 |

The lookup arm used 9.6% more input tokens and 12.8% more uncached input tokens, and 7.9% fewer output tokens. Both arms passed every check. Wall time varied considerably across pairs, so its 14.9% lower aggregate in the lookup arm should not be interpreted as a speed improvement. The five tasks were small and mostly familiar Maxima operations, and the checks do not benchmark runtime performance of the generated Maxima code. This pilot cannot establish a correctness advantage because all runs passed.

Raw trial results and Codex JSONL transcripts are in `records/`; the editable temporary harness is `../gkylcas_rag_benchmark.py`. The ten trial pairs are in `trials/`.
