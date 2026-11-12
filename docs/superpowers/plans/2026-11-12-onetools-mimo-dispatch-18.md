# OneTools iOS：Xiaomi MiMo 派活计划（截止 2026-11-12 18:00）

本文是给 **Xiaomi MiMo** 的派活书，不是今早那份已经执行完的历史记录。

- **谁派：** 用户（Catbaby）把下面的五路口令分别交给 Xiaomi MiMo。DDPC 只写了这份计划，之后只盯进度，**不实施、不改产品代码、不代替 MiMo 跑测试或提交**。
- **谁做：** Xiaomi MiMo。五条线（A 基准 / B Clash / C 调研 / D 规则 / E OneUI）加打磨与收尾，由用户按路派发。
- **仓库：** `E:\GQ\Ultra\Onetools-IoS`，分支 `main`。写本文时 HEAD 是 `5cef23b`（2026-11-12 09:58:26 +08:00），工作区干净，其后没有新提交。
- **截止：** 2026-11-12 18:00:00 Asia/Shanghai（unix 1794477600）。到点停止派新活，做完收尾就停。
- **机器：** Halo（Windows + WSL Ubuntu-24.04，Swift 6.4.2 在 `/opt/swift`）。能在这台机器验证的要验证；要 Mac 的只允许写成检查单或脚本，并标明「未在 Mac 上运行」。
- **上一份：** 今早本机直接执行的计划是 `docs/superpowers/plans/2026-11-12-onetools-complete-polish-18.md`（Q0–Q5 已完成）。那是历史记录，不要覆盖，也不要按它再做一遍。总计划仍是 `docs/superpowers/plans/2026-11-11-onetools-ios-master-plan.md`。12 小时自动执行计划是 `docs/superpowers/plans/2026-11-11-onetools-12h-autorun.md`（已于 06:00:13 截止）。
- 本地提交可以（一个单元一次，只提交本单元文件），**不推送**。不改系统代理或全局 git，不跑 `git submodule update`，不写 `DONE`/`PAUSE`。

---

## 0. 已经做完的，不要重做

### 0.1 今早在 Halo 上由本机直接做完（提交 `5cef23b`，09:58:26 +08）

这些 **不是** 在 Xiaomi MiMo 里跑的，所以 MiMo 对话里没有记录。产物已经在仓库里，不要再做一遍。

| 编号 | 状态 | 不要再做的内容 |
|---|---|---|
| Q0 | 已验证 `99b49e5` | 写下 18:00 计划并刷新状态 |
| Q1 | 已验证 `b50bcd7` | 全量门禁。两次 `flutter test` 均为 `00:27 +271: All tests passed!`；270 张金图 sha256=`51d437c1c04373e13b9c6362d7dfdd876cebb5e2e3ec4cbd67c06be386fe3a33`，`HASH_SAME`。N6 `46 passed`。N1 六个上游干净。N13 HEAD=`7a8839e`。证据在 `docs/autorun/closeout-2026-11-12/` |
| Q2 | 已验证 `65082e1` | `docs/autorun/REPORT.md`。第一行是阻塞停，**没有**弱化 A4/N5 的 `icons.json` 要求 |
| Q3 | 部分通过 `f28e45c` | 部分 E3：`TypeScale.swift`、`DockEdges.swift`、`InkRippleModel.swift` 及夹具遍历测试。`swift test --package-path OneUI` 为 Executed 7 tests, 0 failures；假键 `__probe` 使测试失败后已撤掉。**不算 E3 全部通过**（图标仍阻塞） |
| Q4 | 已验证 `68fadb5` | 五份只读审查：`docs/autorun/reviews/2026-11-12-lane-A.md` 至 `lane-E.md`。线 A 抽看了 10 张基准图 |
| Q5 | 已验证 `7e39df4` | `docs/findings/integration-inventory.md` 改为指向已验收的 `docs/findings/submodules.md` 和 09:50 重数（247/25/6）。不跑 `git submodule update` |
| Q6 | 无新增 | 当时判定本机可做且不违反禁区的打磨已做完。本派活书给出的是审查与总计划里**当时没做、现在仍值得做**的剩余项，不是把 Q6 再跑一遍 |
| Q7 | 已更新（09:58） | 报告已写入 Q3–Q5 |

注意：`docs/superpowers/plans/2026-11-11-onetools-p4-oneui-core.md`（SP-04）和 `…-p4-oneui-components.md`（SP-05）写于今早 Q3 **之前**（约 04:21），其中「没有 `TypeScale.swift` / `DockEdges.swift` / `InkRippleModel.swift`」已经过时。以仓库和 `REPORT.md` 为准，不要按 SP-04 把部分 E3 再实现一遍。订正这两份文档是线 C 的待派单元。

### 0.2 昨晚 12 小时自动执行已验收的（截止 06:00:13，最后提交 `886992d`，04:43:50）

| 范围 | 状态 |
|---|---|
| 第 0 轮 R0-1 到 R0-9 | 已验证（R0-6 用 zipball 就位，三个仓已 unshallow；子模块目录没有 `.git`） |
| A 线：A1–A3、A5–A11、P1、P2 | 已验证。P1 末次（及今早 Q1）为 271 项、270 张图两次哈希相同。A4 因缺少 `icons.json` 阻塞 |
| B 线：B1 | 已验证。B2 按设计标「未编译」。B3 不可行，B4 不做，P3 因 B3 阻塞 |
| C 线：C1–C6、SP-04 到 SP-09、P5、P7/P8 草稿核对 | 已验证或已核对。双 Go 和通话六项未决定。C6 是推断，未经解析器实测 |
| D 线：D1–D4 | 已验证 |
| E 线：E1、E2、P4 | 已验证。P6 数值草稿只过了 `swiftc -parse`，四项实现未选定。E3 今早只完成非图标部分 |

不要重跑已验收单元的实现，除非本轮自己改坏了、需要修。不要为了「再确认」把 271 项 `flutter test` 再跑两遍——那是收尾条件触发时才做的事（见第 6 节）。

---

## 1. 硬约束（冻结，不要绕）

1. **不要发明或伪造 `icons.json`。** `Icons.eye` / `Icons.eye_slash` 来自 `obscurable_field.dart:51` 的 Cupertino，Material 解析只有 119 项。不要写成 119，不要造假 121，不要改 `ow_icons.txt` 的 121 行，不要自行把两个 Cupertino 图标另列。A4 和 E3 图标码点保持阻塞。回退条件只在用户写入 `DECISIONS.md` 之后才成立。
2. **不要弱化 N2、A4、N5。** `check_fixtures.py` 在缺 `icons.json` 时仍可能输出 `ok`（只检查已存在的 A4 文件）——报告里必须把 N5 拆成「五份已验证，`icons.json` 阻塞」，不能把缺图标说成 N5 全部通过。不要为过关而改判据、删测试、放宽阈值。
3. **不要在这台 Windows/WSL 机器上完整编译 B2**（需要 Xcode / Apple 框架）。状态继续记「未编译」。允许已有的 `swiftc -parse` 语法级检查。
4. **不要在 Linux 上重试 B3。** `ModuleJQ` / `ModuleJSONText` 被 `#if os(iOS) || os(macOS)` 裁掉，已判不可行。B4、P3 保持不做 / 阻塞。解析器只允许写成「Mac 上用原工程」的检查单，标「未在 Mac 上运行」。
5. **不要选定** P6 的文字 / 模糊 / 投影 / 水波纹触摸实现，不要声称 G3 或 G2 已有结论，不要决定 P8 通话规格的六项未决——除非用户已经把决定写进 `DECISIONS.md`（写本文时没有）。草稿和检查单可以写，第一行必须是「未在 Mac 上运行」或「未决定」。
6. **不要改系统代理或全局 git 配置。** 不要推送到任何远端，不要开 PR。
7. **不要跑 `git submodule update`。** zipball 就位的 IDeviceKitten、Zsign、DeveloperDiskImage 没有 `.git`，不要补 Git 元数据。线 C 的一项工作正是把仍会调用 submodule update 的 Mac 脚本改掉（见 MC-1）。
8. **不要改 `ClashtvOS` 的 `project.yml`**（已有决定）。不要改 Swipt、Feather 源码。不要打开或输出 `ONEWIFIX/IOS/HANDOFF-GROK-iOS-Pairing.md`。不要花钱，不要对外发消息。
9. 拿不准时：已有冻结决定的，按决定做；没有决定又要等人或等 Mac 的，标阻塞或「未决定」，不擅自拍板。同一失败先看 `NEGATIVE.md` 和 `DECISIONS.md`，不盲目重试。

验收用语与 12 小时计划第 8 节相同：

- **已验证**：本机跑过，附输出。
- **语法通过，未编译**：只过了 `swiftc -parse`，要等 Mac。
- **未运行**：写了但没有任何检查。
- **阻塞**：冻结证据说明做不到，附决定条目，不改判据。
- **部分通过**：仅用于部分 E3 这类拆开的项，不要用到 N2/N5 的完整条文上。

Swift 命令一律经 `wsl -d Ubuntu-24.04`（需要时 `-u root`），路径 `/opt/swift/usr/bin/swift`。不用 Windows 上的 `swift.exe`（`NEGATIVE.md`：访问冲突）。

---

## 2. 派活方式

用户把第 8 节的五段口令分别交给 Xiaomi MiMo（五路子代理或五次对话均可）。每路先读本文第 0、1 节和本路单元表，再动手。

每完成一个单元：

1. 按该单元验收栏自验（附命令输出）。
2. 追加 `docs/autorun/STATE.md` 的「当前阶段 / 下一动作」和本轮队列表（**保留** 12 小时与今早 Q0–Q7 的历史表格，不要删证据）。
3. 只向本路线的 `docs/autorun/lane-*-notes.md` 追加新证据。
4. 本地提交一次，说明写清单元编号，不推送。
5. `docs/autorun/gates.log` 由 `tools/gates.py` 追加，不要手改旧记录。有新决定或「试过不行」才追加 `DECISIONS.md` / `NEGATIVE.md`，且必须可回退。

路线之间的文件边界：

| 谁写 | 写什么 |
|---|---|
| A | `docs/findings/` 下本轮夹具审计文档；不改 `_golden/` 夹具数值和金图，不造 `icons.json` |
| B | `docs/` 下 Mac 解析器 / ClashtvOS 检查单（新文件或补充已有 `docs/decisions/W-parser-harness.md` 的「Mac 重做」节）；不改 `project.yml`，不完整编译 |
| C | `scripts/mac/*`、`docs/superpowers/plans/2026-11-11-mac-stage.md`、SP-04 到 SP-09 的过时段落、G2/通话的文档加深（不改 Clash-Client 工程） |
| D | M7 检查单和规则对照表（文档）；不改已收录规则，不加 anti-AD / ACL4SSR |
| E | `OneUI/Sources/OneUICore/` 与测试（仅 layout 缺口）、`experiments/G3/` 的夹具遍历测试；不改 14 个界面文件，不改 `Package.swift` 的 Linux/macOS 分支策略，不选定四项实现 |

两路不要改同一文件。`scripts/mac/40-verify-windows-work.sh` 归线 C；线 B 把要补进脚本的清单写在自己的文档里，由 C 在 MC-1 或 MC-2 折进去（若 C 先做，直接采用 `REPORT.md` 第 3 节已有的未编译文件列表）。

18:00 到点：停止新单元，做第 6 节收尾。

---

## 3. 各路还剩什么（诚实盘点）

这台机器上能验证的产品实现，大部分已经验收或标成阻塞。各路若剩余很少，下面直接写明，并只派真正有用的单元：更深的文档订正、今早审查里发现但还没改的过时内容、不需要 Mac 就能准备的 Mac 检查单与脚本修正。**不要发明凑工。** 不要把只能在 Mac 上编译运行的步骤写成「本机可通过」；那些只能作为脚本或检查单，并标明「未在 Mac 上运行」。

| 线 | 本机产品实现还剩多少 | 本轮真正值得做的 |
|---|---|---|
| A | 几乎没有。场景、金图、五份夹具、覆盖 32/32、总览 270/270、P2 对 `tokens.json` 的 40 点审计都已验收。A4 阻塞 | 把 P2「未收录」的 17 项对到其他已有夹具或写明故意不收；可选再抽一组对四份夹具。不扩场景 |
| B | 几乎没有。B1 已验证；B2 未编译；B3/B4/P3 冻结 | Mac 上重做解析器的检查单；M2 要用的未编译文件与 ClashtvOS 依赖说明。不完整编译，不在 Linux 重试 B3 |
| C | 实现类没有。调研结论已验收，但有几份文档和 Mac 脚本已过时，其中脚本仍会调用 `git submodule update`，这是本轮最值得做的事 | 改脚本与手册；订正 SP-04/SP-05（及必要的 SP-06–09）；加深 G2 步骤（不给结论）；通话六项整理成决策表（不拍板） |
| D | 本机实现已完（D1–D4 已验证） | 只写 M7/T2.8 真机实测检查单，对照已有 C6 推断稿。不改规则 |
| E | 图标码点阻塞；14 个界面文件和 P6 实现要等 Mac。`layout.json` 的 `dock.slideMs` 等尚未被 OneUICore 遍历；G3 草稿只有 `swiftc -parse` | 按 E2 写法补 layout 缺口（不重算场景矩形）；给 G3 草稿加夹具遍历测试，仍不选定实现 |

---

## 4. 各路待派单元

编号用 `MA`/`MB`/`MC`/`MD`/`ME`/`MP`，避免与已验收的 A1–A11、B1–B4、C1–C6、D1–D4、E1–E3、P1–P8、Q0–Q7 混淆。预估是单路连续做的粗算，不是承诺。

### 4.A 线 A：基准与夹具

已验证：A1–A3、A5–A11、P1、P2、今早 Q1。A4 保持阻塞。

| 编号 | 目标 | 验收 | 依赖 | 预估 |
|---|---|---|---|---|
| MA-1 | **夹具交叉补全盘点。** P2 从 Dart 盲读 40 个数，只对 `tokens.json`：23 个一致，17 个「未收录」，没有同一键对不上。主代理已注明第 33 条 `480` 实际在 `layout.json` 的 `dock.slideMs`。写一份新的 `docs/findings/fixture-completeness.md`（不要改写 P2 原文 `fixture-cross-audit.md` 的历史表，可在文末或新文件引用）：对那 17 项逐条标明——已在哪份已有夹具的哪个键、或故意不收及原因（例如 `liquidDockFill` 不进五种填充，已有说明）。可顺带扫一眼 `typography.json`、`dock_edges.json`、`ripple.json`、`layout.json` 是否还有明显的「源码有、夹具无、且应收录」的缺口，只记录，不擅自改夹具 | 17 项每条有归宿或「故意不收」+ 出处（文件和行号）。不改夹具数值，不造 `icons.json`，不扩场景，不改金图。若发现应收录的缺口，记在文档和 `STATE.md`，等决定再改夹具 | 不依赖其他新单元 | 40–70 分钟 |
| MA-2 | **（有余力再做）** 用与 P2 相同方法，从 Dart 再盲抽一组**不与 P2 那 40 个重复**的数值（建议 20–40 个），对照四份已有夹具（`tokens` / `typography` / `dock_edges` / `ripple`，以及 `layout` 的 `dock` 段），结果写入同一份或相邻 findings。不要为凑一致而改夹具 | 抽到的每一项：一致、在另一份夹具、或未收录且有说明。没有「同一键数值不同」却不写原因的情况 | MA-1 更好先完成，以免两份结论打架 | 40–60 分钟 |

线 A 不要做：新场景、重跑两遍 271 项（除非第 6 节收尾条件触发）、任何形式的 `icons.json`、削弱 N5。

### 4.B 线 B：Clash

已验证：B1。B2 未编译。B3 不可行，B4 不做，P3 阻塞。本机几乎没有可再验收的产品代码。

| 编号 | 目标 | 验收 | 依赖 | 预估 |
|---|---|---|---|---|
| MB-1 | **Mac 上重做解析器的检查单**（B3 在 Mac 用原工程，不在 Linux 重试）。在 `docs/decisions/W-parser-harness.md` 增一节「Mac 重做」，或新写 `docs/findings/mac-parser-rehearsal.md`。写清：用 Clash-Client 原工程而不是 `_harness/ModuleParser` 的理由（`#if os(iOS) \|\| os(macOS)`）；建议命令与工作目录；成功/失败时记什么；成功后才能考虑 B4（实测忽略清单）和 P3 缺口（Loon `script(...)`、QX `[Argument]`），本轮仍不实现这些。第一行：「未在 Mac 上运行」 | 文档可复查；引用的源文件和行号存在；没有在 WSL 里再跑 `swift build --package-path _harness/ModuleParser`；没有改产品解析器，没有改 `project.yml` | 无 | 40–60 分钟 |
| MB-2 | **M2 / B2 验收预备。** 根据 `REPORT.md` 第 3 节和线 B 备忘，写 `docs/findings/mac-b2-verify.md`（或同等路径）：B2 未编译文件清单（`ConfigTransforms.swift`、`ProfileActivationCoordinator.swift`、`VPNController.swift` 含 `Sources/Mac/`、`TunnelSettingsView.swift`、三种语言的 `Localizable.strings`，提交 `1358825`）；已知 `ConfigTransforms.swift` 若 `import ClashClientUI`，未依赖该包的 ClashtvOS 在 Mac 上会编不过（已决定不改 `project.yml`，Mac 阶段要给 ClashtvOS 补依赖或把合并改成不依赖该模块——只记录选项，不改工程）；建议的 `swiftc -parse` / `xcodebuild` 命令。可选：在 WSL 对已有 B2 Swift 文件再跑一次 `swiftc -parse`（只是语法，不是完整编译），把退出码记入文档。第一行：「未在 Mac 上运行」（若只做了 parse，写明 parse 已在 WSL 跑过、完整编译未做） | 清单与仓库路径一致；不完整编译 B2；不改 `project.yml`。把「请折进 `40-verify-windows-work.sh`」的要点写清楚，交给线 C，两路不要同时改那个脚本 | 无 | 30–50 分钟 |

线 B 不要做：完整编译、Linux 上重试 B3、开始 B4 或 P3 实现、改 ClashtvOS。

### 4.C 线 C：调研与 Mac 预备（本轮最满的一路）

已验证：C1–C6、P5、P7/P8 草稿。G2 结论和通话六项未决定。下面几项是真实剩余，不是重复调研。

| 编号 | 目标 | 验收 | 依赖 | 预估 |
|---|---|---|---|---|
| MC-1 | **订正 Mac 脚本里过时的子模块步骤（优先）。** `scripts/mac/30-swipt.sh` 仍执行 `git submodule update --init`，并写「撰写时该目录为空」；`35-feather.sh` 仍执行 `git submodule update --init --recursive`，并写 Zsign / IDeviceKitten「是空目录」。这两个目录已用 zipball 就位（247/25/6），**没有 `.git`**，在 Mac 上跑 submodule update 会失败或破坏树。`10-env.sh` 注释仍写「IDeviceKit 子模块还没拉下来」。改法：检测已有文件（对照 `docs/findings/submodules.md` 与 `.mimocode/r0-6-submodules-ready.txt`），文件在就跳过拉取并打印现状；文件不在就打印说明并失败，**仍然不跑** `git submodule update`。同步改 `docs/superpowers/plans/2026-11-11-mac-stage.md` 的 M4（以及脚本头注释）。每个脚本开头保持「未在 Mac 上运行」。改完用 `"C:\Program Files\Git\bin\bash.exe" -n`（或等价）对五个脚本再做语法检查 | `bash -n` 退出码 0；全文不再调用 `git submodule update`；手册不再把 zipball 树写成「未初始化」；没有补 `.git`，没有在本机执行这些脚本的其余步骤（`make`、`bun`、bootstrap 等） | 无。先做这一项 | 40–70 分钟 |
| MC-2 | **订正过时的子计划，并扩充 `40-verify-windows-work.sh` 的说明。** SP-04、SP-05 仍写没有 `TypeScale.swift`、`DockEdges.swift`、`InkRippleModel.swift`、没有字号/底栏测试——这在 Q3（`f28e45c`）之后已不成立。按仓库现状改「已核对 / 未做」：部分 E3 已验证（7 项测试，图标仍阻塞）；14 个界面文件仍未改；4.2–4.9 界面层、xcodebuild、G4 仍未做、仍标「未在 Mac 上运行」。SP-06–09、`mac-stage.md` 的 M2 若有同类过时句（子模块空目录、OneUI 测试数仍是 4、未提及 SigningLogic 13 项和部分 E3 的 7 项）一并订正。把 MB-2 或 `REPORT.md` 第 3 节的未编译清单、ClashtvOS 注意事项、`swift test --package-path SigningLogic` 写进 `40-verify-windows-work.sh` 的注释或回显（脚本在 Mac 上仍标未运行；本机不要为了「试跑」去调 xcodebuild） | 打开 SP-04/SP-05 不再会误导人重做 Q3；「未做」的界面层没有被勾成完成；脚本 `bash -n` 仍过；没有声称在 Mac 上跑过 | 最好在 MC-1 之后，以免手册和脚本又不一致 | 50–80 分钟 |
| MC-3 | **加深 G2 的 Mac 步骤，不给结论。** 在 `docs/drafts/g2-go-runtimes.md` 或相邻文件补充：在 Mac 上按总计划 T2.6 要执行的步骤、观察什么、怎样写入 `docs/decisions/G2-go-runtimes.md`。沿用草稿已核对的事实（`Swipt/Frameworks` 不存在、没有 `LibSwipt.xcframework`、`project.yml` 里 Clash `type: framework` 与 embed 行号、探测函数 `NewLoopbackProbe` 在 `device.go:77`）。第一行保持「未在 Mac 上运行」。**不改** Clash-Client 工程，不把草稿 target 写进 `project.yml`，不声称共存或冲突 | 步骤可在 Mac 上按文档执行；没有工程改动；没有 G2 结论句 | 无 | 40–60 分钟 |
| MC-4 | **（有余力）通话六项决策表，不拍板。** 规格在 `docs/superpowers/plans/2026-11-11-onetools-p9-calls-design.md`：Calls 9 个文件、3038 行；四个点名文件在 Runner 下。六项（号码网关、SIP 还是自有协议、后端放哪、配对入口、Push 权限、代码归属）都是「未决定」。整理成给用户看的选项和后果表，仍全部标「未决定」。可选：顺手把 `HANDOFF.md` 里 Skia「凭记忆、没核实」那句改成指向 `_ref/NOTES.md` 已有的「一致」结论（SP-04 已指出过时；只改这一处表述，不改字体规格） | 六项仍未决定；没有实现代码；若改 HANDOFF，只纠正已核实的那一句并引用 NOTES 行号 | 无 | 30–50 分钟 |

线 C 不要做：声称 G2/G3 结论、勾选通话六项、改 `project.yml`、跑 `git submodule update`、把 14 个界面文件当已重写。

### 4.D 线 D：规则

已验证：D1–D4。本机规则实现没有剩余。不要重做插件，不要把 anti-AD 或 ACL4SSR 加为第二来源。

| 编号 | 目标 | 验收 | 依赖 | 预估 |
|---|---|---|---|---|
| MD-1 | **M7 / T2.8 检查单。** 写 `docs/findings/mac-m7-loon-checklist.md`（或同等路径）：在 Mac 上如何对照 C6 的 `docs/findings/loon-ignored-predicted.md`，用原工程解析器跑出真实忽略清单并写入 `docs/findings/loon-ignored.md`（该文件目前不存在，B4 未做）。列出样本路径、预期对照方式、与推断稿不一致时怎么记。第一行：「未在 Mac 上运行」「推断稿不能当成实测」。不调用解析器（本机不可行），不改 `adblock/` 规则和样本 | 检查单引用的样本和 C6 行号存在；没有新的规则文件；没有把推断写成已实测 | 最好等 MB-1 的「必须先在 Mac 上编过解析器」一句能对上，也可以先写、互相引用 | 30–50 分钟 |
| MD-2 | **（有余力）** 把 13 个未收 SDK 的原因、8 个已覆盖 SDK、两来源原则，整理成一张便于 Mac 对照的简表（可附在 MD-1 或 `ad-sdk-domains.md` 末，不要改收录结论） | 与已验收的 `ad-sdk-domains.md`、覆盖检查 21 行一致；不新增来源 | MD-1 | 20–30 分钟 |

### 4.E 线 E：OneUI

已验证：E1、E2、P4；部分 E3（字号、底栏、水波纹）已验证；图标码点阻塞；P6 草稿语法通过、实现未选定。不要重做 TypeScale / DockEdges / InkRippleModel。

| 编号 | 目标 | 验收 | 依赖 | 预估 |
|---|---|---|---|---|
| ME-1 | **`layout.json` 数值层缺口。** `Glass` / `OneTokens` 已有 `dockHeight` 56 等与 `layout.json` 的 `dock` 段重叠的量；`dock.slideMs`（480）在 P2 审计里记为「tokens 未收录」，Swift 目录尚未遍历 `layout.json`。按 E2 写法：对 `layout.json` 的 `dock` 段每一个键做夹具遍历测试；已在 `Glass` 里的键做交叉断言（两边必须相同）；`slideMs` 补常量（名称自定，放在 OneUICore，只依赖 Foundation）。`scenes.*` 下的矩形是 Flutter 实测，**不要在 Linux 上重算或改成自己的公式**，可选只读记录或只读断言「夹具里有这些数」，不声称界面已对拍。测试期望从夹具读；往 `dock` 临时加 `__probe` 必须失败，然后撤掉 | `wsl … swift test --package-path /mnt/e/GQ/Ultra/Onetools-IoS/OneUI` 退出码 0，原有 7 项仍过，新测试纳入计数；假键探测失败后夹具哈希恢复。在备忘和 STATE 写明这是 layout 缺口，**仍不算 E3 全部通过**（图标仍阻塞）。不改 14 个界面文件，不改 `Package.swift` 分支策略 | 无。不要和线 A 同时改夹具——本单元不应改夹具，只读 | 50–80 分钟 |
| ME-2 | **G3 草稿的夹具遍历测试，不选定实现。** `experiments/G3/` 现有四个 `*Numbers.swift` 只过了 `swiftc -parse`。补上可在 WSL 跑的 `swift test`：期望值从已有夹具读取（模糊常数已与夹具一致：`blurPanel` 18、`blurBar` 24、`blurDock` 12、`blurLiquid` 10）。第一行和 `NOTES.md` 仍写「未在 Mac 上运行」；文字、模糊、投影、水波纹触摸**仍不选定**；不要把草稿提升成 `Sources/OneUI/` 的界面实现，不要引入 UIKit 私有 API | `swift test`（该实验包）退出码 0；`NOTES.md` 没有「已选定」句；OneUI 界面目录未改 | 无 | 40–70 分钟 |

线 E 不要做：`MaterialIconCodepoints.swift` / `gen_icon_codepoints.py` / `icons.json`；选定 P6 四项；重写 14 个界面文件；声称 G3 通过。

---

## 5. 打磨队列

必达的新单元完成或阻塞之后，按顺序：

| 编号 | 做什么 | 哪条线 | 说明 |
|---|---|---|---|
| 先做完上面带编号的优先项 | MC-1 优先于同一路的其他项；ME-1、MA-1、MB-1、MD-1 是各路的首选 | — | 不要跳过 MC-1 去写更长的调研 |
| MA-2、MC-4、MD-2 | 有余力 | 各线 | 可选，不做不算失败 |
| MP-1 | 18:00 收尾，见第 6 节 | 收尾（可指定一路或主会话） | 必做 |

不要做的打磨：扩基准图场景；再做一遍今早五线审查（除非本轮改了大量代码，可追加审查，不要覆盖今早那五份）；为 N5 改 `check_fixtures.py` 的既有「有文件才查」行为——缺图标时输出 `ok` 已在 `REPORT.md` 写明，保持即可。不要发明与冻结决定无关的新功能。

---

## 6. 成功标准与收尾

18:00 到点，或全部待派单元已验证 / 阻塞时，做 **MP-1**：

1. 更新 `docs/autorun/STATE.md`：本轮新单元状态、当前阶段、下一步（Mac 项与图标策略仍等待）、剩余时间或「已到点」。保留历史表。
2. 更新 `docs/autorun/REPORT.md`：在今早报告上追加「MiMo 18:00 这一班」——新完成的单元、提交、未做完的、仍然冻结的阻塞。**不改 N1–N14 的条文。** 第一行结论仍应是阻塞停（`icons.json` 仍缺），除非用户已经另有书面决定（写本文时没有）。
3. **全量门禁是否再跑：** 仅当本轮改了 `_golden/`、夹具、金图、`OneUI` 产品代码、`adblock/`、或门禁清单时，才再跑 `python tools/gates.py`，并在 `_golden` 再跑一次 `flutter test`、比较哈希。只改文档和 Mac 脚本、或只改 `experiments/G3` 测试时，**不必**为收尾再跑两遍 271 项；在报告里写明「未重跑全量，因未改金图/夹具/门禁所覆盖的产品代码」（若 ME-1 改了 OneUICore，则应当跑 OneUI 的 `swift test`，并视情况跑 `gates.py` 里已有的 OneUI 项，不必强求两次完整 `flutter test`）。
4. 禁区没有被打破。阻塞项仍是阻塞。Mac 相关产物第一行是「未在 Mac 上运行」。没有推送，没有 `git submodule update`，没有改系统代理或全局 git。

本班「全部判据通过」不要写——A4/`icons.json` 仍然解除不了。成功标准是：该做的剩余项已验证或诚实标为做到哪；过时文档和危险的 submodule 调用已经订正；收尾报告与磁盘一致。

---

## 7. 状态文件

- 本派活书：`docs/superpowers/plans/2026-11-12-onetools-mimo-dispatch-18.md`。
- 今早计划不要当新队列执行；只在需要时于文首保留指向本文的指针。
- `docs/autorun/STATE.md`：把「当前计划」指到本文，保留 Q0–Q7 与 12 小时表格。每完成一个本班单元就更新「当前阶段 / 下一动作」。
- 线备忘只追加。`gates.log` 不手改旧记录。

---

## 8. 给用户的派活口令（可直接粘进 Xiaomi MiMo）

仓库：`E:\GQ\Ultra\Onetools-IoS`，分支 `main`。先读 `docs/superpowers/plans/2026-11-12-onetools-mimo-dispatch-18.md` 的第 0、1 节和本路口令对应的单元表。截止 2026-11-12 18:00:00 Asia/Shanghai。本地提交可以，一个单元一次，不推送。不改系统代理和全局 git，不跑 `git submodule update`。做到点或做完后更新 STATE，收尾见该计划第 6 节。

### 线 A

你负责线 A（基准与夹具）。不要重做已验收的 A1–A3、A5–A11、P1、P2 和今早的全量门禁、金图。不要写 `icons.json`，不要写成 119 或造假 121，不要弱化 N2/A4/N5，不要扩场景。先做 MA-1：把 P2 那 17 个「未收录」项对到其他已有夹具或写明故意不收，产出 `docs/findings/fixture-completeness.md`，不改夹具。有余力再做 MA-2（另抽一组对四份夹具）。做完追加 `docs/autorun/lane-A-notes.md` 和 `STATE.md`。

### 线 B

你负责线 B（Clash）。不要重做 B1，不要完整编译 B2，不要在 Linux 上重试 B3，B4 和 P3 保持不做。不要改 `project.yml`。先做 MB-1：写 Mac 上用原工程重做解析器的检查单，标「未在 Mac 上运行」。再做 MB-2：B2 未编译文件清单和 ClashtvOS 依赖注意，可选 WSL 上 `swiftc -parse`。不要同时改 `scripts/mac/40-verify-windows-work.sh`（归线 C），把要点写在文档里。做完追加 `lane-B-notes.md` 和 `STATE.md`。

### 线 C

你负责线 C（调研与 Mac 预备）。不要重做 C1–C6 和已核对的 P5/P7/P8，不要声称 G2 结论，不要决定通话六项，不要改 Clash-Client 工程，不要跑 `git submodule update`。SP-04/SP-05 已过时，不要按它们重做部分 E3。**先做 MC-1：** 去掉 `30-swipt.sh`、`35-feather.sh` 里的 `git submodule update`，改为检测 zipball 已就位的文件并指向 `docs/findings/submodules.md`，同步改 `mac-stage.md` 的 M4，五个脚本 `bash -n`。再做 MC-2：订正 SP-04/SP-05（及过时的 SP-06–09、M2），补上部分 E3 已验证、图标仍阻塞；扩充 `40-verify-windows-work.sh` 说明。然后 MC-3：加深 G2 步骤，不给结论。有余力做 MC-4（通话决策表，全部未决定）。做完追加 `lane-C-notes.md` 和 `STATE.md`。

### 线 D

你负责线 D（规则）。D1–D4 已验收，不要改插件和样本，不要把 anti-AD 或 ACL4SSR 加为第二来源。本机实现没有剩余。做 MD-1：写 M7/T2.8 在 Mac 上对照 `loon-ignored-predicted.md` 跑实测清单的检查单，标「未在 Mac 上运行」「推断稿不能当成实测」。有余力做 MD-2（未收/已覆盖简表，不改结论）。做完追加 `lane-D-notes.md` 和 `STATE.md`。

### 线 E

你负责线 E（OneUI）。不要重做 E1、E2、P4 和今早部分 E3（TypeScale、DockEdges、InkRippleModel 已通过 7 项测试）。不要写图标码点或 `icons.json`，不要选定文字/模糊/投影/水波纹实现，不要改 14 个界面文件。先做 ME-1：按 E2 写法给 `layout.json` 的 `dock` 段做夹具遍历（`slideMs` 补常量，已在 Glass 的键交叉断言）；不要重算 `scenes` 矩形。仍不算 E3 全部通过。再做 ME-2：给 `experiments/G3/` 加夹具遍历的 `swift test`，仍不选定实现，标「未在 Mac 上运行」。Swift 走 WSL `/opt/swift`。做完追加 `lane-E-notes.md` 和 `STATE.md`。

