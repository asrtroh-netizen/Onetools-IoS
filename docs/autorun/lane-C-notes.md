# 线 C 备忘

C4、C5 在 2026-11-12 落盘。C1、C2、C3 的下载没做。C6 没做。没有 git 写操作，没有改 Swipt 和 Feather 的源码。

## 决定

- `TEAM_ID` 和 `BUNDLE_BASE` 只从环境变量读。缺了 `scripts/mac/20-clash-client.sh` 就退出并打印缺哪个。不写死 Team ID。依据：总计划 T2.2 的 `--bundle-base` / `--team`，以及 `Clash-Client/scripts/configure.py` 第 12–19 行。空字符串也算缺，因为本脚本要求调用方显式传入。
- `20-clash-client.sh` 不调用 `xcodebuild`。`configure.py` 自己会跑 `xcodegen` 和 `build_cli.py` 的 `go build`，这是 T2.2 的步骤，保留。
- `35-feather.sh` 不写编译命令。`Feather/Zsign` 和 `Feather/IDeviceKitten` 是空目录，README 不在本机。脚本只 `git submodule update --init --recursive`，然后 echo「先读 Zsign/README 和 IDeviceKitten/README 再编译」。
- `40-verify-windows-work.sh` 里 ClashLogic 的预期命令是 `swift test`。OneUI 的预期命令是总计划 P4 的两条 `xcodebuild`。`swift test --package-path OneUI` 留作对照。撰写时 `OneUI/Package.swift` 只有 iOS 15，没有测试 target。
- 并入清单的数字都来自本机 `rg`。三个子模块目录为空，写成「未初始化」，不编文件数。

## 没在本次改的

- `scripts/mac/10-env.sh` 已有「未在 Mac 上运行」，原样保留。它在系统 Python 上检查 PyYAML，失败会退出；提示指向 20 号脚本的 venv。
- 上游 `Feather/Makefile` 的 `clean` / `deps` 会删目录，并从 backloop.dev 下载证书。35 号脚本不调用 `make`。

## 结论（2026-11-12 重跑）

仓库根：`E:\GQ\Ultra\Onetools-IoS`。`$rg` 是 `C:\Users\Administrator\AppData\Local\OpenAI\Codex\bin\a7d4c4900eafc659\rg.exe`。

- C4：主代理已用 Git bash `-n` 检过 `scripts/mac/10-env.sh`、`20-clash-client.sh`、`30-swipt.sh`、`35-feather.sh`、`40-verify-windows-work.sh`，五个退出码都是 0。脚本没在 Mac 上跑。
- C5 `Bundle.main`：`-c` 各行数字相加是 58（44 个文件：Clash-Client 20、Swipt 22、Feather 16）。`VPNController.swift` 三处现在是 986、1104、2664。
- C 类补上的命令（标识 / 日志 / 路径 / 本地化）重跑 36 行。扣掉归 B 或 D 的 4 行后是 32。
- B 类收紧后：`Bundle.main.url/path(forResource:)` 加 `bundleURL.appendingPathComponent` 是 10 行；`let configURL = Bundle.main.url(` 另有 2 行。合计 12。
- 文档类型命令命中 Swipt `.swiplet`、Feather `.ipa` 与 `.tipa`、Clash `public.yaml`（`project.yml:113` 和 `:118`）。`:371` 是分享扩展激活规则。
- 顶层同名类型命令 8 行：`AppDelegate`、`AppLanguage`、`HomeView`、`SettingsView`。
- 版本：swift-crypto Clash 3.15.1 / Feather 3.12.3；swift-asn1 Clash 1.7.3 / Feather 1.3.2 与 1.3.1；swift-atomics Swipt 1.3.1 / Feather 1.2.0；`golang.org/x/sys` Clash cli v0.48.0 / Swipt v0.49.0；gomobile 两边都是 v0.1.13。
- 子模块 `Feather/Zsign`、`Feather/IDeviceKitten`、`Swipt/Swipt/Resources/DeveloperDiskImage` 仍是空目录，未初始化。C1、C2、C3 没做。

## C1（主代理 2026-11-12 01:06 重核）

四个文件的 blob 与 `e9ed4fc9f1544c58d8a9347c1fc9471d8dd7c465` 一致。插值表在 `SkTextFormatParams.h` 第 15–25 行，是 9 与 36、1/24 与 1/32。结论写成「一致」，不改 P4 字体规格。详情在 `_ref/NOTES.md`。

主代理 2026-11-12 00:52 重跑：五个 `bash -n` 退出码 0；`Bundle.main` 各文件计数相加 58；三个子模块目录文件数为 0。`40-verify-windows-work.sh` 里关于 OneUI 没有测试 target 的句子已改成和 E1 之后的 `Package.swift` 一致。脚本仍未在 Mac 上运行。

## C2（2026-11-12 00:56 开始）

只做了 C2。C1、C3、C6 没做。没有改内核、Swipt、Feather，没有下载，没有 git 写操作。结论在 `docs/decisions/W-kernel-loopback.md`。

- 锁定树有 `loopback-address`。`config/config.go:307` 声明，`:1871` 抄进 TUN。该文件与 `Clash-Core/config/config.go` SHA256 前 12 位相同（`D2456054F469`）。
- 实现是 IP 层反射：`listener/sing_tun/server.go:427-428` 拆地址，`:535` 走 `tun.NewStack`；`third_party/sing-tun/ip_rewrite.go:50-53` 和 `:82-86` 命中后交换源和目的再写回，TCP / UDP / ICMP 同路。测试 `ip_rewrite_loopback_test.go:33-36`。
- 工作区的选项文本相同，数据面改成 Go 栈：`Clash-Core/listener/sing_tun/server.go:516` 调 `startGoStack`，`bind/clash/go_stack_darwin.go:110-111` 用 `NewIPRewriter`。锁定树没有 `sing-tun-go`；工作区 `third_party/sing-tun/` 没有 `stack_system.go`、`stack_gvisor.go`、`stack_mixed.go`、`stack_mipstack.go`。

## C6（2026-11-12 01:23 开始，01:38 写完）

只做了 C6。B3 已经判定不可行，没有再编译测试台，没有写 B4。没有改 Clash-Client、Swipt、Feather、ONEWIFIX，没有 git 写操作，没有下载，没有执行样本。结论在 `docs/findings/loon-ignored-predicted.md`。

- 入口用 `ModuleParser.parse`，不把 `adblock4limbo.list` 改送 `ModuleRuleSetSyntax.convert`。依据：C6 替代的是 B4，B4 跑的是模块解析器。回退：以后若确认名单走规则集，按 `convert` 重写第 1 节。那条路上 `plainKernelLine` 要求 `DOMAIN` 类只有两段（`ModuleRuleSetSyntax.swift:519-520`），这 548 行带策略，会先返回 nil，再被拼上另一个策略交给 `map`（`:399-400`）。
- 平台按 iOS。依据：`ModuleIR.swift:34-40` 的 `current` 在 iOS 目标上是 `.ios`，这个应用是 iOS 客户端。回退：改按 Mac 推断时，`weibo.plugin` 和 `XWebAds.plugin` 的 `#!system` 会在 `ModuleParser.swift:972-975` 整份变成 `otherPlatform`。
- `DOMAIN` / `AND` 过了 Swift 映射之后还要 `kernelCheck`（`ModuleRuleMapping.swift:36-39`）。`AppCore.validateItem` 不在本树，不把这些规则写成忽略。依据：计划 5.5，查不到就不凭印象写成会被内核拒绝。回退：有了 Clash 模块之后用 B4 的真实输出替换这一句。
- 正则用本机 Swift 6.4.2 Foundation 的 `NSRegularExpression` 核对了 160 条，对应 `ModuleLineSyntax.swift:121`。没有跑解析器。结果是 0 条构造失败。

