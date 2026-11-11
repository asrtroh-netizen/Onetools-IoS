#!/bin/bash
# 未在 Mac 上运行
# T2.2 Clash-Client：建 venv、装 PyYAML、bootstrap、configure。
# configure.py 会改 apple/ClashClient/project.yml，再调 xcodegen 和 scripts/build_cli.py（go build）。
# 本脚本不调用 xcodebuild。Team ID 只从环境变量 TEAM_ID 读，不写死。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
missing=0

if [[ -z "${BUNDLE_BASE:-}" ]]; then
  echo "FAIL 缺少环境变量 BUNDLE_BASE"
  missing=1
fi
if [[ -z "${TEAM_ID:-}" ]]; then
  echo "FAIL 缺少环境变量 TEAM_ID"
  missing=1
fi
if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

cd "$ROOT/Clash-Client"
python3 -m venv .build/python-env
# shellcheck disable=SC1091
source .build/python-env/bin/activate
python3 -m pip install PyYAML
python3 scripts/bootstrap.py
python3 scripts/configure.py --bundle-base "$BUNDLE_BASE" --team "$TEAM_ID"

echo "T2.2 脚本停在 configure.py。没有调用 xcodebuild。"
echo "bootstrap 预期最后一行：Public dependencies verified. Run python3 scripts/configure.py, then build an app scheme."
echo "下一步在 Xcode 里编 ClashiOS 并装机，见 docs/superpowers/plans/2026-11-11-mac-stage.md 的 M3。"
echo "装机前可再查：rg -n \"LoopbackAddress\" .build/dependencies/kernel/listener/config/tun.go"
echo "并看 .build/dependencies/kernel/third_party/sing-tun/ 下有没有 ip_rewrite.go，结果记进 docs/decisions/G1-bringup.md。"
