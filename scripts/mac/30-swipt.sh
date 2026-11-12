#!/bin/bash
# 未在 Mac 上运行
# T2.4 Swipt 原版。
# DeveloperDiskImage 已用 zipball 就位，没有 .git。
# 对照 docs/findings/submodules.md 与 .mimocode/r0-6-submodules-ready.txt：
# 6 个文件 / 18046187 字节，路径 Swipt/Swipt/Resources/DeveloperDiskImage
# （Swipt/.gitmodules 的 path = Swipt/Resources/DeveloperDiskImage，相对 Swipt 仓库）。
# 文件在就跳过拉取并打印现状；文件不在就说明并失败。不要跑 git submodule update。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DDI="$ROOT/Swipt/Swipt/Resources/DeveloperDiskImage"

echo "检查 DeveloperDiskImage（zipball，不拉取）"

markers=(
  README.md
  Image.dmg
  BuildManifest.plist
  Image.dmg.trustcache
  Image.dmg.root_hash
  Image.dmg.cryptex_info
)

missing=0
for name in "${markers[@]}"; do
  if [[ ! -f "$DDI/$name" ]]; then
    echo "FAIL 缺少 $DDI/$name"
    missing=1
  fi
done

if [[ -e "$DDI/.git" ]]; then
  echo "NOTE $DDI 存在 .git。本脚本仍然不拉取。"
else
  echo "OK $DDI 没有 .git"
fi

if [[ "$missing" -ne 0 ]]; then
  echo "FAIL DeveloperDiskImage 未按 zipball 就位。见 docs/findings/submodules.md 与 .mimocode/r0-6-submodules-ready.txt。不要跑 git submodule update。"
  exit 1
fi

file_count="$(find "$DDI" -type f | wc -l | tr -d '[:space:]')"
echo "OK DeveloperDiskImage 已就位：${file_count} 个文件（对照记录 6 files / 18046187 bytes）。跳过拉取。"

cd "$ROOT/Swipt"

make lib
bun dev frameworks
make build_ios

echo "T2.4 编译步骤结束。装机和 LocalDevVPN 基线是手工步骤，见 docs/superpowers/plans/2026-11-11-mac-stage.md 的 M4。"
