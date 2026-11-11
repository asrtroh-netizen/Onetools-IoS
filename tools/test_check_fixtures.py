import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import check_fixtures

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "_golden" / "fixtures"


def test_missing_tokens_fails(tmp_path: Path) -> None:
    errors = check_fixtures.check(tmp_path)
    assert errors
    assert any("tokens.json" in item for item in errors)


def test_repo_a3_fixtures_pass() -> None:
    errors = check_fixtures.check(FIXTURES)
    assert errors == []


def test_rereads_disk_and_rejects_bad_stroke_alpha(tmp_path: Path) -> None:
    fixture_dir = tmp_path / "fixtures"
    fixture_dir.mkdir()
    for name in ("tokens.json", "typography.json"):
        (fixture_dir / name).write_text(
            (FIXTURES / name).read_text(encoding="utf-8"), encoding="utf-8"
        )
    assert check_fixtures.check(fixture_dir) == []

    payload = json.loads((fixture_dir / "tokens.json").read_text(encoding="utf-8"))
    payload["resolved"]["light"]["stroke"]["alpha"] = "0.6000"
    (fixture_dir / "tokens.json").write_text(
        json.dumps(payload, indent=2) + "\n", encoding="utf-8"
    )
    errors = check_fixtures.check(fixture_dir)
    assert errors
    assert any("stroke" in item and "alpha" in item for item in errors)


def test_rejects_bad_dock_edge(tmp_path: Path) -> None:
    fixture_dir = tmp_path / "fixtures"
    fixture_dir.mkdir()
    for src in FIXTURES.glob("*.json"):
        (fixture_dir / src.name).write_text(src.read_text(encoding="utf-8"), encoding="utf-8")
    payload = json.loads((fixture_dir / "dock_edges.json").read_text(encoding="utf-8"))
    payload["transitions"][0]["samples"][5]["left"] += 1
    (fixture_dir / "dock_edges.json").write_text(
        json.dumps(payload) + "\n", encoding="utf-8"
    )
    errors = check_fixtures.check(fixture_dir)
    assert any("left" in item for item in errors)


def test_rejects_bad_layout_height(tmp_path: Path) -> None:
    fixture_dir = tmp_path / "fixtures"
    fixture_dir.mkdir()
    for name in ("tokens.json", "typography.json"):
        (fixture_dir / name).write_text(
            (FIXTURES / name).read_text(encoding="utf-8"), encoding="utf-8"
        )
    constants = check_fixtures._glass_constants(check_fixtures._read(check_fixtures.GLASS_PATH))
    slide = check_fixtures._slide_ms(check_fixtures._read(check_fixtures.DOCK_PATH))
    rect = {"left": 0, "top": 1, "width": 2, "height": 3}
    indicator = {
        "left": 4,
        "top": 5,
        "width": 6,
        "height": constants["dockIndicatorHeight"],
    }
    payload = {
        "dock": {
            "height": constants["dockHeight"],
            "radius": constants["radiusDock"],
            "bottomGap": constants["dockBottomGap"],
            "blur": constants["blurDock"],
            "tabInset": constants["dockTabInset"],
            "indicatorHeight": constants["dockIndicatorHeight"],
            "slideMs": slide,
        },
        "scenes": {
            name: {"light": {"dock": rect, "indicator": indicator}, "dark": {"dock": rect, "indicator": indicator}}
            for name in check_fixtures.D_SCENES
        },
    }
    layout = fixture_dir / "layout.json"
    layout.write_text(json.dumps(payload), encoding="utf-8")
    assert check_fixtures.check(fixture_dir) == []
    payload["dock"]["height"] = constants["dockHeight"] + 1
    layout.write_text(json.dumps(payload), encoding="utf-8")
    errors = check_fixtures.check(fixture_dir)
    assert any("height" in item and "dockHeight" in item for item in errors)


def test_rejects_bad_glass_constant(tmp_path: Path) -> None:
    fixture_dir = tmp_path / "fixtures"
    fixture_dir.mkdir()
    for name in ("tokens.json", "typography.json"):
        (fixture_dir / name).write_text(
            (FIXTURES / name).read_text(encoding="utf-8"), encoding="utf-8"
        )
    payload = json.loads((fixture_dir / "tokens.json").read_text(encoding="utf-8"))
    payload["glass"]["radiusCard"] = payload["glass"]["radiusCard"] + 1
    (fixture_dir / "tokens.json").write_text(
        json.dumps(payload, indent=2) + "\n", encoding="utf-8"
    )
    errors = check_fixtures.check(fixture_dir)
    assert any("radiusCard" in item for item in errors)
