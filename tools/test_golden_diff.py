import json
import sys
from pathlib import Path

import numpy as np
import pytest
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))

import golden_diff


def _save(path: Path, size: tuple[int, int], color: tuple[int, int, int, int]) -> None:
    Image.new("RGBA", size, color).save(path)


def _paint_block(src: Path, dest: Path) -> None:
    with Image.open(src) as image:
        edited = image.convert("RGBA").copy()
    pixels = edited.load()
    for y in range(10):
        for x in range(10):
            pixels[x, y] = (255, 0, 0, 255)
    edited.save(dest)


def test_identical_image_diff_is_zero(tmp_path: Path) -> None:
    left = tmp_path / "same.png"
    right = tmp_path / "same_copy.png"
    _save(left, (32, 24), (10, 20, 30, 255))
    _save(right, (32, 24), (10, 20, 30, 255))
    diff = golden_diff.compare(left, right)
    assert diff.diff_pixels == 0
    assert diff.max_channel_delta == 0
    assert diff.diff_ratio == 0


def test_ten_by_ten_block_diff_is_100_pixels(tmp_path: Path) -> None:
    left = tmp_path / "base.png"
    right = tmp_path / "edited.png"
    _save(left, (40, 40), (0, 0, 0, 255))
    _paint_block(left, right)
    diff = golden_diff.compare(left, right)
    assert diff.diff_pixels == 100
    assert diff.max_channel_delta == 255
    assert diff.diff_ratio == pytest.approx(100 / (40 * 40))


def test_different_size_fails(tmp_path: Path) -> None:
    left = tmp_path / "wide.png"
    right = tmp_path / "narrow.png"
    _save(left, (10, 8), (0, 0, 0, 255))
    _save(right, (9, 8), (0, 0, 0, 255))
    with pytest.raises(golden_diff.SizeMismatch):
        golden_diff.compare(left, right)


def test_directory_report_counts_block_and_rejects_size(tmp_path: Path) -> None:
    left = tmp_path / "left"
    right = tmp_path / "right"
    out = tmp_path / "out"
    left.mkdir()
    right.mkdir()
    _save(left / "block.png", (40, 40), (0, 0, 0, 255))
    _paint_block(left / "block.png", right / "block.png")
    _save(left / "shape.png", (10, 8), (0, 0, 0, 255))
    _save(right / "shape.png", (9, 8), (0, 0, 0, 255))
    report = golden_diff.compare_dirs(left, right, out)
    assert report["ok"] is False
    by_name = {item["file"]: item for item in report["pairs"]}
    assert by_name["block.png"]["diff_pixels"] == 100
    assert by_name["block.png"]["max_channel_delta"] == 255
    heatmap = out / by_name["block.png"]["heatmap"]
    with Image.open(heatmap) as image:
        red = np.array(image)[:, :, 0]
    assert int((red != 0).sum()) == 100
    assert by_name["shape.png"]["status"] == "size_mismatch"
    saved = json.loads((out / "report.json").read_text(encoding="utf-8"))
    assert saved["pairs"][0]["diff_pixels"] == 100
