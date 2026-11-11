"""D4：check_ad_coverage.py 要求清单里每个 SDK 有规则，或写明没有的原因；每条规则至少两个来源。"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "tools" / "check_ad_coverage.py"
LINT = ROOT / "tools" / "loon_lint.py"
PLUGIN = ROOT / "adblock" / "onetools-cn-ads.plugin"
FINDINGS = ROOT / "docs" / "findings" / "ad-sdk-domains.md"
SDK_LIST = ROOT / "adblock" / "sdk-list.json"


def _run(root: Path, sdk: Path, plugin: Path, findings: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [
            sys.executable,
            str(CHECKER),
            "--root",
            str(root),
            "--sdk",
            str(sdk),
            "--plugin",
            str(plugin),
            "--findings",
            str(findings),
        ],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )


def _fixture(tmp_path: Path, *, sources: int, extra_plugin_rule: str = "", reason: str = "两份独立公开列表都没有这个 SDK 的广告专用域名。") -> tuple[Path, Path, Path]:
    sample = tmp_path / "adblock" / "samples" / "a.list"
    listed = tmp_path / "adblock" / "lists" / "b.txt"
    sample.parent.mkdir(parents=True)
    listed.parent.mkdir(parents=True)
    sample.write_text("# sample\nDOMAIN,mobads.baidu.com,reject\n", encoding="utf-8")
    listed.write_text("||mobads.baidu.com^\n", encoding="utf-8")
    sdk = tmp_path / "sdk-list.json"
    sdk.write_text(
        json.dumps({"count": 2, "sdks": [{"id": "baidu"}, {"id": "adgain"}]}),
        encoding="utf-8",
    )
    plugin = tmp_path / "onetools-cn-ads.plugin"
    plugin.write_text(
        "#!name=fixture\n[Rule]\nDOMAIN,mobads.baidu.com,REJECT\n" + extra_plugin_rule,
        encoding="utf-8",
    )
    source_lines = [
        "  - adblock/samples/a.list:2",
        "  - adblock/lists/b.txt:1",
    ][:sources]
    findings = tmp_path / "ad-sdk-domains.md"
    findings.write_text(
        "\n".join(
            [
                "## baidu",
                "status: ruled",
                "- domain: mobads.baidu.com",
                "  rule: DOMAIN,mobads.baidu.com,REJECT",
                "  sources:",
                *source_lines,
                "",
                "## adgain",
                "status: no-rule",
                f"reason: {reason}",
                "",
            ]
        ),
        encoding="utf-8",
    )
    return sdk, plugin, findings


def test_one_source_fails(tmp_path: Path) -> None:
    sdk, plugin, findings = _fixture(tmp_path, sources=1)
    proc = _run(tmp_path, sdk, plugin, findings)
    assert proc.returncode != 0
    assert "NEED-SOURCE" in proc.stdout + proc.stderr
    assert "mobads.baidu.com" in proc.stdout + proc.stderr


def test_missing_reason_fails(tmp_path: Path) -> None:
    sdk, plugin, findings = _fixture(tmp_path, sources=2, reason="")
    proc = _run(tmp_path, sdk, plugin, findings)
    assert proc.returncode != 0
    text = proc.stdout + proc.stderr
    assert "UNCOVERED" in text
    assert "adgain" in text


def test_extra_plugin_rule_fails(tmp_path: Path) -> None:
    sdk, plugin, findings = _fixture(
        tmp_path,
        sources=2,
        extra_plugin_rule="DOMAIN,made-up.example,REJECT\n",
    )
    proc = _run(tmp_path, sdk, plugin, findings)
    assert proc.returncode != 0
    text = proc.stdout + proc.stderr
    assert "EXTRA-RULE" in text
    assert "made-up.example" in text


def test_complete_fixture_passes(tmp_path: Path) -> None:
    sdk, plugin, findings = _fixture(tmp_path, sources=2)
    proc = _run(tmp_path, sdk, plugin, findings)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "ok baidu" in proc.stdout
    assert "ok adgain" in proc.stdout


def test_bad_source_line_fails(tmp_path: Path) -> None:
    sdk, plugin, findings = _fixture(tmp_path, sources=2)
    text = findings.read_text(encoding="utf-8").replace(
        "adblock/lists/b.txt:1",
        "adblock/lists/b.txt:9",
    )
    findings.write_text(text, encoding="utf-8")
    (tmp_path / "adblock" / "lists" / "b.txt").write_text(
        "||mobads.baidu.com^\n" + "\n" * 8 + "not this host\n",
        encoding="utf-8",
    )
    proc = _run(tmp_path, sdk, plugin, findings)
    assert proc.returncode != 0
    assert "BAD-SOURCE" in proc.stdout + proc.stderr


def test_repository_coverage_and_lint() -> None:
    proc = _run(ROOT, SDK_LIST, PLUGIN, FINDINGS)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    listed = json.loads(SDK_LIST.read_text(encoding="utf-8"))
    stdout = proc.stdout
    for item in listed["sdks"]:
        assert f"ok {item['id']}" in stdout
    lint = subprocess.run(
        [sys.executable, str(LINT), str(PLUGIN)],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    assert lint.returncode == 0, lint.stdout + lint.stderr
    assert f"ok {PLUGIN}" in lint.stdout
