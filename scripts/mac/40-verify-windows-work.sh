#!/bin/bash
# 未在 Mac 上运行
# 在 Mac 上复核 Windows/WSL 已跑过的 Swift 单测。
# 不代编 REPORT.md 第 3 节的未编译清单，不改 ClashtvOS 的 project.yml。
# 不要跑 git submodule update。本机不要为了试跑去调 xcodebuild。
#
# REPORT.md 第 3 节「语法通过，未编译」（脚本只回显）：
# - 线 B 的 P3 其余代码（B2），在 Clash-Client 的 onetools 上：
#   apple/ClashClient/Sources/ConfigStore/ConfigTransforms.swift、
#   ProfileActivationCoordinator.swift、Sources/VPNController.swift、
#   Sources/Mac/VPNController.swift、Sources/ConfigUI/TunnelSettingsView.swift，
#   以及三种语言的 Localizable.strings（提交 1358825）。
#   未改 ClashtvOS 的 project.yml（已有决定）。
# - experiments/G3/：Package.swift、Sources/G3Numbers/{Text,Blur,Shadow,Ripple}Numbers.swift、NOTES.md。
#   只过了 swiftc -parse。文字、模糊、投影、水波纹触摸都未选定实现。
# - OneUI 现有 14 个界面文件（Sources/OneUI/ 下组件、主题、Gallery 等）。
#   Linux 上不参与 swift test。界面层等 Mac 上的 G3 实验。4.2–4.9 界面层、xcodebuild、G4 仍未做。
#
# ClashtvOS 注意事项（REPORT.md 第 5 节第 7 条）：
# ConfigTransforms.swift 若 import ClashClientUI，未依赖该包的 ClashtvOS 会在 Mac 上编不过。
# 已决定不改 project.yml。Mac 阶段要给 ClashtvOS 补依赖，或把合并改成不依赖该模块。本脚本不做这件事。
#
# 单测：
# - swift test --package-path _harness/ClashLogic
# - swift test --package-path SigningLogic（WSL：13 项，0 失败；ExpiryReminderTests 9，BatchTests 4）
# - swift test --package-path OneUI 是对照。部分 E3（f28e45c）之后 WSL 为 Executed 7 tests, with 0 failures。
#   图标仍阻塞。Mac 主机上会走 Package.swift 的 macOS 分支，不是预期路径。预期是下面的 xcodebuild。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

echo "未编译清单（docs/autorun/REPORT.md 第 3 节）。本脚本不编译这些文件："
echo "- B2 / P3：Clash-Client onetools 上的 ConfigTransforms.swift、ProfileActivationCoordinator.swift、VPNController.swift、Sources/Mac/VPNController.swift、TunnelSettingsView.swift，以及三种语言的 Localizable.strings（1358825）。未改 ClashtvOS 的 project.yml。"
echo "- experiments/G3/：Package.swift、Text/Blur/Shadow/RippleNumbers.swift、NOTES.md。只过了 swiftc -parse。四项实现未选定。"
echo "- OneUI 14 个界面文件仍未改。4.2–4.9 界面层、xcodebuild、G4 仍未做。"
echo "NOTE ClashtvOS：ConfigTransforms.swift 若 import ClashClientUI，未依赖该包的 ClashtvOS 会编不过。不要在本脚本里改 project.yml。"

echo "预期命令：swift test --package-path _harness/ClashLogic"
swift test --package-path _harness/ClashLogic

echo "预期命令：swift test --package-path SigningLogic"
echo "WSL 已核对 13 项、0 失败（ExpiryReminderTests 9 项，BatchTests 4 项）。"
swift test --package-path SigningLogic

echo "对照命令：swift test --package-path OneUI"
echo "部分 E3（f28e45c）之后 WSL 为 Executed 7 tests, with 0 failures：骨架 3、tokens 1、字号/底栏/水波纹各 1。图标仍阻塞，不是 E3 全部通过。macOS 分支含 iOS 15 的 OneUI、OneUICore 和 OneUICoreTests。总计划 P4：Mac 主机上的 swift test 会去编 macOS，所以这条不是预期路径。"
set +e
swift test --package-path OneUI
oneui_swift_status=$?
set -e
echo "swift test --package-path OneUI 退出码 ${oneui_swift_status}。总计划把这条当对照，OneUI 的预期命令是下面的 xcodebuild。"

echo "预期命令：xcodebuild build -scheme OneUI，以及 xcodebuild test -scheme OneUI-Package。未在 Mac 上运行过。14 个界面文件仍未改。"
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
