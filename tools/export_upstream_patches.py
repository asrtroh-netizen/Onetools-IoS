#!/usr/bin/env python3
"""Export or verify deterministic git patches for mutable upstream repos.

Because /Clash-Client/, /Swipt/, and /Feather/ are gitignored nested repos in the
root repository, GitHub Actions runners hydrate them from upstreams.lock.json and
apply patches/<name>.patch on branch `onetools`.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCK_PATH = ROOT / "upstreams.lock.json"
PATCH_DIR = ROOT / "patches"
MANIFEST_PATH = PATCH_DIR / "manifest.json"
MUTABLE_REPOS = ("Clash-Client", "Swipt", "Feather")


def load_locked_revisions(lock_path: Path = LOCK_PATH) -> dict[str, dict[str, str]]:
    entries = json.loads(lock_path.read_text(encoding="utf-8"))
    by_path: dict[str, dict[str, str]] = {}
    for entry in entries:
        by_path[str(entry["path"])] = {
            "url": str(entry["url"]),
            "revision": str(entry["revision"]),
        }
    return by_path


def git_bytes(repo_dir: Path, *args: str) -> bytes:
    proc = subprocess.run(
        ["git", "-C", str(repo_dir), *args],
        capture_output=True,
        check=False,
    )
    if proc.returncode != 0:
        stderr = proc.stderr.decode("utf-8", errors="replace").strip()
        raise RuntimeError(f"git {' '.join(args)} in {repo_dir} failed: {stderr}")
    return proc.stdout


def compute_repo_patch(repo_dir: Path, base_revision: str) -> tuple[str, bytes]:
    branch = git_bytes(repo_dir, "branch", "--show-current").decode("utf-8").strip()
    if branch != "onetools":
        raise RuntimeError(
            f"{repo_dir.name} must be on branch 'onetools' (got {branch!r})"
        )
    status = git_bytes(
        repo_dir, "status", "--porcelain", "--untracked-files=normal"
    ).decode("utf-8", errors="replace")
    if status.strip():
        raise RuntimeError(
            f"{repo_dir.name} has uncommitted changes; commit or stash first:\n{status}"
        )
    head = git_bytes(repo_dir, "rev-parse", "HEAD").decode("utf-8").strip()
    patch = git_bytes(
        repo_dir,
        "-c",
        "core.quotepath=false",
        "diff",
        "--binary",
        "--full-index",
        f"{base_revision}..HEAD",
    )
    return head, patch


def build_bundle(
    root: Path = ROOT,
    lock_path: Path = LOCK_PATH,
    repos: tuple[str, ...] = MUTABLE_REPOS,
) -> tuple[dict[str, bytes], dict[str, object]]:
    locks = load_locked_revisions(lock_path)
    patches: dict[str, bytes] = {}
    manifest_repos: dict[str, dict[str, object]] = {}

    for name in repos:
        if name not in locks:
            raise KeyError(f"{name} missing from {lock_path}")
        repo_dir = root / name
        base_rev = locks[name]["revision"]
        head_rev, patch_bytes = compute_repo_patch(repo_dir, base_rev)
        patch_rel = f"patches/{name}.patch"
        patches[name] = patch_bytes
        manifest_repos[name] = {
            "url": locks[name]["url"],
            "base_revision": base_rev,
            "head_revision": head_rev,
            "patch_file": patch_rel,
            "patch_bytes": len(patch_bytes),
            "patch_sha256": hashlib.sha256(patch_bytes).hexdigest(),
        }

    manifest: dict[str, object] = {
        "schema_version": 1,
        "repos": manifest_repos,
    }
    return patches, manifest


def render_manifest_bytes(manifest: dict[str, object]) -> bytes:
    return (json.dumps(manifest, indent=2, sort_keys=True) + "\n").encode("utf-8")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Verify patches/*.patch and patches/manifest.json match local HEADs.",
    )
    parser.add_argument(
        "--check-manifest",
        action="store_true",
        help="Verify patches/*.patch SHA-256 digests match patches/manifest.json (CI-safe without nested repos).",
    )
    args = parser.parse_args(argv)

    if args.check_manifest:
        if not MANIFEST_PATH.is_file():
            print("FAIL: missing patches/manifest.json", file=sys.stderr)
            return 1
        doc = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
        repos_meta = doc.get("repos", {})
        for name, meta in repos_meta.items():
            patch_path = ROOT / str(meta["patch_file"])
            if not patch_path.is_file():
                print(f"FAIL: missing {meta['patch_file']}", file=sys.stderr)
                return 1
            raw = patch_path.read_bytes()
            digest = hashlib.sha256(raw).hexdigest()
            if digest != meta["patch_sha256"] or len(raw) != int(meta["patch_bytes"]):
                print(f"FAIL: {meta['patch_file']} digest/size mismatch with manifest.json", file=sys.stderr)
                return 1
        print(f"OK patch manifest verified ({len(repos_meta)} repos)")
        return 0

    patches, manifest = build_bundle()
    expected_manifest = render_manifest_bytes(manifest)

    if args.check:
        mismatches: list[str] = []
        if not MANIFEST_PATH.is_file():
            mismatches.append("missing patches/manifest.json")
        elif MANIFEST_PATH.read_bytes().replace(b"\r\n", b"\n") != expected_manifest:
            mismatches.append("patches/manifest.json is out of date")

        for name, expected_patch in patches.items():
            patch_path = PATCH_DIR / f"{name}.patch"
            if not patch_path.is_file():
                mismatches.append(f"missing patches/{name}.patch")
            elif patch_path.read_bytes() != expected_patch:
                mismatches.append(f"patches/{name}.patch drifted from {name} HEAD")

        if mismatches:
            for item in mismatches:
                print(f"FAIL: {item}", file=sys.stderr)
            print(
                "Run `python tools/export_upstream_patches.py` to refresh patches.",
                file=sys.stderr,
            )
            return 1

        summary = ", ".join(
            f"{name}={len(data)}B" for name, data in patches.items()
        )
        print(f"OK patches synced ({summary})")
        return 0

    PATCH_DIR.mkdir(parents=True, exist_ok=True)
    for name, patch_bytes in patches.items():
        (PATCH_DIR / f"{name}.patch").write_bytes(patch_bytes)
    MANIFEST_PATH.write_bytes(expected_manifest)

    summary = ", ".join(f"{name}={len(data)}B" for name, data in patches.items())
    print(f"Exported patches ({summary}) -> {PATCH_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
