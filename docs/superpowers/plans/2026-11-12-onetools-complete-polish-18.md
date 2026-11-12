# OneTools iOS：完成与打磨计划（截止 2026-11-12 18:00）

> **后续（不要当新派活书，也不要重做 Q0–Q5）：** 本文件是今早 09:45–09:58 由本机直接执行并完成 Q0–Q5 的历史记录，最新提交 `5cef23b`（09:58:26 +08）。给 Xiaomi MiMo 的新派活计划是 `docs/superpowers/plans/2026-11-12-onetools-mimo-dispatch-18.md`。用户来派，DDPC 只盯不实施。

本文是 12 小时自动执行（`2026-11-11-onetools-12h-autorun.md`，截止 2026-11-12 06:00:13）之后的新一轮计划。不覆盖那份 12 小时计划，也不改第 8 节已冻结的判据 N1–N14。总计划仍是 `2026-11-11-onetools-ios-master-plan.md`。

- 起点：2026-11-12 09:45:00 +08:00（仓库 `main`，工作区干净，最新提交 `886992d`，2026-11-12 04:43:50 +08:00）
- 截止：2026-11-12 18:00:00 +08:00（unix 1794477600）
- 机器：Halo（Windows + WSL Ubuntu-24.04，Swift 6.4.2 在 `/opt/swift`）
- 目标：把 12 小时该交而没交的收尾做完，再做这台机器上还能做的打磨。五条线仍是 A 基准、B Clash、C 调研、D 规则、E OneUI，外加打磨与收尾队列。

本轮由本机直接执行，不重启已结束的 AFK 钩子，不写 `DONE`/`PAUSE`，不驱动需要人点的 Xiaomi MiMo 界面。不改系统代理或全局 git，不推送到远端，不跑 `git submodule update`。

---

## 0. 已完成与还没做完的

12 小时截止时，最后一次进度写在 04:38，最后一次提交是 04:43:50 的 `886992d`。此后到本轮起点，仓库没有新提交。

### 0.1 已经验收、本轮不重做（除非全量门禁要求再跑）

| 范围 | 状态 |
|---|---|
| 第 0 轮 R0-1 到 R0-9 | 已验证（R0-6 用 zipball 就位，三个仓已 unshallow；子模块目录没有 `.git`） |
| A 线：A1–A3、A5–A11、P1、P2 | 已验证。P1 末次是 271 项、270 张图两次哈希相同（04:06） |
| B 线：B1 | 已验证。B2 按设计标「未编译」，本轮不尝试完整编译 |
| C 线：C1–C6、SP-04 到 SP-09、P5、P7/P8 草稿核对 | 已验证或已核对。双 Go 和通话六项未决定 |
| D 线：D1–D4 | 已验证 |
| E 线：E1、E2、P4 | 已验证。P6 数值草稿只过了 `swiftc -parse`，四项实现未选定 |

### 0.2 本轮要做（这台机器做得到）

按这个顺序，一个单元做完再做下一个。做完就更新 `STATE.md`、线备忘、`gates.log`，并按既往习惯本地提交（一个单元一次提交，不推送）。

| 编号 | 线 | 做什么 | 验收 |
|---|---|---|---|
| Q0 | 收尾 | 写下本计划，刷新 `docs/autorun/STATE.md`（新截止、当前队列） | 文件在仓里，截止写成 18:00:00 +08:00 |
| Q1 | 收尾 | 全量门禁：`python tools/gates.py`，并在 `_golden` 里再跑一次 `flutter test`（门禁里已有一次，两次都要过）。两次之后比较 `goldens/` 哈希。另补 N1、N6（`python -m pytest tools -q`）、N13（ONEWIFIX 工作区与 HEAD）的证据 | 门禁全部通过；两次 `flutter test` 都是 `All tests passed!`；第二次后金图哈希与第一次相同；证据写入报告可用的日志 |
| Q2 | 收尾 | 写 `docs/autorun/REPORT.md`（12 小时计划第 9 节、判据 N14） | 见第 6 节。阻塞项标阻塞并引用冻结证据，不弱化 N2、A4、N5 |
| Q3 | E | **部分 E3**：对着已有的 `typography.json`、`dock_edges.json`、`ripple.json` 写 `TypeScale.swift`、`DockEdges.swift`、`InkRippleModel.swift` 和遍历夹具键的测试；经 WSL 跑 `swift test --package-path OneUI` | 测试全过；期望值从夹具读，不是写死在测试里的同一个数；往夹具临时加假键必须失败，然后撤掉。**明确标「部分 E3，不是 E3 全部通过」** |
| Q4 | 审查 | 只读五线审查，写入 `docs/autorun/reviews/` | 五份审查，对照 12 小时计划 11.2 的清单；每条发现有文件和行号 |
| Q5 | C | 订正 `docs/findings/integration-inventory.md` 里过时的「子模块未初始化」，改为指向已验收的 `docs/findings/submodules.md`（zipball 清点） | 不跑 `git submodule update`，不给 zipball 树补 `.git` |
| Q6 | 打磨 | 总计划里其他这台机器做得到、且不违反禁区的打磨 | 每项单独验收；做不了的记下原因 |
| Q7 | 收尾 | 18:00 前更新 `REPORT.md` 与 `STATE.md`（本轮新增产物、剩余时间、下一步） | 状态与磁盘一致 |

### 0.3 必须等待，本轮不做

| 项 | 原因 | 冻结依据 |
|---|---|---|
| A4 的 `icons.json`、E3 的图标码点（`MaterialIconCodepoints.swift`、`gen_icon_codepoints.py`、121 项一致） | 不造假、不写成 119。`Icons.eye` 与 `Icons.eye_slash` 来自 `obscurable_field.dart:51` 的 Cupertino，Material 解析只有 119。两种方式得不到码点 | `DECISIONS.md` 2026-11-12：A4 标阻塞。回退条件是以后单独列出 Cupertino 图标，或改冻结证据 |
| B2 完整编译 | 需要 Xcode / Apple 框架 | 12 小时计划：状态记「未编译」 |
| B3 在 Linux 上重试、B4、P3 | `ModuleJQ` / `ModuleJSONText` 被 `#if os(iOS) \|\| os(macOS)` 裁掉 | `DECISIONS.md`：B3 不可行，B4 不做，P3 因 B3 阻塞。等 Mac 上用原工程编过解析器 |
| P6 文字 / 模糊 / 投影 / 水波纹触摸的实现选定；声称 G3 结论 | 要等 Mac 实验（闸门 G3） | 已有 `experiments/G3/` 语法通过，四项未选定 |
| P7 双 Go 运行时结论（G2） | 要等 Mac；草稿已写，产物不在盘上，未改工程 | `docs/drafts/g2-go-runtimes.md` 第一行是「未在 Mac 上运行」 |
| P8 通话规格的六项未决 | 要等人拍板或 Mac | 草稿已核对：Calls 9 个文件、3038 行 |
| M0–M10 | 全部要 Mac 或你准备账号与证书 | 12 小时计划第 12 节，本轮仍不在范围内 |
| 改 `ClashtvOS` 的 `project.yml` | 已决定不改 | `DECISIONS.md` 2026-11-12 |
| 造假 `icons.json` / 121 图标项；弱化 N2、A4、N5 | 禁止为通过而改判据 | 12 小时计划 4.3、8 |

---

## 1. 授权与禁区

沿用 12 小时计划第 4 节，并加上本轮补充。

可以写：顶层 `docs/`、`OneUI/` 的 `OneUICore` 数值层与测试（Q3）、`docs/autorun/` 状态和报告、`docs/autorun/reviews/`、`docs/findings/integration-inventory.md` 的过时段落、本计划文件。本地提交可以，一个单元一次，不推送。

只读：`E:\GQ\Ultra\ONEWIFIX\`、`E:\GQ\Ultra\Onetools\`、`Clash-Core/`、`Swiplets/`、`zsign/` 工作区、`C:\Flutter\flutter\`。

无论如何不做：

- 推送到任何远端，开 PR。
- 改系统代理、全局 git 配置、电源、防火墙。
- 跑 `git submodule update`。zipball 就位的子模块没有 `.git`，不要补 Git 元数据。
- 发明或伪造 `icons.json` / 121 项图标。不要把 Cupertino 图标另列，除非冻结决定里已经授权（目前没有）。
- 完整编译 B2，或在 Linux 上重试 B3。
- 选定 P6 四项实现、声称 G2 结论、决定 P8 六项未决。
- 改 `ClashtvOS` 的 `project.yml`。
- 为通过而弱化检查：删测试、放宽阈值、改 N1–N14。
- 覆盖别人正在写的线 A/C/D 文件（若 MiMo 又开始写）。MiMo 空闲时可以做。
- 打开或输出 `ONEWIFIX/IOS/HANDOFF-GROK-iOS-Pairing.md`。
- 花钱，对外发消息。

拿不准时：已有冻结决定的，按决定做；没有决定、又要等人或等 Mac 的，标阻塞或「未决定」，不擅自拍板。

---

## 2. 五条线在本轮做什么

队列顺序以第 0.2 节为准。各线在全量门禁和审查里都要参与，但不再重做已验收单元的实现。

### 2.A 线 A：基准线

已验证：A1–A3、A5–A11、P1、P2。A4 因缺少 `icons.json` 阻塞，本轮保持阻塞。

本轮：参加 Q1 全量门禁（含两次 `flutter test`、夹具检查、覆盖 32/32、总览页）。不扩充新场景，除非门禁失败需要修复自己引入的问题。不改第 8 节对 A4「121 项且两种方式一致」的要求。

夹具现状：`tokens.json`、`typography.json`、`dock_edges.json`、`ripple.json`、`layout.json` 已在。`icons.json` 不在。`check_fixtures.py` 只检查已存在的 A4 文件，缺 `icons.json` 时仍可能输出 `ok`——报告里必须把 N5 写成「五份已验证，`icons.json` 阻塞」，不能把缺图标说成 N5 全部通过。

### 2.B 线 B：Clash 线

已验证：B1。B2 未编译（本轮只可随门禁做已有的语法级检查，不完整编译）。B3 不可行，B4 不做，P3 阻塞。

本轮：参加 Q1（`sync_harness.py --check`、`swift test --package-path _harness/ClashLogic`）。Q4 按 11.2 审查线 B。不改 `project.yml`，不在 Linux 上重试解析器测试台。

### 2.C 线 C：调研线

已验证：C1–C6、SP-04 到 SP-09、P5；P7、P8 草稿已核对。

本轮：Q5 订正并入清单；Q4 审查线 C。不改 `project.yml`，不把双 Go 草稿变成工程改动，不勾选通话六项，不声称 G2 结论。Mac 脚本仍标「未在 Mac 上运行」。

### 2.D 线 D：规则线

已验证：D1–D4。

本轮：参加 Q1（样本哈希、插件 lint、覆盖检查、相关 pytest）。Q4 审查线 D。不改收录规则，不把 anti-AD 或 ACL4SSR 加为第二来源（已有决定）。

### 2.E 线 E：OneUI 线

已验证：E1、E2、P4。P6 语法通过、实现未选定。E3 此前整项等 `icons.json`。

本轮做 **部分 E3**（Q3），范围仅限三份已有夹具：

| 文件 | 职责 | 测试 |
|---|---|---|
| `Sources/OneUICore/Tokens/TypeScale.swift` | 字号表，键与 `typography.json` 对齐 | 遍历该夹具每一个键 |
| `Sources/OneUICore/Motion/DockEdges.swift` | 底栏插值，键与 `dock_edges.json` 对齐 | 同上 |
| `Sources/OneUICore/Motion/InkRippleModel.swift` | 水波纹曲线，键与 `ripple.json` 对齐 | 同上 |

实现约定（与 E2 一致）：

- 只依赖 Foundation，不引入 SwiftUI，不改 14 个界面文件，不改 `Package.swift` 的 Linux/macOS 分支策略（除非为了让新文件进入已有 `OneUICore` target——它们放在 `Sources/OneUICore/` 下即可，Linux 的 `path: Sources` 会收录）。
- 测试期望值从夹具文件读取，用与 `OneTokenFixtureTests` 相同的遍历方式；Swift 目录缺键或夹具多一个键，测试必须失败。
- 主代理验收：`wsl -d Ubuntu-24.04 -u root -- env PATH=/opt/swift/usr/bin:/usr/bin:/bin /opt/swift/usr/bin/swift test --package-path /mnt/e/GQ/Ultra/Onetools-IoS/OneUI` 退出码 0；往三份夹具之一临时加 `__probe`，对应测试失败，撤掉后再过。
- 通过后把该 `swift test` 命令加进 `tools/gates.json`（可沿用已有的 `E2-swift-test`，因同一包一次跑全部测试；在备忘里写明部分 E3 已纳入）。
- **不算 E3 全部通过。** 图标码点仍阻塞。`STATE.md`、`REPORT.md`、线 E 备忘都写「部分 E3」。

P6 四项实现仍不选定。不把实验工程的草稿提升成正式界面实现。

---

## 3. 打磨与收尾队列

Q1、Q2 优先于部分 E3，因为 `REPORT.md` 是 12 小时未交的必达交付（N14）。报告先按全量门禁当时的仓库状态写；Q3–Q6 做完后，在 Q7 把本轮新增写进同一份报告，不另起炉灶，也不改 N1–N14 的条文。

Q6 只考虑不违反第 1 节的项，例如：审查里发现的真实、可修、不越权的问题；文档交叉引用；门禁清单里漏掉但本机可跑的已有检查（如完整 `pytest tools`）。发现后先记在 `STATE.md`，再做。

18:00 到点或全部单元做完或阻塞时：停止派新活，把状态写准，更新报告摘要。若必须提前停，`STATE.md` 写清已做、下一步和剩余时间，并在执行机箱上留 `/workspace/onetools-polish-18-status.md` 快照，方便后续接着跑。

---

## 4. 门禁

`tools/gates.py` 仍是唯一的门禁入口。清单只在一个单元验收通过之后加命令，不删、不放宽已有项。

Q1 的全量检查包括：

1. `python tools/gates.py`（现有全部已启用项，其中 `_golden` 的 `flutter test` 一次，上次 P1 约 25 分钟）。
2. 再在 `_golden` 跑一次 `flutter test`，并比较两次前后 `goldens/` 的哈希（与 P1 相同做法）。
3. `python -m pytest tools -q`（N6，门禁里是分文件跑的，收尾要有一次整目录输出）。
4. N1：六个上游 `git status --porcelain`，以及 `upstreams.lock.json` 与各仓起点。
5. N13：`git -C E:\GQ\Ultra\ONEWIFIX\IOS status --porcelain` 为空，HEAD 仍是 `7a8839e`。
6. 把命令输出收进报告（N14）。

Swift 命令一律经 `wsl -d Ubuntu-24.04`（需要时 `-u root`），路径 `/opt/swift/usr/bin/swift`。不用 Windows 上的 `swift.exe`（NEGATIVE：访问冲突）。

Q3 通过后，OneUI 的 `swift test` 已在门禁里，不必重复加一条相同命令；若要区分日志，可加一条 id 为 `E3-partial-swift-test` 的相同命令，但不删 `E1-swift-test` / `E2-swift-test`。

---

## 5. 验收说法

与 12 小时计划第 8 节相同，结果只用三种说法：

- **已验证**：本机跑过，附输出。
- **语法通过，未编译**：只过了 `swiftc -parse`，要等 Mac。
- **未运行**：写了但没有任何检查。

另用：

- **阻塞**：冻结证据已经说明做不到，附决定条目，不改判据。
- **部分通过**：仅用于部分 E3——三份数值夹具已验证，图标码点仍阻塞。不要把「部分通过」用到 N2、N5 的完整条文上；N5 在报告里拆成已验证的五份和阻塞的 `icons.json`。

成功标准（本轮结束时）：

- `docs/autorun/REPORT.md` 存在，覆盖 N1–N14 的状态与收尾命令输出，单元表完整，有未编译/未运行清单、执行中决定、发现的问题、Mac 前需要做的事。
- 全量门禁已跑，两次 `flutter test` 有记录。
- 部分 E3 要么已验证，要么在 `STATE.md` 写清做到哪、为何停下。
- 五线只读审查已落盘，或写清未能完成的原因。
- 并入清单不再声称子模块「未初始化」（若 zipball 树仍在）。
- 禁区没有被打破。阻塞项仍是阻塞。

本轮「全部判据通过」只有在 N1–N14 都不含阻塞时才写。由于 A4/`icons.json` 已冻结为阻塞，Q2 第一行应写「到点停」或「阻塞停」——以阻塞项仍在、收尾已交为准，推荐第一行：「阻塞停（A4/N5 的 `icons.json`、E3 图标码点仍缺；其余本机能验证的已验证或标未编译）。」Q3 之后仍是这句话，只补「部分 E3 已验证」。

---

## 6. 报告应有的内容

`docs/autorun/REPORT.md` 按 12 小时计划第 9 节写：

1. 第一行：本次结论（见第 5 节，不写「全部判据通过」除非阻塞已解除——本轮解除不了）。
2. 时间：12 小时段 2026-11-11 18:00:13–2026-11-12 06:00:13；本轮 09:45–18:00；最后提交与门禁时间。
3. 第 8 节每条判据的状态和证据（收尾那一轮的命令输出）。N5、N7 如实拆开。
4. 全部单元状态表（R0、A–E、P、本轮 Q0–Q7）。
5. 标「未编译」和「未运行」的文件清单。
6. 执行中的决定（可引用 `DECISIONS.md`，本轮若有新决定另记并写入该文件，且必须可回退）。
7. 发现的问题，以及对总计划的修正建议。
8. Mac 阶段开始前需要你做的事（沿用第 12 节 M0，加上本机无法关闭的阻塞：图标夹具策略、B3 在 Mac 上重做、P6/P7/P8 未决）。

不写控制文件 `DONE`/`PAUSE`（AFK 循环已结束）。

---

## 7. 状态文件

- `docs/autorun/STATE.md`：本轮一开始就改成这份计划的截止和队列；每完成一个单元更新「当前阶段 / 下一动作」。12 小时已验收的表格保留，不要删历史证据。
- `docs/autorun/lane-*-notes.md`：只追加本轮相关线的新证据。
- `docs/autorun/gates.log`：由 `gates.py` 追加，不要手改旧记录。
- `docs/autorun/DECISIONS.md`、`NEGATIVE.md`：有新决定或新的「试过不行」才追加。
- 本计划路径：`docs/superpowers/plans/2026-11-12-onetools-complete-polish-18.md`。

---

## 8. 时间怎么管

现在大约 09:45，到 18:00 约 8 小时。粗估：

| 时段 | 做什么 | 大约耗时 |
|---|---|---|
| 先 | Q0 计划与状态 | 已在写 |
| 紧接着 | Q1 全量门禁（两次 flutter test 是大头，每次约 25 分钟） | 60–80 分钟 |
| 随后 | Q2 报告 | 40–60 分钟 |
| 然后 | Q3 部分 E3 | 60–90 分钟 |
| 然后 | Q4 审查、Q5 清单订正、Q6 | 余下时间 |
| 18:00 前 | Q7 更新报告和状态 | 20–30 分钟 |

Q1 跑门禁时，可以只读准备 Q3（读夹具和 E2 写法），但不要在门禁跑到一半时改 OneUI 或 `_golden`，以免和测试抢同一份树。Flutter 测试进行中不要动 `goldens/`。

若某一项失败：先修本轮自己引入的问题；不是本轮引入、又不能在禁区内修的，记入报告和 `STATE.md`，不弱化判据。同一失败不盲目重试（先看 NEGATIVE 和决定）。

---

## 9. Mac 阶段（仍不在本轮）

顺序仍是 12 小时计划第 12 节的 M0–M10。本轮只保证 Windows 侧该交的报告、部分 E3 和文档订正已经落盘，方便 Mac 按 `scripts/mac/40-verify-windows-work.sh` 验收「未编译」产物。
