# G1 基线与无签名构建验收记录（GitHub Actions macOS 实测）

- 日期：2026-11-25
- 云端流水线运行：[Run #45595057439](https://github.com/asrtroh-netizen/Onetools-IoS/actions/runs/45595057439)（5 / 5 任务全绿）
- 提交：`321ea0db703d53bcf32198f9dba0969d90fb2c63`

## 1. Clash 内核环回源码核查（T2.2 / M3）

在 `Clash-Client/scripts/bootstrap.py` 拉取并校验的锁定内核（`4b7d5f53cff448f01cd5012b5e3f7eddc7d43e33`）与 Adapter（`09fbc0d7ec3a563758384fddef9c7cce94822b21`）上实测确认：

- `listener/config/tun.go` 第 32 行存在 `LoopbackAddress []netip.Addr`（`yaml:"loopback-address" json:"loopback-address,omitempty"`）。
- `third_party/sing-tun/` 完整包含 Darwin / gVisor 环回地址重写实现：
  - `ip_rewrite.go`
  - `ip_rewrite_darwin.go`
  - `ip_rewrite_gvisor.go`
  - `ip_rewrite_loopback_test.go` / `ip_rewrite_loopback_gvisor_test.go`

因此 `ClashTunnelRouteShaping` 默认注入 `10.7.0.1` 至 `tun.loopback-address` 在锁定版内核中具备完整的底层包重写支撑。

## 2. 三大工程编译与无签名 `.ipa` 产物基线（M2 / M3 / M4）

| 目标产物 | 运行镜像 / 工具链 | 结果 | 产物大小 | 包含的 OneTools 改造 |
|---|---|---|---|---|
| `OneTools-ClashiOS-unsigned.ipa` | `macos-26-arm64` / Xcode 26.6 | **PASS**（含 `ClashmacOS`、`ClashtvOS` 回归） | 60,631,160 B (57.8 MB) | `OneToolsRootShellView` 四页签玻璃底栏主壳、`OneUI`、`SigningLogic`、`10.7.0.1` 环回注入、内置 `onetools-cn-ads.plugin`、剔除付费专属 iCloud 权限键（D8） |
| `OneTools-Swipt-unsigned.ipa` | `xcode-27` / Xcode 27 + Go 1.26.8 + Bun 1.4.4 | **PASS** | 48,029,604 B (45.8 MB) | 移除 `LocalDevVPN` 引导改为检测跳转 Clash `10.7.0.1` 环回、默认跳过自动解锁、首次自动安装 `skip-chinese-ads` 并预置 `fuzzy_skip = 1`、导出 `SwiptRootView` |
| `OneTools-Feather-unsigned.ipa` | `xcode-27` / Xcode 27 + `Zsign` + `IDeviceKitten` | **PASS** | 16,135,232 B (15.4 MB) | 接入 `SigningLogic`、`CertificateExpiryNotifier`（提前 7 天 / 1 天本地通知）、`BatchSigningCoordinator`（多选批量签名错误隔离与一键全部重签）、导出 `FeatherRootView` |
| `OneUI` & `OneUICoreTests` | `macos-26-arm64` / Xcode 26.6 + iOS Simulator | **PASS** | 快照 PNG 已导出 | 19 个 SwiftUI/UIKit 组件源文件在 `generic/platform=iOS` 与 iOS 模拟器上零错误编译并通过单测 |
