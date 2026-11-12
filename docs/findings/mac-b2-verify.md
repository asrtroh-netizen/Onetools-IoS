未在 Mac 上运行
parse 已在 WSL 跑过，完整编译未做。本轮不改 `project.yml`，不完整编译 B2。

## B2 未编译文件

提交 `1358825` 全名 `1358825c463f0f8b22583c1453e70fd7918c96c6`（Clash-Client，2026-11-12 00:44:28 +0800，说明「记下 Clash 环回的运行时配置和设置项，语法检查通过，未编译」）。`git show --stat` 里实际改了 7 个文件，路径相对 Clash-Client 仓库：

- `apple/ClashClient/Sources/ConfigStore/ConfigTransforms.swift`
- `apple/ClashClient/Sources/ConfigStore/ProfileActivationCoordinator.swift`
- `apple/ClashClient/Sources/VPNController.swift`
- `apple/ClashClient/Sources/ConfigUI/TunnelSettingsView.swift`
- `apple/ClashClient/Sources/AppArchitecture/AppLocalization/en.lproj/Localizable.strings`
- `apple/ClashClient/Sources/AppArchitecture/AppLocalization/zh-Hans.lproj/Localizable.strings`
- `apple/ClashClient/Sources/AppArchitecture/AppLocalization/zh-Hant.lproj/Localizable.strings`

仓库根目录下再加上 `Clash-Client/` 前缀。三种语言都在 `AppLocalization`，不在 `Resources/tvOS/Localization`。打开核对过的键：三份都是 `:1619` 那句 `10.7.0.1` 环回说明，`:3094` 是 `"Swipt Compatibility"`。

`docs/autorun/REPORT.md` 第 3 节还列了 `Sources/Mac/VPNController.swift`。该文件在仓库里，路径是 `Clash-Client/apple/ClashClient/Sources/Mac/VPNController.swift`，不在 `1358825` 的 diff 里。`:5` 是 `import ClashClientUI`。`ClashmacOS` 排除的是 `Sources` 下的 `VPNController.swift`（`project.yml:420`），相对路径 `Mac/VPNController.swift` 不是同一条，所以这份仍会进 `ClashmacOS`。该 target 在 `project.yml:516` 依赖 ClashClientUI 包。

## ClashtvOS 与 ClashClientUI

`ConfigTransforms.swift:4` 是 `import ClashClientUI`。`:2438` 调用 `ClashTunnelRouteShaping.loopbackAddresses`。

`ClashtvOS` 的 `sources` 包含这个文件（`project.yml:742`）。它的 `dependencies`（`:837-843`）是 ClashClientKit、`Clash.xcframework`、`ClashtvOSExtension`、NetworkExtension，没有 `package: ClashClientUI`。全文件只有两处 `package: ClashClientUI`：`ClashiOS` 的 `:146`，`ClashmacOS` 的 `:516`。

因此未依赖该包的 ClashtvOS 在 Mac 上会编不过。已决定不改 `project.yml`。本轮只记录两个选项，不改工程：

1. 给 ClashtvOS 补上 ClashClientUI 包依赖。
2. 把合并改成不依赖该模块（使 `ConfigTransforms.swift` 不再 `import ClashClientUI`，ClashtvOS 仍只编译已经按文件拷进 target 的源，不引用该模块里的 `ClashTunnelRouteShaping`）。

`ProfileActivationCoordinator.swift:4` 也 `import ClashClientUI`，但 `ClashtvOS` 的 sources 清单里没有这个文件。卡住 ClashtvOS 的是 `ConfigTransforms.swift`。

## 建议的命令

语法（已在 WSL 跑过，见下一节）。不要用 Windows 的 `swift.exe`。工作目录随便；路径用 WSL 的 `/mnt/e/GQ/Ultra/Onetools-IoS/...`：

```sh
wsl -d Ubuntu-24.04 -u root -- /opt/swift/usr/bin/swiftc -parse /mnt/e/GQ/Ultra/Onetools-IoS/Clash-Client/apple/ClashClient/Sources/ConfigStore/ConfigTransforms.swift
```

其余四个 Swift 文件把路径换成下一节列出的那些。`.strings` 不走 `swiftc`。

完整编译只在 Mac 上做，本轮没做。先按 `scripts/mac/20-clash-client.sh` 生成工程（`configure.py` 会改写 `project.yml`，那是 Mac 阶段既有步骤）。生成之后工作目录为 `Clash-Client/apple/ClashClient`：

```sh
xcodebuild build -scheme ClashiOS -destination 'generic/platform=iOS'
xcodebuild build -scheme ClashmacOS -destination 'platform=macOS'
xcodebuild build -scheme ClashtvOS -destination 'generic/platform=tvOS'
```

前两条应能看见 ClashClientUI 包。`ClashtvOS` 在未选上面两个选项之一前，预期会卡在 `ConfigTransforms.swift` 的 `import ClashClientUI`。不要把这次失败记成 iOS / macOS 目标失败。本轮不选、不改。

## WSL 上的 swiftc -parse

工具链：Swift 6.4.2（`swift-6.4.2-RELEASE`），`x86_64-unknown-linux-gnu`，`/opt/swift/usr/bin/swiftc`。命令走 `wsl -d Ubuntu-24.04 -u root`。每个文件单独 `-parse`，没有 `-typecheck`，没有 `swift build`，没有 `xcodebuild`。

| 文件 | 退出码 |
|---|---|
| `Sources/ConfigStore/ConfigTransforms.swift` | 0 |
| `Sources/ConfigStore/ProfileActivationCoordinator.swift` | 0 |
| `Sources/VPNController.swift` | 0 |
| `Sources/Mac/VPNController.swift` | 0 |
| `Sources/ConfigUI/TunnelSettingsView.swift` | 0 |

成功时编译器没有输出。这只说明语法过了。完整编译未做。

## 请线 C 折进 scripts/mac/40-verify-windows-work.sh

线 B 不改这个脚本。MC-2 已经把 REPORT 第 3 节的未编译清单、ClashtvOS 注意事项和 `swift test --package-path SigningLogic` 写进 `scripts/mac/40-verify-windows-work.sh`。第 2 行仍是「未在 Mac 上运行」，`set -euo pipefail` 在第 28 行。回显在第 33–37 行，SigningLogic 在第 42–44 行。ClashLogic 与 OneUI 的既有步骤还在。

脚本里还没有、仍留在本检查单的：

1. 工程由 `configure.py` / xcodegen 生成之后，在 `Clash-Client/apple/ClashClient` 执行 `xcodebuild build -scheme ClashiOS -destination 'generic/platform=iOS'`，以及 `xcodebuild build -scheme ClashmacOS -destination 'platform=macOS'`。
2. `ClashtvOS` 单独一条：`xcodebuild build -scheme ClashtvOS -destination 'generic/platform=tvOS'`。先打印「可能因缺少 ClashClientUI 包依赖失败」。用 `set +e` 接住，打印退出码后再 `set -e`，避免这次已知失败挡住后面的 OneUI。不改 `project.yml:837-843`（没有 `package: ClashClientUI`）。
3. 回显本机 WSL 的 `swiftc -parse` 五个文件退出码都是 0，并写明那不是完整编译。

本机不要为了试跑去调 `xcodebuild`。
