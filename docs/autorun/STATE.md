# OneTools 12 小时自动执行 · 状态

- 起点：2026-11-11 18:00:13 +08:00（发车检查通过、计时 armed）
- 截止：2026-11-12 06:00:13 +08:00（unix 1794434413）
- 续跑上限：40
- 当前阶段：第 2 轮后半。现在 2026-11-12 03:37 +08:00，剩余约 143 分钟。
- 下一动作：A9 已验收。派 A10（设计文件覆盖）和 A11（总览页）。B4 不做。E3 等图标夹具。

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
| A 基准线 | A1–A3、A5–A9 已验证；A4 阻塞（缺 `icons.json`）；A10、A11 进行中 | 主代理在 `_golden` 连跑两次 `flutter test`，都是 `00:14 +113: All tests passed!`，退出码 0。20 张底栏图都是 1170×2532。`layout.json` 底栏 56 / 28 / 8 / 12 / 4 / 48，滑动 480 ms，与 `glass.dart` 和 `GlassDock._slideDuration` 一致。场景用 `ultra_glass_dock.dart` 的 `GlassDock` |
| B Clash 线 | B1 已验证；B2 未编译；B3 不可行；B4 未做 | 主代理重跑 `swift build --package-path _harness/ModuleParser` 退出码 1：`cannot find 'ModuleJQ'`、`cannot find 'ModuleJSONText'`。原文件第 1 行是 `#if os(iOS) || os(macOS)`。B4 不做。B1 提交 `658c29c`，B2 提交 `1358825` |
| C 调研线 | C1、C2、C3、C6 已验证；C4、C5 已验证并提交 `37f542c` | 主代理重数：Zsign 247 文件 / 29 目录 / 73,644,372 字节；IDeviceKitten 25 / 13 / 46,693；DeveloperDiskImage 6 / 0 / 18,046,187。三处都没有 `.git`。`Package.swift` 的 binaryTarget 在 IDeviceKitten 第 21–24 行；Zsign LICENSE 第 1、3 行是 MIT / zhlynn；`Platform.swift:88` 挂载 DeveloperDiskImage。两份 OpenSSL `.lib` 分别是 57,184,898 和 12,535,234 字节。C6 文档开头是「推断，未经解析器实测」 |
| D 规则线 | D1–D4 已验证 | 主代理重跑：覆盖检查与样本 `pytest` 为 `9 passed`；`loon_lint.py` 为 `ok`；`check_ad_coverage.py` 为 21 行 `ok`。抽查 11 处来源行，域名都在该行。三份公开列表的 SHA-256 与 `SOURCES.md` 一致。插件 12 条规则，覆盖 8 个 SDK；其余 13 个写了未收原因 |
| E OneUI 线 | E1 已验证，提交 `cb3fcdc`；E2 已验证；E3 等图标夹具 | 主代理重跑 `swift test --package-path OneUI`：`Executed 4 tests, with 0 failures`。假键 `__probe` 失败于 `swift missing tokens.__probe`，撤掉后再过。`Glass.radiusCard` 18，浅色描边 alpha `0.5950` |

## 下载（R0-6）

- 2026-11-11 18:25 带 `127.0.0.1:12348` 的四项全部 exit 128，仓库仍是 shallow，三个子模块未初始化，`_ref/kernel-4b7d5f5` 只有空的 `.git`。
- 2026-11-11 23:35 直连 `github.com:443` 超时；`api.github.com` 与 `download.swift.org` 返回 200。
- API zipball 302 到 `codeload.github.com`，curl 一次 `Recv failure`。下一轮再试一次，失败就标阻塞。
- 2026-11-12 00:19 直连重试 zipball 成功（6907079 字节，curl exit 0）。00:35 已解压到 `_ref/kernel-4b7d5f5/`，3362 个文件。证据：`.mimocode/r0-6-kernel-ready.txt`。
- 2026-11-12 01:14 子模块改走 zipball 完成（不是 git submodule）：IDeviceKitten、Zsign、DeveloperDiskImage 已就位，见 `.mimocode/r0-6-submodules-ready.txt`。这些目录没有 `.git`，不要再跑 submodule update。
- 2026-11-12 01:15 第一次 unshallow 失败（连接重置 / 超时）。01:47 直连重试成功：Clash-Client 4.4s、Swipt 39.4s、Feather 7.7s，三个仓库均为 `shallow=false`。证据：`.mimocode/r0-6-unshallow-ready.txt`。未改全局 git 或系统代理，未推送。

