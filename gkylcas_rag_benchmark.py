"""Temporary paired benchmark runner for Maxima documentation retrieval."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import random
import re
import shutil
import subprocess
import tarfile
import time


REPO = Path("/Users/mfrancis/Documents/gkeyll/code/gkeyll_v3/gkylcas")
ROOT = Path("/private/tmp/gkylcas_rag_benchmark")

TASKS = {
    "member_refactor": {
        "file": "util_maxima/utilities.mac",
        "prompt": (
            "Improve isInList(e, lst) in util_maxima/utilities.mac. It must return true exactly "
            "when e is a top-level element of lst, including symbolic expressions and nested lists, "
            "and false for an empty list. Avoid building a list of matching indices or changing "
            "caller/global variables. Preserve the signature."
        ),
        "check": '''load("util_maxima/utilities.mac")$
i:31415$
ok:isInList(3,[1,3,5]) and not isInList(2,[1,3,5])
   and isInList(x^2,[x,x^2,y])
   and isInList([1,2],[[2,1],[1,2]])
   and not isInList(0,[]) and i=31415$
if ok then print("BENCH_PASS") else print("BENCH_FAIL")$
''',
    },
    "poly_coeffs": {
        "file": "util_maxima/utilities.mac",
        "prompt": (
            "Add polyCoeffList(expr, x, degree) to util_maxima/utilities.mac. For a nonnegative "
            "integer degree, return the exact coefficients of x^0 through x^degree after expanding "
            "expr. Include zero coefficients and support symbolic coefficients. Do not change "
            "global variables."
        ),
        "check": '''load("util_maxima/utilities.mac")$
same(a,b):=is(ratsimp(a-b)=0)$
i:31415$
a:polyCoeffList((u+v*x)^3,x,3)$
b:polyCoeffList(x^4+2*x^2+7,x,4)$
c:polyCoeffList(5,x,0)$
ok:length(a)=4 and same(a[1],u^3) and same(a[2],3*u^2*v)
   and same(a[3],3*u*v^2) and same(a[4],v^3)
   and length(b)=5 and same(b[1],7) and same(b[2],0)
   and same(b[3],2) and same(b[4],0) and same(b[5],1)
   and length(c)=1 and same(c[1],5) and i=31415$
if ok then print("BENCH_PASS") else print("BENCH_FAIL")$
''',
    },
    "symbol_swap": {
        "file": "util_maxima/utilities.mac",
        "prompt": (
            "Add swapSymbols(expr, a, b) to util_maxima/utilities.mac. The distinct inputs a and b "
            "are unassigned symbols. Exchange every occurrence of a and b in expr simultaneously, "
            "so a replacement must not be replaced again. Handle symbols inside compound expressions "
            "and lists. Do not change global variables."
        ),
        "check": '''load("util_maxima/utilities.mac")$
same(a,b):=is(ratsimp(a-b)=0)$
i:31415$
r:swapSymbols(x^2+3*x*y+2*y,x,y)$
s:swapSymbols([x,y,x+y^2],x,y)$
ok:same(r,y^2+3*x*y+2*x) and is(s=[y,x,y+x^2])
   and same(swapSymbols(x,x,y),y) and i=31415$
if ok then print("BENCH_PASS") else print("BENCH_FAIL")$
''',
    },
    "jacobian": {
        "file": "util_maxima/utilities.mac",
        "prompt": (
            "Add jacobianMatrix(exprs, vars) to util_maxima/utilities.mac. Both inputs are nonempty "
            "lists. Return a Maxima matrix with one row per expression and one column per variable; "
            "entry (i,j) is the symbolic derivative of exprs[i] with respect to vars[j]. "
            "Do not change global variables."
        ),
        "check": '''load("util_maxima/utilities.mac")$
same(a,b):=is(ratsimp(a-b)=0)$
i:31415$
j:jacobianMatrix([x^2*y,sin(x)+y],[x,y])$
k:jacobianMatrix([x^3],[x])$
ok:matrixp(j) and same(j[1,1],2*x*y) and same(j[1,2],x^2)
   and same(j[2,1],cos(x)) and same(j[2,2],1)
   and matrixp(k) and same(k[1,1],3*x^2) and i=31415$
if ok then print("BENCH_PASS") else print("BENCH_FAIL")$
''',
    },
    "basis_writer": {
        "file": "util_maxima/out-scripts.mac",
        "prompt": (
            "Fix writeBasis(fh, basisIn) in util_maxima/out-scripts.mac. Write one C-style "
            "assignment per basis expression to b[0], b[1], ... on the supplied stream fh. "
            "Each line must end in a semicolon and newline. It must work even if a global "
            "Maxima variable named b has a numeric value. Preserve the signature and leave "
            "writeCBasis untouched."
        ),
        "check": '''load("util_maxima/out-scripts.mac")$
b:42$
fh:openw("{output}")$
writeBasis(fh,[x+1,2*x])$
close(fh)$
print("BENCH_PASS")$
''',
    },
}


def run_command(args: list[str], cwd: Path | None = None, **kwargs):
    return subprocess.run(args, cwd=cwd, check=True, **kwargs)


def prepare() -> None:
    ROOT.mkdir(parents=True, exist_ok=True)
    archive = ROOT / "base.tar"
    if not archive.exists():
        with archive.open("wb") as output:
            run_command(["git", "archive", "HEAD"], REPO, stdout=output)
    for arm in ("baseline", "lookup"):
        template = ROOT / f"template_{arm}"
        if template.exists():
            continue
        template.mkdir()
        with tarfile.open(archive) as archive_file:
            archive_file.extractall(template)
        instructions = (REPO / "AGENTS.md").read_text()
        if arm == "baseline":
            instructions = "\n".join(
                line for line in instructions.splitlines()
                if "[Maxima documentation](.agents/skills/maxima-docs/SKILL.md)" not in line
            ) + "\n"
        (template / "AGENTS.md").write_text(instructions)
        if arm == "lookup":
            shutil.copytree(REPO / ".agents/skills/maxima-docs", template / ".agents/skills/maxima-docs")
            (template / "tools").mkdir(exist_ok=True)
            shutil.copytree(
                REPO / "tools/maxima_docs", template / "tools/maxima_docs",
                ignore=shutil.ignore_patterns("__pycache__", "test_maxima_docs.py"),
            )
            shutil.copy2(REPO / "tools/__init__.py", template / "tools/__init__.py")
            shutil.copy2(REPO / "README.md", template / "README.md")
            shutil.copy2(REPO / ".gitignore", template / ".gitignore")
    print("Prepared baseline and lookup templates", flush=True)


def initialize_trial(arm: str, task: str, repetition: int) -> Path:
    trial = ROOT / "trials" / f"{task}_{repetition}_{arm}"
    if trial.exists():
        shutil.rmtree(trial)
    shutil.copytree(ROOT / f"template_{arm}", trial)
    run_command(["git", "init", "-q"], trial)
    run_command(["git", "add", "-A"], trial)
    run_command(
        ["git", "-c", "user.name=Benchmark", "-c", "user.email=benchmark@example.invalid",
         "commit", "-qm", "Initial benchmark snapshot"], trial
    )
    return trial


def evaluate(trial: Path, task: str) -> tuple[bool, str, int]:
    definition = TASKS[task]
    check_dir = ROOT / "checks"
    check_dir.mkdir(exist_ok=True)
    output_file = check_dir / f"{trial.name}_basis.c"
    script = check_dir / f"{trial.name}.mac"
    script.write_text(definition["check"].format(output=str(output_file)))
    try:
        result = subprocess.run(
            ["maxima", "--no-init", "--quiet", "-b", str(script)],
            cwd=trial, capture_output=True, text=True, timeout=30,
        )
        log = result.stdout + "\n" + result.stderr
    except subprocess.TimeoutExpired:
        return False, "Maxima timed out", 0
    passed = bool(re.search(r"(?m)^BENCH_PASS\s*$", log)) and not bool(
        re.search(r"(?m)^BENCH_FAIL\s*$", log)
    ) and result.returncode == 0
    if task == "member_refactor":
        code = (trial / definition["file"]).read_text()
        matches = list(re.finditer(r"isInList\s*\([^)]*\)\s*:=.*?\$", code, re.S))
        match = matches[-1] if matches else None
        passed = passed and match is not None and "sublist_indices" not in match.group(0)
    if task == "basis_writer":
        if not output_file.exists():
            passed = False
        else:
            lines = [line.strip() for line in output_file.read_text().splitlines() if line.strip()]
            passed = passed and len(lines) == 2 and all(
                re.search(rf"\bb\[{i}\]\s*=.+;\s*$", line) for i, line in enumerate(lines)
            ) and all("x" in line for line in lines)
    diff = subprocess.run(["git", "diff", "--numstat"], cwd=trial, capture_output=True, text=True)
    changed_lines = 0
    for line in diff.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) >= 2 and parts[0].isdigit() and parts[1].isdigit():
            changed_lines += int(parts[0]) + int(parts[1])
    return passed, log[-1500:], changed_lines


def run_trial(arm: str, task: str, repetition: int) -> dict:
    stem = f"{task}_{repetition}_{arm}"
    saved_record = ROOT / "records" / f"{stem}.json"
    if saved_record.exists():
        record = json.loads(saved_record.read_text())
        print(f"{stem}: reused pass={record['passed']}", flush=True)
        return record
    trial = initialize_trial(arm, task, repetition)
    record_dir = ROOT / "records"
    record_dir.mkdir(exist_ok=True)
    jsonl = record_dir / f"{stem}.jsonl"
    stderr = record_dir / f"{stem}.stderr"
    prompt = (
        TASKS[task]["prompt"] + " Modify only the named file. Follow the repository instructions. "
        "Prioritize correctness, then simplicity, then performance. Run a focused Maxima check. "
        "Work offline; do not browse the web."
    )
    command = [
        "codex", "exec", "--ephemeral", "--json", "--sandbox", "workspace-write",
        "-C", str(trial), prompt,
    ]
    start = time.monotonic()
    try:
        with jsonl.open("w") as output, stderr.open("w") as errors:
            process = subprocess.run(
                command, cwd=trial, stdin=subprocess.DEVNULL, stdout=output,
                stderr=errors, timeout=300,
            )
        returncode = process.returncode
    except subprocess.TimeoutExpired:
        returncode = 124
    elapsed = time.monotonic() - start
    usage = {"input_tokens": 0, "cached_input_tokens": 0, "output_tokens": 0}
    doc_commands = 0
    for line in jsonl.read_text().splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") == "turn.completed":
            usage.update(event.get("usage", {}))
        if event.get("type") == "item.started":
            item = event.get("item", {})
            if item.get("type") == "command_execution" and "tools.maxima_docs" in item.get("command", ""):
                doc_commands += 1
    passed, check_log, changed_lines = evaluate(trial, task)
    record = {
        "task": task, "arm": arm, "repetition": repetition, "returncode": returncode,
        "passed": passed, "elapsed_seconds": round(elapsed, 2), "changed_lines": changed_lines,
        "doc_commands": doc_commands, "usage": usage, "trial": str(trial),
        "check_log": check_log,
    }
    (record_dir / f"{stem}.json").write_text(json.dumps(record, indent=2))
    print(
        f"{stem}: pass={passed} rc={returncode} input={usage['input_tokens']} "
        f"output={usage['output_tokens']} docs={doc_commands} time={elapsed:.1f}s",
        flush=True,
    )
    return record


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("prepare", "run", "trial"))
    parser.add_argument("--task", choices=TASKS)
    parser.add_argument("--arm", choices=("baseline", "lookup"))
    parser.add_argument("--repetition", type=int, default=1)
    args = parser.parse_args()
    prepare()
    if args.command == "prepare":
        return
    if args.command == "trial":
        if not args.task or not args.arm:
            parser.error("trial requires --task and --arm")
        run_trial(args.arm, args.task, args.repetition)
        return
    pairs = [(task, repetition) for repetition in (1, 2) for task in TASKS]
    random.Random(20261006).shuffle(pairs)
    for task, repetition in pairs:
        arms = ("baseline", "lookup") if repetition == 1 else ("lookup", "baseline")
        for arm in arms:
            run_trial(arm, task, repetition)


if __name__ == "__main__":
    main()
