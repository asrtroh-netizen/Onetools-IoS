# OneTools 12 小时自动执行 · 状态

- 起点：2026-11-11 18:00:13 +08:00（发车检查通过、计时 armed）
- 截止：2026-11-12 06:00:13 +08:00（unix 1794434413）
- 续跑上限：40
- 当前阶段：打磨队列。现在 2026-11-12 04:35 +08:00，剩余约 85 分钟。
- 下一动作：P7 双 Go 草稿已核对。P6（`experiments/G3/`）和 P8（通话规格）仍在写。A4、E3 图标夹具仍阻塞，B4 不做，P3 因 B3 不可行阻塞。

## 第 0 轮

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

## 五条线

第 1 轮已派出 A、C、D。队列顺序仍是计划第 7 节。

| 线 | 队列 | 现状 |
|---|---|---|
| A 基准线 | A1–A3、A5–A11、P1、P2 已验证；A4 阻塞（缺 `icons.json`） | 种子 `20261112` 盲读 40 个数值，对 `tokens.json` 一致 23、未收录 17，没有同一键数值不同。主代理按行号复核源码字面量，并抽查 12 个一致键。480 毫秒在 `layout.json` 的 `dock.slideMs`，不在 `tokens.json` |
| B Clash 线 | B1 已验证；B2 未编译；B3 不可行；B4 未做 | 主代理重跑 `swift build --package-path _harness/ModuleParser` 退出码 1：`cannot find 'ModuleJQ'`、`cannot find 'ModuleJSONText'`。原文件第 1 行是 `#if os(iOS) || os(macOS)`。B4 不做。B1 提交 `658c29c`，B2 提交 `1358825` |
| C 调研线 | C1、C2、C3、C6 已验证；C4、C5 已验证并提交 `37f542c`；SP-04 到 SP-09 已复核；P7 草稿已核对 | 双 Go 草稿在 `docs/drafts/g2-go-runtimes.md`，第一行是「未在 Mac 上运行」。`Swipt/Frameworks` 不存在，没有 `LibSwipt.xcframework`。`project.yml:164` 是 `type: framework`，`ClashiOS` 对 Clash 是 `embed: true`（`:155-156`），扩展是 `embed: false`（`:259-260`）。`device.go:77` 是 `NewLoopbackProbe`。没改 `project.yml`。G2 结论还没有 |
| D 规则线 | D1–D4 已验证 | 主代理重跑：覆盖检查与样本 `pytest` 为 `9 passed`；`loon_lint.py` 为 `ok`；`check_ad_coverage.py` 为 21 行 `ok`。抽查 11 处来源行，域名都在该行。三份公开列表的 SHA-256 与 `SOURCES.md` 一致。插件 12 条规则，覆盖 8 个 SDK；其余 13 个写了未收原因 |
| E OneUI 线 | E1 已验证，提交 `cb3fcdc`；E2 已验证；E3 等图标夹具；P4 自签纯逻辑已验证 | 主代理重跑 `swift test --package-path SigningLogic`：`Executed 13 tests, with 0 failures`，退出码 0。到期前 7 天和 1 天各一条；已过期、当天到期、提前 6 天都不发。批量里单个失败不影响其余。只依赖 Foundation |

## 下载（R0-6）

- 2026-11-11 18:25 带 `127.0.0.1:12348` 的四项全部 exit 128，仓库仍是 shallow，三个子模块未初始化，`_ref/kernel-4b7d5f5` 只有空的 `.git`。
- 2026-11-11 23:35 直连 `github.com:443` 超时；`api.github.com` 与 `download.swift.org` 返回 200。
- API zipball 302 到 `codeload.github.com`，curl 一次 `Recv failure`。下一轮再试一次，失败就标阻塞。
- 2026-11-12 00:19 直连重试 zipball 成功（6907079 字节，curl exit 0）。00:35 已解压到 `_ref/kernel-4b7d5f5/`，3362 个文件。证据：`.mimocode/r0-6-kernel-ready.txt`。
- 2026-11-12 01:14 子模块改走 zipball 完成（不是 git submodule）：IDeviceKitten、Zsign、DeveloperDiskImage 已就位，见 `.mimocode/r0-6-submodules-ready.txt`。这些目录没有 `.git`，不要再跑 submodule update。
- 2026-11-12 01:15 第一次 unshallow 失败（连接重置 / 超时）。01:47 直连重试成功：Clash-Client 4.4s、Swipt 39.4s、Feather 7.7s，三个仓库均为 `shallow=false`。证据：`.mimocode/r0-6-unshallow-ready.txt`。未改全局 git 或系统代理，未推送。

