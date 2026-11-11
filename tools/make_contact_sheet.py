"""Write _golden/index.html from the PNG files currently in _golden/goldens.

The page is a local overview. Image paths are relative (goldens/<name>). The
PNG list is read from disk on every run; the image count is not a literal.
"""

from __future__ import annotations

import html
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GOLDENS = ROOT / "_golden" / "goldens"
INDEX = ROOT / "_golden" / "index.html"


def list_pngs(directory: Path) -> list[str]:
    names = [
        path.name
        for path in directory.iterdir()
        if path.is_file() and path.suffix.lower() == ".png"
    ]
    return sorted(names, key=str.lower)


def render(names: list[str]) -> str:
    cards: list[str] = []
    for name in names:
        safe = html.escape(name, quote=True)
        cards.append(
            "<figure>"
            f'<img src="goldens/{safe}" alt="{safe}">'
            f"<figcaption>{safe}</figcaption>"
            "</figure>"
        )
    count = len(names)
    body = "\n".join(cards)
    return (
        "<!DOCTYPE html>\n"
        '<html lang="zh-CN">\n'
        "<head>\n"
        '<meta charset="utf-8">\n'
        f"<title>基准图总览 ({count})</title>\n"
        "<style>\n"
        "body { font-family: sans-serif; margin: 16px; background: #111; color: #eee; }\n"
        ".grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 12px; }\n"
        "figure { margin: 0; background: #1c1c1c; padding: 8px; }\n"
        "figure img { width: 100%; height: auto; background: #fff; }\n"
        "figcaption { font-size: 12px; word-break: break-all; margin-top: 6px; }\n"
        "</style>\n"
        "</head>\n"
        "<body>\n"
        f"<h1>基准图总览 ({count})</h1>\n"
        '<div class="grid">\n'
        f"{body}\n"
        "</div>\n"
        "</body>\n"
        "</html>\n"
    )


def listed_in_page(text: str) -> list[str]:
    return re.findall(r'src="goldens/([^"]+)"', text)


def main() -> int:
    if not GOLDENS.is_dir():
        print(f"missing directory: {GOLDENS}", file=sys.stderr)
        return 1
    names = list_pngs(GOLDENS)
    if "--check" in sys.argv[1:]:
        if not INDEX.is_file():
            print(f"missing {INDEX}", file=sys.stderr)
            return 1
        shown = listed_in_page(INDEX.read_text(encoding="utf-8"))
        print(f"png={len(names)} html={len(shown)}")
        if shown != names:
            return 1
        return 0
    INDEX.write_text(render(names), encoding="utf-8", newline="\n")
    print(f"png={len(names)}")
    print(f"wrote {INDEX}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
