#!/bin/bash
# 未在 Mac 上运行
# T2.4 Swipt 原版。子模块路径见 Swipt/.gitmodules：Swipt/Resources/DeveloperDiskImage。
# 撰写时该目录为空（未初始化）。本脚本在 Mac 上执行时才拉子模块。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/Swipt"

git submodule update --init
make lib
bun dev frameworks
make build_ios

echo "T2.4 编译步骤结束。装机和 LocalDevVPN 基线是手工步骤，见 docs/superpowers/plans/2026-11-11-mac-stage.md 的 M4。"
