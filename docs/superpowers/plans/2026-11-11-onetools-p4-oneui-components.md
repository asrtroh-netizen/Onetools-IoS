# SP-05 OneUI 组件（总计划 4.6 到 4.9）

未在 Mac 上运行。

4.6 到 4.9 都还没做。这里只记已经打开源文件核对过、且会卡住这几步的事实。

## 已核对

- `OneUI/Package.swift` 里没有 `OneUISnapshotTests`。macOS 分支 `:19-31` 只有 `OneUI`、`OneUICore`、`OneUICoreTests`。Linux 分支 `:40-59` 只有 `OneUICore` 和 `OneUICoreTests`。
- Linux 分支 `:44-51` 把界面目录 exclude 掉：`OneUI/Components`、`Gallery`、`Glass`、`Theme`、`Tokens`，以及 `Resources/Fonts`。这些目录不进 Linux 上的 `swift test`。
- `docs/autorun/lane-E-notes.md:5` 和 `:7`：E1、E2 都没改这 14 个界面文件。盘上仍是 `Sources/OneUI/Glass/GlassSurface.swift`，`Components/Nameplate.swift`、`Metrics.swift`、`StatusHero.swift`、`Actions.swift`、`DotMatrixFace.swift`、`Tiles.swift`、`Containers.swift`，`Gallery/OneGallery.swift`，`Theme/Compat.swift`、`OneTheme.swift`，`Tokens/OneFont.swift`、`OnePalette.swift`、`OneMetrics.swift`。
- 数值层只做到色板、常量和玻璃，见 SP-04。`OneUI` 源码里没有 `TypeScale.swift`、`DockEdges.swift`、`InkRippleModel.swift`、`MaterialIconCodepoints.swift`。主题和控件要用的字号、图标码点、水波纹、底栏插值还没进 `OneUICore`。
- 合成加粗与交接文档一致，不改 P4 字体规格。依据是 `_ref/skia/src/core/SkTextFormatParams.h:15-25`（`SK_Scalar1*9`、`SK_Scalar1*36`、`SK_Scalar1/24`、`SK_Scalar1/32`）和 `_ref/NOTES.md:21`、`docs/autorun/DECISIONS.md:20`。
- E3 图标夹具仍阻塞。`_ref/ow_icons.txt:47-48` 的 `Icons.eye` / `Icons.eye_slash` 来自 `ONEWIFIX/IOS/lib/design/widgets/obscurable_field.dart:51` 的 `CupertinoIcons`。`_golden/fixtures/` 没有 `icons.json`。
- `scripts/mac/40-verify-windows-work.sh:2` 写着「未在 Mac 上运行」。`:22` 的 `xcodebuild` 是预期命令，没跑。五个 Mac 脚本只过了 `bash -n`（`docs/autorun/lane-C-notes.md:35`）。

## 还没做

- 4.6 主题和 Material 控件。C 组对拍未做。现有 `Theme/OneTheme.swift`、`Theme/Compat.swift` 没按这一步重写。
- 4.7 组件。B 组对拍和按批代码审查未做。现有 `Components/` 没按这一步重写。
- 4.8 底栏。D 组对拍、键盘隐藏、减弱动态效果，都未做。没有 `Dock/UltraGlassDock.swift` 这一批新文件。
- 4.9 总验收。G4a 全量对拍和 G4b 真机并排都未做。交接文档偏离表没逐行对上场景或单测。
