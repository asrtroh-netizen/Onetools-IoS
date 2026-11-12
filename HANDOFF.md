# OneTools iOS · 交接文档

日期：2026-11-11
工作目录：`/home/ub/work/ios/`（本机 Linux，没有 Xcode；所有 iOS 编译、真机验证都还没做）

---

## 1. 产品目标与已定决策

一个 iOS App 搞定四件事，外加一项后期能力：

| 模块 | 底座 | 状态 |
|---|---|---|
| 代理（Clash） | ProjectClash/Clash-Client（SwiftUI）+ ProjectClash/Clash（mihomo 改版内核） | 已敲定，未改代码 |
| 去广告（网络层） | Clash-Client 自带模块引擎，能解析 Loon / Surge / QX / Stash 插件，含 MITM、重写、脚本 | 已有，缺口见 §4.4 |
| 去广告（界面层） | Swipt + 官方 Swiplet「跳过中国广告」 | 计划并入，未动 |
| 自签 | Feather（证书签，对标全能签、轻松签） | 计划并入，未动 |
| 电话短信互通 | 复用 OneWIFI 的 CallKit / PushKit / 音频桥接 + 后端 APNs | 后期，未动 |
| UI | 完整移植 OneWIFI 的 Flutter 设计系统到 SwiftUI（`OneUI`） | **进行中，停在一半**，见 §3 |

已定决策：

- 一个 App，一个 VPN。Clash 兼任 Swipt 需要的环回 VPN（`tun.loopback-address: [10.7.0.1]`），不再装 LocalDevVPN。
- 前期只做自签：用朋友公司的开发者账号证书，装自己的设备。暂不上架。
- 以 Clash-Client 为主工程（XcodeGen），其余模块往里并。
- 整体许可证 GPLv3，自签自用没有冲突。以后如果要上架，需要重新评估（§7）。
- UI 要求「完整移植、观感一致」，原版有 bug 就顺手修。**不要再加我自己的设计改动**（上一版犯过这个错，见 §3.2）。

---

## 2. 仓库清单

均为 `git clone --depth 1`，工作区干净，没有本地改动。

| 目录 | 来源 | 许可证 | HEAD |
|---|---|---|---|
| `Clash-Client/` | github.com/ProjectClash/Clash-Client | GPL-3.0 | `e3e6472`（2026-10-28） |
| `Clash-Core/` | github.com/ProjectClash/Clash | GPL-3.0 | `e6334ad`（2026-11-07） |
| `Swipt/` | github.com/swipt-automation/swipt | GPL-3.0 | `ab21880`（2026-11-10） |
| `Swiplets/` | github.com/swipt-automation/official-swiplets | GPL-3.0 | `3e37730`（2026-11-10） |
| `Feather/` | github.com/claration/feather | GPL-3.0 | `31ab6de`（2026-11-01），**子模块没拉** |
| `zsign/` | github.com/zhlynn/zsign | MIT | `9299685`（2026-10-20） |
| `OneUI/` | 自建，SwiftUI 包 | 我们的代码 | 无 git |

注意：

- `Clash-Client/Dependencies.lock.json` 锁的内核是 `4b7d5f53c`，而 `Clash-Core/` 拉的是最新 `e6334ad`，两者不一致。正式编译要走 `scripts/bootstrap.py`，它会按锁文件取源码，不要直接用这份 `Clash-Core/`。这份只拿来读代码。
- Feather 的子模块要另外拉：`Zsign`（khcrysalis/Zsign-Package，C++ / OpenSSL）、`IDeviceKitten`（khcrysalis/IDeviceKit，Rust 写的 idevice）。

相关的本机仓库（只读参考，没改动）：

- `/home/ub/work/ONEWIFIX/IOS`：OneWIFI iOS 端（Flutter），UI 移植的来源，也是 CallKit 代码的来源。
- `/home/ub/work/ONEWIFIX/WEB后端`：OneWIFI 后端（Go，MIT），里面有 APNs / VoIP 推送和通话媒体代码。
- `/home/ub/work/Onetools`：Android 版 OneTools，和 iOS 版没有代码关系。

---

## 3. OneUI：当前状态（最重要）

位置：`/home/ub/work/ios/OneUI`（Swift Package，iOS 15+）。
来源：`/home/ub/work/ONEWIFIX/IOS/lib/design`（约 4200 行 Dart）。

### 3.1 现在的状态：资源已换，代码没换

**目前编不过，也不能用。**

- 资源已经按「完整移植」换好：
  - `Resources/Fonts/Montserrat-Regular.ttf`：OneWIFI 原版，SHA-256 `f5a3f02c…348c`，和 IPA 里那份一致。
  - `Resources/Icons/MaterialIcons-Regular.otf`：Flutter 3.44.9 自带的那份，来自 `material_fonts.version` 指向的 fonts.zip，Apache 2.0。
  - Medium / SemiBold / Bold 三个字重已删除。
- 14 个 Swift 文件还是上一版「优化版」，里面引用了已删除的字重，还在用 SF Symbols 和系统 Liquid Glass。这些都要按 §3.3 重写。
- 上一版只用 `swiftc -parse` 过了语法检查，没做类型检查（Linux 上没有 SwiftUI）。

### 3.2 上一版偏离原版的地方，需要全部撤回

| 文件 | 偏离 | 还原成 |
|---|---|---|
| `Tokens/OneFont.swift` | 4 个真字重，绑定了动态字体 | 只用 Regular；600 及以上做合成加粗（§3.3.2）；M3 固定字号、行高、字距 |
| `Glass/GlassSurface.swift` | iOS 26 走 `glassEffect`；磨砂用 `.ultraThinMaterial` | 所有系统版本都用原版配方：模糊 18 / 24 / 12 + 半透明填充 + 发丝边 |
| `Theme/OneTheme.swift` | 用系统 TabView 和 UITabBar 外观 | 手写悬浮胶囊底栏（§3.3.4） |
| 所有组件 | SF Symbols | Material Icons 字形（码点从 Flutter `icons.dart` 取） |
| 所有组件 | `RoundedRectangle(style: .continuous)` | 普通圆角；只有对话框、菜单、Chip 用超椭圆 |
| `Components/Tiles.swift` 等 | `PressableStyle` 按下缩放 | InkRipple 水波纹 + 高光（§3.3.3） |
| `Tokens/OneMetrics.swift` | `PlateTone` 合并成 4 色 | 保留原来 6 个枚举名，API 一一对应；色值照旧（blue = green，purple = teal） |
| `Components/StatusHero.swift` | 加了触感反馈，用了 `ViewThatFits` | 去掉；原版窄屏（< 300pt）是把右上挂件挪到标题下面 |
| `Components/Actions.swift` | `ChoiceChips` 改成横向滚动 | 改回 `Wrap` 折行 |

可以保留（不影响默认观感）：降低透明度时退成实底、VoiceOver 标签。

### 3.3 已核实的原版参数（照这些实现）

来源：OneWIFI 源码，以及 Flutter 3.44.9 源码（下载在 `/tmp/flsrc/`，见 §8）。

#### 3.3.1 色板与玻璃（`one_palette.dart` / `glass.dart`）

- 色板：`OnePalette.swift` 里的值是逐字段搬的，可以继续用。
- `Glass.accent`：primary 亮度 > 0.7 时改用 onSurface。所以浅色强调色是 `#1A1B20`，深色是 `#E2E2E9`（不是纯白）。
- 填充：
  - `fill`：浅 surface .55 / 深 containerHighest .22
  - `fillStrong`：containerLow，浅 .72 / 深 .62
  - `barFill`：浅 surface .86 / 深 containerLow .86
  - `modalFill`：containerLow .92
  - `dialogFill`：containerLow .88
- 发丝边：深色是白 .12。浅色是白 .55 叠在 onSurface .10 上，精确合成结果约 `#EEEEEE`、alpha 0.595（现在代码里写的是 .6，要改准）。线宽 0.8。
- 投影：Flutter blurRadius 换算 sigma 的公式是 `sigma = blur × 0.57735 + 0.5`。SwiftUI `shadow(radius:)` 和 sigma 的对应关系没核实，要截图校准。
  - 深色：单层，黑 .28 / .32，blur 18 / 22，y 8 / 10
  - 浅色：两层，接触影 黑 .08 / .10，blur 6 / 8，y 2 / 3；环境影 黑 .16 / .20，blur 22 / 28，y 10 / 12
- 背景渐变（中性色板）：浅色 `#FFFFFF → #EDEDF4`，深色 `#282A2F → #111318`，从上到下。

#### 3.3.2 字体与文字

- 字体全局 Montserrat，只有 Regular（字重 400）。
- **Skia 合成加粗规则**（`skparagraph/OneLineShaper.cpp`，已核实）：要的字重 ≥ 600，且比字体实际字重高 ≥ 200 时才加粗。
  - 所以 w600 / w700 会合成加粗。
  - **w500 不加粗，直接显示成 Regular**。原版 titleMedium、labelSmall 这些默认 w500 的字，实际看到的都是常规体。
- 加粗量：Skia `setEmbolden` 在字号 9 到 36 之间插值，描边宽度 = 字号 × (1/24 到 1/32)。这组数在 `_ref/NOTES.md:21` 的结论是「一致」（同一行写明 `SkTextFormatParams.h` 第 15–25 行）。
  - iOS 上的实现办法：CoreText `kCTStrokeWidthAttributeName` 设成负值，单位是字号的百分比，例如 16pt 约 -3.9。
  - SwiftUI `Text` 不支持描边属性，需要包一层 UILabel，或者自己写文字渲染。合成加粗会不会改变字宽，也要核实。
- M3 字号标度（`typography.dart` 2021 版，`leadingDistribution: even`）：

| 样式 | 字号 | 字重 | 行高倍数 | 字距 |
|---|---|---|---|---|
| headlineSmall | 24 | 400 | 1.33 | 0 |
| titleLarge | 22 | 400 | 1.27 | 0 |
| titleMedium | 16 | 500 | 1.50 | 0.15 |
| titleSmall | 14 | 500 | 1.43 | 0.1 |
| bodyLarge | 16 | 400 | 1.50 | 0.5 |
| bodyMedium | 14 | 400 | 1.43 | 0.25 |
| bodySmall | 12 | 400 | 1.33 | 0.4 |
| labelLarge | 14 | 500 | 1.43 | 0.1 |
| labelMedium | 12 | 500 | 1.33 | 0.5 |
| labelSmall | 11 | 500 | 1.45 | 0.5 |

- Material 默认文字样式是 bodyMedium。
- Montserrat 的自然行高是 1.219em（upem 1000，ascent 968，descent 251，lineGap 0，use typo metrics）。
  - 单行文字上下各补 `(height − 1.219) × 字号 / 2`。
  - 多行的行间距 = `(height − 1.219) × 字号`。
- 各组件覆盖的字重、字距以原 Dart 文件为准（例如 Section 标题是 titleMedium w600、字距 -0.2）。

#### 3.3.3 水波纹（iOS 上 `splashFactory = InkRipple`；InkSparkle 只在 Android 用）

- 颜色：
  - splash：浅 `0x66C8C8C8` / 深 `0x40CCCCCC`
  - highlight：浅 `0x66BCBCBC` / 深 `0x40CCCCCC`，淡入淡出 200ms
  - 按钮会用自己的 overlayColor 覆盖：Filled 是 onPrimary .1，Text / Outlined 是 primary .1
- 半径：起始 `targetRadius × 0.3`，结束 `targetRadius + 5`，曲线 `Curves.ease`。`targetRadius` 等于盒子对角线的一半。
- 时长：按住未松手时扩散 1s；松手确认后扩散 225ms；淡入 75ms；淡出 375ms，区间从 225/375 开始；取消时 75ms。
- 圆心是触点位置，裁剪到控件形状。

#### 3.3.4 悬浮底栏（`ultra_glass_dock.dart`，不能用系统 TabBar）

- 外边距：左右 16，下方 8 + 安全区底部。
- 胶囊：高 56，圆角 28，模糊 12，无投影。
  - 填充：中性色板用白色，浅 .12 / 深 .06
- 外圈高光：线宽 1.25，从上到下渐变。
  - 深色：`#8CFFFFFF → #1AFFFFFF → #47FFFFFF`，stops 0 / .45 / 1
  - 浅色：`#B8FFFFFF → #2EFFFFFF → #52FFFFFF`，stops 0 / .45 / 1
- 指示条：
  - 内缩 4，高 48，胶囊形
  - 静止填充：深 白 .10 / 浅 onSurface .08；移动中按 `sin(π·t)` 插值到 深 白 .14 / 浅 黑 .10
  - 边缘高光：SweepGradient 描边 1.2，透明度 `.85 × sin(π·t)`，5 个色值见源码
- 滑动：480ms。前沿用 easeOutCubic，后沿用 easeInCubic（`glassDockTabEdges`），切换途中会同时盖住两格。系统开了「减弱动态效果」时直接跳到终点。
- 每一格（M3 NavigationBar，标签始终显示）：
  - 图标 20，标签 labelSmall，选中 w600、未选 w500，颜色 accent / onSurfaceVariant
  - 标签上边距 4，图标和标签作为一组垂直居中
  - 文字不随系统字号缩放
  - 按下水波纹是 accent .10，形状为胶囊
  - 长按出 Tooltip
- 键盘弹出时隐藏整个底栏。
- 页面滚动底部留白 = 56 + 8 + 安全区底部 + 16。

#### 3.3.5 主题覆盖与组件（`one_theme.dart` / `glass.dart` 的 `apply`）

这些是原版观感的一部分，业务页面大量直接用 Material 控件，都会吃到这些覆盖：

- **TextButton / IconButton 带发丝边框**：`focusAwareSide` 平时返回 hairline，聚焦时变成 2px 焦点色。
  - TextButton：最小 44×44，圆角 14
  - IconButton：最小 44×44
- **FilledButton**：最小 44×52，圆角 14，同样带发丝边。primary 浅色是近黑、深色是白。
- **输入框**：填充 `fill`，圆角 14，发丝边；聚焦 2px 焦点色；报错 2px error；内边距 16。
- **Card**：填充 fillStrong，普通圆角 18 + 发丝边；elevation 浅 1 / 深 0。
- **Dialog**：填充 dialogFill，超椭圆圆角 22。
- **Chip**：填充 sheer，发丝边，超椭圆圆角 10。
- **Popup / Menu**：填充 modal，超椭圆圆角 14。
- **AppBar / NavigationBar**：填充 barFill，elevation 0。
- **Divider**：outlineVariant 浅 .65 / 深 .45，粗 0.5。
- **二级弹层**（`OneGlassPopupFrame`）：**原版在 iOS 上用的就是系统玻璃**。iOS 26 及以上是 `UIGlassEffect(.regular)`，更早系统是 `UIBlurEffect(.systemThinMaterial)`，圆角 22。这里照用系统材质就是还原。
- **iOS 原生控件**：原版的 `SystemSwitch` 是 UISwitch，`SystemSpinner` 是 UIActivityIndicatorView，照搬原生即可。
  - `SystemIcon` 的注释写的是 SF Symbol，但实现是 Material `Icon`。以实现为准，用 Material Icons。
- **StatusHero**：
  - 整体：内边距 24，圆角 22，模糊 24
  - 底色：告警 errorContainer .38，忙 primaryContainer .32，就绪 fill
  - 左侧状态图标：38pt，`warning_rounded` / `refresh_rounded` / `check_circle_rounded`
  - 点阵脸：放在 fillStrong 小砖上（圆角 14，内边距 8），脸 36
  - 状态药丸：onSurface .14，内边距 12×6，labelLarge w600
  - 主按钮：白底黑字胶囊，高 52，内边距 16×14，禁用时 .38
  - 阶段：圆点 10，连线 2（亮 .55 / 暗 .18），未亮标签 .32
  - 宽度 < 300 时，右上挂件挪到标题下面
- **OneWIFI 包装层**（`widgets/one_status_hero.dart`）：
  - 状态映射：healthy → ready；critical / attention → inactive；neutral → activating
  - 药丸文字：就绪 / 注意 / 处理中
  - 阶段文字：关闭 / 处理中 / 就绪
- 其余组件逐个对照原文件：`nameplate.dart`、`section.dart`、`glass_tile.dart`、`glass_panel.dart`、`metric_card.dart`、`stage_row.dart`、`soft_label.dart`、`glass_action.dart`、`page_head.dart`、`ow_accent.dart`、`one_mark.dart`、`choice_toggle.dart`、`obscurable_field.dart`、`feature_failure_notice.dart`、`glass_dialog.dart`。

#### 3.3.6 业务页面会用到的 Material 控件（出现次数）

TextField 32、SnackBar 26、TextButton 24、IconButton 24、FilledButton 19（加 `.icon` 8、`.tonal` 2）、RefreshIndicator 14、SwitchListTile 11、CircularProgressIndicator 11、ListTile 10、TextFormField 8、Divider 8、TextButton.icon 7、AlertDialog 6、OutlinedButton(.icon) 8、AppBar 4、LinearProgressIndicator 3、Card 3、TabBar / FilterChip / CheckboxListTile 各 1。

这些控件的 M3 默认值都在 `/tmp/flsrc/*.dart`（§8）。已经确认的几项：

- 三种按钮默认最小尺寸都是 64×40，按下 overlay .1、悬停 .08
- OutlinedButton 默认边框 outline
- NavigationBar 默认高 80，指示条 64×32，标签上边距 4

### 3.4 接下来的顺序

1. **文字层**（最难，先做，先上 Mac 验证）：M3 字号表、行高补偿、w600+ 合成加粗。决定用 UILabel 包装还是自绘。
2. **`MaterialIcon` 视图**：用 `MaterialIcons-Regular.otf` 加码点渲染。码点从 `/tmp/flsrc/icons.dart` 生成；原版用到的 121 个图标名可以这样重新导出：`grep -rhoE "Icons\.[a-z0-9_]+" ONEWIFIX/IOS/lib | sort -u`。
3. **InkRipple 修饰器**（§3.3.3）。
4. **定制模糊半径**（需要你拍板）：SwiftUI 公开接口给不了任意模糊半径。三个方案：
   - `UIVisualEffectView` + `UIViewPropertyAnimator` 停在 fractionComplete，只能近似
   - 私有 `_UICustomBlurEffect` / `CABackdropLayer`，精确，但上架会被拒
   - Metal 自己采样背景，最重

   自签阶段建议用私有 API，把它隔离在一个文件里。
5. **玻璃面**：sheer / fillStrong / frosted / liquid 四档，数值按 §3.3.1 校准。
6. **组件**：按 Dart 文件一对一重写，API 名称保持一致，方便以后对照。
7. **底栏**（§3.3.4）。
8. **主题覆盖下的 Material 控件**（§3.3.5、§3.3.6）。
9. **截图比对验收**（§3.5）。

### 3.5 验收方法

1. 在 OneWIFI 原工程写 Flutter golden 测试，每个组件深浅色各出一张基准图。需要 Flutter 3.44.9 / Dart 3.12.2，本机没装，`which flutter` 为空。
2. 在 Mac 上用 SwiftUI `ImageRenderer` 或模拟器截图，出同尺寸的图。
3. 两边做像素 diff，按差异热点调参，直到只剩抗锯齿差异。
4. 真机上两个 App 并排看磨砂和动画。

### 3.6 原版观察到的问题（顺手修，不改观感）

我没有系统排查过 bug，下面只是读代码时看到的：

- 浅色发丝边的合成值：原版每帧都重新计算 alphaBlend。Swift 里直接写成预合成常量，按 §3.3.1 的精确值。
- `LiquidGlass` 每次 build 都注册一个 postFrameCallback 去量尺寸。SwiftUI 不需要这个。原版代码里也已经没有调用方，可以不移植。
- 原版 `Nameplate.lifted` 的底色硬编码成深色 `0xF2141414`，浅色模式下也是这块深色。是不是有意为之要问你，默认照搬。

---

## 4. 整合：下一步（按顺序）

### 4.1 Clash 默认注入环回地址（Linux 上能做）

- 内核支持：`Clash-Core/listener/config/tun.go:32`（`loopback-address`）→ `listener/sing_tun/server.go:423`。
- 客户端覆盖项：`Clash-Client/apple/ClashClient/Sources/AppArchitecture/ProfileRoutingDomain.swift`，第 64、153、182、201、235、280、304 行。
- 要做：
  - 找到 patch 最终写进配置的位置，默认加上 `10.7.0.1`
  - 设置里加「Swipt 兼容」开关
  - 用户配置里已经写了的话，不重复添加
- Swipt 那边是怎么找 VPN 的：`Swipt/internal/coredevice/vpnpeer/vpnpeer.go`。它扫所有 utun 的网关、目的地址、对端地址，最后兜底试 `10.7.0.1`，不认具体是哪个 App。

### 4.2 双 Go 运行时实验（要 Mac，决定后面的路线）

- Clash：`Clash.xcframework`，gomobile 用 `sagernet/gomobile@v0.1.13`，Go 1.26.10。`project.yml` 里是 `target: Clash, embed: true`，作为动态框架。
- Swipt：`LibSwipt.xcframework`，由 `make lib`（`go run ./internal/cmd/build_libswipt`）生成，Go 1.26.8。
- 实验：在 `ClashiOS` target 里加链 LibSwipt，看会不会符号冲突，以及运行时能不能共存。
  - 能共存：两个框架都嵌进去。
  - 冲突：合成一次 gomobile 编译。要解决依赖冲突：mihomo 自带一份改过的 gvisor（`third_party/gvisor`），sing 用的是 sagernet/gvisor。
- Feather 还会再带进 Rust（IDeviceKit）和 C++（Zsign）。Swipt 自己已经用 Go 实现了 AFC / instproxy（`internal/coredevice/afc`、`instproxy`，目前只有 `internal/computer/guest.go` 在调用），以后考虑只留一套安装通道。

### 4.3 并入 Swipt

- 把 Swift 源码（`Swipt/Swipt/`）、LibSwipt、React Native + Hermes 运行时打包（`make runtime_bundle`，需要 bun，hermesc 只有 osx 版）并进 Clash-Client 的 `project.yml`。
- 首次设置流程：`Swipt/Swipt/Device/SetupView.swift`
  - 去掉 `LoopbackSetupView`（LocalDevVPN 那一页），换成判断 Clash VPN 是否已连接
  - 配对页和自动解锁页保留；自动解锁可以默认跳过
- 首次启动自动装「跳过中国广告」：官方源 URL 在 `Swipt/Swipt/Automation/SwipletStore.swift:433`。
- 模糊匹配默认改成开：`Swiplets/skip-chinese-ads/src/storage.ts` 的 `fuzzySkip` 默认是 `false`。
- 蜂窝网络下不可用：`Swipt/Swipt/Device/DeviceConnection.swift:132` 写死了。换成 Clash 当环回 VPN 之后能不能放开，要实测。
- 系统要求：Swiplet 需要 iOS 17.4 及以上；iOS 26 及更早的设备配对要借电脑（iloader 导出配对文件）。

### 4.4 去广告（网络层）的缺口

代码在 `Clash-Client/apple/ClashClient/Sources/ConfigStore/Module*.swift` 和 `Extension/Module/`，约 2.7 万行。

- Loon 新语法里的 `script(...)` 会被跳过：`ModuleLoonRewriteSyntax.swift` 约 1225 行，`ModuleParser.swift` 约 1377 行（`newerSyntaxNotSupported`）。
- BoxJS 整体被过滤：`boxJSNotSupported`。
- QX 格式的 `[Argument]` 会被跳过：`argumentsNotSupported`。
- `mapLocalNotSupported` 只声明了，没有地方抛出。
- 先实测：导入常用的 Loon 去广告插件，在模块详情里看忽略了哪些条目、原因是什么，再决定补哪些。
- 补规则的检查清单：`Swiplets/skip-chinese-ads/src/rules.ts` 里有 30 多家国内广告 SDK（gdt、csj / pangle、kuaishou、baidu、sigmob、beizi、tobid、ubix……）。逐家核对广告域名，现有规则没覆盖的，写进我们自己的 Loon 插件。

### 4.5 并入 Feather（自签）

- 先拉子模块，确认 Zsign-Package 和 IDeviceKit 怎么编译。
- 关键文件：
  - 签名：`Feather/Utilities/Handlers/SigningHandler.swift`、`ZsignHandler.swift`
  - 安装：`Backend/Server/ServerInstaller*.swift`（本地 HTTPS + itms-services）
  - 证书吊销检测：`Backend/Storage/Storage+Certificate.swift`
  - 签名选项：`Backend/Observable/OptionsManager.swift`
- 直装通道复用 Swipt 的配对和 Clash 的环回地址。
- 要补的（全能签有、Feather 没有）：批量签名、证书到期提醒、到期前一键全部重签。

---

## 5. 电话短信互通（后期）

可复用的 OneWIFI 代码：

- iOS：`ONEWIFIX/IOS/ios/Runner/Calls/`（约 3000 行 Swift，带单测）、`CallAudioBridge.swift`、`APNsBridge.swift`、`OtpNotifier.swift`、`OtpLiveActivity` + `OneWifiIsland`
  - `CallAudioBridge` 依赖 Flutter MethodChannel，要改成纯 Swift。音频格式：8 kHz 单声道 s16le，每帧 160 个样本。
- 后端（MIT）：`ONEWIFIX/WEB后端/internal/server/apns_*.go`、`call_push_api.go`、`internal/callmedia/`、`internal/otprelay/`

建议路线：号码放在网关（4G 模块或 VoWiFi），通话走 SIP，iPhone 用 CallKit 接，音频走 WebSocket。这样绕开了「Android 上没法往通话上行注入音频」的问题。

不能用的：

- `ONEWIFIX/Mac`：PolyForm Noncommercial 许可，和 GPL 不兼容；源自第三方的 Switch 2.67。
- `ONEWIFIX/IOS` 没有 LICENSE 文件。如果全是你自己写的代码就没问题，否则要先确认。

还没解决的：

- `ONEWIFIX/IOS/HANDOFF-GROK-iOS-Pairing.md`（10-09）记录了 iOS 找不到配对入口。配对链接用的是 `onetools://onewifi?...`，但 Onetools 仓库里搜不到对应的实现。

---

## 6. 安全事项

`ONEWIFIX/IOS/HANDOFF-GROK-iOS-Pairing.md` 里有明文凭据：控制台管理员口令、路由盒 root 口令、公网 IP、APNs Key ID 和 Team ID。如果这个文件进过 git 或推过远端，建议改掉这些口令，并把文件移出仓库。我没有检查它的 git 历史。

---

## 7. 风险与合规

- **上架**：
  - 全部依赖都是 GPLv3，fork 别人的 GPL 代码上架有风险；mihomo 原版是 MIT，可以作为退路
  - 中国区 App Store 下架代理类 App
  - CallKit 在中国区不允许
  - 定制模糊用了私有 API 的话会被拒
- **证书**：用朋友公司的证书只给自己的设备签。外发签名包可能导致证书被吊销，会连累他们公司的其他 App。
- **内存**：Packet Tunnel 扩展有内存上限，MITM 和脚本都跑在扩展里。Clash-Client 自带 `ModuleMemoryLadder` 和 `CoreMemoryPressure` 来控制。
- **合规**：国内使用代理工具有合规风险，自行评估。

---

## 8. 本机临时文件（都没删，等你决定）

| 路径 | 大小 | 用途 | 建议 |
|---|---|---|---|
| `/tmp/swiftbin` | 3.5G | Swift 6.4.2 Linux 工具链，只能做 `swiftc -parse` 语法检查 | 不在 Linux 上开发了就删 |
| `/tmp/flsrc` | 3.2M | Flutter 3.44.9 的 Material 源码，§3.3 的参数来源 | 移植完成前保留，或挪进仓库 |
| `/tmp/flfonts` | 7.1M | Flutter fonts.zip 解压结果，Roboto 和 MaterialIcons | 图标已经复制进 OneUI，可以删 |
| `/tmp/sk_*.cpp` | — | Skia skparagraph 源码，合成加粗规则的出处 | 同 flsrc |
| `/tmp/ftenv`、`/tmp/get-pip.py` | 52M | Python 环境，装了 fonttools 和 skia-pathops | 可以删 |
| `/tmp/owipa` | 864K | 从 `OneWIFI.ipa` 解出的 flutter_assets | 可以删 |
| `/tmp/ow_icons.txt` | — | 原版用到的 121 个图标名 | 能重新生成，可以删 |

`/tmp` 重启后可能被清空。`flsrc` 和 `sk_*.cpp` 要留的话，先挪到 `/home/ub/work/ios/_ref/`。

---

## 9. Mac 上要做的（一次跑完）

环境：

- Xcode 27+
- XcodeGen
- Go 1.26.10（Clash）和 1.26.8（Swipt），或者开启 Go 自动切换工具链
- Python 3 + PyYAML
- bun

步骤：

1. 编 Clash-Client：
   ```sh
   python3 scripts/bootstrap.py
   python3 scripts/configure.py --bundle-base <你的前缀> --team <TeamID>
   ```
   然后在 Xcode 里编 `ClashiOS`，自签装上真机。
2. 实测 Loon 插件，按 §4.4 记录被忽略的条目。
3. 编 Swipt：`make lib`、`bun dev frameworks`、`make build_ios`。
4. 双 Go 运行时实验（§4.2）。
5. 在 Xcode 里打开 `OneUI/Package.swift`。要等 §3.4 重写完才能编过，现在打开会报错。
6. 拉 Feather 子模块并编译。
