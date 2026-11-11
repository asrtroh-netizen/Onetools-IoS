"""把 Clash 环回的源文件和测试复制进 _harness/ClashLogic，或核对副本逐字节相同。"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PAIRS = (
    (
        ROOT
        / "Clash-Client/apple/ClashClientUI/Sources/ClashClientUI/Features/Tunnel/ClashTunnelRouteShaping.swift",
        ROOT / "_harness/ClashLogic/Sources/ClashClientUI/ClashTunnelRouteShaping.swift",
    ),
    (
        ROOT / "Clash-Client/apple/ClashClientUI/Tests/ClashClientUITests/SwiptLoopbackTests.swift",
        ROOT / "_harness/ClashLogic/Tests/ClashClientUITests/SwiptLoopbackTests.swift",
    ),
)


def copy_all() -> int:
    for src, dst in PAIRS:
        if not src.is_file():
            print(f"missing source {src.relative_to(ROOT)}")
            return 1
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(src.read_bytes())
        print(f"copied {src.relative_to(ROOT)} -> {dst.relative_to(ROOT)}")
    return 0


def check_all() -> int:
    failed = 0
    for src, dst in PAIRS:
        rel_src = src.relative_to(ROOT)
        rel_dst = dst.relative_to(ROOT)
        if not src.is_file() or not dst.is_file():
            print(f"missing {rel_src} or {rel_dst}")
            failed += 1
            continue
        if src.read_bytes() != dst.read_bytes():
            print(f"differ {rel_src}")
            failed += 1
        else:
            print(f"same {rel_src}")
    return 1 if failed else 0


def main(argv: list[str]) -> int:
    if "--check" in argv:
        return check_all()
    return copy_all()


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
