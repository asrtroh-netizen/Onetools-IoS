# SP-04 OneUI 核心（总计划 4.0 到 4.5）

未在 Mac 上运行。

只记本机打开源文件核对过的事实。总计划 4.0 的验收是 `xcodebuild`，本机没跑。标成「未做」的步骤还没做。

## 4.0 包骨架

已核对：

- `OneUI/Package.swift:11` 是 `#if os(macOS)`。macOS 分支 `:14` 平台 iOS 15，`:16-17` 产品是 `OneUI` 和 `OneUICore`，`:23-24` 资源是 `Resources/Fonts` 与 `Resources/Icons`，`:27` 的 `OneUICore` 没有另写 path。
- `#else` 从 `:34` 起。`:43` 是 `path: "Sources"`。`:44-51` exclude 掉 `OneUI/Components`、`Gallery`、`Glass`、`Theme`、`Tokens`、`Resources/Fonts`。`:53` 资源是 `.copy("OneUI/Resources/Icons")`。`:38` 只产品化 `OneUICore`。
- 同一决定写在 `docs/autorun/DECISIONS.md:18`。
- 测试 `OneUI/Tests/OneUICoreTests/OneUICoreSkeletonTests.swift:6` 读 `OneUICoreMarker.moduleName`（定义在 `OneUI/Sources/OneUICore/OneUICoreMarker.swift:2`）。`:10-15` 检查清单里的 Icons 资源声明。`:18-29` 只在 Linux 上读 `Icons/MaterialIcons-Regular.otf`。
- `docs/autorun/lane-E-notes.md:3`：E1 当时的 `swift test` 退出码 0，`Executed 3 tests, with 0 failures`。`:5` 写明现有 14 个界面文件未改。这 14 个文件现在仍未改。当前包的测试数不是这 3 项，见 4.1 的部分 E3（7 项）。
- 本机用来跑 `swift test` 的工具链记录是 WSL `Swift version 6.4.2 (swift-6.4.2-RELEASE)`，见 `docs/autorun/STATE.md:19`。E1/E2 的重跑记录本身没有再打印这一行版本号。
- 这 14 个界面文件仍在：`Sources/OneUI/Glass/GlassSurface.swift`，`Components/Nameplate.swift`、`Metrics.swift`、`StatusHero.swift`、`Actions.swift`、`DotMatrixFace.swift`、`Tiles.swift`、`Containers.swift`，`Gallery/OneGallery.swift`，`Theme/Compat.swift`、`OneTheme.swift`，`Tokens/OneFont.swift`、`OnePalette.swift`、`OneMetrics.swift`。

未做：

- 总计划 `docs/superpowers/plans/2026-11-11-onetools-ios-master-plan.md:807-808` 的两条 `xcodebuild` 没跑。
- 4.0 要删掉这 14 个文件里已删字重和系统玻璃的引用。文件未改，这步未做。
- `scripts/mac/40-verify-windows-work.sh` 第 2 行仍是「未在 Mac 上运行」。脚本里的 `xcodebuild` 是预期命令，没跑。五个 `scripts/mac/*.sh` 只过了 `bash -n`，没有在 Mac 上跑。

## 4.1 数值层

色板、设计常量和玻璃是 E2，当时 4 项测试。字号、底栏插值、水波纹曲线是部分 E3（Q3，提交 `f28e45c`），已核对，不要再实现一遍。图标夹具仍阻塞。合计 7 项测试。界面层、`xcodebuild`、G4 仍未做，未在 Mac 上运行。

- 实现在 `OneUI/Sources/OneUICore/Tokens/OnePalette.swift`、`OneTokens.swift`、`Glass.swift`。`Glass.swift:47` 的 `radiusCard` 是 18，`:50` 的 `radiusHero` 是 `radiusCard + 4`。
- 测试是 `OneUI/Tests/OneUICoreTests/OneTokenFixtureTests.swift:6` 的 `testEveryTokensJsonKeyMatchesSwiftCatalog`。
- `lane-E-notes.md:7`：实现后 `Executed 4 tests, with 0 failures`，退出码 0。期望从 `_golden/fixtures/tokens.json` 读，遍历每一个键。把 `radiusCard` 改成 19 后退出码 1，已改回。`:9`：2026-11-12 01:50 再跑仍是 4 个测试、0 失败。夹具根上临时加 `__probe` 后失败信息是 `swift missing tokens.__probe`，撤掉后再过。
- Linux 上 E2 当时的 4 个测试对应骨架里的 3 个（含 `:18` 的图标资源测试）加这 1 个夹具测试。那是 Q3 之前的计数。

部分 E3 已核对（不是 E3 全部通过）：

- `OneUI/Sources/OneUICore/Tokens/TypeScale.swift`、`Motion/DockEdges.swift`、`Motion/InkRippleModel.swift` 已在。测试是 `OneUI/Tests/OneUICoreTests/PartialE3FixtureTests.swift:6`、`:10`、`:14`，分别遍历 `typography.json`、`dock_edges.json`、`ripple.json`。
- `docs/autorun/REPORT.md` 的 N7 与 `docs/autorun/lane-E-notes.md:15`：Q3 之后 `swift test --package-path OneUI` 为 `Executed 7 tests, with 0 failures`（上面 4 项加这 3 项）。往 `typography.json` 加 `__probe` 的失败信息是 `swift missing typography.__probe`，已撤掉。
- `_golden/fixtures/` 仍有 `layout.json`，没有 `icons.json`。`layout.json` 还没有逐键测试。图标逐项断言未做。

未做：

- 图标码点，见 4.3。
- 14 个界面文件未改。4.2 的文字界面、4.4–4.5 的触摸和模糊界面、`xcodebuild`、G4 都未做，未在 Mac 上运行。

## 4.2 文字层

已核对，不改 P4 字体规格：

- `_ref/skia/src/core/SkTextFormatParams.h:15-18`：9 point 及以下描边增加 text size/24，36 point 及以上增加 text size/32，中间插值。`:19-21` 的键是 `SK_Scalar1*9` 与 `SK_Scalar1*36`。`:23-25` 的值是 `SK_Scalar1/24` 与 `SK_Scalar1/32`。
- `_ref/NOTES.md:21` 的结论是「一致」。`docs/autorun/DECISIONS.md:20`：不改 P4 的字体规格。
- `HANDOFF.md:116` 仍写这组数「凭记忆、没核实」。那一句没改。规格以头文件和 NOTES 的「一致」为准。

未做：

- 数值层 `OneUI/Sources/OneUICore/Tokens/TypeScale.swift` 已在，见 4.1，不要再写一遍。界面层 `Sources/OneUI/Text/OneText.swift` 仍没有。`a1_typography`、`a2_weights` 的 Swift 对拍未做。未在 Mac 上运行。

## 4.3 图标

已核对，E3 图标夹具阻塞：

- `_ref/ow_icons.txt:47` 是 `Icons.eye`，`:48` 是 `Icons.eye_slash`。文件共 121 行。
- 调用点在 `ONEWIFIX/IOS/lib/design/widgets/obscurable_field.dart:51`：`CupertinoIcons.eye` / `CupertinoIcons.eye_slash`。`_golden/pubspec.yaml:8-9` 把 `onewifi_android` 指到 `../../ONEWIFIX/IOS`。
- `_golden/test/scenes/a3_icons_test.dart:13-14` 写明这两个名字不画，Material Icons 没有这两个名字。`:6` 断言个数是 119。
- `_ref/flutter-3.44.9/material/icons.dart` 共 29454 行。检索 `eye_slash` 和 `IconData eye` 都没有命中。
- `docs/autorun/lane-A-notes.md:83`：`icons.json` 没有写，不把 121 改成 119，也不改 `ow_icons.txt`。`DECISIONS.md:21` 把这项标成阻塞。

未做：

- `OneUI` 源码里没有 `MaterialIconCodepoints.swift`。总计划要的 121 项码点表未做。`a3_icons` 的 Swift 对拍未做。

## 4.4 水波纹、4.5 模糊和玻璃面

数值层已核对，界面层未做。`OneUI/Sources/OneUICore/Motion/InkRippleModel.swift` 和 `Motion/DockEdges.swift` 已在，夹具测试见 4.1，不要再实现一遍。仍没有 `Ink/InkRipple.swift`、`Glass/BackdropBlurView.swift`。真机对拍未做。4.4、4.5 的界面层和 G4 未做，未在 Mac 上运行。
