"""Compare PNG directories pixel by pixel and write report.json plus heatmaps."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image


class SizeMismatch(Exception):
    def __init__(self, left: tuple[int, int], right: tuple[int, int]) -> None:
        self.left = left
        self.right = right
        super().__init__(
            f"size mismatch: {left[0]}x{left[1]} vs {right[0]}x{right[1]}"
        )


@dataclass(frozen=True)
class ImageDiff:
    diff_pixels: int
    diff_ratio: float
    max_channel_delta: int
    width: int
    height: int


def _load_rgba(path: Path) -> np.ndarray:
    with Image.open(path) as image:
        return np.array(image.convert("RGBA"))


def _delta(left: Path, right: Path) -> np.ndarray:
    left_px = _load_rgba(left)
    right_px = _load_rgba(right)
    if left_px.shape != right_px.shape:
        raise SizeMismatch(
            (int(left_px.shape[1]), int(left_px.shape[0])),
            (int(right_px.shape[1]), int(right_px.shape[0])),
        )
    return np.abs(left_px.astype(np.int16) - right_px.astype(np.int16))


def compare(left: Path, right: Path) -> ImageDiff:
    delta = _delta(Path(left), Path(right))
    changed = np.any(delta != 0, axis=2)
    height, width = (int(changed.shape[0]), int(changed.shape[1]))
    diff_pixels = int(changed.sum())
    pixel_count = width * height
    max_channel_delta = int(delta.max()) if delta.size else 0
    diff_ratio = diff_pixels / pixel_count if pixel_count else 0.0
    return ImageDiff(
        diff_pixels=diff_pixels,
        diff_ratio=diff_ratio,
        max_channel_delta=max_channel_delta,
        width=width,
        height=height,
    )


def _write_heatmap(left: Path, right: Path, dest: Path) -> None:
    magnitude = _delta(left, right).max(axis=2).astype(np.uint8)
    heat = np.zeros((magnitude.shape[0], magnitude.shape[1], 4), dtype=np.uint8)
    heat[..., 0] = magnitude
    heat[..., 3] = 255
    Image.fromarray(heat, mode="RGBA").save(dest)


def _pngs(directory: Path) -> dict[str, Path]:
    found: dict[str, Path] = {}
    for pattern in ("*.png", "*.PNG"):
        for path in directory.glob(pattern):
            if path.is_file():
                found[path.name] = path
    return found


def compare_dirs(left: Path, right: Path, out: Path) -> dict:
    left = Path(left)
    right = Path(right)
    out = Path(out)
    if not left.is_dir():
        raise FileNotFoundError(left)
    if not right.is_dir():
        raise FileNotFoundError(right)
    out.mkdir(parents=True, exist_ok=True)

    left_pngs = _pngs(left)
    right_pngs = _pngs(right)
    pairs: list[dict] = []
    unpaired: list[dict] = []
    for name in sorted(set(left_pngs) | set(right_pngs)):
        if name not in left_pngs or name not in right_pngs:
            status = "missing_left" if name not in left_pngs else "missing_right"
            unpaired.append({"file": name, "status": status})
            print(f"{name} {status}")
            continue
        try:
            diff = compare(left_pngs[name], right_pngs[name])
        except SizeMismatch as exc:
            pairs.append(
                {
                    "file": name,
                    "status": "size_mismatch",
                    "left_size": [exc.left[0], exc.left[1]],
                    "right_size": [exc.right[0], exc.right[1]],
                }
            )
            print(
                f"{name} size_mismatch "
                f"{exc.left[0]}x{exc.left[1]} vs {exc.right[0]}x{exc.right[1]}"
            )
            continue
        heatmap = f"{Path(name).stem}.heatmap.png"
        _write_heatmap(left_pngs[name], right_pngs[name], out / heatmap)
        status = "match" if diff.diff_pixels == 0 else "diff"
        pairs.append(
            {
                "file": name,
                "status": status,
                "diff_pixels": diff.diff_pixels,
                "diff_ratio": diff.diff_ratio,
                "max_channel_delta": diff.max_channel_delta,
                "width": diff.width,
                "height": diff.height,
                "heatmap": heatmap,
            }
        )
        print(
            f"{name} {status} diff_pixels={diff.diff_pixels} "
            f"diff_ratio={diff.diff_ratio:.6f} "
            f"max_channel_delta={diff.max_channel_delta}"
        )

    report = {
        "ok": bool(pairs)
        and not unpaired
        and all(item["status"] == "match" for item in pairs),
        "pairs": pairs,
        "unpaired": unpaired,
    }
    (out / "report.json").write_text(
        json.dumps(report, indent=2) + "\n",
        encoding="utf-8",
    )
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Pair PNGs in two directories and write a pixel-diff report."
    )
    parser.add_argument("left", type=Path)
    parser.add_argument("right", type=Path)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args(argv)
    report = compare_dirs(args.left, args.right, args.out)
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
