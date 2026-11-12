# -*- coding: utf-8 -*-
"""Q1 closeout: full gates, second flutter test, N1/N6/N13 evidence."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if not (ROOT / "tools" / "gates.json").exists():
    ROOT = Path(r"E:/GQ/Ultra/Onetools-IoS")

GATES_PATH = ROOT / "tools" / "gates.json"
LOG_PATH = ROOT / "docs" / "autorun" / "gates.log"
OUT_DIR = ROOT / "docs" / "autorun" / "closeout-2026-11-12"
GOLDENS = ROOT / "_golden" / "goldens"
ONEWIFI = Path(r"E:/GQ/Ultra/ONEWIFIX/IOS")
TZ = timezone(timedelta(hours=8))


def now() -> str:
    return datetime.now(TZ).strftime("%Y-%m-%d %H:%M:%S %z")


def hash_goldens() -> tuple[str, int, str]:
    files = sorted(p for p in GOLDENS.rglob("*.png") if p.is_file())
    digest = hashlib.sha256()
    lines = []
    for path in files:
        raw = path.read_bytes()
        item = hashlib.sha256(raw).hexdigest()
        rel = path.relative_to(GOLDENS).as_posix()
        digest.update(rel.encode("utf-8"))
        digest.update(b"\0")
        digest.update(item.encode("ascii"))
        digest.update(b"\n")
        lines.append(f"{item}  {rel}")
    return digest.hexdigest(), len(files), "\n".join(lines) + ("\n" if lines else "")


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def run_cmd(cmd: list[str] | str, cwd: Path, log_path: Path) -> tuple[int, str]:
    started = now()
    try:
        proc = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        code = proc.returncode
        text = (proc.stdout or "") + (proc.stderr or "")
    except OSError as exc:
        code = 127
        text = str(exc)
    ended = now()
    header = f"$ cwd={cwd}\n$ {cmd}\nstarted={started}\nended={ended}\nexit={code}\n\n"
    write(log_path, header + text)
    return code, text


def last_key(text: str) -> str:
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    return lines[-1] if lines else "(no output)"


def run_gates(summary: list[str]) -> int:
    spec = json.loads(GATES_PATH.read_text(encoding="utf-8"))
    gates = spec["gates"]
    stamp = now()
    failed = 0
    log_lines = [f"== {stamp} =="]
    table = [f"{'id':<28} {'result':<8} key", "-" * 72]
    print(f"Q1 gates start {stamp}", flush=True)
    print(table[0], flush=True)
    print(table[1], flush=True)
    for gate in gates:
        gid = str(gate["id"])
        if not gate.get("enabled", True):
            gid, result, code, key = gid, "skip", 0, "disabled"
            text = "disabled\n"
        else:
            cwd = (ROOT / gate.get("cwd", ".")).resolve()
            cmd = gate["command"]
            code, text = run_cmd(cmd, cwd, OUT_DIR / "gates" / f"{gid}.log")
            key = last_key(text)
            result = "pass" if code == 0 else "fail"
        if result == "fail":
            failed += 1
        shown = key.replace("\t", " ")
        if len(shown) > 120:
            shown = shown[:117] + "..."
        line = f"{gid:<28} {result:<8} {shown}"
        print(line, flush=True)
        table.append(line)
        log_lines.append(f"{gid} result={result} exit={code} key={key}")
        summary.append(f"{gid}: result={result} exit={code} key={key}")
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with LOG_PATH.open("a", encoding="utf-8") as fh:
        fh.write("\n".join(log_lines) + "\n")
    write(OUT_DIR / "gates-table.txt", "\n".join(table) + "\n")
    return failed


def flutter_second(summary: list[str]) -> int:
    cmd = [
        r"C:/Flutter/flutter/bin/flutter.bat",
        "test",
    ]
    cwd = ROOT / "_golden"
    code, text = run_cmd(cmd, cwd, OUT_DIR / "flutter-test-2.log")
    key = last_key(text)
    result = "pass" if code == 0 else "fail"
    print(f"{'A1-flutter-test-2':<28} {result:<8} {key[:120]}", flush=True)
    summary.append(f"A1-flutter-test-2: result={result} exit={code} key={key}")
    stamp = now()
    with LOG_PATH.open("a", encoding="utf-8") as fh:
        fh.write(f"== {stamp} extra ==\n")
        fh.write(f"A1-flutter-test-2 result={result} exit={code} key={key}\n")
    return 0 if code == 0 else 1


def extra_n6(summary: list[str]) -> int:
    code, text = run_cmd(
        [sys.executable, "-m", "pytest", "tools", "-q"],
        ROOT,
        OUT_DIR / "N6-pytest-tools.log",
    )
    key = last_key(text)
    result = "pass" if code == 0 else "fail"
    print(f"{'N6-pytest-tools':<28} {result:<8} {key[:120]}", flush=True)
    summary.append(f"N6-pytest-tools: result={result} exit={code} key={key}")
    return 0 if code == 0 else 1


def extra_n1(summary: list[str]) -> int:
    lock = json.loads((ROOT / "upstreams.lock.json").read_text(encoding="utf-8"))
    lines = [f"closeout N1 {now()}"]
    bad = 0
    for item in lock:
        path = ROOT / item["path"]
        expected = item["revision"]
        def git(*args: str) -> subprocess.CompletedProcess[str]:
            return subprocess.run(
                ["git", "-C", str(path), *args],
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
            )
        porcelain = git("status", "--porcelain")
        head = git("rev-parse", "HEAD")
        branch = git("branch", "--show-current")
        start = git("rev-parse", "--verify", "onetools") if True else None
        # starting point of onetools: merge-base with... plan says lock equals onetools branch start (or HEAD if no branch)
        # Check if onetools exists and what its start is. For repos with onetools, the lock should be the branch start.
        # Also collect reflog / first commit on branch if possible.
        onetools = git("show-ref", "--verify", "--heads", "refs/heads/onetools")
        merge_base_main = git("merge-base", "HEAD", expected) if expected else None
        status = porcelain.stdout
        head_sha = head.stdout.strip()
        branch_name = branch.stdout.strip()
        has_onetools = onetools.returncode == 0
        ok_clean = porcelain.returncode == 0 and status == ""
        # N1: lock revision equals onetools starting point. Check lock sha is an ancestor and equals
        # the branch point. We'll record lock vs HEAD vs onetools.
        onetools_sha = ""
        if has_onetools:
            ot = git("rev-parse", "refs/heads/onetools")
            onetools_sha = ot.stdout.strip()
        lock_ok = git("cat-file", "-t", expected)
        lines.append(f"## {item['path']}")
        lines.append(f"lock={expected}")
        lines.append(f"HEAD={head_sha} exit={head.returncode}")
        lines.append(f"branch={branch_name or '(none)'} exit={branch.returncode}")
        lines.append(f"onetools={onetools_sha or '(no onetools branch)'}")
        lines.append(f"porcelain_exit={porcelain.returncode}")
        lines.append("porcelain:" + (" (empty)" if not status else "\n" + status))
        lines.append(f"lock_object={lock_ok.stdout.strip()} exit={lock_ok.returncode}")
        if not ok_clean:
            bad = 1
            lines.append("FAIL: working tree not clean")
        if lock_ok.returncode != 0:
            bad = 1
            lines.append("FAIL: lock revision not in repo")
        # For Clash-Client, Swipt, Feather: onetools should exist. Lock is the start of onetools.
        # Compare lock to merge-base of onetools and its upstream? Record whether onetools contains lock.
        if has_onetools:
            contains = git("merge-base", "--is-ancestor", expected, "refs/heads/onetools")
            lines.append(f"lock_is_ancestor_of_onetools exit={contains.returncode}")
            # If onetools was created from lock and never rebased, first unique? 
            # N1 text: lock six items equal each repo's onetools branch starting point (HEAD if no branch).
            # The starting point IS the lock revision. Check that onetools can reach it and
            # that we report whether HEAD moved (expected: yes, work happened on onetools).
        else:
            if head_sha != expected:
                # no branch: lock should equal HEAD
                lines.append("NOTE: no onetools branch; N1 says lock should equal HEAD")
                if head_sha != expected:
                    lines.append(f"DIFF: HEAD != lock")
                    # This may be OK if we never opened a branch and HEAD moved? Plan says equal HEAD.
                    # Don't auto-fail if this is a pre-existing situation; record it.
                    # Actually N1 is a frozen criterion. Record clearly. I'll flag mismatch.
                    bad = 1
                    lines.append("FAIL: no onetools and HEAD != lock")
        lines.append("")
    write(OUT_DIR / "N1-upstreams.txt", "\n".join(lines) + "\n")
    print(f"{'N1-upstreams':<28} {'pass' if bad==0 else 'fail':<8} see N1-upstreams.txt", flush=True)
    summary.append(f"N1-upstreams: result={'pass' if bad==0 else 'fail'} details=N1-upstreams.txt")
    return bad


def extra_n13(summary: list[str]) -> int:
    expected = "7a8839e"
    def git(*args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["git", "-C", str(ONEWIFI), *args],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    porcelain = git("status", "--porcelain")
    head = git("rev-parse", "HEAD")
    short = git("rev-parse", "--short", "HEAD")
    head_sha = head.stdout.strip()
    short_sha = short.stdout.strip()
    status = porcelain.stdout
    ok = porcelain.returncode == 0 and status == "" and short_sha.startswith(expected[:7])
    text = [
        f"closeout N13 {now()}",
        f"path={ONEWIFI}",
        f"HEAD={head_sha}",
        f"short={short_sha}",
        f"expected_prefix={expected}",
        f"porcelain_exit={porcelain.returncode}",
        "porcelain:" + (" (empty)" if not status else "\n" + status),
        f"result={'pass' if ok else 'fail'}",
    ]
    write(OUT_DIR / "N13-onewifix.txt", "\n".join(text) + "\n")
    print(f"{'N13-onewifix':<28} {'pass' if ok else 'fail':<8} HEAD={short_sha}", flush=True)
    summary.append(f"N13-onewifix: result={'pass' if ok else 'fail'} HEAD={head_sha} porcelain_empty={status==''}")
    return 0 if ok else 1


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    summary: list[str] = [f"Q1 closeout started {now()}"]
    failed = 0

    h0, n0, listing0 = hash_goldens()
    write(OUT_DIR / "goldens-hash-before.txt", f"sha256={h0}\ncount={n0}\n\n{listing0}")
    print(f"goldens before: {n0} pngs sha256={h0}", flush=True)
    summary.append(f"goldens-before count={n0} sha256={h0}")

    failed += run_gates(summary)

    h1, n1, listing1 = hash_goldens()
    write(OUT_DIR / "goldens-hash-after-gates.txt", f"sha256={h1}\ncount={n1}\n\n{listing1}")
    same01 = h0 == h1 and n0 == n1
    print(f"goldens after gates: {n1} pngs sha256={h1} same_as_before={same01}", flush=True)
    summary.append(f"goldens-after-gates count={n1} sha256={h1} same_as_before={same01}")
    if not same01:
        failed += 1
        summary.append("FAIL: goldens changed during gates flutter test")

    failed += flutter_second(summary)

    h2, n2, listing2 = hash_goldens()
    write(OUT_DIR / "goldens-hash-after-second.txt", f"sha256={h2}\ncount={n2}\n\n{listing2}")
    same12 = h1 == h2 and n1 == n2
    print(f"goldens after second: {n2} pngs sha256={h2} HASH_SAME={same12}", flush=True)
    summary.append(f"goldens-after-second count={n2} sha256={h2} HASH_SAME={same12}")
    stamp = now()
    with LOG_PATH.open("a", encoding="utf-8") as fh:
        fh.write(f"Q1-goldens-hash result={'pass' if same12 else 'fail'} exit={0 if same12 else 1} key={'HASH_SAME' if same12 else 'HASH_DIFF'} {h2} count={n2}\n")
    if not same12:
        failed += 1

    failed += extra_n6(summary)
    failed += extra_n1(summary)
    failed += extra_n13(summary)

    summary.append(f"Q1 closeout ended {now()} failed_count={failed}")
    write(OUT_DIR / "SUMMARY.txt", "\n".join(summary) + "\n")
    print("----", flush=True)
    print(f"Q1 done failed={failed} at {now()}", flush=True)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
