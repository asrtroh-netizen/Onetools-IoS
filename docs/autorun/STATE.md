# OneTools 完成与打磨 · 状态

- 当前派活计划：`docs/superpowers/plans/2026-11-12-onetools-mimo-dispatch-18.md`。
- 今早本机已完成计划（不要重做 Q0–Q5）：`docs/superpowers/plans/2026-11-12-onetools-complete-polish-18.md`
- 今早起点：2026-11-12 09:45:00 +08:00（仓库在 `886992d`，工作区干净）
- 截止仍是：2026-11-12 18:00:00 +08:00（unix 1794477600）
- 上一轮：12 小时自动执行，起点 2026-11-11 18:00:13 +08:00，截止 2026-11-12 06:00:13 +08:00（unix 1794434413），最后提交 `886992d`（04:43:50 +08:00）。AFK 循环已停，不写 DONE/PAUSE，不重启钩子。
- 当前阶段：MA、MB、MC、MD、ME 已复核。不推送。派活书里的必做单元到此做完。
- 现在：MC 提交 `25fab74`，MB 提交 `69d7774`，MD 提交 `2ce4375`，ME 提交 `36f1e70`。MA-1、MA-2 的盘点在本提交。Q0–Q5 不重做。Q1 提交 `b50bcd7`；Q2 提交 `65082e1`。
- 网络：路由器 DNS 把 `raw.githubusercontent.com` 解析成 `0.0.0.0`。已把正在使用的「以太网」IPv4 DNS 从 `192.168.1.1` 改为 `1.1.1.1`、`8.8.8.8`，没改系统代理和全局 git。改完 `raw.githubusercontent.com` 与 `github.com` 均返回 200。回退：把该网卡 DNS 设回 `192.168.1.1`。记录在 `.mimocode/dns-fix-2026-11-12.txt`。

## 本轮队列

| 编号 | 状态 | 说明 |
|---|---|---|
| Q0 | 已验证 | 提交 `99b49e5`（09:48:17） |
| Q1 | 已验证 | 09:49:24–09:51:15，退出码 0。两次 `flutter test` 均为 `00:27 +271: All tests passed!`；270 张金图 sha256=`51d437c1c04373e13b9c6362d7dfdd876cebb5e2e3ec4cbd67c06be386fe3a33`，`HASH_SAME`。N6 `46 passed`。N1 六个上游干净。N13 HEAD=`7a8839e`。证据在 `docs/autorun/closeout-2026-11-12/`。 |
| Q2 | 已验证 | `docs/autorun/REPORT.md`。第一行：阻塞停（icons.json 仍缺）。N1–N14 均附本轮命令输出。 |
| Q3 | 部分通过 | 字号、底栏、水波纹已验证：swift test 为 Executed 7 tests, with 0 failures。假键 __probe 使测试失败后已撤掉。图标码点仍阻塞。不算 E3 全部通过。 |
| Q4 | 已验证 | 五份只读审查在 `docs/autorun/reviews/2026-11-12-lane-A.md` 至 `lane-E.md`。线 A 看了 10 张基准图；线 C 记录并入清单过时（Q5 订正）。 |
| Q5 | 已验证 | `integration-inventory.md` 改为指向已验收的 `docs/findings/submodules.md` 和 09:50 重数（247/25/6）。不跑 submodule update。 |
| Q6 | 无新增 | 本机可做且不违反禁区的打磨已做完。 |
| Q7 | 已更新（09:58） | 报告已写入 Q3–Q5。到 18:00 若无新变化即可保持。 |

## MiMo 派活（2026-11-12）

| 编号 | 状态 | 说明 |
|---|---|---|
| MB-1 | 已写入，未在 Mac 上运行 | `docs/findings/mac-parser-rehearsal.md`。没有在 WSL 重跑 `_harness/ModuleParser`。提交 `69d7774` |
| MB-2 | 语法通过，未编译 | 主代理用 WSL Swift 6.4.2 对五个 Swift 文件再跑 `swiftc -parse`，退出码都是 0。完整编译未做。同一提交 |
| MC-1 至 MC-4 | 脚本语法已过；步骤未在 Mac 上运行 | 五个 `scripts/mac/*.sh` 的 `bash -n` 退出码都是 0。`git submodule update` 没有作为命令。G2 与通话六项仍未决定。提交 `25fab74` |
| MD-1、MD-2 | 已写入，未运行 | `docs/findings/mac-m7-loon-checklist.md`。`check_ad_coverage.py` 为 21 行 `ok`，退出码 0。未调用解析器。提交 `2ce4375` |
| MA-1、MA-2 | 已核对 | `docs/findings/fixture-completeness.md`。P2 的 17 条里只有 480 在 `layout.json` 的 `dock.slideMs`；其余 16 条按合同不收。同一洗牌的第 41–80 条：一致 32，在另一份夹具 1，未收录 7。没有同一键数值不同。未改夹具，未造 `icons.json`。主代理按行号核过源码字面量，并抽查夹具键。 |
| ME-1、ME-2 | 已验证 | OneUI `Executed 9 tests, with 0 failures`；G3 `Executed 4 tests, with 0 failures`。图标仍阻塞，四项实现未选定。提交 `36f1e70` |

## 第 0 轮（上一轮已验证，保留证据）

| 编号 | 状态 | 证据 |
|---|---|---|
| R0-1 | 已验证 | `curl.exe` 访问 `https://raw.githubusercontent.com/flutter/flutter/master/README.md` 返回 `200`（1.01s）；`$env:USERPROFILE\.cursor\afk\ACTIVE` 在发车前不存在；E 盘剩余 665.04 GB |
| R0-2 | 已验证 | `hooks.json` 与 `hooks\afk-loop.py` 已写入。临时目录四条离线测试全部符合预期（未启动 `{}`、armed、已启动含 `followup_message`、别的对话 `{}`、过期输出 `{}` 且出现 `PAUSE`）。真计时 `python afk-loop.py --arm 12` 输出 `armed: deadline=1794434413 max_loops=40` |
| R0-3 | 已验证 | 六个仓库 `core.filemode=false`、`core.autocrlf=false`（2026-11-11 23:30 重查） |
| R0-4 | 已验证 | 顶层 `75b4ab8`「执行前的现状」；当时 `git status --porcelain` 为空 |
| R0-5 | 已验证 | Clash-Client、Swipt、Feather 的当前分支都是 `onetools`。`gates.log` 有 `R0-5-branches result=pass` |
| R0-6 | 已就绪 | 内核锁定版已从 zipball 解压到 `_ref/kernel-4b7d5f5/`（3362 文件，见 `.mimocode/r0-6-kernel-ready.txt`）。三个仓库 `git fetch --unshallow` 已在 2026-11-12 01:48 完成，均为 `shallow=false`，分支仍是 `onetools`（见 `.mimocode/r0-6-unshallow-ready.txt`）。子模块未走 `git submodule update`，已用 zipball 就位：IDeviceKitten 25 文件、Zsign 247 文件、DeveloperDiskImage 6 文件（见 `.mimocode/r0-6-submodules-ready.txt`）。这些目录没有 `.git`，不要再对它们跑 submodule update。 |
| R0-7 | 已验证 | Windows 版 `swift.exe` 访问冲突，见 NEGATIVE。WSL 里 `swift test`：`Test run with 1 test in 0 suites passed`，日志末行 `SMOKE_OK`，版本 `Swift version 6.4.2 (swift-6.4.2-RELEASE)`。包在 `_harness/_smoke` |
| R0-8 | 已验证 | Material 快照 200=200；`ow_icons.txt` 121 行。提交 `06414ac` |
| R0-9 | 已验证 | `tools/gates.py` 与 `gates.json` 已在，三条门禁曾通过。本文件已改成真实进度 |

## 五条线（上一轮验收 + 本轮动作）

| 线 | 上一轮 | 本轮 |
|---|---|---|
| A 基准线 | A1–A3、A5–A11、P1、P2 已验证；A4 阻塞（缺 `icons.json`） | MA-1、MA-2 已核对。A4 保持阻塞，不造假 icons.json |
| B Clash 线 | B1 已验证；B2 未编译；B3 不可行；B4 未做；P3 阻塞 | MB-1、MB-2 已提交 `69d7774`。不完整编译，不在 Linux 上重试 B3 |
| C 调研线 | C1–C6、SP-04 到 SP-09、P5 已验证；P7、P8 草稿已核对。G2 结论和通话六项未决定 | MC-1 至 MC-4 已提交 `25fab74`。G2 与通话六项仍未决定 |
| D 规则线 | D1–D4 已验证 | MD-1、MD-2 已提交 `2ce4375`。推断稿不是实测 |
| E OneUI 线 | E1、E2、P4 已验证；E3 等图标夹具；P6 数值草稿语法通过，四项实现未选定 | ME-1、ME-2 已提交 `36f1e70`。图标码点仍阻塞。不选定 P6 实现 |

上一轮细节（不删）：

- A：种子 `20261112` 盲读 40 个数值，对 `tokens.json` 一致 23、未收录 17，没有同一键数值不同。主代理按行号复核源码字面量，并抽查 12 个一致键。480 毫秒在 `layout.json` 的 `dock.slideMs`，不在 `tokens.json`。
- B：主代理重跑 `swift build --package-path _harness/ModuleParser` 退出码 1：`cannot find 'ModuleJQ'`、`cannot find 'ModuleJSONText'`。原文件第 1 行是 `#if os(iOS) || os(macOS)`。B4 不做。B1 提交 `658c29c`，B2 提交 `1358825`。
- C：双 Go 草稿在 `docs/drafts/g2-go-runtimes.md`，第一行是「未在 Mac 上运行」。`Swipt/Frameworks` 不存在，没有 `LibSwipt.xcframework`。`project.yml:164` 是 `type: framework`，`ClashiOS` 对 Clash 是 `embed: true`（`:155-156`），扩展是 `embed: false`（`:259-260`）。`device.go:77` 是 `NewLoopbackProbe`。没改 `project.yml`。通话规格在 `docs/superpowers/plans/2026-11-11-onetools-p9-calls-design.md`：`Calls` 目录 9 个文件、3038 行；四个点名文件在 `Runner` 下，不在 `Calls` 里。六项都标「未决定」。
- D：主代理重跑：覆盖检查与样本 `pytest` 为 `9 passed`；`loon_lint.py` 为 `ok`；`check_ad_coverage.py` 为 21 行 `ok`。抽查 11 处来源行，域名都在该行。三份公开列表的 SHA-256 与 `SOURCES.md` 一致。插件 12 条规则，覆盖 8 个 SDK；其余 13 个写了未收原因。
- E：主代理重跑 `swift test --package-path SigningLogic`：`Executed 13 tests, with 0 failures`，退出码 0。`experiments/G3/` 四个 Swift 文件一起 `swiftc -parse` 退出码 0，只 `import Foundation`。模糊常数与夹具一致：`blurPanel` 18、`blurBar` 24、`blurDock` 12、`blurLiquid` 10。文字、模糊、投影、水波纹触摸都没选实现。

## 下载（R0-6，上一轮）

- 2026-11-11 18:25 带 `127.0.0.1:12348` 的四项全部 exit 128，仓库仍是 shallow，三个子模块未初始化，`_ref/kernel-4b7d5f5` 只有空的 `.git`。
- 2026-11-11 23:35 直连 `github.com:443` 超时；`api.github.com` 与 `download.swift.org` 返回 200。
- API zipball 302 到 `codeload.github.com`，curl 一次 `Recv failure`。下一轮再试一次，失败就标阻塞。
- 2026-11-12 00:19 直连重试 zipball 成功（6907079 字节，curl exit 0）。00:35 已解压到 `_ref/kernel-4b7d5f5/`，3362 个文件。证据：`.mimocode/r0-6-kernel-ready.txt`。
- 2026-11-12 01:14 子模块改走 zipball 完成（不是 git submodule）：IDeviceKitten、Zsign、DeveloperDiskImage 已就位，见 `.mimocode/r0-6-submodules-ready.txt`。这些目录没有 `.git`，不要再跑 submodule update。
- 2026-11-12 01:15 第一次 unshallow 失败（连接重置 / 超时）。01:47 直连重试成功：Clash-Client 4.4s、Swipt 39.4s、Feather 7.7s，三个仓库均为 `shallow=false`。证据：`.mimocode/r0-6-unshallow-ready.txt`。未改全局 git 或系统代理，未推送。
