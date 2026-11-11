"""D2：check_samples.py 核对样本 SHA-256。哈希不对必须失败。"""

from __future__ import annotations

import hashlib
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "tools" / "check_samples.py"
SAMPLES = ROOT / "adblock" / "samples"


def _block(name: str, digest: str, *, url: str = "https://example.invalid/fake.plugin") -> str:
    return (
        "<!-- sample -->\n"
        f"file: {name}\n"
        f"url: {url}\n"
        "fetched: 2026-11-11\n"
        f"sha256: {digest}\n"
        "license: MIT\n"
        "covers: \u5f00\u5c4f\u5e7f\u544a\n"
        "why: temporary fixture\n"
        "<!-- /sample -->\n"
    )


def _run(samples: Path, sources: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [
            sys.executable,
            str(CHECKER),
            "--samples",
            str(samples),
            "--sources",
            str(sources),
        ],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )


def test_wrong_hash_fails(tmp_path: Path) -> None:
    body = b"[Rule]\nDOMAIN,ads.example,REJECT\n"
    plugin = tmp_path / "fake.plugin"
    plugin.write_bytes(body)
    digest = hashlib.sha256(body).hexdigest()
    wrong = ("0" if digest[-1] != "0" else "1")
    bad = digest[:-1] + wrong
    sources = tmp_path / "SOURCES.md"
    sources.write_text("# fixture\n\n" + _block("fake.plugin", bad), encoding="utf-8")
    proc = _run(tmp_path, sources)
    assert proc.returncode != 0
    text = proc.stdout + proc.stderr
    assert "MISMATCH" in text
    assert "fake.plugin" in text


def test_right_hash_passes(tmp_path: Path) -> None:
    body = b"[Rule]\nDOMAIN,ads.example,REJECT\n"
    (tmp_path / "fake.plugin").write_bytes(body)
    digest = hashlib.sha256(body).hexdigest()
    sources = tmp_path / "SOURCES.md"
    sources.write_text("# fixture\n\n" + _block("fake.plugin", digest), encoding="utf-8")
    proc = _run(tmp_path, sources)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert f"ok fake.plugin {digest}" in proc.stdout


def test_repository_samples_match_sources() -> None:
    sources = SAMPLES / "SOURCES.md"
    proc = _run(SAMPLES, sources)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    oks = [ln for ln in proc.stdout.splitlines() if ln.startswith("ok ")]
    assert 5 <= len(oks) <= 10
    text = sources.read_text(encoding="utf-8")
    for kind in ("\u5f00\u5c4f\u5e7f\u544a", "\u4fe1\u606f\u6d41\u5e7f\u544a", "\u89c6\u9891\u8d34\u7247"):
        assert kind in text
    assert text.count("fetched: 2026-11-11") == len(oks)
