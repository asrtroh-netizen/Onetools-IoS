# G2 双 Go 运行时共存实测与根治结论（GitHub Actions macOS 实测）

- 日期：2026-11-26
- 初测运行：[Run #45595057439](https://github.com/asrtroh-netizen/Onetools-IoS/actions/runs/45595057439)
- 根治与三合一总装全绿运行：[Run #45669957741](https://github.com/asrtroh-netizen/Onetools-IoS/actions/runs/45669957741)
- 实验与验证脚本：[run-g2-dual-go-experiment.sh](file:///e:/GQ/Ultra/Onetools-IoS/scripts/ci/run-g2-dual-go-experiment.sh)、[verify-onetools-ipa.sh](file:///e:/GQ/Ultra/Onetools-IoS/scripts/ci/verify-onetools-ipa.sh)

## 1. 冲突根因诊断

1. **C / `cgo` 全局符号层**：未经隔离直接对 `Clash.xcframework`（1,639 个全局符号）与 `LibSwipt.xcframework`（1,641 个全局符号）做单二进制 `-force_load` 会触发重复符号冲突（`_crosscall1`、`_crosscall2`、`__cgo_panic`、`_DestroyRef` 等）。
2. **`libobjc` 全局类表与 `-dealloc` 串扰**：宿主主进程 `ClashiOS` 本身有 40+ 处源码直接调用 `Clash` Go 库（配置预检、GeoIP/GeoSite 编译、节点导入等），主进程必须链接 `Clash.framework`。初测发现即便通过两个 `@rpath/*.framework` 隔离 C 符号，两份 `sagernet/gomobile@v0.1.13` 仍向进程唯一的 Objective-C 全局类表注册同名的 `GoSeqRef`、`RefTracker`、`RefCounter`、`goSeqDictionary`、`Universeerror`，导致 `[GoSeqRef dealloc]` 跨运行时误调另一侧的 `DestroyRef(_refnum)`。

## 2. 根治方案（构建期桥接类命名空间隔离 + 动态库两级命名空间）

1. **不触碰锁定内核 `Clash.xcframework`**（保持 `bootstrap.py` SHA-256 溯源校验 100% 原样通过）。
2. **在 `Swipt/internal/cmd/build_libswipt/main.go` 定制构建隔离版 `gomobile` / `gobind`**：将 `LibSwipt` 的 5 个 Objective-C 桥接类与协议重命名为独立命名空间（`SwiptGoSeqRef`、`SwiptRefTracker`、`SwiptRefCounter`、`swiptGoSeqDictionary`、`swiptGoSeqRefInterface`、`SwiptUniverseerror`），重叠全局符号从 78 个降至仅 54 个内部 C 符号，再经 `@rpath/LibSwipt.framework` `-exported_symbol` 隐藏全部内部 `cgo` 符号。
3. **扩展进程严格单运行时**：`ClashiOSExtension`（Packet Tunnel）仅链接 `@rpath/Clash.framework/Clash`，完全不链接 `LibSwipt`、`SwiptUI`、`FeatherUI` 或 React Native，确保隧道扩展内存上限不受任何影响。

## 3. 根治后实测结果（Run `#45669957741`）

| 验证维度 | 实测结果 |
|---|---|
| 单进程同时 `dlopen` 加载 `Clash` + `LibSwipt` | **PASS**（基线 RSS `5.4 MB` → `+Clash 16.1 MB` → `+LibSwipt 53.4 MB`，净增 `+48.0 MB`） |
| `libobjc` 重复 Objective-C 类告警数 | **0 个告警**（`0 duplicate ObjC class warnings`） |
| 三合一 `OneTools.app` 全包 13 个 Mach-O 镜像跨库重名 ObjC 类审计 | **0 个冲突**（`GoSeqRef` 归属 `Clash.framework`，`SwiptGoSeqRef` 归属 `LibSwipt.framework`） |
| `ClashiOSExtension` 扩展进程依赖隔离审计 | **PASS**（仅链接 `Clash.framework`） |
