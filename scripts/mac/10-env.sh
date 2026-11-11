#!/bin/bash
# 未在 Mac 上运行
# T2.1：按总计划第 6 节检查 Mac 工具。缺 Rust 只报告，不让本脚本失败：IDeviceKit 子模块还没拉下来，现编与否要到 T2.5 再看 README。
set -euo pipefail

missing=0

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "FAIL 缺少 $1"
    missing=1
  else
    echo "OK $1"
  fi
}

need_cmd xcodebuild
need_cmd xcodegen
need_cmd bun
need_cmd go
need_cmd python3
need_cmd xcbeautify
need_cmd jq

if ! command -v rustc >/dev/null 2>&1; then
  echo "NOTE 缺少 rustc。总计划第 6 节把 Rust 列为 IDeviceKit 的可能前置；子模块未核实之前不在这里失败。"
else
  echo "OK rustc"
  rustc --version
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

xcode_line=$(xcodebuild -version | sed -n '1p')
xcode_major=$(printf '%s\n' "$xcode_line" | sed -n 's/^Xcode \([0-9][0-9]*\).*$/\1/p')
echo "$xcode_line"
xcodebuild -version | sed -n '2p'
if [[ -z "$xcode_major" || "$xcode_major" -lt 27 ]]; then
  echo "FAIL xcodebuild 主版本需要 27 以上"
  exit 1
fi

xcodegen --version
bun --version
go version
python3 --version
jq --version
xcbeautify --version || xcbeautify -v || true

if ! python3 -c "import yaml"; then
  echo "FAIL python3 没有 PyYAML。Clash-Client 的 configure.py 要用它。可以用 20-clash-client.sh 里的 venv 安装，不要改系统 Python。"
  exit 1
fi

echo "T2.1 工具检查通过"
