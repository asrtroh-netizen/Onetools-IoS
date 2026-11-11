"""从 rules.ts 的 `const sdk` 对象导出广告 SDK 清单。每次重新数键，不把个数写死。"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUT = ROOT / "adblock" / "sdk-list.json"
PREFERRED_RULES = ROOT / "Swiplets" / "skip-chinese-ads" / "src" / "rules.ts"


def sdk_keys(source: str) -> list[str]:
    """返回 `const sdk = { ... }` 的顶层键，顺序与源文一致。"""
    marker = "const sdk = {"
    start = source.find(marker)
    if start < 0:
        raise ValueError("no `const sdk = {` in source")
    i = start + len(marker) - 1
    if source[i] != "{":
        raise ValueError("sdk marker did not land on '{'")
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
                raise ValueError(f"sdk key {key!r} has no colon")
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
        raise ValueError(f"unbalanced sdk object, brace={brace}")
    if not keys:
        raise ValueError("sdk object has no keys")
    return keys


def find_rules(root: Path) -> Path:
    """优先用总计划写明的 Swiplets 路径；该文件没有 sdk 对象时再看 Clash-Client。"""
    if PREFERRED_RULES.is_file():
        text = PREFERRED_RULES.read_text(encoding="utf-8")
        if "const sdk = {" in text:
            return PREFERRED_RULES
    clash = root / "Clash-Client"
    if clash.is_dir():
        for path in sorted(clash.rglob("rules.ts")):
            if not path.is_file():
                continue
            text = path.read_text(encoding="utf-8")
            if "const sdk = {" in text:
                return path
    raise SystemExit("rules.ts with `const sdk = {` not found")


def source_label(rules: Path, root: Path) -> str:
    try:
        return rules.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return rules.as_posix()


def build_payload(rules: Path, root: Path) -> dict:
    keys = sdk_keys(rules.read_text(encoding="utf-8"))
    return {
        "source": source_label(rules, root),
        "count": len(keys),
        "sdks": [{"id": key} for key in keys],
    }


def write_payload(payload: dict, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"sdk_count={payload['count']}")
    print(f"source={payload['source']}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Export ad SDK ids from rules.ts")
    parser.add_argument("--rules", type=Path, default=None)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    args = parser.parse_args(argv)
    rules = args.rules if args.rules is not None else find_rules(ROOT)
    if not rules.is_file():
        raise SystemExit(f"rules file not found: {rules}")
    write_payload(build_payload(rules, ROOT), args.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
