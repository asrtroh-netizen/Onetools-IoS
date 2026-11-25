# P5 / P7 三合一单包（OneTools All-in-One IPA）云端总装审计报告

- 日期：2026-11-26
- 云端全绿流水线：[Run #45669957741](https://github.com/asrtroh-netizen/Onetools-IoS/actions/runs/45669957741)（HEAD `7da61fef`）
- 产物文件名：`OneTools-AllInOne-unsigned.ipa`
- 安装包体积：**117.8 MB**（`123,526,894` 字节；解压后 `.app` 体积 `332 MB`）
- 桌面显示名（`CFBundleDisplayName`）：`OneTools`
- 应用组标识（`AppGroupIdentifier`）：`group.org.onetools.app`
- Swipt 官方源通道（`SwiptChannel`）：`stable`（首次进入自动静默安装 `skip-chinese-ads` 并预置 `fuzzySkip = true`）

## 1. 主程序与扩展进程链接结构

- **主可执行文件 `Payload/Clash.app/Clash`**：同时链接 `@rpath/Clash.framework/Clash`、`@rpath/SwiptUI.framework/SwiptUI`（通过纯 ObjC ABI 防火墙 `OneToolsSwiptBridge` 挂载 `SwiptRootView`）与 `@rpath/FeatherUI.framework/FeatherUI`（通过纯 ObjC ABI 防火墙 `OneToolsFeatherBridge` 挂载 `FeatherRootView` 及 `feather://` / `.ipa` / `.tipa` 深链路由）。
- **隧道扩展 `Payload/Clash.app/PlugIns/ClashiOSExtension.appex/ClashiOSExtension`**：仅链接 `@rpath/Clash.framework/Clash`，完全隔离于 `LibSwipt`、`SwiptUI`、`FeatherUI`、React Native 与 Hermes。
- **跨镜像 Objective-C 类表冲突数**：**0**（全包主程序 + 12 个动态框架零重名 ObjC 类）。

## 2. 内嵌 12 个动态框架清单（`Payload/Clash.app/Frameworks/`）

| 动态框架 | 解压体积 | 用途 |
|---|---|---|
| `Clash.framework` | `49M` | Clash（`mihomo`）核心代理、Loon 模块引擎与 `10.7.0.1` 环回注入 |
| `LibSwipt.framework` | `45M` | Swipt Go 核心运行时（`SwiptGoSeqRef` 独立 ObjC 命名空间） |
| `SwiptUI.framework` | `43M` | Swipt 原生界面、`main.jsbundle` 与 `DeveloperDiskImage` |
| `FeatherUI.framework` | `40M` | Feather 原生自签工作台、`Zsign`、`IDeviceSwift`、`Vapor` 与 `SigningLogic`（批量签名、一键重签、7天/1天到期通知） |
| `React.framework` | `12M` | Swiplet React Native 运行时底座 |
| `hermesvm.framework` | `6.1M` | Swiplet Hermes JS 字节码引擎 |
| `OpenSSL.framework` | `4.2M` | Zsign 证书解析与 CMS 代码签名加密库 |
| `ExpoModulesCore.framework` | `3.3M` | Swiplet Expo 核心桥接模块 |
| `ReactNativeDependencies.framework` | `1.3M` | React Native 原生运行时依赖 |
| `ExpoMaps.framework` | `904K` | Swiplet 地图组件支持 |
| `ExpoFont.framework` | `280K` | Swiplet 字体加载支持 |
| `ExpoModulesWorklets.framework` | `168K` | Swiplet Worklets 并发支持 |
