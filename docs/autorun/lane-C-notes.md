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

## C3（2026-11-12）

只做了 C3。没有改 C1、C2、C4、C5、C6 各段，也没有改本文件前半里「空目录 / C3 没做」的原句。那些句子停在 zipball 落地之前。当前盘面以 `docs/findings/submodules.md` 为准。没有 git 写操作，没有 submodule update，没有编译，没有下载，没有跑这三个目录里的脚本。

- 三份都是 zipball 副本。三处 `.git` 的 `Test-Path` 都是 false。含点文件的清点：Zsign 247 文件 / 29 目录 / 73,644,372 字节；IDeviceKitten 25 / 13 / 46,693；DeveloperDiskImage 6 / 0 / 18,046,187。与 `.mimocode/r0-6-submodules-ready.txt:2-4` 一致。
- Zsign 给 Feather 用要现编 C++ 源。依据：`project.pbxproj:512` 本地包，`Package.swift:39-53` 列了源，没有 `binaryTarget`，盘上没有 `bin/zsign`。README 的 CLI 是另 clone `zhlynn/zsign` 再 `make clean && make`（`README.zh-CN.md:51-54`、`:62-65`、`:73-82`，Windows 是打开 `zsign.sln`，`:87`）。本次不跑。`build/macos/Makefile:14-18` 用 `git describe`，取不到则为 `0.0.0-dev`；本目录没有 `.git`。体积大头是已在树里的两份 OpenSSL `.lib`，不把它们当成已编好的 zsign。
- IDeviceKit（目录名 IDeviceKitten）不在本目录现编 Rust。没有 `Cargo.toml`。`IDevice` 是 `binaryTarget`，zip 不在盘上（`Package.swift:21-24`）。`IDeviceSwift` 是源码（`:26-29`）。README 只有标题，没有编译命令。
- DeveloperDiskImage 不编译。`README.md:7` 只写替换文件。这份快照里没有 LICENSE，README 也没写许可。个性化变体和 `Restore.plist`：README `:5` 写留在外面，目录 6 个文件里也没有这两个名字。
- 提交号只出现在 `.mimocode/r0-6-zsign-ready.txt:2`、`r0-6-idevicekit-ready.txt:2`、`r0-6-ddi-ready.txt:2` 的 zip URL 里。树内没有 `.git`，本次没有重下 zip 去复核。
- 不改 `docs/findings/integration-inventory.md`。它仍写「未初始化」。超出本次可写的两个路径。

## P5

六份子计划只记本机已核对的事实，开头都是「未在 Mac 上运行」。没有 git 写操作。

- `docs/superpowers/plans/2026-11-11-onetools-p4-oneui-core.md`（SP-04，4.0 到 4.5）
- `docs/superpowers/plans/2026-11-11-onetools-p4-oneui-components.md`（SP-05，4.6 到 4.9）
- `docs/superpowers/plans/2026-11-11-onetools-p5-shell-swipt.md`（SP-06，5.0、5.1）
- `docs/superpowers/plans/2026-11-11-onetools-p5-feather.md`（SP-07，5.2）
- `docs/superpowers/plans/2026-11-11-onetools-p6-adblock.md`（SP-08，P6）
- `docs/superpowers/plans/2026-11-11-onetools-p7-signing.md`（SP-09，P7）

## P7

打磨队列 P7：双 Go 运行时实验的工程配置草稿。只写了 `docs/drafts/g2-go-runtimes.md`。没有改 Clash-Client、Clash-Core、Swipt，没有改 `docs/autorun/STATE.md`，没有 git 写操作，没有编译，没有下载。上面 SP-09 那一行仍是自签子计划，与这一节不是同一件事。

- 草稿第一行是「未在 Mac 上运行」。不进 Clash-Client 分支。
- 总计划 T2.6（`docs/superpowers/plans/2026-11-11-onetools-ios-master-plan.md:737`）要的是实验结论：共存（A）或冲突（B）（`:283`、`:742`、`:746`）。这次没跑实验，没有结论。
- 盘上没有 `LibSwipt.xcframework`，也没有同名二进制。`Swipt/Frameworks` 不存在。`Swipt/.gitignore:2` 忽略 `/Frameworks/`。产物路径写在 `Swipt/internal/cmd/build_libswipt/main.go:21` 和 `Swipt/Swipt.xcodeproj/project.pbxproj:30`。本次没编。
- `Clash-Client/apple/ClashClient/project.yml` 未改。`Clash` 的 `type: framework` 在 `:164`。`ClashiOS` 对它 `embed: true`（`:155-156`）。`ClashiOSExtension` 对它 `embed: false`（`:259-260`）。
- 实验要加的 target 名是计划里的 `SwiptCore`（`:193`、`:740`）。`ClashiOS` 依赖并嵌入它（`:740`）。探测函数名按计划抄 `LibSwiptNewLoopbackProbe`（`:741`）。Go 源里是 `Swipt/libswipt/device.go:77` 的 `NewLoopbackProbe`。

## P8

打磨队列 P8：通话规格草稿，对应总计划 SP-10。只写了 `docs/superpowers/plans/2026-11-11-onetools-p9-calls-design.md`。没有改代码，没有改 `docs/autorun/STATE.md`，没有 git 写操作，没有下载。

- 文件第一行是「未在 Mac 上运行。这一步不排期。」
- `E:\GQ\Ultra\ONEWIFIX\IOS\ios\Runner\Calls\` 存在。9 个文件，按「换行符个数，末尾无换行则加 1」合计 3038 行。`CallPushRegistry.swift` 末尾无换行，145 行（换行符 144）。
- `CallAudioBridge.swift`、`APNsBridge.swift`、`OtpNotifier.swift`、`OtpLiveActivity.swift` 在 `ONEWIFIX\IOS\ios\Runner\`，不在 `Calls\`。行数 207、218、233、136。
- 写下规格之前，`onetools://` 在本仓库 2 处：`HANDOFF.md:322`、总计划 `:926`。两处都是在记「没有实现」。规格摘了总计划那一行，写完后再搜会多出规格和本备忘里的复述。
- 号码网关、SIP 还是自有协议、后端放哪、配对入口、Push 权限、代码归属，六条都标「未决定」。

## MC-1 至 MC-4（2026-11-12）

只追加这一节。上文里「子模块空目录」「脚本执行 git submodule update」「OneUI 没有测试 target」是当时记录。以本节之后的脚本和子计划为准。没有 git 写操作，没有改 `project.yml`，没有在 Mac 上跑脚本，没有跑 `xcodebuild` / `make` / `bun` / bootstrap。

- MC-1：`scripts/mac/30-swipt.sh` 与 `35-feather.sh` 改为检查 zipball 标记文件（247 / 25 / 6，没有 `.git`）。文件在就跳过拉取并打印现状；文件不在就失败。不要跑 `git submodule update`。`10-env.sh` 不再写 IDeviceKit 子模块没拉下来。`docs/superpowers/plans/2026-11-11-mac-stage.md` 的 M4 已同步。五个脚本用 `"C:\Program Files\Git\bin\bash.exe" -n` 检查，退出码都是 0。
- MC-2：SP-04、SP-05 改为部分 E3 已核对（7 项测试，图标仍阻塞）。14 个界面文件仍未改。4.2–4.9 界面层、xcodebuild、G4 仍未做，仍标「未在 Mac 上运行」。SP-06、SP-07 不再写空目录和脚本拉子模块。SP-08 没有这类过时句，未改。SP-09 本来就写着 SigningLogic 13 项，未改。M2 补上 SigningLogic 13 项和部分 E3 的 7 项。`40-verify-windows-work.sh` 回显 REPORT.md 第 3 节未编译清单、ClashtvOS 注意事项，并写入 `swift test --package-path SigningLogic`。改完再 `bash -n`，五个退出码仍是 0。
- MC-3：`docs/drafts/g2-go-runtimes.md` 补上 Mac 步骤。第一行仍是「未在 Mac 上运行」。再核对：`Swipt/Frameworks` 不存在，没有 `LibSwipt.xcframework`；`project.yml` 的 `type: framework` 在 `:164`，`embed: true` 在 `:155-156`，`embed: false` 在 `:259-260`；`device.go:77` 是 `NewLoopbackProbe`。没有 G2 结论，没有改 Clash-Client 工程。
- MC-4：`docs/findings/calls-decisions.md` 六项都是未决定。`HANDOFF.md:116` 的 Skia 加粗量改为指向 `_ref/NOTES.md:21` 的「一致」，字号规格没改。

主代理复核：五个 `scripts/mac/*.sh` 再跑 `bash -n`，退出码都是 0。`git submodule update` 只出现在「不要跑」的说明里，没有作为命令。未跑 `xcodebuild`。`_ref/NOTES.md:21` 的结论是「一致」。


