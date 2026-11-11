# OneTools iOS 执行计划书（总计划）

> 日期：2026-11-11
> 状态：计划稿，等你审阅。计划里的任务一步都还没有执行。
> 执行顺序（2026-11-11 定）：先做不需要 Mac 的部分，细则在同目录的 `2026-11-11-onetools-12h-autorun.md`；需要 Mac 的全部排在最后，顺序见第 7 节开头。
> 依据：仓库根目录的 `HANDOFF.md` + 当日对 `E:\GQ\Ultra\Onetools-IoS` 的实测
> For agentic workers: REQUIRED SUB-SKILL — 执行时用 subagent-driven-development（推荐）或 executing-plans。步骤用 `- [ ]`。

**Goal:** 一个自签的 iOS App，包含 Clash 代理、网络层去广告、界面层去广告（Swipt）、自签（Feather），界面完整还原 OneWIFI 的设计系统；电话短信互通放在后期。

**Architecture:** 以 Clash-Client 的 XcodeGen 工程为宿主，Swipt、Feather、OneUI 各自作为独立 target / Swift 包并入，互不共享编译单元。Clash 的 Packet Tunnel 兼任 Swipt 与直装通道需要的环回 VPN（`tun.loopback-address` 含 `10.7.0.1`）。UI 还原靠「Flutter 出基准图和数值夹具，SwiftUI 对拍」来验收，不靠目测。

**Tech Stack:** SwiftUI / UIKit、XcodeGen、Go（gomobile，两个运行时）、React Native + Hermes（Swiplet 运行时）、Rust（IDeviceKit）、C++ / OpenSSL（Zsign）、Flutter 3.44.9（只用来出基准）。

---

## 0. 这份文档怎么用

- 第 2 节是今天核实的事实，包括交接文档里需要更正的 15 处。后面的计划都建立在这一节上。
- 第 4 节是决策登记。标了「默认」的我先按默认推进，你不同意随时改。
- 第 7、8 节是阶段、闸门和任务。每个任务写了在哪台机器做、动哪些文件、怎么验证、怎样算过。
- 这是总计划。P0 和 P3 已经写到命令和代码级，可以直接执行。P1 给了骨架和场景清单。其余阶段依赖 Mac 上的实验结果，写到任务级并给出分支条件，开工前再出命令级子计划（第 11 节）。
- 不需要 Mac 的部分怎么自动执行（五路子代理、12 小时、中途不问），写在 `2026-11-11-onetools-12h-autorun.md` 里。两份文档说法不一致时，以那一份为准。

---

## 1. 目标、范围、非目标

**范围内**

| 模块 | 交付物 |
|---|---|
| 代理 | Clash-Client 在自签证书下编译、装机、可用 |
| 去广告（网络层） | 现有模块引擎可用；补齐实测发现的解析缺口；一份自有的国内广告 SDK 规则插件 |
| 去广告（界面层） | Swipt 并入，不装 LocalDevVPN，首次启动装好「跳过中国广告」 |
| 自签 | Feather 并入；补批量签名、到期提醒、一键重签 |
| UI | OneUI 包完整还原 OneWIFI 设计系统，并用在宿主外壳上 |
| 电话短信互通 | 后期。本计划只列前置条件，开工前要单独做规格 |

**非目标**

- 上架 App Store。许可证、私有 API、CallKit 中国区限制都按自签自用处理。
- macOS、tvOS 版本。Clash-Client 自带这两个平台的 target，保持能编过即可，不做功能。
- 对原版设计做任何改进。原版有 bug 才修，修法不改变观感。

---

## 2. 基线核实（2026-11-11）

### 2.1 本机环境

本机是 **Windows 10.0.26200**，不是交接文档说的 Linux。交接文档里的 `/home/ub/work/...` 和 `/tmp/...` 在本机都不存在，对应关系如下：

| 交接文档路径 | 本机路径 | 状态 |
|---|---|---|
| `/home/ub/work/ios/` | `E:\GQ\Ultra\Onetools-IoS\` | 在 |
| `/home/ub/work/ONEWIFIX/IOS` | `E:\GQ\Ultra\ONEWIFIX\IOS` | 在，HEAD `7a8839e`（2026-11-02），工作区干净 |
| `/home/ub/work/ONEWIFIX/WEB后端` | `E:\GQ\Ultra\ONEWIFIX\WEB后端` | 在 |
| `/home/ub/work/Onetools` | `E:\GQ\Ultra\Onetools` | 在 |
| `/tmp/flsrc`、`/tmp/flfonts` | `C:\Flutter\flutter`（见下） | 可替代 |
| `/tmp/sk_*.cpp` | 无 | 要重新取，见 T0.3 |

本机工具：git、Go 1.27.0、Python 3.14.6、Node 22.23.1、Rust 1.98.0、**Flutter 3.44.9 / Dart 3.12.2**。没有：Swift、bun、make、cmake、xcodegen、docker。

Swift 可以补上：VS 生成工具 2022（含 MSVC x64 和 Windows SDK 10.0.26100）已装，winget 里有官方的 Swift 6.4.2。装上之后，只依赖 Foundation 的 Swift 代码能在本机编译和跑单测；SwiftUI 和 iOS 的代码仍然不能。

网络（直连，2026-11-11 实测）：GitHub 的 git 协议和 API 可用，下载约 30 KB/s；`raw.githubusercontent.com` 和 googlesource 不通；pub 的国内镜像正常。

WSL 里有一个 `Ubuntu-24.04`，处于停止状态。它是不是交接文档说的那台 Linux，我没有启动它去看：Ubuntu 开机可能清空 `/tmp`，而交接文档 §8 的临时文件写着「等你决定」。本计划不依赖那些文件。

### 2.2 与交接文档一致、已复核的

- 六个仓库的 HEAD（`e3e6472`、`e6334ad`、`ab21880`、`3e37730`、`31ab6de`、`9299685`），全部是浅克隆。
- `Clash-Client/Dependencies.lock.json` 锁的内核是 `4b7d5f53c…`，gomobile 是 `sagernet/gomobile@v0.1.13`。Swipt 的 `go.mod` 用的也是 `sagernet/gomobile v0.1.13`。
- 环回地址的代码位置：`Clash-Core/listener/config/tun.go:32`、`listener/sing_tun/server.go:423`、`ProfileRoutingDomain.swift` 的 64 / 153 / 182 / 201 / 235 / 280 / 304 行。
- Swipt：`vpnpeer.go` 最后兜底试 `10.7.0.1`；`SetupView.swift:28` 和 `:82` 是 `LoopbackSetupView`；`SwipletStore.swift:433` 是官方源 URL；`DeviceConnection.swift:132–135` 在蜂窝网络下直接不探测。
- `Swiplets/skip-chinese-ads/src/storage.ts:121` 的 `fuzzySkip` 默认是 `false`。
- 模块引擎的四个忽略原因：`newerSyntaxNotSupported`（`ModuleLoonRewriteSyntax.swift:1230`、`ModuleParser.swift:1378`）、`boxJSNotSupported`（`ModuleLineSyntax.swift:693`、`ModuleLoonRewriteSyntax.swift:1645` 和 `:1747`）、`argumentsNotSupported`（`ModuleQuantumultXParser.swift:46`）、`mapLocalNotSupported`（只在 `ModuleIR.swift:1385` 声明，没有地方抛出）。
- Feather 的四个关键文件都在；`Zsign/` 和 `IDeviceKitten/` 是空目录。
- OneUI 资源：`Montserrat-Regular.ttf` 的 SHA-256 与 OneWIFI `assets/fonts/` 里那份相同（`F5A3F02C…348C`）；`MaterialIcons-Regular.otf` 与本机 Flutter 缓存里那份相同（`D9865B67…2453`）。
- OneWIFI 源码里用到的 `Icons.*` 去重后是 121 个。
- §3.3 的参数我抽查了 `glass.dart`、`one_theme.dart`、`glass_surface.dart`、`system_controls.dart`、`adaptive_glass_dock.dart`：填充、描边、投影、圆角、底栏尺寸、主题覆盖、二级弹层用系统材质、`SystemIcon` 实际是 Material 图标、底栏不用系统 TabBar，二十多项全部对得上。

### 2.3 需要更正或补充的

| # | 交接文档的说法 | 实测 | 对计划的影响 |
|---|---|---|---|
| 1 | 本机 Linux | 本机 Windows，路径见 2.1 | 所有命令按 PowerShell 写；Mac 步骤单列 |
| 2 | 工作区干净 | Swipt 3 个、Feather 1 个、zsign 2 个文件显示已修改。内容没变，只是可执行位：仓库配置 `core.filemode=true`，Windows 上读不到 755 | T0.1 修掉，否则以后的 diff 都带噪音 |
| 3 | 本机没装 Flutter，golden 要等 | `C:\Flutter\flutter` 就是 3.44.9 / Dart 3.12.2 | Golden 基准现在就能做，提前到 P1，不再等 Mac |
| 4 | Material 源码在 `/tmp/flsrc` | 本机 SDK 的 `packages\flutter\lib\src\material\` 就是同一版本；框架版本 `6b182d2c75…`，引擎 `5a2a6a42…`，Skia 钉在 `e9ed4fc9f1544c58d8a9347c1fc9471d8dd7c465` | T0.3 从 SDK 固化一份到 `_ref/` |
| 5 | 只有 Feather 的子模块没拉 | Swipt 也有一个：`Swipt/Resources/DeveloperDiskImage`，目录是空的 | P2 编 Swipt 前要拉 |
| 6 | 没提 | 三个工程的最低系统和 Swift 语言模式不同：Clash-Client iOS 15.0 / Swift 5.9；Swipt iOS 16.4 / Swift 6.0；Feather iOS 16.0 / Swift 5.0 | 合并后 App 最低 iOS 16.4；三者必须是独立 target，不能把源码倒进一个 target（D2、5.2） |
| 7 | 没提 | `OneUI/Package.swift` 的 resources 只声明了 `Resources/Fonts`，`Resources/Icons` 没进包 | P4 第一步修 |
| 8 | 模块引擎约 2.7 万行 | `ConfigStore/Module*.swift` 74 个文件 45,181 行，`Extension/Module/` 29 个文件 22,758 行，合计约 6.8 万行（含空行） | P6 的工作量按这个规模估 |
| 9 | 模糊 18 / 24 / 12 | 这些数是 `ImageFilter.blur(sigmaX:, sigmaY:)` 的 **sigma**，不是半径 | iOS 上的模糊半径要换算并截图校准，写进 G3 |
| 10 | 凭据文件没查 git 历史 | `HANDOFF-GROK-iOS-Pairing.md` 被 `.gitignore:61` 忽略，没有被追踪；`git log --all` 在本地全部引用（含三个远端的跟踪分支）里都没有它 | 没进过这个仓库的历史。明文口令仍在磁盘上，改不改由你定（T0.6） |
| 11 | 4.1 在 Linux 上能做 | Clash-Client 整个仓库没有任何测试 target | P3 要自己加一个测试 target，否则没法先红后绿 |
| 12 | 没提 | `Repository.official` 只有在 Info.plist 的 `SwiptChannel` 等于 `stable` 时才用稳定源，否则用 nightly | 并入时必须把这个键带进宿主的 Info.plist |
| 13 | 没提 | 最新内核里环回是在 IP 层做的：`third_party/sing-tun/ip_rewrite.go` 命中环回地址就交换源和目的地址再写回，不分 TCP / UDP | 对 Swipt 是好消息。但这是 `e6334ad` 的代码，锁定的 `4b7d5f5` 要在 Mac 上再确认（T2.2） |
| 14 | Skia 加粗参数待核实 | 本机直连 `raw.githubusercontent.com` 被重置（试了一次），没取到源码 | 仍未核实。T0.3 走代理取 |
| 15 | §3.3 是全部参数 | `glass.dart` 里还有交接文档没列的：`blurredBarFill`、`liquidFill`、`liquidHighlight`、间距标度（2 到 24）、`pageMargin 16`、`cardGap 14`、`padCard 16`、`radiusHero 22`、Card 阴影色、BottomSheet / Drawer / SearchBar / ExpansionTile 的主题覆盖 | Dart 源文件是唯一依据，§3.3 只当摘要用 |

规模参考（含空行）：Clash-Client `apple/` 下 Swift 822 个文件 388,712 行；Swipt Swift 63 个文件 9,893 行，Go 233 个文件 51,263 行；Feather Swift 97 个文件 11,010 行；OneWIFI `ios/Runner/Calls/` 9 个文件 3,038 行；OneWIFI `lib/design/` 32 个 Dart 文件。

### 2.4 还没核实的

- 任何 iOS 编译和真机行为。要 Mac。
- 锁定内核 `4b7d5f5` 的环回实现。不要 Mac：读源码就能确认，排进 12 小时计划的 C2。
- Skia 合成加粗的数值（字号 9 到 36、系数 1/24 到 1/32）。不要 Mac：12 小时计划的 C1。
- Feather 和 Swipt 子模块的内容和编译方式。内容不要 Mac：12 小时计划的 C3；实际编译要 Mac。
- CJK 文字的回退字体行为（见 P2 的 S1）。

---

## 3. 全局约束

1. 一个 App，一个 VPN。不装 LocalDevVPN。
2. 只自签，装自己的设备。签名包不外发。
3. 宿主是 Clash-Client 的 XcodeGen 工程，改 `project.yml`，不手改 `.xcodeproj`。
4. 整体 GPLv3。OneWIFI 的 Mac 端（PolyForm Noncommercial）一行都不能用。
5. UI 完整移植、观感一致。不加设计改动。Dart 源文件是依据，Swift 的 API 名和 Dart 一一对应。
6. 可以保留的无障碍行为：降低透明度时退成实底、VoiceOver 标签。
7. 正式编译内核走 `scripts/bootstrap.py`，按锁文件取源码。`Clash-Core/` 只读。
8. 私有 API 只允许出现在 `OneUI/Sources/OneUI/Glass/BackdropBlurView.swift` 一个文件里。
9. 所有文本文件用 LF。Windows 和 Mac 之间只通过 git 传代码，不拷工作区。
10. 没有本轮跑出来的验证输出，就不说「完成」。Windows 上写的 Swift 在 Mac 编过之前，状态一律是「已写，未编译」。

---

## 4. 决策登记

### 4.1 已定（来自交接文档）

一个 App 一个 VPN；前期只自签；Clash-Client 为主工程；GPLv3；UI 完整移植不加改动。

### 4.2 按默认推进，等你确认

| 编号 | 事项 | 默认 | 理由 |
|---|---|---|---|
| D1 | 仓库怎么管（**2026-11-11 你已同意**，只做本地提交，不推送） | 顶层建一个自己的 git 仓库，放 `OneUI/`、`docs/`、`_golden/`、`_ref/`、`tools/`；六个上游目录先忽略，用 `upstreams.lock.json` 记 SHA；要改的上游仓库各开一条 `onetools` 分支。你建好 fork 后再改成子模块 | 不用等 fork 就能开工，又不丢上游关系 |
| D2 | 最低系统 | iOS 16.4。Swiplet 功能运行时判断 17.4 | Swipt 的工程就是 16.4，降不下去 |
| D3 | 定制模糊 | 私有 API，隔离在一个文件，带公开 API 的近似实现作为编译开关 | 交接文档的建议。G3 出对比图后你最终确认 |
| D4 | `Nameplate.lifted` 浅色模式下也是深色底 | 照搬 | 交接文档的默认 |
| D5 | 页签 | 四个：代理、去广告、自签、设置 | 四件事各一个入口。名字和顺序你可以改 |
| D6 | OneUI 用到多深 | 先做外壳（底栏、首页、设置）。各模块原有页面先保持原样，之后按页推进 | Clash-Client 的 UI 代码量极大，一次换完不现实 |
| D7 | 「模糊跳过」默认开 | 第一阶段不改 Swiplet，首次设置里引导你点一下开关 | 改默认值要 fork 官方 Swiplet 仓库、自己出包、自己托管源，而官方几乎每天更新。等基本功能稳定后再做 |
| D8 | iCloud 能力 | 自签构建里去掉 | 朋友的账号少配一项能力；本机用不上跨设备同步 |

### 4.3 需要你提供

| 编号 | 事项 | 卡住什么 |
|---|---|---|
| I1 | Mac 什么时候能用，怎么用（你自己操作并回传日志，还是能 SSH）。**2026-11-11 答复：Mac 还没着落。** 用法等有了 Mac 再定 | P2 之后的全部。这是整个计划里最大的不确定项。在此之前能做的见 12 小时计划 |
| I2 | Bundle ID 前缀、Team ID、朋友账号能否开 Network Extensions 和 App Groups、设备 UDID 是否已注册 | T0.5、P2 装机 |
| I3 | `ONEWIFIX/IOS` 是否全部是你自己写的代码（仓库里没有 LICENSE）。**2026-11-11 答复：全部归你或你有权使用。** | P4 用它的设计、P9 用它的通话代码 |
| I4 | `HANDOFF-GROK-iOS-Pairing.md` 里的口令改不改 | 不卡进度，属于安全事项 |
| I5 | 实测用哪些 Loon 插件。**2026-11-11 答复：由我挑 5 到 10 个常见的。** | T2.8 |

---

## 5. 架构与集成策略

### 5.1 目录布局

```
Onetools-IoS/                     # 顶层仓库（T0.2 建）
  HANDOFF.md
  upstreams.lock.json             # 六个上游的 URL + SHA
  docs/superpowers/plans/         # 本文和子计划
  docs/decisions/                 # 闸门结论，带测量数据
  docs/findings/                  # 实测记录（Loon 忽略条目等）
  _ref/                           # Flutter Material 源码快照、Skia 源文件
  _golden/                        # Flutter 包：出基准图和数值夹具
  tools/                          # golden_diff、图标码点生成脚本
  OneUI/                          # Swift 包
  Clash-Client/  （onetools 分支）  # 宿主
  Swipt/         （onetools 分支）
  Swiplets/      （只读，D7 改了再动）
  Feather/       （onetools 分支）
  Clash-Core/、zsign/             # 只读参考
```

### 5.2 Xcode target 划分

宿主 `Clash-Client/apple/ClashClient/project.yml` 现有 4 个 iOS target：`ClashiOS`、`ClashiOSExtension`（Packet Tunnel）、`ClashControlsExtension`、`ClashShareExtension`，以及把 Go 静态库包成动态框架的 `Clash`。

并入后新增：

| target / 包 | 类型 | 语言模式 | 内容 |
|---|---|---|---|
| `OneUI` | 本地 Swift 包 | Swift 5.9 | 设计系统 |
| `SwiptCore` | 动态框架 | — | 照 `Clash` target 的做法包 `LibSwipt.xcframework` |
| `SwiptUI` | 框架 | Swift 6.0 | `Swipt/Swipt/` 的 Swift 源码，`@main` 改成导出的根视图 |
| `FeatherUI` | 框架 | Swift 5.0 | `Feather/Feather/` 的 Swift 源码，同样导出根视图 |

三套代码各有自己的 `SettingsView`、`App` 之类的同名类型，语言模式也不同，所以只能分模块。宿主只认每个模块导出的一个根视图和几个生命周期入口。

每个模块搬进框架后要查三样东西：

- `Bundle.main` 的用法。读 Info.plist 键的保留，并把键加到宿主 Info.plist；读资源的改成框架自己的 bundle。
- Info.plist 键。Swipt 需要带过去的有：`BGTaskSchedulerPermittedIdentifiers`、`NSBonjourServices`（`_remotepairing._tcp`、`_remotepairing-pairable-host._tcp`、`_swipt._tcp`）、`UIBackgroundModes` 的 `location`、`.swiplet` 文档类型和导出类型、`UIFileSharingEnabled`、`SwiptChannel = stable`。`LSApplicationQueriesSchemes` 里的 `localdevvpn` 不再需要。
- Entitlements。宿主已有 App Groups 和 Network Extension。Swipt 的 App Group 改指宿主那一个。Feather 只要 `get-task-allow`，开发证书自带。

### 5.3 双 Go 运行时

`project.yml` 里，`Clash` 是一个框架 target，用 `-force_load` 把 Go 静态库整个链进去；主 App 嵌入它（`embed: true`），Packet Tunnel 扩展链接它（`embed: false`）。Swipt 的 Go 代码只在主 App 里用。

由此得出两点：

- **扩展进程里只有 Clash 一个 Go 运行时**，扩展的内存上限不受 Swipt 影响。
- **主 App 进程里会同时有两个 Go 运行时**。两边用的是同一个 gomobile 版本，只要 LibSwipt 也照 `Clash` 的做法包进自己的框架，链接期不会撞符号。运行期有一个已知的观察点：两个框架都带 gomobile 生成的 `ref.h` 和 `Universe.objc.h`，也就是两个镜像里有同名的 ObjC 类。

第一点可以从工程配置直接读出来，第二点能不能稳定共存要靠 G2 实验。

### 5.4 单 VPN 的数据通路

1. 设置里「Swipt 兼容」开着（默认开），生成运行时配置时往 `tun.loopback-address` 里补 `10.7.0.1`，用户已经写了就不动（P3）。
2. 扩展从内核选项里读到环回地址，把 `10.7.0.1/32` 加进隧道的 includedRoutes。这段代码已经有了：`ExtensionProvider.swift:2359–2363`。
3. Swipt 拨 `10.7.0.1:端口`，包进 utun，内核发现目的地址在环回表里，交换源和目的地址后写回。系统把它当成从 `10.7.0.1` 发来的入站连接交给本机的 lockdownd / remotepairing。
4. Swipt 的 `vpnpeer` 会并发试所有 utun 的网关、目的地址、对端地址，再加 `10.7.0.1`，谁先把令牌回环回来就用谁。预期其他候选在 Clash 下会被代理栈接走、令牌回不来，不影响 `10.7.0.1` 那一路。这一条在 G5 实测。

### 5.5 验证分层

| 层 | 手段 | 在哪跑 |
|---|---|---|
| 纯逻辑（环回合并、字号表、水波纹曲线、底栏插值、图标码点） | Swift 包单测；期望值来自 Dart 导出的 JSON 夹具 | 只依赖 Foundation 的部分先在 Windows 上用 `swift test` 跑（装 Swift for Windows 之后），到 Mac 再跑一遍。Mac 上 `ClashClientUI` 支持 macOS，用 `swift test`；`OneUI` 只支持 iOS，用 `xcodebuild test` 在模拟器上跑 |
| 解析器（Loon / QX 语法） | 给宿主加单测 target，用插件文件做夹具 | Mac `xcodebuild test` |
| UI 还原 | Flutter 基准图 + `tools/golden_diff` 像素对拍 | 基准在 Windows 出，对拍在 Mac |
| 磨砂、动画、CJK 文字 | 真机上和 OneWIFI 原 App 并排 | 真机 |
| 集成 | 真机检查单，每条写明可观察的预期 | 真机 |

---

## 6. 环境矩阵

| 事情 | Windows（现在） | Mac | 真机 |
|---|---|---|---|
| 仓库整理、文档、子计划 | 可以 | — | — |
| Flutter 基准图和数值夹具 | 可以 | — | — |
| 图标码点表、规则域名核对 | 可以 | — | — |
| 写 Swift（不能编译） | 可以，状态记为「未编译」 | — | — |
| 只依赖 Foundation 的 Swift 单测 | 装了 Swift for Windows 之后可以 | 再跑一遍 | — |
| 编译任何 iOS 代码、SwiftUI 代码 | 不行 | 必须 | — |
| gomobile、`make lib`、hermesc、xcodegen | 不行 | 必须 | — |
| VPN、配对、Swiplet、签名安装 | 不行 | 装机用 | 必须 |

Mac 需要装：Xcode 27 以上、XcodeGen、Go（开自动工具链切换，Clash 要 1.26.10，Swipt 要 1.26.8）、Python 3 + PyYAML、bun、xcbeautify（Swipt 的 Makefile 用）、jq（Feather 的 Makefile 用）、Rust（IDeviceKit，拉了子模块后确认）。

---

## 7. 阶段与闸门

**执行顺序（2026-11-11 定）：需要 Mac 的全部排在最后。**

- **第一段，不需要 Mac**：P0、P1、P3 的代码和纯逻辑单测，再加 P4、P6、P7 里只依赖 Foundation、能在 Windows 上验证的部分（OneUI 的数值层、广告规则插件、解析器测试台、自签的日期逻辑）。这一段由 12 小时计划自动执行。
- **第二段，需要 Mac**：P2、P3 的真机验证、P4 的界面层、P5、P6 余下的部分、P7、P8、P10。Mac 到位后按 12 小时计划第 12 节的 M0 到 M10 的顺序做。P9 另行规格。

下表按阶段编号列，不代表先后；先后以上面两段为准。

| 阶段 | 内容 | 机器 | 前置 | 粗估（人日） |
|---|---|---|---|---|
| P0 | 工程地基 | Windows | — | 0.5–1 |
| P1 | Golden 基准与数值夹具 | Windows | P0 | 3–5 |
| P3 | Clash 环回（Swipt 兼容开关） | 写在 Windows，验在 Mac | P0 | 1–2 |
| P2 | Mac 首次全量构建 + 三项技术验证 | Mac + 真机 | P0，I1，I2 | 3–6 |
| P4 | OneUI 重写 | Mac 为主 | P1，G3 | 15–25 |
| P5 | 外壳 + 并入 Swipt、Feather | Mac + 真机 | G1，G2，P3 | 10–20 |
| P6 | 网络层去广告补缺 | Mac | T2.8 的数据 | 5–12 |
| P7 | 自签增强 | Mac + 真机 | P5 | 4–6 |
| P8 | OneUI 按页推进 | Mac | P4，P5 | 按页计，不设总数 |
| P9 | 电话短信互通 | — | 单独规格，I3 | 规格后再估 |
| P10 | 收尾加固 | Mac + 真机 | P5–P7 | 2–3 |

粗估是按代码量和一个人带 Mac 连续干来算的，不是承诺。P2 第一次编三个陌生工程，最容易超。

**闸门**

| 闸门 | 判定 | 通过后放行 |
|---|---|---|
| G0 | 仓库状态干净，顶层仓库建好，证书能力确认 | P1、P3、P2 |
| G1 | Clash-Client、Swipt、Feather 各自在真机上跑通原版功能 | P5 |
| G2 | 双 Go 运行时实验有结论：共存（A）或冲突（B） | P5 的 Swipt 路线 |
| G3 | 文字、模糊、投影、水波纹、出图方式五项技术路线定下来，附对比数据 | P4 |
| G4a | OneUI 全部场景通过像素对拍 | P8 |
| G4b | 真机并排，磨砂、动画、中文文字你看过点头 | P8 |
| G5 | 不装 LocalDevVPN，Clash 连着时 Swipt 能配对并跑 Swiplet | P5 收尾 |
| G6 | 合并后的 App 连续日用三天无崩溃、无断流 | P10 |

关键路径：I1（Mac）→ P2 → G2 / G3 → P4 / P5。Mac 到位之前，第一段的内容由五条子代理工作线并行做完，不浪费时间。

---

## 8. 分阶段任务

### P0 工程地基（Windows）

**T0.1 修掉假改动，固定换行**

- [ ] 执行：

```powershell
$w = 'E:\GQ\Ultra\Onetools-IoS'
foreach ($d in 'Clash-Client','Clash-Core','Swipt','Swiplets','Feather','zsign') {
  git -C "$w\$d" config core.filemode false
  git -C "$w\$d" config core.autocrlf false
  "$d : $((git -C "$w\$d" status --porcelain | Measure-Object).Count)"
}
```

- [ ] 预期：六行都是 `: 0`。

**T0.2 顶层仓库**

- [ ] 在 `E:\GQ\Ultra\Onetools-IoS` 建 `.gitattributes`，内容一行：`* text=auto eol=lf`。
- [ ] 建 `.gitignore`，忽略六个上游目录：`/Clash-Client/`、`/Clash-Core/`、`/Swipt/`、`/Swiplets/`、`/Feather/`、`/zsign/`，以及 `/_golden/.dart_tool/`、`/_golden/build/`。
- [ ] 建 `upstreams.lock.json`，六项，每项 `{ "path", "url", "revision" }`，SHA 用 `git -C <目录> rev-parse HEAD` 的完整值。
- [ ] `git init`，`git add -A`，提交 `chore: 顶层仓库与上游锁定`。
- [ ] 对要改的三个上游（Clash-Client、Swipt、Feather）：`git fetch --unshallow`（要代理），然后 `git switch -c onetools`。
- [ ] 预期：`git -C Clash-Client rev-parse --is-shallow-repository` 输出 `false`；`git -C Clash-Client branch --show-current` 输出 `onetools`。Swipt、Feather 同理。

**T0.3 固化参考源**

- [ ] 把 `C:\Flutter\flutter\packages\flutter\lib\src\material\` 整个目录复制到 `_ref\flutter-3.44.9\material\`。
- [ ] 建 `_ref\NOTES.md`，记录：Flutter 3.44.9，框架 `6b182d2c7585eba26d4edce0f97630effd256c33`，引擎 `5a2a6a42cce67f965cf540fcecf616faca624aa1`，Skia `e9ed4fc9f1544c58d8a9347c1fc9471d8dd7c465`。
- [ ] 走代理从 Skia 仓库按上面的版本取三个文件到 `_ref\skia\`：`src/core/SkScalerContext.cpp`、`src/core/SkFontPriv.h`、`modules/skparagraph/src/OneLineShaper.cpp`。
- [ ] 在三个文件里搜 `FakeBold` 和 `Embolden`，把合成加粗的字号区间和系数抄进 `NOTES.md`，写明文件和行号。
- [ ] 预期：`NOTES.md` 里有一句明确结论——「与交接文档 §3.3.2 的 9 到 36、1/24 到 1/32 一致」或「不一致，实际是……」。不一致就先改 P4 的字体规格再开工。

**T0.4 OneWIFI 图标清单**

- [ ] 执行：

```powershell
rg -o --no-filename --no-line-number 'Icons\.[a-z0-9_]+' 'E:\GQ\Ultra\ONEWIFIX\IOS\lib' |
  Sort-Object -Unique | Set-Content -Encoding utf8 'E:\GQ\Ultra\Onetools-IoS\_ref\ow_icons.txt'
```

- [ ] 预期：文件 121 行。

**T0.5 证书能力核对（你和朋友）**

- [ ] 定 Bundle ID 前缀和 Team ID（I2）。
- [ ] 朋友的账号里建 4 个 App ID，对应 `ClashiOS`、`ClashiOSExtension`、`ClashControlsExtension`、`ClashShareExtension`。
- [ ] 能力：四个都开 App Groups（同一个 group）；主 App 和 Packet Tunnel 扩展开 Network Extensions。
- [ ] 你的设备 UDID 已注册，四个开发描述文件能下载。
- [ ] 预期：四个 `.mobileprovision` 到手。到不了手，P2 只能做「无签名编译」，不能装机。

**T0.6 安全与许可（你）**

- [ ] I3：确认 `ONEWIFIX/IOS` 的代码归属。
- [ ] I4：决定是否更换 `HANDOFF-GROK-iOS-Pairing.md` 里的口令。

**P0 出口（G0）**：T0.1 到 T0.4 的预期全部满足；T0.5 有结论（能或不能）。

---

### P1 Golden 基准与数值夹具（Windows）

目的：在动 OneUI 之前，先把「原版长什么样」固定成文件。后面每个组件写完，都和这里的图和数对拍。

**做法**

- `_golden/` 是一个独立的 Flutter 包，通过路径依赖引用 OneWIFI（包名 `onewifi_android`），只读，不改 OneWIFI 仓库。
- 字体在测试启动时手工加载。Flutter 的组件测试默认用占位字体，不加载就全是方块。

`_golden/pubspec.yaml`：

```yaml
name: onetools_golden
publish_to: none
environment:
  sdk: ^3.12.2
dependencies:
  flutter:
    sdk: flutter
  onewifi_android:
    path: ../../ONEWIFIX/IOS
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
```

`_golden/test/flutter_test_config.dart`：

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 路径相对于 _golden/。两个字体在 T1.1 里复制进来，这个包不依赖别的目录怎么摆。
  await _load('Montserrat', 'fonts/Montserrat-Regular.ttf');
  await _load('MaterialIcons', 'fonts/MaterialIcons-Regular.otf');
  await testMain();
}

Future<void> _load(String family, String path) async {
  final bytes = await File(path).readAsBytes();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}
```

`_golden/test/support/scene.dart`：

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onewifi_android/design/one/glass.dart';
import 'package:onewifi_android/design/theme/one_theme.dart';

/// 每个场景出深浅两张图：goldens/<name>.light.png 和 goldens/<name>.dark.png。
void goldenScene(String name, Widget Function() build, {Size size = const Size(390, 844)}) {
  for (final brightness in Brightness.values) {
    testWidgets('$name ${brightness.name}', (tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = size * 3.0;
      addTearDown(tester.view.reset);
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      debugDisableShadows = false;
      try {
        final dark = brightness == Brightness.dark;
        final theme = dark ? OneTheme.dark() : OneTheme.light();
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: DecoratedBox(
            decoration: BoxDecoration(gradient: Glass.backdrop(theme.colorScheme, dark)),
            child: Scaffold(body: Center(child: build())),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 500));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../../goldens/$name.${brightness.name}.png'),
        );
      } finally {
        debugDisableShadows = true;
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
```

**T1.1 骨架跑通**

- [ ] 把 `E:\GQ\Ultra\ONEWIFIX\IOS\assets\fonts\Montserrat-Regular.ttf` 和 `OneUI\Sources\OneUI\Resources\Icons\MaterialIcons-Regular.otf` 复制到 `_golden\fonts\`。预期：SHA-256 分别以 `F5A3F02C` 和 `D9865B67` 开头。
- [ ] 建上面三个文件，再建 `_golden/test/scenes/a1_typography_test.dart`，用 `goldenScene('a1_typography', …)` 画一列文字：10 个 M3 样式各一行，内容用 `Hamburgefonstiv 0123456789`。
- [ ] 执行 `flutter pub get`，再 `flutter test --update-goldens`。
- [ ] 预期：`_golden/goldens/a1_typography.light.png` 和 `.dark.png` 生成，1170×2532 像素，文字是 Montserrat 而不是方块。
- [ ] 再执行 `flutter test`（不带参数）。预期：`All tests passed!`，证明出图是确定的。

**T1.2 `tools/golden_diff`**

- [ ] 写 `tools/golden_diff.py`（Pillow + numpy）：输入两个目录，按文件名配对，输出每张图的差异像素占比、最大通道差、一张热力图，和一份 `report.json`。尺寸不同直接判失败。
- [ ] 先写它的测试 `tools/test_golden_diff.py`：同一张图比自己，差异为 0；把一张图的一个 10×10 区域改色后再比，差异像素数恰好 100。
- [ ] 先装依赖：`python -m pip install pillow numpy pytest`。
- [ ] 执行 `python -m pytest tools/test_golden_diff.py -q`。预期：先失败（脚本还没写），实现后 2 个通过。

**T1.3 场景清单**

每个场景深浅各一张。文字一律用拉丁字母和数字（原因见本节末尾的限制）。

| 组 | 场景 | 来源 |
|---|---|---|
| A 基元 | `a1_typography` 10 个样式 | M3 字号表 |
| | `a2_weights` 字重 400 / 500 / 600 / 700 × 字号 11、12、14、16、22、24 | 合成加粗 |
| | `a3_icons` 121 个图标，20 和 24 两个尺寸 | `_ref/ow_icons.txt` |
| | `a4_fills` 五种填充 + 发丝边，放在背景渐变上 | `glass.dart` |
| | `a5_shadows` 普通和强投影 | `Glass.shadow` |
| | `a6_ripple_hold` 按住 0 / 75 / 200 / 500 / 1000 ms | InkRipple |
| | `a7_ripple_confirm` 松手后 0 / 75 / 225 / 400 / 600 ms | InkRipple |
| B 组件 | `nameplate`、`section`、`glass_tile`、`glass_panel`、`metric_card`、`stage_row`、`soft_label`、`glass_action`、`page_head`、`ow_accent`、`one_mark`、`choice_toggle`、`obscurable_field`、`feature_failure_notice`、`glass_dialog`、`dot_matrix_face` 各一个 | `widgets/*.dart`、`one/dot_matrix_face.dart` |
| | `status_hero_ready` / `_busy` / `_alert`，宽 390 和宽 280 各一套 | `one_status_hero.dart` |
| C 主题控件 | `text_field`（空、聚焦、报错）、`text_button`（含带图标）、`icon_button`、`filled_button`（普通、带图标、tonal、禁用）、`outlined_button`、`card`、`alert_dialog`、`snack_bar`、`list_tile`、`switch_list_tile`、`checkbox_list_tile`、`divider`、`progress`（线形和圆形，固定进度值）、`app_bar`、`tab_bar`、`filter_chip`、`popup_menu` | §3.3.6 |
| D 底栏 | `dock_static_0` 到 `dock_static_3`（四个页签各选中一次） | `ultra_glass_dock.dart` |
| | `dock_slide_t000` / `t025` / `t050` / `t075` / `t100`（从第 0 格滑到第 2 格） | 480 ms 动画 |
| | `dock_pressed` | 胶囊水波纹 |

- [ ] 按组写场景文件，每组一个提交。含 `SystemSwitch`、`SystemSpinner` 的场景要先给平台视图通道装空实现，否则测试里建不出 `UiKitView`。
- [ ] 预期：`flutter test` 全过；`goldens/` 下大约 110 张图（56 个场景，深浅各一张）。

**T1.4 数值夹具**

用一个测试把数值写成 JSON，放在 `_golden/fixtures/`，P4 的 Swift 单测直接读这些文件做断言。

| 文件 | 内容 |
|---|---|
| `tokens.json` | `oneBlackWhiteLight` / `oneBlackWhiteDark` 两个 ColorScheme 的全部字段（ARGB 十六进制）；`Glass` 的全部常量；五种填充、描边、两档投影在深浅色下的解析结果；背景渐变的两个端点；`Glass.accent` |
| `typography.json` | 主题解析后每个样式的字号、字重、行高倍数、字距；每个样式一行文字实际量到的高度 |
| `dock_edges.json` | `glassDockTabEdges` 在 t = 0、0.1、…、1.0 的输出，覆盖 4 格里 0→1、0→3、3→0 三种切换 |
| `layout.json` | 每个 B、C、D 组场景里关键元素的矩形（用 `tester.getRect` 取） |
| `ripple.json` | 水波纹的半径和透明度在各个时刻的取样。用 Flutter 自己的 `Tween` 和 `Curve` 类，按 `_ref` 里 `ink_ripple.dart` 的常量算出，常量所在行号写进文件 |
| `icons.json` | 121 个图标名和码点。用脚本从 `_ref/flutter-3.44.9/material/icons.dart` 里按名字解析 |

- [ ] 预期：六个文件都在；`icons.json` 恰好 121 项；`tokens.json` 里浅色描边的 alpha 记录到小数点后四位（交接文档写的是约 0.595）。

**这套基准管不到的地方**

- 测试环境用软件渲染，真机用 Impeller。模糊和投影的边缘会有细小差别，所以模糊区域的阈值放宽，最终以真机并排为准（G4b）。
- 测试环境没有系统字体回退，中文会显示成方块，所以基准图里不放中文。中文文字的字体和字重在 P2 的 S1 里用真机核对。
- `SystemSwitch`、`SystemSpinner`、二级弹层在 iOS 上本来就是原生控件，基准图里是空白，不参与对拍。

**P1 出口**：连续两次 `flutter test` 全过且 `goldens/` 没有变化；六个夹具文件齐全；`tools/golden_diff` 的测试通过。

---

### P3 Clash 环回：「Swipt 兼容」开关

代码在 Windows 上写。T3.1、T3.2 的纯逻辑只依赖 Foundation，装了 Swift for Windows 之后在本机就能先红后绿（做法见 12 小时计划的 B1）。T3.3、T3.4 依赖 App 里的其它代码，状态记为「已写，未编译」。完整的单测和编译在 Mac 上跑（P2 的 T2.2 编过原版之后，即 T2.3），真机效果在 G5 验。

**设计**

照现有的 `excludeAPNsRoute` 走同一条线。它从 App Group 的 UserDefaults 读出来，在生成运行时配置时（`ConfigTransforms.clientRuntimeRoot`）改配置。「Swipt 兼容」多做一步判断：键从没写过时算「开」。

扩展那一侧不用改：它已经会把内核报上来的环回地址加进隧道路由。

**文件**

| 动作 | 文件 | 位置 |
|---|---|---|
| 改 | `Clash-Client/apple/ClashClientUI/Sources/ClashClientUI/Features/Tunnel/ClashTunnelRouteShaping.swift` | 第 29 行 `excludeAPNsRouteKey` 之后 |
| 改 | `Clash-Client/apple/ClashClientUI/Package.swift` | 加测试 target |
| 建 | `Clash-Client/apple/ClashClientUI/Tests/ClashClientUITests/SwiptLoopbackTests.swift` | — |
| 改 | `Clash-Client/apple/ClashClient/Sources/ConfigStore/ConfigTransforms.swift` | 2213–2323 |
| 改 | `Clash-Client/apple/ClashClient/Sources/ConfigStore/ProfileActivationCoordinator.swift` | 195、226–233、243–249、515–517 |
| 改 | `Clash-Client/apple/ClashClient/Sources/VPNController.swift` | 255–306（`VPNTunnelSettings`） |
| 改 | `Clash-Client/apple/ClashClient/Sources/ConfigUI/TunnelSettingsView.swift` | 第 140 行之后 |
| 改 | `…/AppArchitecture/AppLocalization/{en,zh-Hans,zh-Hant}.lproj/Localizable.strings` | 各加两条 |

**T3.1 先写失败的测试**

- [ ] `Package.swift` 的 `targets` 数组末尾加：

```swift
.testTarget(name: "ClashClientUITests", dependencies: ["ClashClientUI"])
```

- [ ] 建 `SwiptLoopbackTests.swift`：

```swift
import XCTest
@testable import ClashClientUI

final class SwiptLoopbackTests: XCTestCase {
    func testAddsTheAddressWhenOnAndAbsent() {
        XCTAssertEqual(
            ClashTunnelRouteShaping.loopbackAddresses(configured: [], swiptLoopback: true),
            ["10.7.0.1"])
    }

    func testKeepsWhatTheUserWroteAndAppends() {
        XCTAssertEqual(
            ClashTunnelRouteShaping.loopbackAddresses(configured: ["10.9.0.1", "fd00::1"], swiptLoopback: true),
            ["10.9.0.1", "fd00::1", "10.7.0.1"])
    }

    func testDoesNotAddItTwice() {
        XCTAssertEqual(
            ClashTunnelRouteShaping.loopbackAddresses(configured: ["10.7.0.1"], swiptLoopback: true),
            ["10.7.0.1"])
    }

    func testLeavesTheListAloneWhenOff() {
        XCTAssertEqual(
            ClashTunnelRouteShaping.loopbackAddresses(configured: ["10.9.0.1"], swiptLoopback: false),
            ["10.9.0.1"])
    }

    func testAKeyNeverWrittenCountsAsOn() {
        let defaults = UserDefaults(suiteName: "SwiptLoopbackTests.\(UUID().uuidString)")!
        XCTAssertTrue(ClashTunnelRouteShaping.swiptLoopbackEnabled(in: defaults))
        defaults.set(false, forKey: ClashTunnelRouteShaping.swiptLoopbackKey)
        XCTAssertFalse(ClashTunnelRouteShaping.swiptLoopbackEnabled(in: defaults))
        XCTAssertTrue(ClashTunnelRouteShaping.swiptLoopbackEnabled(in: nil))
    }
}
```

- [ ] Mac 上在 `Clash-Client/apple/ClashClientUI` 执行 `swift test --filter SwiptLoopbackTests`。预期：编译失败，报找不到 `loopbackAddresses`、`swiptLoopbackEnabled`、`swiptLoopbackKey`。

**T3.2 最小实现**

- [ ] `ClashTunnelRouteShaping.swift` 第 29 行之后加：

```swift
    public static let swiptLoopbackKey = "vpn.tunnel.swiptLoopback"

    /// LocalDevVPN 与 StosVPN 约定的环回对端地址，Swipt 最后兜底试的也是它。
    public static let swiptLoopbackAddress = "10.7.0.1"

    /// 键从没写过时算「开」。`UserDefaults.bool(forKey:)` 对缺失的键返回 false，这里不能用它。
    public static func swiptLoopbackEnabled(in defaults: UserDefaults?) -> Bool {
        (defaults?.object(forKey: swiptLoopbackKey) as? Bool) ?? true
    }

    /// 配置里已经有 10.7.0.1 就原样返回。
    public static func loopbackAddresses(configured: [String], swiptLoopback: Bool) -> [String] {
        guard swiptLoopback, !configured.contains(swiptLoopbackAddress) else { return configured }
        return configured + [swiptLoopbackAddress]
    }
```

- [ ] 再跑 `swift test --filter SwiptLoopbackTests`。预期：5 个测试通过。

**T3.3 接进运行时配置**

- [ ] `ConfigTransforms.swift`：给 `applyClientRuntimePolicy`（2213）、`applyClientRuntimePolicyReading`（2239）、`applyClientRuntimePolicyAroundRules`（2287）、`clientRuntimeRoot`（2312）各加一个参数 `swiptLoopback: Bool`，前两个带默认值 `false`，逐层往下传。凡是现在传 `excludeAPNsRoute:` 的调用点，都同样传 `swiptLoopback:`。
- [ ] `clientRuntimeRoot` 里 `appendAPNsFakeIPFilter` 那个 `if` 之后加：

```swift
        if swiptLoopback {
            appendSwiptLoopbackAddress(to: &root)
        }
```

- [ ] `appendAPNsFakeIPFilter` 之后加：

```swift
    private static func appendSwiptLoopbackAddress(to root: inout OrderedJSON) {
        var configured: [String] = []
        switch root.topLevelValue("tun")?.topLevelValue("loopback-address") {
        case nil:
            break
        case let .array(existing)?:
            configured = existing.compactMap { if case let .string(value) = $0 { return value } else { return nil } }
            // 列表里有不是字符串的项：这是用户自己写的东西，不碰。
            guard configured.count == existing.count else { return }
        default:
            // 写成了别的形状：同样不碰。
            return
        }
        let merged = ClashTunnelRouteShaping.loopbackAddresses(configured: configured, swiptLoopback: true)
        guard merged != configured else { return }
        root = root.setting(path: ["tun", "loopback-address"], to: .array(merged.map { .string($0) }))
    }
```

- [ ] `ProfileActivationCoordinator.swift`：`RuntimeBuildStages` 里紧跟 `var excludeAPNsRoute = false`（195）加 `var swiptLoopback = false`；`finished()`（226–233）和 `finishedReading`（243–249）两处调用加 `swiptLoopback: swiptLoopback` / `swiptLoopback: stages.swiptLoopback`；构造处（515–517）紧跟 `excludeAPNsRoute:` 参数加：

```swift
            swiptLoopback: {
                #if os(iOS)
                return ClashTunnelRouteShaping.swiptLoopbackEnabled(in: UDPFallbackSettings.appGroupDefaults)
                #else
                return false
                #endif
            }(),
```

- [ ] 执行 `rg -n "applyClientRuntimePolicy|excludeAPNsRoute:" Clash-Client/apple/ClashClient/Sources`，逐个核对：每个传了 `excludeAPNsRoute:` 的地方都传了 `swiptLoopback:`。

**T3.4 设置项**

- [ ] `VPNTunnelSettings`（`VPNController.swift:255–306`）：加 `var swiptLoopback = true`；`Key` 里加 `static let swiptLoopback = "vpn.tunnel.swiptLoopback"`；`load` 里用 `ClashTunnelRouteShaping.swiptLoopbackEnabled(in: defaults)`；`save` 里 `defaults.set(swiptLoopback, forKey: Key.swiptLoopback)`。
- [ ] `TunnelSettingsView.swift` 第 140 行（Exclude APNs Route 那个 Section 结束）之后加：

```swift
            #if os(iOS)
            Section {
                Toggle("Swipt Compatibility", isOn: binding(\.swiptLoopback))
                    .accessibilityIdentifier("tunnel.swiptLoopback")
            } header: {
                Text("Swipt Compatibility")
            } footer: {
                Text("If YES, the tunnel answers 10.7.0.1 as a loopback address, so Swipt reaches this device through Clash without a separate loopback VPN. Takes effect on the next connection.")
            }
            #endif
```

- [ ] 三个 `Localizable.strings` 各加两条。简体：

```
"Swipt Compatibility" = "Swipt 兼容";
"If YES, the tunnel answers 10.7.0.1 as a loopback address, so Swipt reaches this device through Clash without a separate loopback VPN. Takes effect on the next connection." = "开启后，隧道把 10.7.0.1 当作环回地址应答，Swipt 直接通过 Clash 连到本机，不用另装环回 VPN。下次连接时生效。";
```

繁体：`"Swipt 相容"` 与 `"開啟後，通道把 10.7.0.1 當作環回網址回應，Swipt 直接透過 Clash 連到本機，不用另外安裝環回 VPN。下次連線時生效。"`。英文两条的值等于键。

**T3.5 Mac 上验证**

- [ ] `swift test`（在 `ClashClientUI` 目录）。预期：全部通过。
- [ ] 编 `ClashiOS`。预期：编译通过。
- [ ] 装机，导入一份不含 `loopback-address` 的订阅并连接。在 App 的运行时配置预览里找 `loopback-address`。预期：值是 `[10.7.0.1]`。
- [ ] 核对一件事：如果订阅根本没有 `tun:` 段，补进去的这一项会不会让内核的 tun 行为变样（连得上、能上网即算没变）。变了的话，把注入条件收紧成「`tun` 段存在时才补」。
- [ ] 关掉开关，重连。预期：预览里没有 `loopback-address`。
- [ ] 换一份自己写了 `loopback-address: [10.7.0.1, 10.9.0.1]` 的配置。预期：预览里还是这两项，没有重复。

---

### P2 Mac 首次全量构建与技术验证（Mac + 真机）

对应交接文档 §9，一次跑完。代码通过 git 传过去，不拷目录。

**T2.1 环境**：按第 6 节装齐。预期：`xcodebuild -version` 报 27 以上；`xcodegen --version`、`bun --version`、`go version` 都有输出。

**T2.2 Clash-Client**

- [ ] 执行：

```sh
cd Clash-Client
python3 -m venv .build/python-env && source .build/python-env/bin/activate
python3 -m pip install PyYAML
python3 scripts/bootstrap.py
python3 scripts/configure.py --bundle-base <前缀> --team <TeamID>
```

- [ ] 预期：bootstrap 最后一行是 `Public dependencies verified. Run python3 scripts/configure.py, then build an app scheme.`
- [ ] 执行 `rg -n "LoopbackAddress" .build/dependencies/kernel/listener/config/tun.go`。预期：至少一处命中。再看 `.build/dependencies/kernel/third_party/sing-tun/` 下有没有 `ip_rewrite.go`，把结果记进 `docs/decisions/G1-bringup.md`（对应 2.3 的第 13 条）。
- [ ] 按 D8 把 `ClashiOS` 的 entitlements 里三个 iCloud 键拿掉：`com.apple.developer.icloud-services`、`com.apple.developer.icloud-container-identifiers`、`com.apple.developer.ubiquity-container-identifiers`，然后重新跑 `configure.py`。注意 `configure.py` 每次都会用 PyYAML 重写 `project.yml`，本文给的行号只对没跑过它的文件有效，之后一律按 target 名和键名找。
- [ ] Xcode 里编 `ClashiOS`，装机。
- [ ] 预期：能导入订阅、连接、打开网页；Xcode 的内存仪表里记下扩展进程的常驻内存。

**T2.3 P3 的验证**：做 T3.5。

**T2.4 Swipt 原版**

- [ ] `git submodule update --init`（拉 `DeveloperDiskImage`），然后 `make lib`、`bun dev frameworks`、`make build_ios`，装机。
- [ ] 先按原版流程装 LocalDevVPN 跑通一次：配对成功，装上「跳过中国广告」，开一个有开屏广告的 App 看它跳过。
- [ ] 预期：这一步是基线。原版在这台设备、这个系统版本上都跑不通的话，后面换 VPN 出了问题就分不清是谁的毛病。

**T2.5 Feather 原版**

- [ ] `git submodule update --init --recursive`，看 `Zsign/` 和 `IDeviceKitten/` 的 README 确认编译前置，编译，装机。
- [ ] 导入证书和描述文件，签一个测试 IPA 并装上。
- [ ] 预期：装上的 App 能打开。把 IDeviceKit 是预编译产物还是要现编 Rust 记下来。

**T2.6 双 Go 运行时实验（G2）**

- [ ] 先看 LibSwipt 的产物是什么：`file LibSwipt.xcframework/ios-arm64/LibSwipt.framework/LibSwipt`。是静态库（`current ar archive`）就照下一步包一层；已经是动态库就直接嵌入。
- [ ] 在 Clash-Client 开一条临时分支。`project.yml` 里仿照 `Clash` target（`type: framework`，`OTHER_LDFLAGS` 用 `-Wl,-force_load` 指向静态库，再加一个拷头文件的脚本）加一个 `SwiptCore` 框架 target，让 `ClashiOS` 依赖并嵌入它。
- [ ] 在 App 启动时调一次 `LibSwiptNewLoopbackProbe`，同时照常走 Clash 的配置校验。
- [ ] 判定为「共存（A）」的条件，全部满足：链接无重复符号错误；启动无崩溃；Clash 能连、Swipt 探测能返回；两者都活跃的情况下跑 30 分钟无崩溃；控制台里即使有 ObjC 类重复的警告也没有功能异常。
- [ ] 留意控制台里 `Class GoSeqRef is implemented in both …` 这类警告（两个框架都带 gomobile 的 `ref.h` 和 `Universe.objc.h`），有的话原样记下来。
- [ ] 同时确认 5.3 的第一点：用 Instruments 看扩展进程里加载的镜像，预期没有 `SwiptCore`。
- [ ] 记录主 App 的内存占用增量和安装包体积增量。
- [ ] 任一条不满足即为「冲突（B）」，把具体报错贴进 `docs/decisions/G2-go-runtimes.md`。

**T2.7 OneUI 技术验证（G3）**

在 Mac 上建一个临时 SwiftUI 工程，五个小实验，前四个都和 P1 的基准图用 `tools/golden_diff` 比。

- [ ] **S1 文字**。用 Montserrat-Regular 画 `a2_weights` 同样的内容。600 和 700 的合成加粗试两种实现：UILabel 加负的 `strokeWidth`，和 CoreText 自绘。行高用 `minimumLineHeight` / `maximumLineHeight` 加 `baselineOffset` 模拟 Flutter 的上下均分。量一下加粗后字宽有没有变。再在真机上并排看中文：我的预期是 Montserrat 没有中文字形，Flutter 会回退到系统的苹方，而苹方有真的 Medium 和 Semibold，所以中文的 500 字重会比常规体粗，和拉丁字母不一样。这一点要以真机上 OneWIFI 原 App 的实际显示为准。
- [ ] **S2 模糊**。私有 API 下分别设半径等于 sigma 和等于 2 倍 sigma，对比 `glass_panel`、`dock_static_0`、`status_hero_ready` 三张基准图，再和真机上的 OneWIFI 并排。在手头能找到的每个系统大版本上各跑一次，确认私有接口都在。同时做公开 API 的近似版，放在一起出对比图给你看（D3）。
- [ ] **S3 投影**。SwiftUI 的 `shadow(radius:)` 分别取 blurRadius 的一半和按 `blur × 0.57735 + 0.5` 算出的 sigma，对比 `a5_shadows`。
- [ ] **S4 水波纹的触摸**。在滚动列表里的一个可点卡片上验证三件事：能拿到按下的坐标；手指开始滚动时水波纹取消；不影响滚动手感。SwiftUI 的手势做不到就改用 UIKit 的触摸视图垫在下面。
- [ ] **S5 出图方式**。SwiftUI 的 `ImageRenderer` 画不出 UIKit 包装的视图，也截不到背景模糊，而文字层和模糊层很可能都要用 UIKit。所以对拍用的图预期要在模拟器里、有窗口的宿主 App 中用 `drawHierarchy(in:afterScreenUpdates:)` 截。这里验证这条路能截到模糊，并且出图尺寸是 1170×2532。
- [ ] 预期：`docs/decisions/G3-oneui-tech.md` 里五项各有一个选定方案，前四项附差异数字。同时用头三张场景把对拍阈值定下来并冻结。初始值：元素矩形误差不超过 0.5 pt；平坦色块每通道差不超过 2；去掉文字边缘和模糊区后的差异像素不超过 0.5%；模糊区按区域平均色比较，每通道差不超过 4。

**T2.8 Loon 插件实测**

- [ ] 导入 I5 给的插件（或我挑的 5 到 10 个），逐个打开模块详情，把被忽略的条目和原因抄进 `docs/findings/loon-ignored.md`，按原因分组计数。
- [ ] 预期：一张表，知道四种忽略原因各占多少，P6 按数量排优先级。

**P2 出口**：G1、G2、G3 三份结论文档齐全。

---

### P4 OneUI 重写（Mac 为主）

前置：P1 完成，G3 有结论。开工前出两份子计划（第 11 节的 SP-04、SP-05）。

**包结构**

```
OneUI/
  Package.swift                 # resources 加上 Resources/Icons；新增 OneUICore 和两个测试 target
  Sources/OneUICore/            # 只依赖 Foundation
    Tokens/OnePalette.swift       ← one/one_palette.dart（现有文件迁过来）
    Tokens/OneTokens.swift        ← tokens/one_tokens.dart
    Tokens/Glass.swift            ← one/glass.dart 的数值部分
    Tokens/TypeScale.swift        ← M3 字号表、行高补偿、合成加粗宽度
    Motion/InkRippleModel.swift   ← 半径和透明度随时间的函数
    Motion/DockEdges.swift        ← glassDockTabEdges
    Icons/MaterialIconCodepoints.swift   # 由 tools 脚本生成，121 项
  Sources/OneUI/
    Text/OneText.swift            # G3 的 S1 选定的实现
    Icons/MaterialIcon.swift
    Ink/InkRipple.swift           # G3 的 S4 选定的实现
    Glass/BackdropBlurView.swift  # 唯一允许私有 API 的文件
    Glass/GlassPanel.swift        ← one/glass_surface.dart、widgets/glass_panel.dart
    Glass/GlassChrome.swift       ← one/glass_chrome.dart
    Theme/OneTheme.swift          ← theme/one_theme.dart、glass.dart 的 apply
    Controls/                     # 主题覆盖下的按钮、输入框、Card、Dialog、Chip、Menu、Divider、SnackBar、ListTile、进度条、AppBar、TabBar
    Controls/SystemControls.swift ← widgets/system_controls.dart
    Components/                   # 与 widgets/*.dart 同名一一对应，外加 DotMatrixFace、StatusHero、OneStatusHero
    Dock/UltraGlassDock.swift     ← one/ultra_glass_dock.dart
    Dock/GlassDock.swift          ← widgets/glass_dock.dart、adaptive_glass_dock.dart
    Dock/KeyboardVisibility.swift ← one/ime_visibility.dart
    Gallery/OneGallery.swift      # 场景名与 _golden 完全一致
  Tests/OneUICoreTests/         # 读 _golden/fixtures/*.json
  Tests/OneUISnapshotTests/     # 按 G3 的 S5 定下的方式出图到临时目录，再调 tools/golden_diff
```

OneUI 只支持 iOS，`swift build` 和 `swift test` 在 Mac 主机上会去编 macOS 版而失败。这个包的编译和测试一律走 `xcodebuild`：

```sh
xcodebuild build -scheme OneUI -destination 'generic/platform=iOS'
xcodebuild test  -scheme OneUI-Package -destination 'platform=iOS Simulator,name=<xcrun simctl list devices available 里有的机型>'
```

`one/liquid_glass.dart` 交接文档说原版已无调用方。移植前用 `rg -n "LiquidGlass" E:\GQ\Ultra\ONEWIFIX\IOS\lib` 再确认一次，确实没有就不移植。

**顺序**（每一步都是先写对拍测试，看它失败，再实现）

| 步 | 内容 | 验收 |
|---|---|---|
| 4.0 | 包骨架、资源声明、删掉现有 14 个文件里引用已删字重和系统玻璃的代码 | 上面的 `xcodebuild build` 通过；`xcodebuild test` 能跑起来（此时 0 个测试） |
| 4.1 | OneUICore 数值层 | `OneUICoreTests` 对 `tokens.json`、`typography.json`、`dock_edges.json`、`icons.json` 逐项断言，全过 |
| 4.2 | 文字层 | `a1_typography`、`a2_weights` 对拍通过 |
| 4.3 | `MaterialIcon` | 单测：121 个码点在字体里都有字形；`a3_icons` 对拍通过 |
| 4.4 | `InkRipple` | `a6`、`a7` 对拍通过 |
| 4.5 | 模糊视图和四档玻璃面 | `a4_fills`、`a5_shadows`、`glass_panel` 对拍通过 |
| 4.6 | 主题和 Material 控件 | C 组全部对拍通过 |
| 4.7 | 组件，三个一批 | B 组全部对拍通过；每批过一次代码审查 |
| 4.8 | 底栏 | D 组全部对拍通过；键盘弹出时隐藏；系统开了减弱动态效果时直接跳到终点 |
| 4.9 | 总验收 | G4a：全量对拍报告无超阈值项。G4b：真机并排，你确认 |

交接文档 §3.2 那张「偏离」表在 4.9 逐行过一遍，每一行都要能指到对应的对拍场景或单测。

---

### P5 外壳与模块并入（Mac + 真机）

前置：G1、G2、P3。开工前出 SP-06、SP-07。

**5.0 宿主外壳**

- [ ] `project.yml`：`deploymentTarget.iOS` 从 `15.0` 改成 `16.4`；`packages` 加 `OneUI`（路径 `../../../OneUI`）；`ClashiOS` 依赖它。
- [ ] 根视图换成 OneUI 的悬浮底栏加四个页签（D5），第一个页签装 Clash 原来的根视图，其余三个先放占位页。
- [ ] 预期：装机后四个页签能切，Clash 功能和 T2.2 时一样。

**5.1 Swipt**

G2 结论是 A（共存）时：

- [ ] `SwiptCore`、`SwiptUI` 两个 target 进 `project.yml`（5.2 节）。React Native 的三个本地包（`build/generated/autolinking`、`build/xcframeworks`、`build/generated/ios`）和 `main.jsbundle` 由一个脚本 `Clash-Client/scripts/build_swipt.py` 生成，接在 `bootstrap.py` 之后。
- [ ] `SwiptApp.swift` 的 `@main` 去掉，导出 `SwiptRootView`。
- [ ] 执行 `rg -n "Bundle\.main" Swipt/Swipt`，逐条按 5.2 的规则处理。
- [ ] 宿主 Info.plist 补 5.2 列的键。
- [ ] `SetupView.swift:28` 的 `LoopbackSetupView` 换成新的一页：检查 Clash VPN 已连接且「Swipt 兼容」开着，没连就给一个「连接」按钮。配对页和自动解锁页保留，自动解锁默认跳过。
- [ ] 首次启动自动从官方稳定源装「跳过中国广告」，并在设置流程最后一页提示打开「模糊跳过」（D7）。
- [ ] 蜂窝网络：先保持 `DeviceConnection.swift:132–135` 不动。G5 通过后单独做一次实验——去掉那个判断，关 Wi-Fi 用蜂窝跑 Swiplet。能跑就去掉，不能跑就留着并记下现象。

G2 结论是 B（冲突）时，按代价从低到高三条路，到时候带着具体报错让你选：

1. 把两份 Go 代码合成一次 gomobile 编译。要 fork 内核的构建脚本，并解决 mihomo 自带的 gvisor 和 sagernet/gvisor 的冲突。
2. Swipt 保持独立 App，只共用 Clash 的 VPN。满足「一个 VPN」，不满足「一个 App」。
3. 放弃 Swipt 的 Go 实现里和 Clash 冲突的部分，改用别的实现。范围要看报错才知道。

**G5 检查单**（真机，不装 LocalDevVPN）

- [ ] Clash 连着，Swipt 设置流程走完，配对成功。
- [ ] 「跳过中国广告」装上，开三个有开屏广告的 App，都跳过了。
- [ ] 关掉「Swipt 兼容」重连，Swipt 显示找不到隧道。再打开重连，恢复。
- [ ] 分别打开 Clash 的隐藏 VPN 图标、HomeKit 兼容、`strict-route`，各重复第二条。
- [ ] Swipt 工作时 Clash 的代理和去广告规则照常。

**5.2 Feather**

- [ ] `FeatherUI` target 进 `project.yml`，本地包 `Zsign`、`IDeviceKitten`、`AltSourceKit`、`NimbleKit` 和远程包 Nuke、Zip、SWCompression、Vapor 一并声明。
- [ ] `FeatherApp.swift` 的 `@main` 去掉，导出 `FeatherRootView`。
- [ ] Feather 的 Makefile 在打包时会从 `https://backloop.dev/pack.json` 取本地 HTTPS 安装服务器用的证书放进 App。查清运行时是否也会自己更新；不会的话把这一步做进我们的构建脚本。
- [ ] 文档类型（`.ipa`、`.p12`、`.mobileprovision`）和 URL scheme 并进宿主 Info.plist。
- [ ] 直装通道：按交接文档，它要靠环回地址连回本机，P3 之后这个地址由 Clash 提供。Feather 这一侧在哪里配地址、用哪种配对，要等拉完 IDeviceKit 子模块（T2.5）才能确认；我的预期是它用电脑导出的配对文件，而 Swipt 用 iOS 17 的 RemotePairing，是两套东西。先各用各的，能不能共用一份配对作为调查项，不卡进度。
- [ ] 预期：在合并后的 App 里导入证书、签一个 IPA、装上、能打开。

**P5 出口**：G5 检查单全过；自签流程走通；记录安装包体积和主 App 冷启动时间。

---

### P6 网络层去广告补缺（Mac）

前置：T2.8 的数据。开工前出 SP-08。

- [ ] **6.0** 给宿主加单测 target `ClashiOSTests`（`project.yml` 里 `bundle.unit-test`，宿主是 `ClashiOS`），能用 `xcodebuild test` 在模拟器上跑。解析器在 App target 里，没有这个 target 就没法测。
- [ ] **6.1** 按 T2.8 的计数排序。下面三项的先后由数据定：
  - Loon 新语法的 `script(...)`：`ModuleLoonRewriteSyntax.swift:1230`、`ModuleParser.swift:1378`。
  - QX 的 `[Argument]`：`ModuleQuantumultXParser.swift:46`。
  - BoxJS：除非实测里它挡住了常用插件，否则保持不支持。
- [ ] 每一项：从实测插件里截一段做夹具文件，先写断言「这条被解析成某某规则」的测试并看它失败，再改解析器。
- [ ] **6.2** 自有规则插件。从 `Swiplets/skip-chinese-ads/src/rules.ts` 导出广告 SDK 清单，逐家查广告域名，和已导入插件的规则求差集，缺的写进 `adblock/onetools-cn-ads.plugin`。清单导出和域名核对在 Windows 上就能先做。
- [ ] 预期：`docs/findings/loon-ignored.md` 里列为要补的条目，重新导入后不再出现在忽略列表里。

---

### P7 自签增强（Mac + 真机）

前置：P5。开工前出 SP-09。

- [ ] 批量签名：多选 IPA，同一套证书和选项，逐个出结果，单个失败不影响其余。
- [ ] 到期提醒：读证书和描述文件的到期日，提前 7 天和 1 天各发一条本地通知。
- [ ] 一键重签：对已签过的 App 列表整体换新证书重签。
- [ ] 日期计算、批处理的失败隔离是纯逻辑，放进可单测的类型里先写测试。
- [ ] 预期：真机上选 3 个 IPA 批量签完并装上；把系统时间调到到期前 6 天，收到通知。

---

### P8 OneUI 按页推进（Mac）

前置：G4a、G4b、P5。

顺序：外壳和首页（P5 已做）→ 设置 → Swipt 的页面 → Feather 的页面 → Clash 的常用页面（配置列表、节点、模块）→ Clash 的深层页面。

每一页的做法相同：只换容器、文字、图标、按钮、输入框这些表层，不动业务逻辑；改完和改之前逐项操作对比，功能不变。做到哪一层停，由你定（D6）。

---

### P9 电话短信互通（后期）

不在本计划里排期。开工的前置条件：

- I3 确认代码归属。
- 朋友的账号能开 Push Notifications。
- 先做规格：号码放在哪种网关、SIP 还是自有协议、后端部署在哪。交接文档 §5 的建议路线作为规格的起点。
- 可复用的 iOS 代码：`ONEWIFIX/IOS/ios/Runner/Calls/`（9 个文件 3,038 行）、`CallAudioBridge.swift`、`APNsBridge.swift`、`OtpNotifier.swift`、`OtpLiveActivity.swift`。`CallAudioBridge` 要去掉 Flutter 通道。
- 配对入口的问题（`onetools://onewifi?...` 在 Onetools 仓库里找不到实现）在规格阶段一并解决。

---

### P10 收尾加固（Mac + 真机）

- [ ] 扩展内存：开着 MITM 和脚本类模块连续用一小时，扩展不被系统杀掉。
- [ ] 证书卫生：确认构建产物不外发；到期提醒对宿主自己的签名证书也生效。
- [ ] 私有 API 只在 `BackdropBlurView.swift`：`rg -n "_UICustomBlurEffect|CABackdropLayer|NSClassFromString" OneUI Clash-Client/apple Swipt/Swipt Feather/Feather`，预期只命中那一个文件（上游原有的命中单独列出来说明）。
- [ ] 许可：`Resources/Legal` 里补上 Swipt、Feather、Zsign、IDeviceKit、Montserrat（OFL）、Material Icons（Apache 2.0）的声明。
- [ ] G6：连续日用三天。

---

## 9. 验收总账

| # | 可观察的结果 | 在哪验 |
|---|---|---|
| 1 | 不装 LocalDevVPN，Clash 连着时 Swiplet 能跳广告 | G5 |
| 2 | 关掉「Swipt 兼容」后配置里没有 `10.7.0.1`；用户自己写过的不重复 | T3.5 |
| 3 | 常用 Loon 去广告插件导入后，列为要补的忽略条目清零 | P6 |
| 4 | App 内导入证书，批量签名并安装，到期前收到提醒 | P7 |
| 5 | OneUI 全部场景像素对拍通过，§3.2 的每条偏离都已撤回 | G4a |
| 6 | 真机并排，磨砂、动画、中文文字与 OneWIFI 一致 | G4b |
| 7 | 扩展进程里只有一个 Go 运行时，开 MITM 用一小时不被杀 | T2.6、P10 |
| 8 | 私有 API 只出现在一个文件里 | P10 |
| 9 | 连续日用三天无崩溃、无断流 | G6 |

---

## 10. 风险登记

| # | 风险 | 影响 | 应对 |
|---|---|---|---|
| R1 | Mac 迟迟不到位 | P2 之后全部停住 | P0、P1、P3 代码、P6 域名核对先做完；Mac 一到，按 P2 一次跑完 |
| R2 | 两个 Go 运行时在主 App 里冲突 | Swipt 并入要换路线 | G2 提前做；B 路线的三个选项已列 |
| R3 | 私有模糊接口在某个系统版本上不存在或行为不同 | 磨砂观感不一致 | S2 在每个大版本上各跑一次；保留公开 API 的近似实现做开关 |
| R4 | 文字还原不到位，尤其是合成加粗和中文回退 | 最显眼的观感差异 | 文字层排在 P4 最前；S1 用真机核对中文；Skia 参数在 T0.3 核实 |
| R5 | 基准图和真机渲染器不同 | 对拍通过但真机上看着不一样 | 模糊区放宽阈值，G4b 真机并排作为最终判定 |
| R6 | 扩展内存上限 | 开 MITM 和脚本后被系统杀掉 | 依靠 Clash-Client 自带的内存阶梯；P10 实测 |
| R7 | 证书被吊销 | 连累朋友公司的 App | 只装自己的设备，签名包不外发 |
| R8 | 上游更新快（Swipt、Swiplets 几乎每天有提交） | 我们的分支和上游越走越远 | 锁 SHA；每个阶段开始前决定要不要跟一次上游，跟就单独一个提交 |
| R9 | Swift 6 严格并发和 Swift 5 模块混编 | 跨模块调用处报并发错误 | 三个模块之间只通过少数几个入口交互，入口处统一标注隔离 |
| R10 | 安装包体积：两个 Go 运行时、RN + Hermes、Vapor、Rust、OpenSSL | 体积大，冷启动慢 | P5 出口处测量；超出可接受范围再看能砍哪个（例如 Feather 的本地服务器） |
| R11 | Swipt 的 Info.plist 声明了后台定位模式（推测是为了后台保活） | 合并后的 App 会弹定位权限 | 并入时先读代码确认用途；首次设置里说明；不用 Swipt 的话不申请 |
| R12 | 本机访问 GitHub 要代理 | 拉子模块、取 Skia 源码会失败 | 涉及网络的步骤都标了要代理 |
| R13 | Windows 和 Mac 之间换行、可执行位出错 | 脚本在 Mac 上跑不起来 | T0.1 的配置；只通过 git 传 |
| R14 | OneWIFI 代码归属不清 | 设计移植和通话代码的合法性 | I3，P4 开工前要有答复 |

---

## 11. 子计划清单

每份在对应阶段开工前写，写到「每步一个动作、有完整代码和预期输出」的程度，存在 `docs/superpowers/plans/`。

| 编号 | 文件名 | 覆盖 | 什么时候写 |
|---|---|---|---|
| SP-01 | `…-p1-golden-scenes.md` | P1 的全部场景代码和夹具导出代码 | 现在就能写 |
| SP-02 | 不单独出 | P0、P3 | 本文已是命令级 |
| SP-03 | `…-p2-mac-bringup.md` | P2 的逐条命令、G2 和 G3 的实验工程 | Mac 时间定下来之后 |
| SP-04 | `…-p4-oneui-core.md` | 4.0 到 4.5 | G3 之后 |
| SP-05 | `…-p4-oneui-components.md` | 4.6 到 4.9 | SP-04 做完之后 |
| SP-06 | `…-p5-shell-swipt.md` | 5.0、5.1 | G2 之后 |
| SP-07 | `…-p5-feather.md` | 5.2 | T2.5 之后 |
| SP-08 | `…-p6-adblock.md` | P6 | T2.8 之后 |
| SP-09 | `…-p7-signing.md` | P7 | P5 之后 |
| SP-10 | `…-p9-calls-design.md` | 通话的规格 | 你决定启动时 |

---

## 12. 接下来

**第一段（不需要 Mac）**：你说「开始」后，按 `2026-11-11-onetools-12h-autorun.md` 自动执行 12 小时。五条子代理工作线并行：

- 线 A：P1 的基准图、数值夹具、对拍工具。
- 线 B：P3 的纯逻辑单测和其余代码；解析器测试台试验。
- 线 C：Skia 参数、内核锁定版、子模块这三项未核实的事实；并入清单；Mac 阶段的脚本。
- 线 D：P6.2 的规则插件、样本和检查工具。
- 线 E：OneUI 的数值层。

Swift for Windows 由主代理在第 0 轮装，不占一条工作线。

执行中不问你。结束时的报告在 `docs/autorun/REPORT.md`。

**第二段（需要 Mac）**：Mac 到位后，按 12 小时计划第 12 节的 M0 到 M10 做。头一天按 P2 一次跑完，拿到 G1、G2、G3 三个结论，P4 和 P5 的路线就都定了。

**还需要你提供的**（都不卡第一段）：I1 Mac；I2 Bundle ID 前缀、Team ID 和证书能力；I4 口令改不改。
