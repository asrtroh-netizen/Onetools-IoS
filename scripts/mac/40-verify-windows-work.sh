#!/bin/bash
# 未在 Mac 上运行
# 在 Mac 上复核 Windows/WSL 已跑过的 Swift 单测，并用 xcodebuild 验证 OneUI 包编译与测试。
# 不要跑 git submodule update。本机（Windows）不要为了试跑去调 xcodebuild。
#
# Windows/WSL 已完成「语法通过，待 Mac 完整编译」清单：
# - Clash-Client（onetools 分支）：环回注入配置与开关（B2）、ClashtvOS 依赖修复、
#   以及 P5.0 的 OneToolsRootShellView 四页签主壳与 OneUI/SigningLogic 包声明。
# - Swipt（onetools 分支）：SetupView 改为检测并跳转 Clash 10.7.0.1 环回隧道、默认跳过自动解锁、
#   导出 SwiptRootView、首次启动自动安装官方 skip-chinese-ads 并预置 fuzzySkip = true。
# - Feather（onetools 分支）：接入 SigningLogic 本地包，新增 OneToolsSigningCoordinator
#   （证书提前 7 天 / 1 天本地通知排程、多选批量签名、到期前一键重签全部应用）及导出 FeatherRootView。
# - OneUI（18 个界面源文件）：已完成 1:1 结构重写与细节精修，WSL 逐文件 swiftc -parse 全部通过。
#
# 单测：
# - swift test --package-path _harness/ClashLogic（WSL：6 项，0 失败）
# - swift test --package-path SigningLogic（WSL：17 项，0 失败；ExpiryReminderTests 12，BatchTests 5）
# - swift test --package-path OneUI（WSL：13 项，0 失败；Mac 上以 OneUI 目录下的 xcodebuild 为准）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

echo "待 Mac 完整编译验证清单（Windows/WSL 已过 swiftc -parse）："
echo "- Clash-Client (onetools)：环回配置、ClashtvOS 依赖修复、OneToolsRootShellView 四页签主壳与 project.yml。"
echo "- Swipt (onetools)：Clash 10.7.0.1 环回引导页、SwiptRootView、首次自动装 skip-chinese-ads + fuzzySkip=true。"
echo "- Feather (onetools)：OneToolsSigningCoordinator（到期提醒通知、多选批量签名、一键重签）与 FeatherRootView。"
echo "- OneUI：Sources/OneUI 下全部 18 个 SwiftUI/UIKit 视图文件（在下方 OneUI 目录执行 xcodebuild）。"

echo "预期命令：swift test --package-path _harness/ClashLogic"
swift test --package-path _harness/ClashLogic

echo "预期命令：swift test --package-path SigningLogic"
echo "WSL 已核对 17 项、0 失败（ExpiryReminderTests 12 项，BatchTests 5 项）。"
swift test --package-path SigningLogic

echo "对照命令：swift test --package-path OneUI"
echo "OneUI 纯逻辑在 WSL 已核对 13 项、0 失败。Mac 主机上的 swift test 会尝试编 macOS，仅作对照；正式验收看下方 xcodebuild。"
set +e
swift test --package-path OneUI
oneui_swift_status=$?
set -e
echo "swift test --package-path OneUI 退出码 ${oneui_swift_status}。"

echo "预期命令：在 OneUI/ 目录下运行 xcodebuild build -scheme OneUI 与 xcodebuild test -scheme OneUI-Package。"
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

echo "(cd OneUI && xcodebuild build -scheme OneUI -destination generic/platform=iOS)"
(
  cd "$ROOT/OneUI"
  xcodebuild build -scheme OneUI -destination 'generic/platform=iOS'
)

echo "(cd OneUI && xcodebuild test -scheme OneUI-Package -destination platform=iOS Simulator,name=${sim})"
(
  cd "$ROOT/OneUI"
  xcodebuild test -scheme OneUI-Package -destination "platform=iOS Simulator,name=${sim}"
)
