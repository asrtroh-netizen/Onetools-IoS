"""D1：导出的 SDK 清单条目数必须等于 rules.ts 里 sdk 对象的键数。"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RULES_TS = ROOT / "Swiplets" / "skip-chinese-ads" / "src" / "rules.ts"
EXPORTER = ROOT / "tools" / "export_ad_sdks.py"
OUT_JSON = ROOT / "adblock" / "sdk-list.json"

FIXTURE = """\
const sdk = {
  alpha: skip(\"OnlyAlpha\", \"brace}notakey\"),
  beta: {
    class: \"UIButton\",
    label: /^\u8df3\u8fc7$/,
    within: { class: /^(?:A|B)$/ },
  },
  gamma: skip(\"brace{notakey\"),
};
export const sdkRules = Object.values(sdk);
"""


def sdk_object_keys(source: str) -> list[str]:
    """独立统计 `const sdk = { ... }` 的顶层键，不执行脚本，不把个数写死。"""
    marker = "const sdk = {"
    start = source.find(marker)
    if start < 0:
        raise AssertionError("no `const sdk = {` in source")
    i = start + len(marker) - 1
    if source[i] != "{":
        raise AssertionError("sdk marker did not land on '{'")
    n = len(source)
    keys: list[str] = []
    i += 1
    brace = 1
    paren = 0
    bracket = 0
    expect_key = True
    prev = "{"

    def skip_ws(pos: int) -> int:
        while pos < n:
            if source[pos] in " \t\r\n":
                pos += 1
                continue
            if source.startswith("//", pos):
                nl = source.find("\n", pos)
                pos = n if nl < 0 else nl + 1
                continue
            if source.startswith("/*", pos):
                end = source.find("*/", pos + 2)
                pos = n if end < 0 else end + 2
                continue
            break
        return pos

    while i < n and brace > 0:
        i = skip_ws(i)
        if i >= n:
            break
        c = source[i]
        if (
            brace == 1
            and paren == 0
            and bracket == 0
            and expect_key
            and (c.isalpha() or c in "_$" or c in "'\"")
        ):
            if c in "'\"":
                quote = c
                i += 1
                chars: list[str] = []
                while i < n:
                    if source[i] == "\\":
                        if i + 1 >= n:
                            break
                        chars.append(source[i + 1])
                        i += 2
                        continue
                    if source[i] == quote:
                        i += 1
                        break
                    chars.append(source[i])
                    i += 1
                key = "".join(chars)
            else:
                j = i + 1
                while j < n and (source[j].isalnum() or source[j] in "_$"):
                    j += 1
                key = source[i:j]
                i = j
            i = skip_ws(i)
            if i >= n or source[i] != ":":
                raise AssertionError(f"sdk key {key!r} has no colon")
            keys.append(key)
            i += 1
            prev = ":"
            expect_key = False
            continue
        if c in "'\"":
            quote = c
            i += 1
            while i < n:
                if source[i] == "\\":
                    i += 2
                    continue
                if source[i] == quote:
                    i += 1
                    break
                i += 1
            prev = quote
            continue
        if c == "`":
            i += 1
            while i < n and source[i] != "`":
                if source[i] == "\\":
                    i += 2
                    continue
                i += 1
            i = min(i + 1, n)
            prev = "`"
            continue
        if c == "/" and not (prev.isalnum() or prev in "_$)]\"'`"):
            i += 1
            in_class = False
            while i < n:
                if source[i] == "\\":
                    i += 2
                    continue
                if source[i] == "[" and not in_class:
                    in_class = True
                    i += 1
                    continue
                if source[i] == "]" and in_class:
                    in_class = False
                    i += 1
                    continue
                if source[i] == "/" and not in_class:
                    i += 1
                    while i < n and source[i].isalpha():
                        i += 1
                    break
                if source[i] == "\n":
                    break
                i += 1
            prev = "/"
            continue
        if c == "{":
            brace += 1
            prev = c
            i += 1
            continue
        if c == "}":
            brace -= 1
            prev = c
            i += 1
            continue
        if c == "(":
            paren += 1
            prev = c
            i += 1
            continue
        if c == ")":
            paren -= 1
            prev = c
            i += 1
            continue
        if c == "[":
            bracket += 1
            prev = c
            i += 1
            continue
        if c == "]":
            bracket -= 1
            prev = c
            i += 1
            continue
        if c == "," and brace == 1 and paren == 0 and bracket == 0:
            expect_key = True
            prev = c
            i += 1
            continue
        prev = c
        i += 1
    if brace != 0:
        raise AssertionError(f"unbalanced sdk object, brace={brace}")
    return keys


def test_oracle_ignores_nested_and_string_braces() -> None:
    assert sdk_object_keys(FIXTURE) == ["alpha", "beta", "gamma"]


def test_real_rules_ts_is_on_disk() -> None:
    assert RULES_TS.is_file()
    keys = sdk_object_keys(RULES_TS.read_text(encoding="utf-8"))
    assert len(keys) == len(set(keys)) > 0


def _run_export(*extra: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(EXPORTER), *extra],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )


def test_export_list_count_matches_rules_ts() -> None:
    proc = _run_export()
    assert proc.returncode == 0, proc.stdout + proc.stderr
    payload = json.loads(OUT_JSON.read_text(encoding="utf-8"))
    expected = sdk_object_keys(RULES_TS.read_text(encoding="utf-8"))
    got = [row["id"] for row in payload["sdks"]]
    assert got == expected
    assert payload["count"] == len(expected)
    assert f"sdk_count={len(expected)}" in proc.stdout


def test_export_recounts_a_different_file(tmp_path: Path) -> None:
    rules = tmp_path / "rules.ts"
    rules.write_text(FIXTURE, encoding="utf-8")
    out = tmp_path / "sdk-list.json"
    proc = _run_export("--rules", str(rules), "--out", str(out))
    assert proc.returncode == 0, proc.stdout + proc.stderr
    payload = json.loads(out.read_text(encoding="utf-8"))
    assert [row["id"] for row in payload["sdks"]] == ["alpha", "beta", "gamma"]
    assert payload["count"] == 3
    assert "sdk_count=3" in proc.stdout
