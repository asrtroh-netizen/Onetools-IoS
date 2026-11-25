# OneTools iOS (`Onetools-IoS`) — 全量 BUG 扫描、修复与 OneUI 精修移植 · Codex 多子代理执行总册

> **生成时间**：2026-11-21  
> **工作区根目录**：`e:\GQ\Ultra\Onetools-IoS`  
> **执行目标**：在不破坏现有 21 项自动化门禁与 270 张 Flutter 金图基线的前提下，启用 **3 个零冲突并行子代理**，一次性完成：
> 1. **基线隔离保护**：将 `_golden` 对 `../../ONEWIFIX/IOS` 的实时路径依赖冻结至 `7a8839e` 只读 worktree，消除跨仓改动干扰；
> 2. **全仓自有代码深度 BUG 扫描与修复**：覆盖 `OneUI`、`SigningLogic`、`Clash-Client`（`onetools` 分支自有增量）、`adblock`、`tools`、`scripts/mac` 及历史报告矛盾；
> 3. **OneUI 视觉体系 1:1 忠实精修重写**：彻底清退 `OneUI/Sources/OneUI/` 下 14 个偏离原版的旧文件，复用 `OneUICore` 单一数值真源，完整实现原版 One 家族玻璃设计系统（单 Regular 字重 + Skia 负描边合成加粗、`MaterialIcon` 121 码点、四档精确光学玻璃、真触点 `InkRipple`、480ms 手写液态胶囊底栏 `UltraGlassDock`、15 个核心组件与主题化控件）。

---

## 一、本机工具链绝对路径与铁律护栏（必读）

### 1.1 已核实可用的本机工具链
- **Python**：`python`（Python 3.14.6，`pytest` 已装）
- **Flutter / Dart**：`C:\Flutter\flutter\bin\flutter.bat`（Flutter 3.44.9 / Dart 3.12.2，与 `_golden` 精确匹配）
- **WSL Swift 6.4.2（Linux x86_64，跑 `swift test` 与 `swiftc -parse`）**：
  ```powershell
  wsl -d Ubuntu-24.04 -u root -- env PATH=/opt/swift/usr/bin:/usr/bin:/bin /opt/swift/usr/bin/swift --version
  ```
  - ⚠️ **铁律 1**：**严禁调用 Windows 原生 `swift.exe`**（存在已知访问冲突，见 `docs/autorun/NEGATIVE.md`）；所有 `swift test` 与 `swiftc -parse` 一律通过上述 `wsl -d Ubuntu-24.04 -u root` 调用 `/opt/swift/usr/bin/swift` / `swiftc`！
  - ⚠️ **铁律 2**：Windows + Linux 均无 Apple `SwiftUI` / `UIKit` SDK，因此涉及 `import SwiftUI` / `import UIKit` 的文件在本机只做 `swiftc -parse` 语法校验 + 纯逻辑抽离进 `OneUICore` 跑 `swift test`，**严禁在文档或提交说明中把“过语法检查”谎报成“已通过 Xcode 编译”**！

### 1.2 仓库禁区（绝对不可触碰）
1. **严禁跑 `git submodule update`**：`Feather/Zsign`（247 文件）、`Feather/IDeviceKitten`（25 文件）、`Swipt/Swipt/Resources/DeveloperDiskImage`（6 文件）已通过 zipball 就位且无 `.git`（见 `docs/findings/submodules.md`）。
2. **严禁修改无自有提交的只读上游仓**：`Swipt/`、`Feather/`、`Clash-Core/`、`Swiplets/`、`zsign/` 保持 `git status --porcelain` 为空且 HEAD 等于 `upstreams.lock.json`。
3. **严禁修改 `e:\GQ\Ultra\ONEWIFIX\IOS` 的工作区文件**（隔壁任务正在使用该目录；Stage 0 仅以 `--detach` 只读添加 gitignored worktree）。
4. **严禁 `git push`、严禁创建 `DONE`/`PAUSE` 文件或重启 AFK 钩子**；所有成果在门禁全绿后仅做本地清晰提交（或保持干净待检状态）。
5. **审美铁律（`HANDOFF.md §1 & §3.2–§3.3`）**：OneUI 的“审美精修”定义是**像素级忠实还原 OneWIFI 原版设计系统与工艺质感，撤回上一版擅自改动的 SF Symbols、系统 TabView、`PressableStyle` 缩放与全 `.continuous` 圆角**，不要臆造偏离原版夹具的新色值或新布局！

---

## 二、Stage 0 · 基线冻结与门禁复位（主代理先执行，约 3 分钟）

### 为什么必须先做 Stage 0？
`_golden/pubspec.yaml` 当前写的是 `path: ../../ONEWIFIX/IOS`，直接编译隔壁 `ONEWIFIX/IOS` 的实时工作区；而隔壁 `ONEWIFIX/IOS` 正在进行新版改造（含新增字重与样式变更），会导致本仓 A1/A2/N13 门禁被跨仓污染。同时注意：**本仓 `.gitignore` 只忽略了 `/_ref/kernel-*/`，没有忽略整个 `_ref/`**！

### Stage 0 精确步骤
1. **创建被 `.gitignore` 自动忽略的只读基线 worktree**：
   ```powershell
   git -C "e:\GQ\Ultra\ONEWIFIX\IOS" worktree add --detach "e:\GQ\Ultra\Onetools-IoS\_ref\kernel-onewifi-ios-7a8839e" 7a8839e
   ```
   核验 `git -C "e:\GQ\Ultra\Onetools-IoS" status -s` 确认 `_ref/kernel-onewifi-ios-7a8839e` 被 `/_ref/kernel-*/` 规则完美忽略，未产生未跟踪噪音。
2. **解耦 `_golden/pubspec.yaml`**：
   将 `_golden/pubspec.yaml` 中的：
   ```yaml
   onewifi_android:
     path: ../../ONEWIFIX/IOS
   ```
   改为：
   ```yaml
   onewifi_android:
     path: ../_ref/kernel-onewifi-ios-7a8839e
   ```
   随后在 `e:\GQ\Ultra\Onetools-IoS\_golden` 下运行 `C:\Flutter\flutter\bin\flutter.bat pub get`。
3. **跑一次基线门禁确认起点全绿**：
   ```powershell
   Set-Location "e:\GQ\Ultra\Onetools-IoS"
   python tools/gates.py
   ```
   确认 21 项门禁全部 pass，且 `_golden/goldens/` 下 270 张 PNG 的合并 SHA-256 仍为 `51d437c1c04373e13b9c6362d7dfdd876cebb5e2e3ec4cbd67c06be386fe3a33`（严禁重生成覆盖金图！）。

---

## 三、Stage 1 · 三路并行子代理任务书（严格目录隔离，零写冲突）

Stage 0 通过后，立即并行拉起以下 **3 个子代理（Subagents）**：

---

### 🤖 子代理 1：`OneUI-Core-And-Engine`（底座、文字、图标、玻璃、水波纹、悬浮底栏）

- **独占写入路径**：
  - `OneUI/Package.swift`
  - `OneUI/Sources/OneUICore/**`
  - `OneUI/Sources/OneUI/Tokens/**`
  - `OneUI/Sources/OneUI/Glass/**`
  - `OneUI/Sources/OneUI/Theme/**`
  - `OneUI/Sources/OneUI/Icons/**`（可新建）
  - `OneUI/Sources/OneUI/Motion/**`（可新建）
  - `OneUI/Tests/OneUICoreTests/**`
- **严禁触碰**：`OneUI/Sources/OneUI/Components/**`、`OneUI/Sources/OneUI/Gallery/**`（由子代理 2 独占）及其它目录。

#### 必做修复与精修规格（逐项落实）
1. **[BUG 修复 · P0] 修复 `OneUI/Package.swift` 漏依赖与 Linux `exclude` 脆弱性**：
   - 在 `#if os(macOS)` 分支（第 `20-26` 行）为 `.target(name: "OneUI", ...)` 补上 **`dependencies: ["OneUICore"]`**，使整个 `OneUI` 视图层能直接 `@_exported import OneUICore` / `import OneUICore`，彻底消灭 `OneUI/Tokens` 与 `OneUICore/Tokens` 两套重复常量的撕裂！
   - 在 `#else`（Linux 分支，第 `44-51` 行）同步把任何新增在 `Sources/OneUI/` 下的界面子目录（如 `"OneUI/Icons"`, `"OneUI/Motion"`）加入 `exclude:`，确保 WSL `swift test --package-path OneUI` 始终 100% 编译通过！
2. **文字排印引擎（重写 `Tokens/OneFont.swift`，对照 `HANDOFF.md §3.3.2`）**：
   - **彻底删除**对不存在的 `"Montserrat-Medium"`、`"Montserrat-SemiBold"`、`"Montserrat-Bold"` 的注册与 PostScript 名称引用，仅注册 `Montserrat-Regular.ttf`。
   - **M3 固定字阶与行高均分（不绑定 iOS Dynamic Type 缩放导致失真，提供可选环境开关但默认 1:1 对齐 `OneUICore.TypeScale`）**：
     - 完整映射 10 档样式（`headlineSmall` 24/400/1.33/0、`titleLarge` 22/400/1.27/0、`titleMedium` 16/500/1.50/0.15、`titleSmall` 14/500/1.43/0.1、`bodyLarge` 16/400/1.50/0.5、`bodyMedium` 14/400/1.43/0.25、`bodySmall` 12/400/1.33/0.4、`labelLarge` 14/500/1.43/0.1、`labelMedium` 12/500/1.33/0.5、`labelSmall` 11/500/1.45/0.5）。
     - **关键规则**：`w500` **不加粗**，直接渲染为 `Montserrat-Regular`（对齐 Skia 规则：请求字重 ≥ 600 且高出字体实际字重 ≥ 200 才触发合成加粗）！
     - **`w600` / `w700` 合成加粗与 `1.219em` 行高补偿**：将合成加粗描边比值公式（在 9pt~36pt 间插值 Skia `1/24`~`1/32` 转换为 CoreText 负 `kCTStrokeWidthAttributeName` 百分比，以及单行上下 `(height - 1.219) * size / 2` / 多行 `lineSpacing` 计算）抽成纯函数放入 `OneUICore` 并补齐单测，同时在 `OneUI/Tokens/OneFont.swift` 提供干净的 `OneText` 视图/修饰器封装（`UIViewRepresentable` `UILabel` 精确富文本或 `AttributedString` + CoreText 属性）。
3. **121 项图标引擎（新建 `Icons/MaterialIcon.swift`，对照 `HANDOFF.md §3.4.2`）**：
   - 注册 `Resources/Icons/MaterialIcons-Regular.otf`；
   - 直接读取 `OneUICore.MaterialIconCodepoints`（已包含 121 项码点并通过 `cmap` 校验），封装 `public struct MaterialIcon: View`（入参 `name: String` 或强类型静态属性、`size: CGFloat = 24`、`color: Color? = nil`），居中无基线偏移渲染字形（注意处理 `obscurable_field` 的 2 个眼睛图标映射）。
4. **色板、圆角与四档光学玻璃（重写 `Tokens/OnePalette.swift`、`Tokens/OneMetrics.swift`、`Glass/GlassSurface.swift`，对照 `HANDOFF.md §3.3.1 & §3.3.5`）**：
   - `OneGlass.stroke` 浅色修正为精确预合成值 `0xEEEEEE, alpha: 0.595`（深色 `0xFFFFFF, alpha: 0.12`），线宽 `0.8`；补齐 `barFill`（浅 `surface 0.86` / 深 `containerLow 0.86`）与 `Glass.accent`（浅 `#1A1B20` / 深 `#E2E2E9`）。
   - **恢复 `PlateTone` 全部 6 个枚举名**（`neutral`, `blue`, `green`, `purple`, `teal`, `red`；保持原版色值兼容 `blue == green (#34D399)`、`purple == teal (#2DD4BF)`、`red (#F87171)`，同时保留 `OneTone` 类型别名以防下游断裂）。
   - **区分两种圆角几何（撤回一刀切 `.continuous`）**：
     - 普通圆角 `RoundedRectangle(cornerRadius: r, style: .circular)`：用于 Card (`18`)、Tile (`14`)、TextField (`14`)、Button (`14`)、StatusHero (`22`)、Dock (`28`)；
     - 连续曲率超椭圆 `RoundedRectangle(cornerRadius: r, style: .continuous)`：**仅用于** Dialog (`22`)、Popup/Menu (`14`)、Chip (`10`)！
   - **隔离模糊后端（`Glass/BackdropBlur.swift`）**：单文件封装 `OneBackdropBlurView(sigma: CGFloat)`——自签默认通过运行时查找 `CABackdropLayer` / `_UICustomBlurEffect` 精确传递 `sigma`（`panel: 18`, `bar/hero: 24`, `dock: 12`, `liquid: 10`），若系统符号不可用或开启合规开关则自动无缝回退 `UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))`！**撤回** `GlassSurface.swift` 中的 iOS 26 `.glassEffect` 分支（仅二级弹层 `OneGlassPopupFrame` 按原版保留 iOS 26 系统玻璃 / 旧版 `systemThinMaterial`）。
5. **真触点 `InkRipple` 水波纹修饰器（新建 `Motion/InkRipple.swift`，对照 `HANDOFF.md §3.3.3`）**：
   - 驱动 `OneUICore.InkRippleModel`：浅色 splash `0x66C8C8C8` / highlight `0x66BCBCBC`；深色 `0x40CCCCCC`；支持按钮自定义 `overlayColor`（Filled 为 `onPrimary 0.10`，Text/Outlined 为 `primary 0.10`）；
   - 以按下触点为圆心，从 `0.3 × targetRadius` 扩散至 `targetRadius + 5`（`targetRadius = hypot(width, height) / 2`），按住 1000ms、松手确认 225ms、淡入 75ms、淡出 375ms、滚动/取消 75ms，严格裁剪到宿主形状！
6. **手写悬浮胶囊底栏（新建 `Theme/UltraGlassDock.swift` 并更新 `Theme/OneTheme.swift`，对照 `HANDOFF.md §3.3.4`）**：
   - **彻底撤回** `OneTheme.swift` 里的系统 `UITabBarAppearance` 方案，手写 `public struct UltraGlassDock: View`：
     - 左右外边距 `16`，距底 `8 + safeAreaBottom`，高 `56`，普通胶囊圆角 `28`，模糊 `sigma = 12`，无投影，填充白（浅 `.12` / 深 `.06`）；
     - `1.25pt` 外圈高光描边（深 `#8CFFFFFF → #1AFFFFFF → #47FFFFFF`；浅 `#B8FFFFFF → #2EFFFFFF → #52FFFFFF`，stops `0 / 0.45 / 1`）；
     - 内缩 `4pt`、高 `48pt` 液态胶囊指示条：使用 `OneUICore.DockEdges` 的 `480ms` 前沿 `easeOutCubic` / 后沿 `easeInCubic` 非对称插值，运动途中按 `sin(π·t)` 动态插值底色并叠加 `1.2pt` 5 色 `AngularGradient`/`SweepGradient` 虹彩描边（透明度 `0.85 * sin(π·t)`）；开启「减弱动态效果」时直接瞬移；
     - 每格图标 `20pt`（`MaterialIcon`）+ `4pt` 间距 + `labelSmall`（选中 `w600` 合成加粗 `accent`，未选 `w500` `onSurfaceVariant`），禁用动态字号缩放（`.dynamicTypeSize(.large)`），按下胶囊水波纹 `accent 0.10`；软键盘弹出时自动隐藏底栏！
   - 修复 `OnePage` 滚动底部留白为 `56 + 8 + safeAreaBottom + 16`（避免底部卡片被悬浮底栏遮挡）。

---

### 🤖 子代理 2：`OneUI-Components-And-Gallery`（全部 15 个组件 + Material 覆盖控件 + 预览画廊）

- **独占写入路径**：
  - `OneUI/Sources/OneUI/Components/**`
  - `OneUI/Sources/OneUI/Gallery/**`
- **只读参考**：`e:\GQ\Ultra\Onetools-IoS\_ref\kernel-onewifi-ios-7a8839e\lib\design\` 下的原版 Dart 组件文件、`HANDOFF.md §3.2–§3.3.6`、以及子代理 1 暴露的 `OneUICore` / `MaterialIcon` / `OneText` / `GlassSurface` / `inkRipple` 接口（注意与子代理 1 对齐命名约定：`MaterialIcon`、`PlateTone`/`OneTone`、`.inkRipple(...)`、`OneFont`/`OneText`）。

#### 必做重写与补齐规格
1. **撤回 `Components/` 现有 6 个文件的全部偏离项并 1:1 对齐原版 Dart**：
   - `StatusHero.swift`（+ `OneStatusHero` 包装层）：
     - 去掉 `.sensoryFeedbackCompat(state)` 触感反馈；
     - 左侧 `38pt` 图标从 `Image(systemName:)` 改为 `MaterialIcon`（`"warning_rounded"` / `"refresh_rounded"` / `"check_circle_rounded"`）；
     - 去掉标题与药丸处的 `ViewThatFitsCompat` 竖排改法；按原版使用 `GeometryReader` / 容器宽度检测：**当卡片宽度 `< 300pt` 时，将右上挂件（`trailing` 点阵脸小砖 `fillStrong` 圆角 14 内边距 8 脸 36）移至标题下方**！
     - 严格核对内边距 `24`、圆角 `22`、模糊 `24`、状态药丸 `onSurface .14`（`12×6`, `labelLarge w600`）、白底黑字胶囊主按钮（高 `52`，禁用 `.38`）、三段圆点 `10` 与连线 `2`（亮 `.55` / 暗 `.18`），补齐 `OneStatusHero` 包装枚举（`healthy/critical/attention/neutral` → `就绪/注意/处理中`）。
   - `Tiles.swift`（`GlassTile`、`SoftLabel`、`SoftLabelGrid`）：
     - 去掉 `PressableStyle` 按下缩放，可点击 `GlassTile` 改用 `.inkRipple(...)` 水波纹；
     - `SoftLabelGrid` 去掉 `typeSize.isAccessibilitySize` 单列退化，保持原版固定双列同行等高栅格。
   - `Actions.swift`（`GlassAction`、`ChoiceToggle`、`ChoiceChips`）：
     - 将被改成横向 `ScrollView` 的 `ChoiceChips` **改回自动折行 `Wrap` 布局**（自定义 iOS 15 兼容折行布局容器或 iOS 16 `Layout` + iOS 15 回退）；
     - 去掉 `PressableStyle`，全部接入水波纹与发丝边。
   - `Containers.swift`（`OwSection`、`GlassPanel`、`GlassListCard`、`OwPageHead`）、`Metrics.swift`（`MetricCard`、`MetricRow`、`StageRow`）、`Nameplate.swift`（保留 `Nameplate.lifted` 原版 `0xF2141414` 深色底）、`DotMatrixFace.swift`：逐文件对照原版 `_ref/kernel-onewifi-ios-7a8839e/lib/design/widgets/*.dart` 核对间距、字重（如 Section 标题 `titleMedium w600` 字距 `-0.2`）、圆角与 API 参数名。
2. **补齐缺失的原版组件与主题覆盖下的 Material 控件（`HANDOFF.md §3.3.5–§3.3.6`）**：
   - 补齐原版存在但 `OneUI` 尚未完整实现的组件：`OneMark`（品牌几何标志）、`ObscurableField`（带显隐眼睛图标切换的 14pt 圆角发丝边密码框）、`FeatureFailureNotice`（错误提示卡）、`OneGlassDialog`（超椭圆圆角 `22`、`dialogFill .88`）与 `OneGlassPopupFrame`（二级弹层：iOS 26+ `UIGlassEffect` / 旧系统 `UIBlurEffect(.systemThinMaterial)`，圆角 `22`）、`SystemSwitch`（`UISwitch` 包装）与 `SystemSpinner`（`UIActivityIndicatorView` 包装）。
   - 补齐业务页高频使用的主题化基础控件（`Components/MaterialControls.swift`）：
     - `OneFilledButton`（最小 `44×52`，圆角 `14`，发丝边，`onPrimary .10` 水波纹）、`OneOutlinedButton`、`OneTextButton`（最小 `44×44`，圆角 `14`，常态 `0.8pt` 发丝边 / 聚焦 `2pt` 焦点边）、`OneIconButton`（`44×44`，发丝边）；
     - `OneTextField`（填充 `fill`，圆角 `14`，内边距 `16`，常态发丝边 / 聚焦 `2pt` 焦点色 / 报错 `2pt error`）；
     - `OneDivider`（`outlineVariant` 浅 `.65` / 深 `.45`，高 `0.5pt`）、`OneSnackBarBanner`。
3. **升级 `Gallery/OneGallery.swift` 为全组件对账总览页**：
   - 将上述全部 15+ 组件、按钮四态、输入框三态、状态英雄卡三态及底部 `UltraGlassDock` 编排进 `OneGallery`，方便上 Mac 后一键截图与 `_golden` 270 张基准图逐项比对。

---

### 🤖 子代理 3：`Repo-Wide-Bug-Audit-And-Fixes`（全仓跨模块深度 BUG 扫描与定点修复）

- **独占写入路径**：
  - `Clash-Client/`（仅限 `onetools` 分支自有修改文件与 `_harness/ClashLogic` 同步测试）
  - `SigningLogic/`
  - `adblock/`
  - `tools/`
  - `scripts/mac/`
  - `docs/autorun/`、`docs/findings/`
- **严禁触碰**：`OneUI/**`、`_golden/goldens/**`、以及无自有提交的上游只读目录。

#### 必查与必修清单
1. **`Clash-Client` 自有分支（`e3e6472..HEAD`）深度审计与修复**：
   - 核查 **默认态与冷启动缺口**：在 `VPNController.swift:272` 中 `VPNTunnelSettings.swiptLoopback` 默认是 `true`，但 `ProfileActivationCoordinator.swift:196` 的 `Stages.swiptLoopback` 初始值是 `false`！仔细核查 `ClashTunnelRouteShaping.swiptLoopbackEnabled(in: defaults)` 在 App 首次安装、用户从未进过「隧道设置」页（即 AppGroup `UserDefaults` 中尚未写入 `"vpn.tunnel.swiptLoopback"` 键）时是否准确返回 **`true`**，以及所有调用 `ConfigTransforms.applyClientRuntimePolicy*`（默认参数当前写的是 `swiptLoopback: Bool = false`！）的入口是否存在漏传导致环回地址 `10.7.0.1` 未注入的路径！
   - 核查环回地址合并幂等性：当用户订阅 YAML 的 `tun.loopback-address` 已含 `10.7.0.1`（或含 IPv6 环回、空白字符）时是否严格不重复添加；当 `tun:` 段在原配置中完全不存在时，`root.setting(path: ["tun", "loopback-address"], ...)` 生成的 YAML 结构是否合法且不冲掉默认 `tun` 行为。
   - 若修改了纯逻辑或新增边界用例，运行 `python tools/sync_harness.py`（检查方向与参数！）确保 `_harness/ClashLogic` 与 `Clash-Client` 测试完全一致并通过 WSL `swift test`。
2. **`SigningLogic` 深度边界扫描与单测加固（`SigningLogic/Sources/` & `Tests/`）**：
   - 逐行审查 `ExpiryReminderPlanner.swift` 与 `Batch.swift`：检查时区/夏令时跨日边界、已过期证书重复提醒抑制、空批次/部分失败错误消息透传、`Sendable` 并发安全性（Swift 6 模式告警），补充缺失的极端边界单测并在 WSL 下跑通 `swift test --package-path SigningLogic`。
3. **`tools/*.py` 与 `scripts/mac/*.sh` 门禁与脚本健壮性扫描**：
   - 扫描 `tools/` 下全部 Python 脚本（路径分隔符跨平台兼容、UTF-8 BOM 处理、子进程超时与返回码吞没、与 Stage 0 冻结基线 `_ref/kernel-onewifi-ios-7a8839e` 的兼容性——检查 `closeout_q1.py` 或任何检查 `ONEWIFIX/IOS` 路径的脚本，使其支持冻结基线路径！）。
   - 逐行审查 `scripts/mac/10-env.sh`、`20-clash-client.sh`、`30-swipt.sh`、`35-feather.sh`、`40-verify-windows-work.sh`：
     - 检查 `set -euo pipefail` 下的未绑定变量隐患、带空格路径引号、`OneUI` 新增文件后 `40-verify-windows-work.sh` 的编译/测试命令是否准确覆盖 `OneUI` 与 `OneUICoreTests`；在 WSL 下对全部 `.sh` 跑 `bash -n` 确保语法 0 错误。
4. **`adblock/` 与集成风险核查 + 历史文档矛盾清理**：
   - 复核 `adblock/onetools-cn-ads.plugin` 的 12 条 Loon 规则是否存在误伤正常业务接口（如微信/抖音/淘宝正常 CDN 或登录接口）的过宽正则；
   - **清理文档内部自相矛盾**：订正 `docs/autorun/REPORT.md` 第 `8`、`81`、`131` 行残留的“图标夹具仍阻塞”过时描述，并统一 `docs/autorun/STATE.md` 中“22 项门禁”与 `tools/gates.json` 实际 **21 项**门禁的表述；
   - 将本次全仓静态审计发现的全部问题、已修项、以及留待 Mac 阶段验证项（含许可证冲突备忘与 `onetools://onewifi` URL Scheme 缺口）汇总写入 **`docs/findings/2026-11-21-full-bug-audit.md`**。

---

## 四、Stage 2 · 主代理集成合龙与全量门禁终验（必跑全绿）

三个子代理全部返回后，主代理依次执行以下 **4 道硬门禁**：

```powershell
# 门禁 1：WSL Swift 6.4.2 对 OneUI 视图层全部 .swift 逐文件做语法与接口联检（0 error）
wsl -d Ubuntu-24.04 -u root -- bash -lc '
  set -e
  cd /mnt/e/GQ/Ultra/Onetools-IoS/OneUI
  files=$(find Sources/OneUI -name "*.swift" | tr "\n" " ")
  echo "Parsing files: $files"
  for f in $files; do
    /opt/swift/usr/bin/swiftc -parse "$f"
  done
  echo "ALL_SWIFTUI_FILES_PARSED_OK"
'

# 门禁 2：WSL Swift 6.4.2 跑通全部 4 套纯逻辑 Swift 测试包（OneUI / SigningLogic / ClashLogic / _smoke）
wsl -d Ubuntu-24.04 -u root -- env PATH=/opt/swift/usr/bin:/usr/bin:/bin /opt/swift/usr/bin/swift test --package-path /mnt/e/GQ/Ultra/Onetools-IoS/OneUI
wsl -d Ubuntu-24.04 -u root -- env PATH=/opt/swift/usr/bin:/usr/bin:/bin /opt/swift/usr/bin/swift test --package-path /mnt/e/GQ/Ultra/Onetools-IoS/SigningLogic
wsl -d Ubuntu-24.04 -u root -- env PATH=/opt/swift/usr/bin:/usr/bin:/bin /opt/swift/usr/bin/swift test --package-path /mnt/e/GQ/Ultra/Onetools-IoS/_harness/ClashLogic

# 门禁 3：Python 工具单测 + 全量 21 项自动化门禁全 PASS
Set-Location "e:\GQ\Ultra\Onetools-IoS"
python -m pytest tools -q
python tools/gates.py

# 门禁 4：核验 270 张金图 SHA-256 未发生任何篡改，且只读上游仓全部干净
python -c "import hashlib,pathlib; gs=sorted(pathlib.Path('_golden/goldens').glob('*.png')); h=hashlib.sha256(b''.join(p.read_bytes() for p in gs)).hexdigest(); print('count=',len(gs),'sha256=',h); assert len(gs)==270 and h=='51d437c1c04373e13b9c6362d7dfdd876cebb5e2e3ec4cbd67c06be386fe3a33'"
```

全部 4 道门禁 **100% 退出码为 0** 后，整理变更摘要并输出最终交付报告（严禁推送远端）。
