# G2 双 Go 运行时共存实测结论（GitHub Actions macOS 实测）

- 日期：2026-11-25
- 云端流水线运行：[Run #45595057439](https://github.com/asrtroh-netizen/Onetools-IoS/actions/runs/45595057439)（任务 `Gate G2 Dual-Go Runtime Experiment`）
- 实验脚本：[run-g2-dual-go-experiment.sh](file:///e:/GQ/Ultra/Onetools-IoS/scripts/ci/run-g2-dual-go-experiment.sh)

## 1. 静态库与全局符号盘点（`ios-arm64`）

| 框架二进制 | 产物形态 | 导出全局符号数 |
|---|---|---|
| `Clash.xcframework/ios-arm64/Clash.framework/Clash` | `ar archive`（Go `c-archive`） | **1,639** |
| `LibSwipt.xcframework/ios-arm64/LibSwipt.framework/LibSwipt` | `ar archive`（Go `c-archive`） | **1,641** |
| **同名全局符号交集** | — | **78 个冲突符号** |

冲突符号集中在两类：
1. **Go `cgo` 运行时与异常端口符号**：`_crosscall1`、`_crosscall2`、`__cgo_panic`、`__cgo_topofstack`、`_darwin_arm_init_mach_exception_handler`、`_darwin_arm_init_thread_exception_port` 等。
2. **`gomobile` / `gobind` 通用桥接符号与 Objective-C 类/协议**：`_DestroyRef`、`_cproxy_error_Error`、`__OBJC_PROTOCOL_$_goSeqRefInterface`、`__OBJC_PROTOCOL_$_Universeerror` 等。

## 2. 三种链接与进程加载策略实测矩阵

| 策略 | 实测结果 | 关键证据 |
|---|---|---|
| **方案 A**：同一 Mach-O 直接静态 `-force_load` 两个 `c-archive` | **FAIL** | 78 个同名 C / cgo / ObjC 全局符号直接触发链接器重复符号冲突 |
| **方案 B**：封装为两个符号隔离的 `@rpath/*.framework` 动态库并链接进同一 iOS 宿主可执行文件 | **PASS（链接通过）** | `-exported_symbol` 隐藏各自内部 `_cgo_*` / `_crosscall2` 后，iOS `arm64` 宿主二进制零错误链接通过 |
| **方案 C**：单进程同时 `dlopen(..., RTLD_NOW \| RTLD_LOCAL)` 初始化双 Go 运行时 | **进程未崩溃（RSS `+47.7 MB`），但存在 5 个 ObjC 全局类冲突** | 基线 RSS `5.4 MB` → 加载 `Clash` 后 `16.0 MB`（`+10.6 MB`）→ 再加载 `LibSwipt` 后 `53.1 MB`（总增量 `+47.7 MB`） |

### 方案 C 捕获的关键 Objective-C 运行时告警

即便使用 `RTLD_LOCAL` 隔离 C 符号表，Apple 的 `libobjc.A.dylib` 在整个进程内共享唯一全局类表，实测捕获到全部 5 个 `gomobile` 桥接基类重名告警：

- `Universeerror`
- `goSeqDictionary`
- `GoSeqRef`
- `RefCounter`
- `RefTracker`

> `objc[1717]: Class GoSeqRef is implemented in both libClashMacDyn.dylib and libSwiptMacDyn.dylib. This may cause spurious casting failures and mysterious crashes.`

## 3. G2 架构裁决

1. **禁止在同一个进程内直接并存两份未经改造的 `gomobile` 产物**：虽然双 Go 运行时本身不会在初始化时崩溃，但 `GoSeqRef` / `RefTracker` 在 Objective-C 全局类表中的二义性会导致跨语言引用计数与类型转换存在潜在串扰风险，且单进程额外常驻约 `47.7 MB` 双运行时开销。
2. **推荐落地路径（进程天然隔离，零侵入上游 Go 代码）**：
   - `Clash`（`mihomo` Go 内核）仅在 **`PacketTunnel` 网络扩展进程**（`ClashiOSExtension`）中加载运行；
   - **主 App 进程**通过现有的 IPC / 控制通道（`ClashCommandClient` + App Group）控制隧道，主进程内仅需加载 `LibSwipt.framework`（唯一一份 `GoSeqRef` 类表！）挂载 `SwiptRootView` 与 `FeatherRootView`。
   - 若未来确需在同一进程内同时链接两者，则必须使用单一联合 Go wrapper module 执行一次 `gomobile bind`（共享单一 Go runtime 与单一 `GoSeqRef`），而非加载两份独立 `gomobile` 动态库。
