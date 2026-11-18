from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

import gen_icon_codepoints


def test_render_swift_has_121_icons() -> None:
    rendered, count = gen_icon_codepoints.render_swift()
    assert count == 121
    assert "public static let add: UInt32 =" in rendered
    assert 'OneIconDescriptor(name: "eye", codePoint: 0xF424, family: .cupertinoIcons)' in rendered
    assert 'OneIconDescriptor(name: "eye_slash", codePoint: 0xF662, family: .cupertinoIcons)' in rendered


def test_check_detects_drift(tmp_path: Path) -> None:
    target = tmp_path / "MaterialIconCodepoints.swift"
    assert gen_icon_codepoints.main(["--check", "--out", str(target)]) == 1
    assert gen_icon_codepoints.main(["--out", str(target)]) == 0
    assert gen_icon_codepoints.main(["--check", "--out", str(target)]) == 0
    target.write_text(target.read_text(encoding="utf-8") + "// drift\n", encoding="utf-8")
    assert gen_icon_codepoints.main(["--check", "--out", str(target)]) == 1
