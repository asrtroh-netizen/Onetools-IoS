"""核对广告 SDK 清单：每个 SDK 要么有插件规则，要么在说明里写了没有的原因。每条规则至少两个不同文件的来源，来源行里要能看到这个域名。"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RULE_RE = re.compile(r"^(DOMAIN|DOMAIN-SUFFIX|DOMAIN-KEYWORD),([^,\s]+),REJECT$")
SOURCE_RE = re.compile(r"^(\S+):(\d+)$")


def plugin_rules(text: str) -> list[str]:
    rules: list[str] = []
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith(("#", "//", ";", "[", "#!")):
            continue
        if RULE_RE.fullmatch(line):
            rules.append(line)
    return rules


def parse_findings(text: str) -> dict[str, dict]:
    sections: dict[str, dict] = {}
    current: dict | None = None
    domain: dict | None = None
    for raw in text.splitlines():
        line = raw.strip()
        if line.startswith("## "):
            current = {"status": "", "reason": "", "domains": []}
            sections[line[3:].strip()] = current
            domain = None
            continue
        if current is None or not line:
            continue
        if line.startswith("status:"):
            current["status"] = line.split(":", 1)[1].strip()
        elif line.startswith("reason:"):
            current["reason"] = line.split(":", 1)[1].strip()
        elif line.startswith("- domain:"):
            domain = {"domain": line.split(":", 1)[1].strip(), "rule": "", "sources": []}
            current["domains"].append(domain)
        elif line.startswith("rule:") and domain is not None:
            domain["rule"] = line.split(":", 1)[1].strip()
        elif line.startswith("- ") and domain is not None:
            match = SOURCE_RE.fullmatch(line[2:].strip())
            if match:
                domain["sources"].append((match.group(1), int(match.group(2))))
    return sections


def resolve_source(root: Path, rel: str) -> Path | None:
    if not rel or rel.startswith(("/", "\\")) or ":" in rel:
        return None
    if ".." in Path(rel).parts:
        return None
    candidate = (root / rel).resolve()
    base = root.resolve()
    if candidate != base and base not in candidate.parents:
        return None
    return candidate


def line_has_domain(path: Path, line_no: int, domain: str) -> bool:
    if not path.is_file():
        return False
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    if line_no < 1 or line_no > len(lines):
        return False
    return domain.lower() in lines[line_no - 1].lower()


def check(root: Path, sdk_path: Path, plugin_path: Path, findings_path: Path) -> int:
    if not sdk_path.is_file():
        print(f"MISSING sdk {sdk_path}", file=sys.stderr)
        return 1
    if not plugin_path.is_file():
        print(f"MISSING plugin {plugin_path}", file=sys.stderr)
        return 1
    if not findings_path.is_file():
        print(f"MISSING findings {findings_path}", file=sys.stderr)
        return 1

    listed = json.loads(sdk_path.read_text(encoding="utf-8"))
    sections = parse_findings(findings_path.read_text(encoding="utf-8"))
    plugin = plugin_rules(plugin_path.read_text(encoding="utf-8"))
    documented: list[str] = []
    failed = False

    for sdk_id in (item["id"] for item in listed["sdks"]):
        section = sections.get(sdk_id)
        if section is None:
            print(f"UNCOVERED {sdk_id}", file=sys.stderr)
            failed = True
            continue
        if section["status"] == "no-rule":
            if section["reason"]:
                print(f"ok {sdk_id}")
            else:
                print(f"UNCOVERED {sdk_id}", file=sys.stderr)
                failed = True
            continue
        if section["status"] != "ruled" or not section["domains"]:
            print(f"UNCOVERED {sdk_id}", file=sys.stderr)
            failed = True
            continue
        sdk_ok = True
        for item in section["domains"]:
            domain = item["domain"]
            rule = item["rule"]
            if rule:
                documented.append(rule)
            match = RULE_RE.fullmatch(rule)
            if not domain or match is None or match.group(2).lower() != domain.lower():
                print(f"BAD-RULE {sdk_id} {rule}", file=sys.stderr)
                sdk_ok = False
                failed = True
                continue
            valid: list[str] = []
            for rel, line_no in item["sources"]:
                path = resolve_source(root, rel)
                if path is None or not line_has_domain(path, line_no, domain):
                    print(f"BAD-SOURCE {rel}:{line_no} {domain}", file=sys.stderr)
                    sdk_ok = False
                    failed = True
                    continue
                valid.append(str(path))
            if len(set(valid)) < 2:
                print(f"NEED-SOURCE {domain}", file=sys.stderr)
                sdk_ok = False
                failed = True
        if sdk_ok:
            print(f"ok {sdk_id}")

    plugin_set = set(plugin)
    documented_set = set(documented)
    for rule in sorted(plugin_set - documented_set):
        print(f"EXTRA-RULE {rule}", file=sys.stderr)
        failed = True
    for rule in sorted(documented_set - plugin_set):
        print(f"MISSING-RULE {rule}", file=sys.stderr)
        failed = True
    return 1 if failed else 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Check ad SDK rules have two sources")
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--sdk", type=Path, default=None)
    parser.add_argument("--plugin", type=Path, default=None)
    parser.add_argument("--findings", type=Path, default=None)
    args = parser.parse_args(argv)
    root = args.root
    sdk = args.sdk if args.sdk is not None else root / "adblock" / "sdk-list.json"
    plugin = args.plugin if args.plugin is not None else root / "adblock" / "onetools-cn-ads.plugin"
    findings = args.findings if args.findings is not None else root / "docs" / "findings" / "ad-sdk-domains.md"
    return check(root, sdk, plugin, findings)


if __name__ == "__main__":
    sys.exit(main())
