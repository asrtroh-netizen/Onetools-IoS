# 线 B 备忘

开工 2026-11-12 00:28 +08。本轮做 B1、B2。B3、B4 不做。

## 决定

- 测试台包名 `ClashLogic`，模块名 `ClashClientUI`，`swift-tools-version` 6.4（与 WSL Swift 6.4.2 和 `_harness/_smoke` 一致）。`ClashClientUI/Package.swift` 仍是 6.0，只加了 test target。依据：总计划要求测试台模块名不变；工具链版本用本机已装的 6.4。回退：改回 6.0 即可。
- `tools/sync_harness.py` 只按二进制复制 `ClashTunnelRouteShaping.swift` 和 `SwiptLoopbackTests.swift`。测试台的 `Package.swift` 手写，不进复制对。`--check` 逐字节比较，缺文件或不同则退出码 1。副本、`.build/` 写进 `_harness/ClashLogic/.gitignore`，不进 git。
- `ConfigTransforms.swift` 加 `import ClashClientUI`。依据：ClashiOS / ClashmacOS 把该文件编进 App target，`ClashTunnelRouteShaping` 在 ClashClientUI 包里，这个文件原来没有这个 import。回退：删掉这一行，并给编该文件的 target 改成能看见该类型。
- 不改 `Mac/VPNTunnelSettings.swift`，也不给 `ClashTunnelRouteShaping.Switches` 加字段。依据：P3 文件表没有 Mac 那个结构体；T3.2 只加独立函数，T3.4 走 iOS 的 `VPNTunnelSettings`。
- 三个 `Localizable.strings` 按现有键的字母序插入：`Swipt Compatibility` 在 Supporting Files 与 Switch 之间；长句在 APNs 的 “the network traffic” 与 “the tunnel does not” 之间。

## 验证

- 先红：`swift test --package-path _harness/ClashLogic` 报 `no member 'loopbackAddresses'`、`'swiptLoopbackEnabled'`、`'swiptLoopbackKey'`。
- 后绿：`Executed 5 tests, with 0 failures`。`sync_harness.py --check` 两行都是 `same`，退出码 0。
- 自查：把 `?? true` 改成 `?? false` 后，`testAKeyNeverWrittenCountsAsOn` 两处 `XCTAssertTrue failed`。已改回，再跑 5 个测试通过，`--check` 仍然 `same`。
- Linux 上 `object(forKey:) as? Bool` 能读到 UserDefaults 的 Bool，总计划那段实现不用改。整份 `ClashTunnelRouteShaping.swift` 在 Swift 6.4.2 linux 上能编过，没有为测试台改源文件。
- B2：改过的 Swift 文件 `swiftc -parse` 退出码 0。状态记「未编译」。

## 不在本次

- `ClashtvOS` 也编 `ConfigTransforms.swift`，但 `project.yml` 里没有 ClashClientUI 包。Mac 上编这个 target 会卡在新加的 import。不改 `project.yml`（不在可写路径）。
- `Clash-Client/apple/ClashClient/Sources/Mac/VPNTunnelSettings.swift:75` 的 `excludeAPNsRoute:` 没有 `swiptLoopback:`。这是 Mac 结构体的成员初始化，不是运行时配置调用链。
- T3.5 真机、B3、B4 没做。

## B3（2026-11-12）

- 结论：不可行。详情在 `docs/decisions/W-parser-harness.md`。卡在 `ModuleJQ` / `ModuleJSONText` 的 `#if os(iOS) || os(macOS)`。`swift build --package-path _harness/ModuleParser` 退出码 1，`cannot find 'ModuleJQ'`、`cannot find 'ModuleJSONText'`。
- 计划那句话：三个语法文件只有 Foundation、ModuleIR 依赖 CryptoKit、ModuleParser 依赖 Darwin 和 os，仍然成立。Syntax 文件现在是 6 个，不是 5 个。
- `import Clash` 退出码 1，`no such module 'Clash'`。头文件不在树里。B4 不做，线 C 改做 C6。
- 没改 Clash-Client，没改 `_harness/ClashLogic`。
