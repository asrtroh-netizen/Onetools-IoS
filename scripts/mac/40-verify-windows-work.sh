#!/bin/bash
# 未在 Mac 上运行
# 在 Mac 上跑这 12 小时里标「未编译」的 Swift 单测。
# 预期：_harness/ClashLogic 用 swift test。OneUI 的预期命令是下面的 xcodebuild。
# swift test --package-path OneUI 在 Mac 主机上会去编 iOS 目标，留作对照，不是预期路径。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

echo "预期命令：swift test --package-path _harness/ClashLogic"
swift test --package-path _harness/ClashLogic

echo "对照命令：swift test --package-path OneUI"
echo "macOS 分支含 iOS 15 的 OneUI 和 OneUICoreTests。总计划 P4：Mac 主机上的 swift test 会去编 macOS，所以这条不是预期路径。"
set +e
swift test --package-path OneUI
oneui_swift_status=$?
set -e
echo "swift test --package-path OneUI 退出码 ${oneui_swift_status}。总计划把这条当对照，OneUI 的预期命令是下面的 xcodebuild。"

echo "预期命令：xcodebuild build -scheme OneUI，以及 xcodebuild test -scheme OneUI-Package。"
set +e
set +o pipefail
sim="$(xcrun simctl list devices available | sed -n 's/^[[:space:]]*\(iPhone[^)]*\) ([0-9A-Fa-f-]\{36\}).*/\1/p' | head -n 1)"
simctl_status=$?
set -o pipefail
set -e
sim="$(printf '%s' "$sim" | sed 's/[[:space:]]*$//')"
if [[ -z "$sim" ]]; then
  echo "FAIL 没有可用的 iPhone 模拟器（xcrun simctl 退出码 ${simctl_status}）。xcodebuild test 的 name 要用本机 simctl list devices available 里的机型。"
  exit 1
fi

echo "xcodebuild build -scheme OneUI -destination generic/platform=iOS"
xcodebuild build -scheme OneUI -destination 'generic/platform=iOS'

echo "xcodebuild test -scheme OneUI-Package -destination platform=iOS Simulator,name=${sim}"
xcodebuild test -scheme OneUI-Package -destination "platform=iOS Simulator,name=${sim}"
