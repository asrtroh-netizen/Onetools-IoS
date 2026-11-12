#!/bin/bash
# 未在 Mac 上运行
# T2.5 Feather 原版。只检查 zipball，不编译。
# Zsign 与 IDeviceKitten 已用 zipball 就位，没有 .git。
# 对照 docs/findings/submodules.md 与 .mimocode/r0-6-submodules-ready.txt：
# Zsign 247 files / 29 dirs / 73644372 bytes；IDeviceKitten 25 files / 13 dirs / 46693 bytes。
# 文件在就跳过拉取并打印现状；文件不在就说明并失败。不要跑 git submodule update。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT/Feather"

status=0

check_tree() {
  local dir="$1"
  local label="$2"
  local expected="$3"
  shift 3
  local missing=0
  local name
  if [[ ! -d "$dir" ]]; then
    echo "FAIL 缺少目录 $dir"
    echo "FAIL $label 未按 zipball 就位。见 docs/findings/submodules.md 与 .mimocode/r0-6-submodules-ready.txt。不要跑 git submodule update。"
    return 1
  fi
  for name in "$@"; do
    if [[ ! -f "$dir/$name" ]]; then
      echo "FAIL 缺少 $dir/$name"
      missing=1
    fi
  done
  if [[ -e "$dir/.git" ]]; then
    echo "NOTE $dir 存在 .git。本脚本仍然不拉取。"
  else
    echo "OK $dir 没有 .git"
  fi
  if [[ "$missing" -ne 0 ]]; then
    echo "FAIL $label 未按 zipball 就位。见 docs/findings/submodules.md 与 .mimocode/r0-6-submodules-ready.txt。不要跑 git submodule update。"
    return 1
  fi
  local file_count
  file_count="$(find "$dir" -type f | wc -l | tr -d '[:space:]')"
  echo "OK $label 已就位：${file_count} 个文件（对照记录 ${expected}）。跳过拉取。"
}

check_tree Zsign "Zsign" "247 files / 29 dirs / 73644372 bytes" README.md Package.swift LICENSE || status=1
check_tree IDeviceKitten "IDeviceKitten" "25 files / 13 dirs / 46693 bytes" README.md Package.swift LICENSE || status=1

if [[ "$status" -ne 0 ]]; then
  exit 1
fi

echo "先读 Zsign/README.md 和 IDeviceKitten/README.md 再决定怎么编译。本脚本到此为止，不编译。"
