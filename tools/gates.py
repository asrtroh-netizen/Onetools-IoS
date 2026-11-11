"""跑 tools/gates.json 里已启用的验证命令。有失败就返回非零。"""

from __future__ import annotations

import json
import subprocess
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GATES_PATH = Path(__file__).with_name("gates.json")
LOG_PATH = ROOT / "docs" / "autorun" / "gates.log"
TZ = timezone(timedelta(hours=8))


def run_gate(gate: dict) -> tuple[str, str, int, str]:
    gid = str(gate["id"])
    if not gate.get("enabled", True):
        return gid, "skip", 0, "disabled"
    cwd = (ROOT / gate.get("cwd", ".")).resolve()
    cmd = gate["command"]
    try:
        proc = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    except OSError as exc:
        return gid, "fail", 127, str(exc)
    text = (proc.stdout or "") + (proc.stderr or "")
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    key = lines[-1] if lines else "(no output)"
    result = "pass" if proc.returncode == 0 else "fail"
    return gid, result, proc.returncode, key


def main() -> int:
    spec = json.loads(GATES_PATH.read_text(encoding="utf-8"))
    gates = spec["gates"]
    now = datetime.now(TZ).strftime("%Y-%m-%d %H:%M:%S %z")
    failed = 0
    log_lines = [f"== {now} =="]
    print(f"{'id':<28} {'result':<8} key")
    print("-" * 72)
    if not gates:
        print(f"{'(none)':<28} {'pass':<8} no gates enabled")
        log_lines.append("(none) result=pass exit=0 key=no gates enabled")
    for gate in gates:
        gid, result, code, key = run_gate(gate)
        if result == "fail":
            failed += 1
        shown = key.replace("\t", " ")
        if len(shown) > 120:
            shown = shown[:117] + "..."
        print(f"{gid:<28} {result:<8} {shown}")
        log_lines.append(f"{gid} result={result} exit={code} key={key}")
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with LOG_PATH.open("a", encoding="utf-8") as fh:
        fh.write("\n".join(log_lines) + "\n")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
