"""核对 adblock/samples/SOURCES.md 里记下的 SHA-256。不一致就非零退出。"""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SAMPLES = ROOT / "adblock" / "samples"
FIELDS = ("file", "url", "fetched", "sha256", "license", "covers", "why")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


def parse_sources(text: str) -> list[dict[str, str]]:
    parts = text.split("<!-- sample -->")
    samples: list[dict[str, str]] = []
    for part in parts[1:]:
        body = part.split("<!-- /sample -->", 1)[0]
        fields: dict[str, str] = {}
        for raw in body.splitlines():
            line = raw.strip()
            if not line or line.startswith("#") or ":" not in line:
                continue
            key, value = line.split(":", 1)
            key = key.strip()
            if key in FIELDS:
                fields[key] = value.strip()
        if fields:
            samples.append(fields)
    return samples


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def safe_sample_path(samples: Path, rel: str) -> Path | None:
    if not rel or rel.startswith(("/", "\\")) or ":" in rel:
        return None
    candidate = (samples / rel).resolve()
    root = samples.resolve()
    if candidate != root and root not in candidate.parents:
        return None
    return candidate


def check(samples_dir: Path, sources_path: Path) -> int:
    if not sources_path.is_file():
        print(f"MISSING {sources_path}", file=sys.stderr)
        return 1
    samples = parse_sources(sources_path.read_text(encoding="utf-8"))
    if not samples:
        print("MISSING samples in SOURCES.md", file=sys.stderr)
        return 1
    failed = 0
    for item in samples:
        name = item.get("file", "")
        for field in ("file", "url", "fetched", "sha256", "license"):
            if not item.get(field):
                print(f"MISSING {name or '?'} field={field}", file=sys.stderr)
                failed += 1
                name = ""
                break
        if not name:
            continue
        expected = item["sha256"].lower()
        path = safe_sample_path(samples_dir, name)
        if path is None:
            print(f"MISSING {name} unsafe path", file=sys.stderr)
            failed += 1
            continue
        if not SHA256_RE.fullmatch(expected):
            print(f"MISMATCH {name} expected={item['sha256']} actual=invalid-sha256", file=sys.stderr)
            failed += 1
            continue
        if not path.is_file():
            print(f"MISSING {name}", file=sys.stderr)
            failed += 1
            continue
        actual = file_sha256(path)
        if actual != expected:
            print(f"MISMATCH {name} expected={expected} actual={actual}", file=sys.stderr)
            failed += 1
            continue
        print(f"ok {name} {actual}")
    return 1 if failed else 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Check Loon sample SHA-256 values")
    parser.add_argument("--samples", type=Path, default=DEFAULT_SAMPLES)
    parser.add_argument("--sources", type=Path, default=None)
    args = parser.parse_args(argv)
    sources = args.sources if args.sources is not None else args.samples / "SOURCES.md"
    return check(args.samples, sources)


if __name__ == "__main__":
    sys.exit(main())
