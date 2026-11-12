未在 Mac 上运行

MB-1 检查单。历史结论仍在 `docs/decisions/W-parser-harness.md`（B3 不可行，B4 不做），本文不改写那份结论。本轮没有在 WSL 里跑 `swift build --package-path _harness/ModuleParser`，没有改产品解析器，没有改 `project.yml`。B4 和 P3 本轮不实现。

## 为什么用 Clash-Client 原工程

`_harness/ModuleParser` 把原文件拷进同一个 SwiftPM target（`_harness/ModuleParser/Package.swift` 的 `ParserHarness`）。源文件整份包在 `#if os(iOS) || os(macOS)` 里。Linux 上这两个条件都为假，类型不会被定义，调用方仍然参照它们。原工程在 iOS 或 macOS 上编这些文件时，这个条件为真。

打开核对过的原文件（都在 `Clash-Client/apple/ClashClient/Sources/ConfigStore/`）：

- `ModuleJQ/ModuleJQ.swift:1` 是 `#if os(iOS) || os(macOS)`，`:342` 是 `#endif`。`:331` 调用 `pthread_get_stackaddr_np`，`:332` 调用 `pthread_get_stacksize_np`（Darwin 才有）。
- `ModuleJQ/ModuleJSONText.swift:1` 是同一行条件，`:977` 是 `#endif`。
- 同目录其余 Swift 文件第 1 行经检索也是这一行条件（含 `ModuleJSONValue.swift` 与各个 `ModuleJQ*.swift`，共 20 个文件）。本检查单以打开读过的 `ModuleJQ.swift` 与 `ModuleJSONText.swift` 为准。
- 测试台副本同样：`_harness/ModuleParser/Sources/ParserHarness/ModuleJQ.swift:1`、`ModuleJSONText.swift:1`。
- 调用方没有这层条件。`ModuleJSONRewriteSyntax.swift:1` 是 `import Foundation`。`:136` 与 `:145` 调用 `ModuleJSONText.parse`，`:227` 调用 `ModuleJQ.parseOnLargeStack`。

因此不要在 Linux 上重试 `_harness/ModuleParser`。要在 Mac 上编 Clash-Client 原工程里已经收进这些文件的 scheme。

原工程怎么收这些文件（`Clash-Client/apple/ClashClient/project.yml`）：

- `ClashiOS` 的 `sources` 含 `Sources`，排除 `Mac` 和 `TV`（`:43-46`）。扩展 target 另列 `Sources/ConfigStore/ModuleJQ`（`:213`）。scheme 在 `:896`。
- `ClashmacOS` 的 `sources` 含 `Sources`，排除 `TV` 等（`:414-416`）。扩展 target 另列 `Sources/ConfigStore/ModuleJQ`（`:616`）。scheme 在 `:912`。
- 仓库里没有 `ClashClient.xcodeproj`。Mac 上要先按既有脚本生成工程，再 `xcodebuild`。

## 建议的命令与工作目录

这些命令本轮没有执行。

前置沿用 `scripts/mac/20-clash-client.sh`（脚本第 2 行已标「未在 Mac 上运行」）。工作目录是仓库里的 `Clash-Client`。脚本依次：建 venv、装 PyYAML、`python3 scripts/bootstrap.py`、`python3 scripts/configure.py --bundle-base "$BUNDLE_BASE" --team "$TEAM_ID"`。`configure.py` 会改写 `apple/ClashClient/project.yml` 并调用 xcodegen。那是 Mac 阶段既有步骤，不是本轮要改的产品解析器。

生成 `ClashClient.xcodeproj` 之后，工作目录改为 `Clash-Client/apple/ClashClient`：

```sh
xcodebuild build -scheme ClashmacOS -destination 'platform=macOS'
xcodebuild build -scheme ClashiOS -destination 'generic/platform=iOS'
```

`ClashmacOS` 直接满足 `os(macOS)`。`ClashiOS` 满足 `os(iOS)`。两条都会编进 `ModuleJQ` 目录。

不要跑：

```sh
swift build --package-path _harness/ModuleParser
```

## 成功或失败时记什么

成功：记日期、机器、Xcode 版本、scheme、destination、退出码 0。日志里不应再出现 `cannot find 'ModuleJQ'` 或 `cannot find 'ModuleJSONText'`。把命令和退出码追加到运行记录（本文件末尾或 `docs/autorun/lane-B-notes.md`）。只有这一步成功之后，才能考虑下面的 B4 和 P3。

失败：记退出码、第一条编译错误、失败发生在生成工程还是源码。不要回到 Linux 重试测试台。不要为了过关改解析器或 `project.yml`。

## 成功之后才能考虑（本轮不实现）

- B4：用原工程解析器对样本跑出真实忽略清单，写入 `docs/findings/loon-ignored.md`（该文件现在不存在）。现有的只是推断稿 `docs/findings/loon-ignored-predicted.md`。推断稿不能当成实测。
- P3 缺口，Loon 的 `script(...)`：`ModuleLineSyntax.swift:895-900` 的 `isNewerLoonSyntax` 认 `request`/`response` 加 `if`、`cron` 加 `then`、`network-changed`/`generic` 加 `then`。`:918-920` 用正则认 `then` 后面的 `script(`。`ModuleLoonRewriteSyntax.swift:1228-1230` 在调用名是 `script` 时 `defer_(.newerSyntaxNotSupported)`。`ModuleParser.swift:1377-1378` 对 `rewrite` / `script` 段直接 `ignore(.newerSyntaxNotSupported)`。
- P3 缺口，QX 的 `[Argument]`：`ModuleQuantumultXParser.swift` 的段枚举没有 argument。未知段在 `:150-152` 记 `sectionNotSupported`。`#!arguments` / `#!arguments-desc` 在 `:44-46` 记 `argumentsNotSupported`。Loon 的 `[Argument]` 走 `ModuleParser.swift:1507-1510`，那是另一条路径。

总计划 6.1 写的 `ModuleLoonRewriteSyntax.swift:1230` 与 `ModuleParser.swift:1378` 仍对得上（`script` 判断从 `:1228` 起）。`ModuleQuantumultXParser.swift:46` 仍是 `argumentsNotSupported` 那一行；段名 `[Argument]` 的丢弃在 `:150-152`。
