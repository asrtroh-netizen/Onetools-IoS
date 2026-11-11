"""A10：check_golden_coverage.py 每次从磁盘重列 lib/design 下的 Dart 文件。分母不写死。"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import check_golden_coverage

ROOT = Path(__file__).resolve().parents[1]
DESIGN = ROOT.parent / "ONEWIFIX" / "IOS" / "lib" / "design"
GOLDEN = ROOT / "_golden"
COVERAGE = GOLDEN / "coverage.json"


def _write_coverage(path: Path, files: dict) -> None:
    path.write_text(
        json.dumps({"files": files}, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _design(tmp_path: Path, names: list[str]) -> Path:
    design = tmp_path / "design"
    for name in names:
        target = design / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text("class X {}\n", encoding="utf-8")
    return design


def test_denominator_follows_files_on_disk(tmp_path: Path, capsys) -> None:
    design = _design(tmp_path, ["one/a.dart"])
    golden = tmp_path / "golden"
    (golden / "fixtures").mkdir(parents=True)
    (golden / "fixtures" / "tokens.json").write_text("{}", encoding="utf-8")
    coverage = tmp_path / "coverage.json"
    _write_coverage(coverage, {"one/a.dart": {"fixtures": ["tokens.json"]}})

    code = check_golden_coverage.main(
        ["--design", str(design), "--golden", str(golden), "--coverage", str(coverage)]
    )
    assert code == 0
    assert capsys.readouterr().out.strip() == "1/1"

    (design / "widgets").mkdir()
    (design / "widgets" / "extra.dart").write_text("class Extra {}\n", encoding="utf-8")
    code = check_golden_coverage.main(
        ["--design", str(design), "--golden", str(golden), "--coverage", str(coverage)]
    )
    captured = capsys.readouterr()
    assert code != 0
    assert captured.out.strip() == "1/2"
    assert "widgets/extra.dart" in captured.err


def test_blank_exclude_does_not_count(tmp_path: Path) -> None:
    design = _design(tmp_path, ["one/a.dart"])
    golden = tmp_path / "golden"
    golden.mkdir()
    coverage = tmp_path / "coverage.json"
    _write_coverage(coverage, {"one/a.dart": {"exclude": "   "}})
    covered, total, errors = check_golden_coverage.check(design, golden, coverage)
    assert (covered, total) == (0, 1)
    assert any("one/a.dart" in item for item in errors)


def test_missing_scene_does_not_count(tmp_path: Path) -> None:
    design = _design(tmp_path, ["widgets/page_head.dart"])
    golden = tmp_path / "golden"
    (golden / "test" / "scenes").mkdir(parents=True)
    coverage = tmp_path / "coverage.json"
    _write_coverage(coverage, {"widgets/page_head.dart": {"scenes": ["page_head"]}})
    covered, total, errors = check_golden_coverage.check(design, golden, coverage)
    assert (covered, total) == (0, 1)
    assert any("page_head" in item for item in errors)


def test_exclude_reason_counts_without_scene(tmp_path: Path, capsys) -> None:
    design = _design(tmp_path, ["one/liquid_glass.dart"])
    golden = tmp_path / "golden"
    golden.mkdir()
    coverage = tmp_path / "coverage.json"
    _write_coverage(
        coverage,
        {"one/liquid_glass.dart": {"exclude": "没有调用方，也没有场景或夹具。"}},
    )
    code = check_golden_coverage.main(
        ["--design", str(design), "--golden", str(golden), "--coverage", str(coverage)]
    )
    assert code == 0
    assert capsys.readouterr().out.strip() == "1/1"


def test_repository_coverage_matches_disk(capsys) -> None:
    files = check_golden_coverage.list_dart_files(DESIGN)
    assert files
    code = check_golden_coverage.main(
        ["--design", str(DESIGN), "--golden", str(GOLDEN), "--coverage", str(COVERAGE)]
    )
    captured = capsys.readouterr()
    assert captured.out.strip() == f"{len(files)}/{len(files)}"
    assert code == 0, captured.out + captured.err
    payload = json.loads(COVERAGE.read_text(encoding="utf-8"))
    assert set(payload["files"]) == set(files)


def test_checker_does_not_hardcode_denominator() -> None:
    text = (ROOT / "tools" / "check_golden_coverage.py").read_text(encoding="utf-8")
    assert "32/32" not in text
    assert "print(32" not in text
