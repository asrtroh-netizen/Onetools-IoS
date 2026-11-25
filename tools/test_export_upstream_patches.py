from __future__ import annotations

import subprocess
from pathlib import Path

import pytest

from tools.export_upstream_patches import build_bundle, render_manifest_bytes


def _git(cwd: Path, *args: str) -> None:
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)


def test_build_bundle_exports_and_applies_cleanly(tmp_path: Path) -> None:
    upstream = tmp_path / "upstream-src"
    upstream.mkdir()
    _git(upstream, "init", "-b", "main")
    _git(upstream, "config", "user.email", "test@example.com")
    _git(upstream, "config", "user.name", "Test")
    (upstream / "hello.txt").write_text("base\n", encoding="utf-8")
    _git(upstream, "add", "hello.txt")
    _git(upstream, "commit", "-m", "initial")
    base_rev = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=upstream, text=True
    ).strip()

    work_root = tmp_path / "work"
    work_root.mkdir()
    repo = work_root / "DummyRepo"
    _git(work_root, "clone", str(upstream), str(repo))
    _git(repo, "config", "user.email", "test@example.com")
    _git(repo, "config", "user.name", "Test")
    _git(repo, "checkout", "-b", "onetools")
    (repo / "hello.txt").write_text("base\nonetools\n", encoding="utf-8")
    _git(repo, "add", "hello.txt")
    _git(repo, "commit", "-m", "onetools edit")

    lock_file = work_root / "upstreams.lock.json"
    lock_file.write_text(
        f'[{{"path":"DummyRepo","url":"{upstream.as_posix()}","revision":"{base_rev}"}}]\n',
        encoding="utf-8",
    )

    patches, manifest = build_bundle(
        root=work_root, lock_path=lock_file, repos=("DummyRepo",)
    )
    assert b"+onetools" in patches["DummyRepo"]
    assert render_manifest_bytes(manifest).endswith(b"\n")

    # Verify fresh clone + git apply reproduces exact file content and clean status.
    ci_clone = tmp_path / "ci-clone"
    _git(tmp_path, "clone", str(upstream), str(ci_clone))
    _git(ci_clone, "checkout", "-B", "onetools", base_rev)
    patch_file = tmp_path / "DummyRepo.patch"
    patch_file.write_bytes(patches["DummyRepo"])
    _git(ci_clone, "apply", "--index", str(patch_file))
    _git(ci_clone, "config", "user.email", "ci@example.com")
    _git(ci_clone, "config", "user.name", "CI")
    _git(ci_clone, "commit", "-m", "apply patch")
    assert (ci_clone / "hello.txt").read_text(encoding="utf-8") == "base\nonetools\n"


def test_build_bundle_rejects_wrong_branch(tmp_path: Path) -> None:
    repo = tmp_path / "DummyRepo"
    repo.mkdir()
    _git(repo, "init", "-b", "main")
    _git(repo, "config", "user.email", "test@example.com")
    _git(repo, "config", "user.name", "Test")
    (repo / "a.txt").write_text("1\n", encoding="utf-8")
    _git(repo, "add", "a.txt")
    _git(repo, "commit", "-m", "init")
    rev = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=repo, text=True
    ).strip()

    lock_file = tmp_path / "upstreams.lock.json"
    lock_file.write_text(
        f'[{{"path":"DummyRepo","url":"https://example.invalid/r.git","revision":"{rev}"}}]\n',
        encoding="utf-8",
    )
    with pytest.raises(RuntimeError, match="branch 'onetools'"):
        build_bundle(root=tmp_path, lock_path=lock_file, repos=("DummyRepo",))
