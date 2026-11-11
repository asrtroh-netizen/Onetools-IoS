"""D3：loon_lint.py 只放过 Clash-Client 解析器会收下的写法。每种写法要对上源码行。"""

from __future__ import annotations

import importlib.util
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LINTER = ROOT / "tools" / "loon_lint.py"

# 每条通过夹具都要在 loon_lint.CITATIONS 里有同名出处。
PASSING = """\
#!name=OneTools CN Ads
#!desc=fixture
#!author=lane-d
#!system=iOS,iPadOS
# hash comment
// slash comment
; semi comment

[Argument]
Enabled = switch,true,false,tag=开关,desc=说明

[Rule]
DOMAIN,ads.example.com,REJECT
DOMAIN-SUFFIX,.ads.example.com,REJECT
DOMAIN-KEYWORD,advert,REJECT-DROP
DOMAIN-WILDCARD,*.ads.example.com,REJECT-IMG
IP-CIDR,203.0.113.0/24,REJECT,no-resolve
IP-CIDR6,2001:db8::/32,REJECT
URL-REGEX,^https?://ads\\.example\\.com,REJECT
USER-AGENT,AdsBot,REJECT
PROTOCOL,TCP,REJECT
GEOSITE,category-ads,REJECT
NETWORK,tcp,DIRECT
DST-PORT,443,PROXY
DOMAIN,log.example.com,REJECT # inline

[Rewrite]
^https?://ads\\.example\\.com/banner reject
^https?://ads\\.example\\.com/img reject-dict
^https?://ads\\.example\\.com/go 302 https://example.com/blank

[URL Rewrite]
^https?://ads\\.example\\.com/tmp 307 https://example.com/blank

[Script]
http-response ^https?://ads\\.example\\.com/api script-path=https://example.com/ads.js, requires-body=true, timeout=60, tag=ads
http-request ^https?://ads\\.example\\.com/req script-path=https://example.com/req.js, enable={Enabled}
cron @daily script-path=https://example.com/cron.js, tag=daily
generic script-path=https://example.com/generic.js
network-changed script-path=https://example.com/net.js

[MITM]
hostname = %APPEND% *.example.com, -ads.example.com, example.com
h2 = true
"""


def _load():
    assert LINTER.is_file(), "loon_lint.py missing"
    spec = importlib.util.spec_from_file_location("loon_lint", LINTER)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def _run(plugin: Path) -> subprocess.CompletedProcess[str]:
    assert LINTER.is_file(), "loon_lint.py missing"
    return subprocess.run(
        [sys.executable, str(LINTER), str(plugin)],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )


def _write(tmp_path: Path, body: str, name: str = "fixture.plugin") -> Path:
    path = tmp_path / name
    path.write_text(body, encoding="utf-8")
    return path


def test_passing_forms(tmp_path: Path) -> None:
    proc = _run(_write(tmp_path, PASSING))
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "ok " in proc.stdout


def test_citations_match_parser_lines() -> None:
    module = _load()
    citations = module.CITATIONS
    required = {
        "metadata-hashbang",
        "metadata-name",
        "metadata-system",
        "comment-line",
        "section-header",
        "section-key",
        "rule",
        "rule-domain",
        "rule-domain-suffix-dot",
        "rule-ip-cidr",
        "rule-dst-port",
        "rule-url-regex",
        "rule-user-agent",
        "rule-protocol",
        "rule-policy",
        "rule-proxy",
        "rule-direct",
        "rule-reject-drop",
        "rule-no-resolve",
        "rule-domain-wildcard",
        "rule-ip-suffix",
        "rule-geoip",
        "rule-src-ip",
        "rule-src-port",
        "rewrite",
        "rewrite-reject-word",
        "rewrite-reject-action",
        "rewrite-302",
        "rewrite-307",
        "rewrite-header",
        "rewrite-reject-dict",
        "rewrite-reject-video",
        "mitm",
        "mitm-hostname",
        "mitm-h2",
        "mitm-host-entry",
        "mitm-append",
        "mitm-insert",
        "script",
        "script-http",
        "script-loon-types",
        "script-address",
        "script-options",
        "script-cron",
        "argument",
        "argument-control",
        "reject-not-a-module",
        "reject-before-section",
        "reject-section",
        "reject-proxy",
        "reject-type-parser",
        "reject-newer-syntax",
        "reject-unknown-rule",
        "reject-policy-not-found",
        "reject-bad-argument",
        "reject-mitm-other",
    }
    missing = required - set(citations)
    assert not missing, sorted(missing)
    for form, (rel, line, needle) in citations.items():
        rows = (ROOT / rel).read_text(encoding="utf-8").splitlines()
        assert 1 <= line <= len(rows), form
        assert needle in rows[line - 1], f"{form}: {rel}:{line} has {rows[line - 1]!r}"


def _expect_fail(tmp_path: Path, body: str, needle: str) -> None:
    proc = _run(_write(tmp_path, body))
    assert proc.returncode != 0
    text = proc.stdout + proc.stderr
    assert needle in text, text


def test_no_section_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "#!name=only\n# comment\n", "not a module")


def test_line_before_section_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "DOMAIN,a.com,REJECT\n[Rule]\nDOMAIN,b.com,REJECT\n", "unreadable")


def test_unknown_section_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "[Map Local]\n^https://a.com file:///tmp/a\n", "section not supported")


def test_proxy_section_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "[Proxy]\nname = direct\n", "proxies")


def test_unknown_rule_type_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "[Rule]\nNOT-A-TYPE,example.com,REJECT\n", "unsupported rule type")


def test_named_policy_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "[Rule]\nDOMAIN,example.com,MyGroup\n", "policy not found")


def test_type_parser_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "#!type=parser\n[Rule]\nDOMAIN,example.com,REJECT\n", "parser")


def test_other_platform_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "#!system=macOS\n[Rule]\nDOMAIN,example.com,REJECT\n", "other platform")


def test_newer_script_fails(tmp_path: Path) -> None:
    _expect_fail(
        tmp_path,
        '[Script]\nresponse if ^https://a.com then script("https://example.com/a.js")\n',
        "newer syntax",
    )


def test_bad_argument_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "[Argument]\nName = toggle,true\n", "unreadable")


def test_bad_mitm_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "[MITM]\nh2 = maybe\n", "unreadable")
    _expect_fail(tmp_path, "[MITM]\nca-p12 = secret\n", "setting not supported")
    _expect_fail(tmp_path, "[MITM]\nhostname = bad host\n", "invalid host")


def test_bad_rewrite_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "[Rewrite]\n^https://a\\.example bounce\n", "unsupported rewrite")
    _expect_fail(tmp_path, "[Rewrite]\n( reject\n", "invalid pattern")


def test_script_without_address_fails(tmp_path: Path) -> None:
    _expect_fail(tmp_path, "[Script]\nhttp-response ^https://a\\.example tag=only\n", "script")


def test_dns_script_fails(tmp_path: Path) -> None:
    _expect_fail(
        tmp_path,
        "[Script]\ndns script-path=https://example.com/a.js\n",
        "dns",
    )


def test_boxjs_script_fails(tmp_path: Path) -> None:
    _expect_fail(
        tmp_path,
        "[Script]\nhttp-request ^https://a\\.example script-path=https://example.com/BoxJS/a.js\n",
        "boxjs",
    )
