#!/bin/bash
# 未在 Mac 上运行
# T2.5 Feather 原版。只初始化子模块。
# 撰写时 Feather/Zsign 与 Feather/IDeviceKitten 都是空目录，README 不在本机，所以这里不写编译命令。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/Feather"

git submodule update --init --recursive

echo "先读 Zsign/README 和 IDeviceKitten/README 再编译"

if [[ ! -f Zsign/README && ! -f Zsign/README.md ]]; then
  echo "Zsign/README 不在本机。目录若仍为空，子模块未初始化。"
fi
if [[ ! -f IDeviceKitten/README && ! -f IDeviceKitten/README.md ]]; then
  echo "IDeviceKitten/README 不在本机。目录若仍为空，子模块未初始化。"
fi

echo "本脚本到此为止，不编译。"
