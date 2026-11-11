"""列出 lib/design 下的 Dart 文件，核对 _golden/coverage.json。

每次从磁盘重新列文件。分母是这次列到的个数，不写死。
每个文件要么指向已有的场景或夹具，要么写明排除原因。
标准输出一行 covered/total。
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESIGN = ROOT.parent / "ONEWIFIX" / "IOS" / "lib" / "design"
GOLDEN = ROOT / "_golden"
COVERAGE = GOLDEN / "coverage.json"


def list_dart_files(design: Path) -> list[str]:
    """Return posix paths of .dart files under design, relative to that directory."""
    design = Path(design)
    if not design.is_dir():
        return []
    found: list[str] = []
    for path in design.rglob("*.dart"):
        if path.is_file():
            found.append(path.relative_to(design).as_posix())
    return sorted(found)


def scene_exists(golden: Path, name: str) -> bool:
    if not isinstance(name, str) or not name or name != Path(name).name:
        return False
    if "/" in name or "\\" in name:
        return False
    scenes = golden / "test" / "scenes"
    if scenes.is_dir():
        for path in scenes.glob("*_test.dart"):
            stem = path.name[: -len("_test.dart")]
            if stem == name:
                return True
            if len(stem) > 2 and stem[1] == "_" and stem[0] in "abcd" and stem[2:] == name:
                return True
    return (golden / "goldens" / f"{name}.light.png").is_file()


def fixture_exists(golden: Path, name: str) -> bool:
    if not isinstance(name, str) or not name or name != Path(name).name:
        return False
    if "/" in name or "\\" in name:
        return False
    return (golden / "fixtures" / name).is_file()


def _entry_errors(golden: Path, rel: str, entry: object) -> list[str]:
    if not isinstance(entry, dict):
        return [f"UNCOVERED {rel}: entry is not an object"]
    exclude = entry.get("exclude", "")
    if isinstance(exclude, str) and exclude.strip():
        return []
    scenes = entry.get("scenes") or []
    fixtures = entry.get("fixtures") or []
    if not isinstance(scenes, list) or not isinstance(fixtures, list):
        return [f"UNCOVERED {rel}: scenes and fixtures must be lists"]
    if not scenes and not fixtures:
        return [f"UNCOVERED {rel}: no scene, fixture, or exclude reason"]
    problems: list[str] = []
    for name in scenes:
        if not scene_exists(golden, name):
            problems.append(f"missing scene {name}")
    for name in fixtures:
        if not fixture_exists(golden, name):
            problems.append(f"missing fixture {name}")
    if problems:
        return [f"UNCOVERED {rel}: {'; '.join(problems)}"]
    return []


def check(design: Path, golden: Path, coverage_path: Path) -> tuple[int, int, list[str]]:
    """Re-list design Dart files and return covered count, total, and errors."""
    design = Path(design)
    golden = Path(golden)
    coverage_path = Path(coverage_path)
    files = list_dart_files(design)
    errors: list[str] = []
    if not design.is_dir():
        errors.append(f"MISSING design {design}")
    if not coverage_path.is_file():
        errors.append(f"MISSING coverage {coverage_path}")
        return 0, len(files), errors

    try:
        payload = json.loads(coverage_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append(f"BAD coverage {coverage_path}: {exc}")
        return 0, len(files), errors
    mapped = payload.get("files") if isinstance(payload, dict) else None
    if not isinstance(mapped, dict):
        errors.append("BAD coverage: files is not an object")
        return 0, len(files), errors

    on_disk = set(files)
    for rel in sorted(set(mapped) - on_disk):
        errors.append(f"EXTRA {rel}")

    covered = 0
    for rel in files:
        entry = mapped.get(rel)
        if entry is None:
            errors.append(f"UNCOVERED {rel}")
            continue
        entry_errors = _entry_errors(golden, rel, entry)
        if entry_errors:
            errors.extend(entry_errors)
            continue
        covered += 1
    return covered, len(files), errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Check lib/design golden coverage")
    parser.add_argument("--design", type=Path, default=DESIGN)
    parser.add_argument("--golden", type=Path, default=GOLDEN)
    parser.add_argument("--coverage", type=Path, default=COVERAGE)
    args = parser.parse_args(argv)
    covered, total, errors = check(args.design, args.golden, args.coverage)
    print(f"{covered}/{total}")
    for item in errors:
        print(item, file=sys.stderr)
    return 0 if covered == total and not errors else 1


if __name__ == "__main__":
    sys.exit(main())
