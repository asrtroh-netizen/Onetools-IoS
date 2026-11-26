# P5 / P7 三合一单包（OneTools All-in-One IPA）全局优化与云端总装审计报告

- 日期：2026-11-26 / 2026-11-27
- 优化后全绿流水线：[Run #45742425538](https://github.com/asrtroh-netizen/Onetools-IoS/actions/runs/45742425538)（HEAD `e5197d8`）
- 全功能版产物：`OneTools-AllInOne-unsigned.ipa`（**`101.1 MiB` / `105,990,482` 字节**，较优化前 `117.80 MiB` 直降 **`-16.72 MiB / -14.2%`**）
- 免费个人号精简自签版产物：`OneTools-AllInOne-Lite-unsigned.ipa`（**`96.9 MiB` / `101,556,964` 字节**，剥离 3 个 `.appex` 仅占 `1` 个每周 App ID 配额、`0` 付费权限）
- 解压后 `.app` 体积：**`217 MB`**（较优化前 `332 MB` 缩减 **`-115 MB / -34.6%`**）
- 首屏冷启动隔离（`pre-main`）：**PASS**（主可执行文件 `Clash` 仅强链接 `Clash.framework`，`SwiptUI` / `FeatherUI` / `LibSwipt` / `React` / `hermesvm` / `OpenSSL` 均按需 `dlopen` 加载）
- 跨镜像 Objective-C 类表冲突数：**`0`**（全包主程序 + 12 个动态框架零重名 ObjC 类）
- 隧道扩展隔离与内存段水位：**PASS**（`ClashiOSExtension` 仅链接 `Clash.framework`，静态 `__DATA` 段总计 `41.06 MB` < `50 MB` Jetsam 红线）

## 内嵌动态框架瘦身前后对比（`Payload/Clash.app/Frameworks/`）

| 动态框架 | 优化前体积 | 优化后体积 | 变化说明 |
|---|---|---|---|
| `Clash.framework` | `49M` | `49M` | Clash（`mihomo`）核心代理、Loon 模块引擎、`10.7.0.1` 环回与 `+.backloop.dev` 真 IP 放行 |
| `LibSwipt.framework` | `45M` | **`39M`** | Swipt Go 核心运行时（`SwiptGoSeqRef` 隔离 + 新增 `FreeOSMemory()` 内存释放 + `strip -x`） |
| `SwiptUI.framework` | `43M` | **`31M`** | Swipt 原生界面（沙盒独立子目录、冷启动 `.swiplet` 队列、局部符号剥离 `-28%`） |
| `FeatherUI.framework` | `40M` | **`18M`** | Feather 自签工作台（局部符号剥离 **`-55%`**、顶栏分段扁平化、`.p12/.mobileprovision` 配对暂存、Nuke `24 MiB` 上限） |
| `React.framework` | `12M` | **`6.5M`** | React Native 运行时底座（`strip -x` `-46%`） |
| `hermesvm.framework` | `6.1M` | **`2.9M`** | Hermes JS 引擎（`strip -x` **`-52%`**） |
| `OpenSSL.framework` | `4.2M` | **`4.0M`** | Zsign CMS 签名加密库 |
| `ExpoModulesCore.framework` | `3.3M` | **`2.1M`** | Expo 核心模块（`-36%`） |
| `ReactNativeDependencies.framework` | `1.3M` | **`860K`** | RN 原生依赖（`-34%`） |
| `ExpoMaps.framework` | `904K` | `904K` | Swiplet 地图组件支持 |
| `ExpoFont.framework` | `280K` | `280K` | Swiplet 字体支持 |
| `ExpoModulesWorklets.framework` | `168K` | **`112K`** | Swiplet Worklets 支持（`-33%`） |
