# OneTools iOS：12 小时自动执行计划（无 Mac 段）

> 日期：2026-11-11
> 状态：执行中。发车 2026-11-11 18:00:13 +08:00，截止 2026-11-12 06:00:13 +08:00。R0-1、R0-2 已完成；本回合在此结束，用来实测续跑钩子。续跑到达后从 R0-3 继续。
> 上位文档：同目录的 `2026-11-11-onetools-ios-master-plan.md`（下文叫「总计划」）。本文只管没有 Mac 也能做的部分。要 Mac 的事全部在第 12 节，排在最后。

**目标：** 用 12 小时，把不需要 Mac 的工作做完并在本机验证：OneWIFI 的基准图和数值、OneUI 的数值层、Clash 环回逻辑、去广告规则、几项还没核实的事实、Mac 阶段要用的脚本。

**做法：** 主代理调度，五条并行的子代理工作线干活。每个单元先写检查再实现，主代理自己重跑检查后才提交。每两轮做一次只读审查。全程不向你提问。

---

## 0. 你的五条要求在这里对应什么

| 你的要求 | 怎么落实 | 在哪 |
|---|---|---|
| 五路子代理 | 五条并行工作线：A 基准线、B Clash 线、C 调研线、D 规则线、E OneUI 线。同一时刻最多五个工作子代理 | 5.1、第 7 节 |
| 一遍遍自行操作和打磨，12 小时 | 按轮循环；每个单元交回前自查；三次只读审查；必达项做完后接着做打磨队列；到点停 | 5.2–5.4、第 6 节 |
| 中途不问 | 拿不准的按固定顺序自己定并记录；禁区里的事不做、记下来、换别的做 | 5.5、4.3 |
| 疑问提前问 | 六项已答复；我另外按默认处理的事也列出来，你发车前可以否掉 | 第 2 节 |
| 要 Mac 的放最后 | 这 12 小时里一件都不排，整段列在最后 | 第 12 节 |

---

## 1. 发车

### 1.1 你要做的

1. 打开系统级代理或 TUN。
2. 这 12 小时里保持 Cursor 这个窗口开着，电脑不关机、不注销。电源设置我查过，接电状态下不会睡眠。
3. 在这个对话里说「开始」。
4. 等到对话里出现第一条以「[OneTools 12 小时自动执行·继续]」开头的自动消息再离开，大约要 5 分钟。这条消息是续跑钩子生效的证明。没出现的话，我会停在那里告诉你，那时你还在场。

### 1.2 随时叫停

- 在对话里说「停」。
- 或者新建一个空文件 `C:\Users\Administrator\.cursor\afk\PAUSE`。

### 1.3 你回来时看什么

- `docs/autorun/REPORT.md`：每条验收判据的结果和证据，做完的、卡住的、没做的各有一张表。
- `_golden/index.html`：全部基准图的总览页，浏览器直接打开。
- 顶层仓库和 `Clash-Client` 的 `git log`：每个验收通过的单元一次提交。

---

## 2. 已定的事

### 2.1 你的答复（2026-11-11）

| 问题 | 你的答复 |
|---|---|
| 三路怎么分 | 当时按工作内容分：Flutter 基准图与数值、Swift 逻辑与单测、调研与去广告规则与 Mac 准备。同日已改为五路，分法以 5.1 为准 |
| 本机没法编译的 Swift 写不写 | 先把本机能验证的做完，有剩余时间再写，并标「未编译」 |
| 允许的改动 | 顶层建 git 仓库并本地提交；Clash-Client、Swipt、Feather 建 `onetools` 分支并本地提交；装 Swift for Windows 6.4.2；装续跑钩子；联网下载；启动 WSL 的 Ubuntu 作备用 |
| 代理 | 开始前你开好系统级代理或 TUN |
| `ONEWIFIX/IOS` 的归属 | 全部归你或你有权使用 |
| Loon 样本 | 我来挑 5 到 10 个 |
| Mac | 还没着落 |

### 2.2 我按默认处理的事

发车前你没说不行，就照这样做。

- **子代理的模型**：跟随当前会话的模型。
- **审查用的子代理**：三个审查点各派五个只读子代理，一人看一条线。`deep-reviewer`、`code-verifier`、`final-audit` 分别看线 A、线 B、线 E。线 C 和线 D 用通用子代理。这些技能调不起来时，五路都改用通用子代理，清单不变（11.2）。
- **提交**：用本机 git 的全局身份。每个验收通过的单元一次提交。不推送，不开 PR。
- **计时**：从发车检查通过那一刻起算 12 小时。到点时还没验收的半成品单独提交，标 `wip(未验收)`，不和已验收的提交混在一起。
- **提前做完**：必达项做完就接着做打磨队列（7.P），不提前停。所有单元都做完或都卡住时才提前收尾。
- **Loon 样本怎么挑**：公开仓库里近 30 天有更新、被引用多的去广告插件，覆盖开屏广告、信息流广告、视频贴片三类。挑了哪些、为什么，记在 `adblock/samples/SOURCES.md`。
- **广告域名怎么收**：从严。一个域名至少在两份互相独立的公开规则里出现才收，来源逐条记录。大平台的主域名、共用 CDN 不收。宁可漏，不误杀。
- **WSL**：只有 Windows 版 Swift 装不上或跑不了测试时才启动它，在里面装 Swift 当备用。
- **钩子文件**：结束后留在原处。没有 `ACTIVE` 文件时它什么都不做。想彻底去掉，删 `hooks.json` 和 `hooks\afk-loop.py` 两个文件。
- **总计划里的 D2 到 D8**（最低系统、私有模糊接口、页签等）：这 12 小时用不到，保持默认，Mac 阶段开始前你再定。

---

## 3. 范围

### 3.1 必达项：做完并在本机验证

- **地基**：修掉六个上游仓库的假改动；建顶层仓库；三个要改的上游仓库开 `onetools` 分支；固化 Flutter Material 源码快照。
- **线 A**：`_golden` 包；56 个场景的基准图（深浅各一张，共 112 张）；六个数值夹具；像素对拍工具；`lib/design` 下 32 个 Dart 文件的覆盖对照；总览页。
- **线 B**：Clash 环回合并逻辑的单测（先红后绿）；P3 其余代码（标「未编译」）；解析器测试台试验的结论。Swift 工具链由主代理在第 0 轮装。
- **线 C**：Skia 合成加粗参数；内核锁定版 `4b7d5f5` 的环回实现；Feather 和 Swipt 子模块的内容与编译前置；Mac 阶段的脚本；并入清单。
- **线 D**：广告 SDK 清单；Loon 样本；自有规则插件及其检查工具。
- **线 E**：OneUI 包拆出只依赖 Foundation 的 `OneUICore`，对着线 A 的夹具逐项断言。

### 3.2 打磨项：必达项之后做

能验证的排前面：基准图扩充（更多宽度和状态）、夹具交叉审计、解析器缺口修复（测试台可行时）、自签的纯逻辑、Mac 阶段各子计划。

本机验证不了的排最后，只有前面全部做完或卡住才开始，一律标「未编译」：OneUI 界面层草稿、技术验证用的实验工程、工程合并的配置草稿。

### 3.3 不做

- 任何要 Mac 的事：编译 iOS 代码、装机、真机验证、总计划里 G1 到 G6 的判定。
- 改 Swipt、Feather 的源码。这 12 小时里对它们只建分支、补全历史、拉子模块、读代码。
- 电话短信互通的实现。

---

## 4. 授权与禁区

### 4.1 可以写的地方

| 位置 | 谁写 | 写什么 |
|---|---|---|
| 顶层新目录 `_golden/`、`_ref/`、`_harness/`、`tools/`、`adblock/`、`scripts/`、`docs/` | 第 7 节每个单元写明的那条线 | 新文件 |
| `OneUI/` | 线 E | 拆出 `OneUICore`。现有 14 个 Swift 文件先原样提交一次再动 |
| `Clash-Client/`（`onetools` 分支） | 线 B | 总计划 P3 文件表里的 8 行（含新增的测试文件）。解析器测试台可行时，再加解析器的修复和测试 |
| `adblock/`，以及 `tools/export_ad_sdks.py`、`check_samples.py`、`loon_lint.py`、`check_ad_coverage.py` | 线 D | 见 7.D |
| `scripts/mac/`、`docs/superpowers/plans/2026-11-11-mac-stage.md` | 线 C | 见 7.C |
| `Swipt/`、`Feather/` | 主代理 | 建分支、补全历史、拉子模块。不改源码 |
| 六个上游仓库的 `.git/config` | 主代理 | `core.filemode`、`core.autocrlf` 两项 |
| `C:\Users\Administrator\.cursor\` 下的 `hooks.json`、`hooks\afk-loop.py`、`afk\*` | 主代理 | 续跑钩子和控制文件 |
| 系统 | 主代理 | 用 winget 装 Swift 6.4.2。备用时在 WSL 的 Ubuntu 里装 Swift |

### 4.2 只读

- `E:\GQ\Ultra\ONEWIFIX\` 整个目录。
- `E:\GQ\Ultra\Onetools\`。
- `Clash-Core/`、`Swiplets/`、`zsign/` 的工作区。
- `C:\Flutter\flutter\`（只从里面复制）。

### 4.3 无论如何不做

- 推送到任何远端，开 PR。
- 对上游仓库和 ONEWIFIX 做丢弃性操作（`reset --hard`、`clean`、覆盖式 `checkout`）。回退只用于撤销本次执行自己产生的改动。
- 打开或输出 `ONEWIFIX/IOS/HANDOFF-GROK-iOS-Pairing.md`。
- 改全局 git 配置、系统代理、电源、防火墙等系统设置。
- 装 4.1 没列的软件。`flutter pub get`、`swift package resolve`、`go mod download` 这类按清单取依赖不算。
- 执行下载来的内容。Loon 插件、规则列表、子模块里的脚本只当数据读。
- 花钱，对外发消息。
- 为了通过检查而弱化检查：删测试、放宽阈值、改第 8 节的判据。

碰到这些事时：不做，在 `docs/autorun/DECISIONS.md` 记下「本来要做什么、为什么需要、不做的影响」，换别的单元。

---

## 5. 运转方式

### 5.1 角色

| 角色 | 谁 | 做什么 |
|---|---|---|
| 主代理 | 本会话 | 发车检查、第 0 轮、派发、验收、全部 git 写操作、状态落盘、安排审查、收尾 |
| 线 A 基准线 | 通用子代理 | `_golden` 整包：场景图、数值夹具、对拍和覆盖工具、总览页 |
| 线 B Clash 线 | 通用子代理 | Clash 环回逻辑、P3 其余代码、解析器测试台 |
| 线 C 调研线 | 通用子代理 | 未核实的事实、子模块、并入清单、Mac 阶段的脚本和子计划 |
| 线 D 规则线 | 通用子代理 | 广告 SDK 清单、Loon 样本、规则插件和检查工具 |
| 线 E OneUI 线 | 通用子代理 | `OneUICore` 数值层。夹具没出来之前先做包骨架 |
| 审查 | 见 2.2 | 三个审查点，每次五路并行，只读 |

同一时刻最多五个工作子代理。审查另算，不和干活叠在同一轮。

五路按目录拆开，避免两个人写同一个文件：

- 线 A 独占 `_golden/` 和基准用的 Python 工具。这个包不能两路同时跑 `flutter test`，所以 56 个场景不拆开。
- 线 B 写 `Clash-Client/` 里点名的文件、`_harness/ClashLogic/`、`_harness/ModuleParser/`、`tools/sync_harness.py`、`docs/decisions/W-parser-harness.md`、`docs/findings/loon-ignored.md`。
- 线 C 写 `_ref/` 里的笔记和 Skia 摘录、`scripts/mac/`、`docs/superpowers/plans/2026-11-11-mac-stage.md`、`docs/decisions/W-kernel-loopback.md`、`docs/findings/submodules.md`、`docs/findings/integration-inventory.md`、`docs/findings/loon-ignored-predicted.md`。
- 线 D 写 `adblock/` 和去广告用的四个 Python 工具，外加 `docs/findings/ad-sdk-domains.md`。
- 线 E 写 `OneUI/` 和 `tools/gen_icon_codepoints.py`。打磨阶段的 `SigningLogic/`、`experiments/G3/` 也归它。和线 B 的 `swift test` 包路径不同，可以同时跑。

规则：

- 五条线在同一条消息里一起派发，并行跑。某一线本轮没有可做的单元，这一轮不派它。主代理等实际派出去的几路都交回再验收。
- 队首单元还在等别的线的产物时，跳过它，做后面第一个现在就能做的。被跳过的留在队列里。
- 子代理不再开子代理，不做任何 git 写操作，不装软件。
- 每条线只写自己名下的文件。第 7 节每个单元都写了产出文件，这就是归属。
- 一条线的队列空了，可以接别的线里互不冲突的单元，文件归属跟着单元走。

跨线等待：

- E2、E3 等线 A 的 A3、A4 验收通过。E1 不等。
- B4 等 B3 的结论是可行，并且线 D 的 D2 已验收。
- C1、C2、C3 等第 0 轮对应的下载完成。没下完就先做 C4、C5。
- D4 等 D1、D2、D3。
- C6 只在 B3 不可行时做。

### 5.2 一轮怎么走

1. **定位**：读 `docs/autorun/STATE.md`，看钟，算剩余时间。
2. **派发**：五条线各领队列最前面现在就能做的 1 到 2 个单元（线 A 可以到 3 个），限时 60 分钟。没有可做单元的线这一轮不派。任务书用 11.1 的模板。
3. **验收**：主代理对每个交回的单元自己重跑它的验证命令，不采信子代理说的「通过」。同时检查改动的路径没越界，ONEWIFIX 没被动过。
4. **提交**：通过的单元各一次提交。没通过的打回，下一轮排最前。同一个单元连续两轮没过，标「阻塞」，换下一个。
5. **回归**：`python tools/gates.py` 把已启用的验证命令全跑一遍。之前通过、现在失败的，先修它，再推进新单元。
6. **记录**：更新 `STATE.md`，追加 `gates.log`，把本轮的决定和失败教训各记一行。

### 5.3 一个单元怎么做

子代理对每个单元：先写一个现在会失败的检查 → 运行并看到它失败 → 实现 → 运行并通过 → 自查一遍 → 做下一个。

纯调研的单元没有「先失败」这一步，改成：每条结论后面跟着能复查的出处（文件和行号，或网址加抓取日期），主代理抽查。

### 5.4 打磨

三层，从小到大：

- **单元内自查**。交回前重读自己的改动，做三件事：每个数值都能指到 Dart 源文件的行或夹具里的键；把实现故意改错一处，确认测试会失败，再改回；删掉没用到的代码。
- **审查点**。第 2、4、6 轮之后各一次。五个只读审查子代理并行，各看一条线到目前为止的全部产物，不只看最新改动。清单在 11.2。审查发现的问题排到队列最前，修完并重审通过后才推进新单元。
- **打磨队列**。必达项做完后进入 7.P。

### 5.5 拿不准时怎么定

按这个顺序找依据，找到就定：

1. 你的答复、交接文档、总计划里已经定的。
2. 上游工程里已有的同类做法。
3. 官方文档。
4. 最保守、最容易回退的做法。

每个决定在 `docs/autorun/DECISIONS.md` 记一行：选了什么、依据、怎么回退。

不确定某个接口、文件、命令、依赖是否存在时：先在代码或官方文档里查到再用。查不到就不用，不凭印象写。

### 5.6 失败怎么办

- 同一个做法失败两次，必须换做法，并在 `docs/autorun/NEGATIVE.md` 记下「试了什么、为什么不行」，之后不再试同一个做法。
- 一个单元修了 5 次还不过：标「阻塞」，写清卡在哪、试过什么、下一步的猜测，做下一个。
- 检查时过时不过：先找出不确定的来源（时间、顺序、网络、随机数）并消掉，不靠多跑几次碰运气。
- 连续两轮没有新的通过单元：停止派发新内容，先做一次审查找原因。

### 5.7 时间怎么管

- 起点是发车检查通过的时刻。截止时间写进钩子的控制文件和 `STATE.md`。
- 每轮开头看钟。剩余不到 100 分钟：不再开大单元，只做 40 分钟内能验收的。剩余不到 40 分钟：进入收尾（第 9 节）。
- 到点就停。钩子在截止时间过后 30 分钟不再续跑，这是硬上限。
- 钩子最多自动续跑 40 次，防止异常情况下空转。
- 所有单元都做完或都阻塞：提前收尾并停机。

### 5.8 状态都在磁盘上

12 小时里我的上下文会被压缩多次，所以进度不靠记忆。每轮结束都把这些文件更新并提交：

| 文件 | 内容 |
|---|---|
| `docs/autorun/STATE.md` | 起止时间；五条线的队列和每个单元的状态；每条线一句话的现状摘要 |
| `docs/autorun/gates.log` | 每次验收的命令、退出码、关键输出行，带时间 |
| `docs/autorun/DECISIONS.md` | 执行中自己做的决定 |
| `docs/autorun/NEGATIVE.md` | 试过不行的做法 |
| `docs/autorun/reviews/` | 每次审查的结论 |
| `docs/autorun/lane-A-notes.md`、`-B-`、`-C-`、`-D-`、`-E-` | 各线自己的备忘 |

单元状态有五种：待做、进行中、已验证、未编译（写了但本机验证不了）、阻塞。

---

## 6. 时间表

这是目标节奏，不是硬切。轮次由队列推动，时钟只决定什么时候审查、什么时候收尾。

| 时间 | 内容 |
|---|---|
| 0:00–0:10 | 发车检查（你在场） |
| 0:10–0:50 | 第 0 轮：主代理串行打地基 |
| 0:50–2:10 | 第 1 轮：五条线各打通一个最小闭环 |
| 2:10–3:30 | 第 2 轮 |
| 3:30–4:00 | 审查点 1 |
| 4:00–5:20 | 第 3 轮 |
| 5:20–6:40 | 第 4 轮 |
| 6:40–7:10 | 审查点 2 |
| 7:10–8:30 | 第 5 轮 |
| 8:30–9:50 | 第 6 轮 |
| 9:50–10:30 | 审查点 3（全量） |
| 10:30–11:20 | 第 7 轮：只修审查发现的问题和小的打磨项 |
| 11:20–12:00 | 收尾 |

每轮大约是 60 分钟子代理干活加 25 分钟主代理验收。五路一起交回时验收按这个上限，不往下加新单元。

能不能在 12 小时里做完全部必达项，我没有把握：线 A 的 56 个场景工作量最大，而且这个包不能拆给第二条线同时跑 `flutter test`。做不完时按队列顺序截断，排在后面的单元在报告里标「未做」。另外四路把 Clash、OneUI、调研、规则从这条关键路径上拿开。

---

## 7. 任务队列

### 7.0 第 0 轮（主代理，串行）

| 编号 | 做什么 | 验证 |
|---|---|---|
| R0-1 | 发车检查：代理是否通、有没有别的挂机任务、磁盘空间 | `curl.exe -s -o NUL -m 15 -w "%{http_code}" https://raw.githubusercontent.com/flutter/flutter/master/README.md` 返回的不是 `000`；`Test-Path $env:USERPROFILE\.cursor\afk\ACTIVE` 是 `False`；E 盘剩余大于 20 GB |
| R0-2 | 装续跑钩子并启动计时（第 10 节） | 10.3 的四条离线测试全过；`python afk-loop.py --arm 12` 输出 `armed:` |
| R0-3 | 总计划 T0.1：六个仓库设 `core.filemode false`、`core.autocrlf false` | 六行都是 `: 0` |
| R0-4 | 总计划 T0.2 前四步：顶层 `.gitattributes`、`.gitignore`、`upstreams.lock.json`、`git init`、首次提交「执行前的现状」 | `git log --oneline` 有一条提交；`git status --porcelain` 为空 |
| R0-5 | Clash-Client、Swipt、Feather 各执行 `git switch -c onetools` | 三个仓库 `git branch --show-current` 都是 `onetools` |
| R0-6 | 后台下载，不等它：三个仓库 `git fetch --unshallow`；Feather `git submodule update --init --recursive`；Swipt `git submodule update --init`；内核锁定版取到 `_ref/kernel-4b7d5f5/` | 每项 30 分钟上限。结果记进 `STATE.md`。失败的在后面某一轮低优先级重试一次 |
| R0-7 | 装 Swift 并冒烟 | 新开的终端里 `swift --version` 含 `6.4.2`；`_harness/_smoke` 里 `swift package init --type library` 后 `swift test` 通过 |
| R0-8 | 总计划 T0.3 前两步和 T0.4：Material 源码快照、`_ref/NOTES.md`、`_ref/ow_icons.txt` | 快照的文件数等于 SDK 里那个目录的文件数；`ow_icons.txt` 121 行 |
| R0-9 | 建状态文件和 `tools/gates.py` | `python tools/gates.py` 能跑，输出一张表 |

补充说明：

- **R0-2 之后先结束一次回合**。R0-1、R0-2 做完，我先结束回合，专门用来实测钩子。续跑消息到了，再做 R0-3 及以后的事。1.1 第 4 步说的「大约 5 分钟」就是等这一下。
- **R0-1 代理不通时**。先看系统代理设置里有没有地址，有就只给本次执行的进程设 `HTTPS_PROXY` 环境变量，不改任何全局配置。还不通就按直连跑：单个文件走 GitHub API 取，大的下载排到低优先级，拉不动的记为阻塞。
- **R0-4 的忽略清单**。六个上游目录、`/_ref/kernel-*/`、`/_golden/.dart_tool/`、`/_golden/build/`、各处的 `.build/`、`__pycache__/`、`.pytest_cache/`、`/.xj-cursor/`。`.gitattributes` 除了 `* text=auto eol=lf`，再加 `*.png`、`*.ttf`、`*.otf` 三行 `binary`。
- **R0-6 取内核锁定版的命令**：

```powershell
$k = 'E:\GQ\Ultra\Onetools-IoS\_ref\kernel-4b7d5f5'
git init $k
git -C $k remote add origin https://github.com/ProjectClash/Clash.git
git -C $k fetch --depth 1 origin 4b7d5f53cff448f01cd5012b5e3f7eddc7d43e33
git -C $k checkout FETCH_HEAD
```

- **R0-7 装 Swift 的命令**：`winget install --id Swift.Toolchain -e --source winget --accept-package-agreements --accept-source-agreements`。失败时启动 WSL 的 Ubuntu，按 swift.org 的安装说明在里面装，之后线 B 和线 E 的 `swift` 命令都经 `wsl` 执行。两条路都不行：线 B 的 B1 到 B4、线 E 的 E1 到 E3 标阻塞。这两条线改接线 C 或线 D 里还没做、文件又不重叠的单元，不进 `_golden/`。
- **`tools/gates.py`**。读 `tools/gates.json` 里的验证命令清单（编号、工作目录、命令、是否启用），逐条执行，打印结果表，追加到 `gates.log`，有失败就返回非零。清单只由主代理维护：一个单元验收通过，才把它的命令加进去。

### 7.A 线 A：基准线

代码骨架在总计划 P1 一节，场景清单在 T1.3，夹具在 T1.4。

| 编号 | 做什么 | 产出文件 | 主代理怎么验收 |
|---|---|---|---|
| A1 | `_golden` 包骨架。两个字体复制到 `_golden/fonts/`，哈希与来源一致。第一个场景 `a1_typography` | `_golden/pubspec.yaml`、`test/flutter_test_config.dart`、`test/support/scene.dart`、`test/scenes/a1_typography_test.dart`、`goldens/a1_typography.*.png` | `flutter test --update-goldens` 后连跑两次 `flutter test`，第二次 `All tests passed!` 且 `goldens/` 没有改动；图是 1170×2532；我打开浅色那张看，文字不是方块 |
| A2 | 像素对拍工具，先写测试 | `tools/golden_diff.py`、`tools/test_golden_diff.py` | `python -m pytest tools/test_golden_diff.py -q` 通过：同图差异为 0；改一块 10×10 区域后差异恰好 100 像素；尺寸不同判失败 |
| A3 | 夹具第一批（线 E 等着用）和夹具检查脚本 | `_golden/test/fixtures/export_test.dart`、`_golden/fixtures/tokens.json`、`typography.json`、`tools/check_fixtures.py` | `python tools/check_fixtures.py` 通过；我在 `tokens.json` 里抽 10 个值对照 `glass.dart` 和 `one_palette.dart` |
| A4 | 夹具第二批 | `_golden/fixtures/icons.json`、`dock_edges.json`、`ripple.json` | `icons.json` 恰好 121 项，且「脚本从 `icons.dart` 解析」和「Dart 运行时读 `Icons.x.codePoint`」两种方式结果一致；`check_fixtures.py` 通过 |
| A5 | A 组其余场景 `a2` 到 `a7` | `test/scenes/a*_test.dart`、对应的图 | `flutter test` 连跑两次稳定；我看 `a3_icons` 里没有空格子 |
| A6 | B 组前 8 个组件 | `test/scenes/b_*_test.dart`、对应的图 | 同上；每个场景用的是 OneWIFI 的原组件，不是仿写的（`rg` 查 import） |
| A7 | B 组后 8 个组件和 `status_hero` 的 6 张 | 同上 | 同上 |
| A8 | C 组 17 个主题控件 | `test/scenes/c_*_test.dart`、对应的图 | 同上 |
| A9 | D 组底栏 10 个场景和布局夹具 | `test/scenes/d_*_test.dart`、`_golden/fixtures/layout.json` | 同上；`layout.json` 里底栏的尺寸与 `ultra_glass_dock.dart` 的常量一致 |
| A10 | 设计文件覆盖对照 | `_golden/coverage.json`、`tools/check_golden_coverage.py`、它的测试 | 脚本每次从磁盘重新列出 `lib/design` 下的 Dart 文件，输出 `32/32`。每个文件要么对应到场景或夹具，要么写明排除原因 |
| A11 | 总览页 | `tools/make_contact_sheet.py`、`_golden/index.html` | 页面里的图片数等于 `goldens/` 下的 PNG 数 |

说明：

- `ripple.json` 的内容：用 Flutter 自己的 `Tween` 和 `Curve` 类，按 `_ref` 里 `ink_ripple.dart` 的常量，算出半径和透明度在各个时刻的取样。常量所在的行号写进文件。水波纹长什么样，仍然以 `a6`、`a7` 两组图为准。
- `flutter pub get` 会解析 OneWIFI 的全部依赖，要联网。它不往 OneWIFI 目录里写东西；每轮验收时我用 `git -C E:\GQ\Ultra\ONEWIFIX\IOS status --porcelain` 确认。
- 含 `SystemSwitch`、`SystemSpinner` 的场景要给平台视图通道装空实现（总计划 T1.3）。

### 7.B 线 B：Clash 线

| 编号 | 做什么 | 产出文件 | 主代理怎么验收 |
|---|---|---|---|
| B1 | Clash 环回的纯逻辑，照总计划 T3.1、T3.2 先红后绿。`ClashTunnelRouteShaping.swift` 只依赖 Foundation，所以能在本机测 | Clash-Client 里：`ClashTunnelRouteShaping.swift`、`ClashClientUI/Package.swift`、`Tests/ClashClientUITests/SwiptLoopbackTests.swift`。顶层：`_harness/ClashLogic/Package.swift`、`tools/sync_harness.py` | `python tools/sync_harness.py` 后 `swift test --package-path _harness/ClashLogic`：5 个测试通过。`sync_harness.py --check` 确认测试台里的副本与 Clash-Client 里的源文件逐字节相同 |
| B2 | P3 其余代码，照总计划 T3.3、T3.4 | `ConfigTransforms.swift`、`ProfileActivationCoordinator.swift`、`VPNController.swift`、`TunnelSettingsView.swift`、三个 `Localizable.strings` | 状态记「未编译」。能查的三样：每个改过的文件 `swiftc -parse` 退出码为 0；`rg -n "excludeAPNsRoute:"` 的每个调用点都带了 `swiptLoopback:`；三个语言文件各有两条新键 |
| B3 | 解析器测试台试验，限时 90 分钟 | `_harness/ModuleParser/`、`docs/decisions/W-parser-harness.md` | 结论文档写明可行或不可行，附编译器的真实输出 |
| B4 | B3 可行、且线 D 的 D2 已验收时：拿样本跑出真实的忽略清单 | `docs/findings/loon-ignored.md` | 清单由测试台程序生成，命令可重跑，两次输出一致 |

说明：

- **B1 的测试台**。SwiftPM 不能引用包目录以外的源文件，所以用脚本把那一个源文件和测试文件复制进 `_harness/ClashLogic/`，副本不进 git。测试台里的模块也叫 `ClashClientUI`，同一份测试文件在 Windows 和 Mac 上都不用改。
- **B3 为什么限时**。五个语法文件里三个只依赖 Foundation，`ModuleIR.swift` 依赖 CryptoKit，`ModuleParser.swift` 依赖 Darwin 和 os，再往下的依赖链有多长我还没查。允许在测试台里写替身模块，不允许为了编过而改上游源码。不可行就记下卡在哪个依赖，B4 标「未做」，线 C 改做 C6。

### 7.C 线 C：调研线

| 编号 | 做什么 | 产出文件 | 主代理怎么验收 |
|---|---|---|---|
| C1 | Skia 合成加粗参数（总计划 T0.3 后两步） | `_ref/skia/` 下三个源文件、`_ref/NOTES.md` | `NOTES.md` 里有一行以「结论：」开头，写明与交接文档 §3.3.2 一致或不一致；引用的行号我去源文件里核对 |
| C2 | 内核锁定版的环回实现 | `docs/decisions/W-kernel-loopback.md` | 文档回答三件事：`4b7d5f5` 里有没有 `loopback-address` 选项；是怎么实现的；和 `Clash-Core/` 里的最新版差在哪。引用的文件和行号我在 `_ref/kernel-4b7d5f5/` 里核对 |
| C3 | 子模块的内容和编译前置 | `docs/findings/submodules.md` | 写明 Zsign、IDeviceKit、DeveloperDiskImage 各是什么、多大、要不要现编、什么许可。引用的路径存在 |
| C4 | Mac 阶段的脚本和操作手册 | `scripts/mac/*.sh`、`docs/superpowers/plans/2026-11-11-mac-stage.md` | 每个脚本过 `"C:\Program Files\Git\bin\bash.exe" -n`。文档和脚本开头都标「未在 Mac 上运行」 |
| C5 | 并入清单：三个工程合并时会撞的地方 | `docs/findings/integration-inventory.md` | 列出 `Bundle.main` 的用法及分类、Info.plist 键、Entitlements、URL scheme 和文档类型、同名类型、同一个第三方包的不同版本。每项附可重跑的 `rg` 命令，我抽三条重跑，数量对得上 |
| C6 | 只在 B3 不可行时做：读解析器源码，推断样本里哪些条目会被忽略 | `docs/findings/loon-ignored-predicted.md` | 文档开头标「推断，未经解析器实测」。每条推断指到解析器的源码行。样本用线 D 的 D2 |

说明：

- C1、C2、C3 依赖 R0-6 的下载。没下完就先做 C4、C5。
- C4 的脚本覆盖总计划 T2.1 到 T2.5，再加一个 `40-verify-windows-work.sh`：在 Mac 上把这 12 小时里标「未编译」的东西全编一遍、把 Swift 单测全跑一遍。

### 7.D 线 D：规则线

| 编号 | 做什么 | 产出文件 | 主代理怎么验收 |
|---|---|---|---|
| D1 | 广告 SDK 清单导出，先写测试 | `tools/export_ad_sdks.py`、它的测试、`adblock/sdk-list.json` | `pytest` 通过；清单的条目数等于 `rules.ts` 里 `sdk` 对象的键数（脚本每次重新数） |
| D2 | Loon 样本 5 到 10 个 | `adblock/samples/`、`SOURCES.md`、`tools/check_samples.py` | 每个样本记了网址、抓取日期、SHA-256、许可；`check_samples.py` 核对哈希通过 |
| D3 | 插件检查工具，先写测试 | `tools/loon_lint.py`、它的测试 | `pytest` 通过。它接受的每种写法都注明 Clash-Client 解析器里对应的源码行 |
| D4 | 自有规则插件 | `adblock/onetools-cn-ads.plugin`、`docs/findings/ad-sdk-domains.md`、`tools/check_ad_coverage.py` | `loon_lint.py` 通过；`check_ad_coverage.py` 通过：清单里每个 SDK 要么有规则，要么写了没有的原因；每条规则记了至少两个来源 |

说明：

- D1、D2、D3 互不等待，按这个顺序做。D4 等这三件都验收通过。
- D4 的收录规则见 2.2。来源指 D2 的样本和最多三份公开的广告域名列表，列表的网址、抓取日期、哈希同样记进 `SOURCES.md`。

### 7.E 线 E：OneUI 线

| 编号 | 做什么 | 产出文件 | 主代理怎么验收 |
|---|---|---|---|
| E1 | OneUI 包拆分骨架 | `OneUI/Package.swift`、`Sources/OneUICore/`、`Tests/OneUICoreTests/` | `swift test --package-path OneUI` 能跑起来。`Resources/Icons` 已声明进资源 |
| E2 | 数值层：色板、设计常量、玻璃参数。测试遍历 `tokens.json` 的每一个键。等 A3 验收通过 | `Sources/OneUICore/Tokens/OnePalette.swift`、`OneTokens.swift`、`Glass.swift`、对应测试 | `swift test --package-path OneUI` 全过。我往 `tokens.json` 临时加一个假键，测试必须失败，然后撤掉 |
| E3 | 数值层：字号表、底栏插值、水波纹曲线、图标码点。等 A3、A4 验收通过 | `Tokens/TypeScale.swift`、`Motion/DockEdges.swift`、`Motion/InkRippleModel.swift`、`Icons/MaterialIconCodepoints.swift`、`tools/gen_icon_codepoints.py`、对应测试 | 同上；码点表 121 项，重新生成后文件无变化 |

说明：

- **E1 的包结构**。沿用总计划 P4 的布局。`Package.swift` 里用宿主系统判断：不是 macOS 时只声明 `OneUICore` 和它的测试，SwiftUI 的 target 不参与。现有 14 个界面文件这一步不动，它们本来就编不过，留到界面层重写时处理。
- E1 不读夹具，第 1 轮就可以做。E2、E3 在夹具验收之前跳过。

### 7.P 打磨队列

必达项全部「已验证」或「阻塞」之后，按顺序做。

本机能验证的：

| 编号 | 做什么 | 哪条线 | 验收 |
|---|---|---|---|
| P1 | 基准图扩充：B、D 两组在宽 320 和 430 下各出一套；按钮和输入框补按下、禁用、聚焦三种状态 | A | `flutter test` 连跑两次稳定；总览页更新 |
| P2 | 夹具交叉审计：一个新的只读子代理不看夹具，从 Dart 源码里独立读出 40 个随机抽的数值，再和 `tokens.json` 比 | 审查 | 40 个全部一致，或者不一致的每一项都查明是谁错并修掉 |
| P3 | 解析器缺口修复，B3 可行时做：Loon 的 `script(...)` 新写法、QX 的 `[Argument]`。每项从样本里截一段做夹具，先写失败的测试 | B | 测试台里测试通过；修改在 Clash-Client 的 `onetools` 分支上 |
| P4 | 自签的纯逻辑：到期提醒的日期计算（提前 7 天和 1 天、已过期的不发）、批量处理时单个失败不影响其余 | E | 新包 `SigningLogic/`，只依赖 Foundation，`swift test` 通过 |
| P5 | 总计划第 11 节的子计划 SP-04 到 SP-09，把这 12 小时查到的事实写进去 | C | 文档里引用的文件、行号、命令都存在 |

本机验证不了的，前面五项全部做完或阻塞之后才开始，一律标「未编译」：

| 编号 | 做什么 | 哪条线 | 能做的检查 |
|---|---|---|---|
| P6 | OneUI 界面层草稿，按总计划 P4 的 4.2 到 4.8 的顺序。文字、模糊、投影、水波纹触摸这四样的实现方式要等 Mac 上的实验，所以只写成实验工程 `experiments/G3/`，不选定方案 | E | 每个文件 `swiftc -parse` 通过；每个数值注明来自哪个夹具键或 Dart 行 |
| P7 | 双 Go 运行时实验的工程配置草稿 | C | 放在 `docs/drafts/`，不进 Clash-Client 的分支 |
| P8 | 通话的规格草稿（总计划 SP-10） | C | 只是文档 |

---

## 8. 验收判据

发车时冻结，执行中不改。做不到的在报告里标「未完成」或「阻塞」，不改判据。

| # | 判据 | 怎么查 |
|---|---|---|
| N1 | 六个上游仓库没有假改动；顶层仓库存在；`upstreams.lock.json` 的六项等于各仓库 `onetools` 分支的起点（没开分支的等于 HEAD） | `git status --porcelain`、`git merge-base` |
| N2 | Material 源码快照完整；`ow_icons.txt` 121 行 | 文件数对比；行数 |
| N3 | 基准图确定且齐全：`flutter test` 连续两次通过，第二次后 `goldens/` 无改动；总计划 T1.3 的 56 个场景每个都有深浅两张 | `flutter test`；数文件 |
| N4 | `lib/design` 下的每个 Dart 文件都有对应的场景、夹具或排除原因 | `python tools/check_golden_coverage.py` 输出 `32/32`，分母每次从磁盘重数 |
| N5 | 六个夹具文件齐全且自洽 | `python tools/check_fixtures.py` |
| N6 | Python 工具的测试全过 | `python -m pytest tools -q` |
| N7 | `OneUICore` 的测试全过，且夹具里的每个键都有 Swift 一侧的对应 | `swift test --package-path OneUI` |
| N8 | Clash 环回的纯逻辑 5 个测试通过；P3 其余代码已写并通过语法检查 | `swift test --package-path _harness/ClashLogic`；`swiftc -parse` |
| N9 | 三项未核实的事实有结论，引用可复查：Skia 参数、内核锁定版的环回、子模块 | 三份文档；主代理抽查引用 |
| N10 | 解析器测试台有结论，可行或不可行都算，附证据 | `docs/decisions/W-parser-harness.md` |
| N11 | 自有规则插件通过检查；每个 SDK 有规则或有原因；每条规则有两个以上来源 | `loon_lint.py`、`check_ad_coverage.py` |
| N12 | Mac 阶段的脚本语法通过；并入清单可复查 | `bash -n`；重跑 `rg` |
| N13 | ONEWIFIX 没被改动 | `git -C E:\GQ\Ultra\ONEWIFIX\IOS status --porcelain` 为空，HEAD 仍是 `7a8839e` |
| N14 | 报告里每条判据都附了收尾那一轮的命令输出 | `docs/autorun/REPORT.md` |

报告里每项结果只用这三种说法之一：

- **已验证**：本机跑过，附输出。
- **语法通过，未编译**：只过了 `swiftc -parse`，要等 Mac。
- **未运行**：写了但没有任何检查，比如 Mac 脚本的实际效果。

---

## 9. 收尾与交付

剩余不到 40 分钟，或所有单元都做完或阻塞时：

1. 不再派发。
2. `python tools/gates.py` 从头全跑一遍，包括 `flutter test` 两次、两处 `swift test`、`pytest`。输出写进报告。
3. 提交。已验收的早已提交。半成品单独提交，标 `wip(未验收)`。
4. 写 `docs/autorun/REPORT.md`：
   - 第一行写明这次是「全部判据通过」「到点停」还是「阻塞停」。
   - 第 8 节每条判据的状态和证据。
   - 全部单元的状态表。
   - 标「未编译」和「未运行」的文件清单。
   - 执行中做的决定。
   - 发现的问题，以及对总计划的修正建议。
   - Mac 阶段开始前需要你做的事。
5. 写控制文件。全部判据通过：写 `DONE`，删 `ACTIVE`。否则写 `PAUSE`。
6. 最后一条回复是报告的摘要。

---

## 10. 续跑钩子

### 10.1 它是什么

Cursor 在我每个回合结束时调用一个脚本。脚本输出一句话，Cursor 就把这句话当作你发的下一条消息，我接着干。没有它，我的回合一结束执行就停。

这台机器现在没有 `hooks.json`，下面两个文件都是新建。

有一点我在发车前验证不了：Cursor 在这台 Windows 上是否按下面的写法调用脚本。发车后第一个回合结束就是实测，所以 1.1 请你等到第一条自动消息出现再离开。没出现时的处理：先重启 Cursor 让它重新加载钩子再试一次；还不行，我就在一个回合里连续做、不结束回合，但这样大概率撑不满 12 小时，由你当场决定。

### 10.2 文件

`C:\Users\Administrator\.cursor\hooks.json`：

```json
{
  "version": 1,
  "hooks": {
    "stop": [
      {
        "command": "python C:/Users/Administrator/.cursor/hooks/afk-loop.py",
        "loop_limit": 50,
        "failClosed": false
      }
    ]
  }
}
```

`C:\Users\Administrator\.cursor\hooks\afk-loop.py`：

```python
"""OneTools 12 小时自动执行的续跑钩子（Cursor 的 stop 事件）。

Cursor 在每个回合结束时把一段 JSON 从标准输入传进来。
输出 {} 表示放行停机；输出 {"followup_message": "..."} 表示把这句话当作下一条用户消息。

  python afk-loop.py              由 Cursor 调用
  python afk-loop.py --arm 12     发车：写入循环上限、截止时间和空的 ACTIVE
"""
import json
import os
import sys
import time
from pathlib import Path

AFK = Path(os.environ.get("ONETOOLS_AFK_DIR") or Path.home() / ".cursor" / "afk")
ACTIVE, PAUSE, DONE = AFK / "ACTIVE", AFK / "PAUSE", AFK / "DONE"
MAX_LOOPS, DEADLINE, ERROR_RETRY = AFK / "MAX_LOOPS", AFK / "DEADLINE", AFK / "ERROR_RETRY"

LOOP_CAP = 40            # 最多自动续跑的次数
WRAPUP_WINDOW = 40 * 60  # 剩余时间少于它就进入收尾
GRACE = 30 * 60          # 截止时间过了这么久就不再续跑

PLAN = r"E:\GQ\Ultra\Onetools-IoS\docs\superpowers\plans\2026-11-11-onetools-12h-autorun.md"
STATE = r"E:\GQ\Ultra\Onetools-IoS\docs\autorun\STATE.md"

CONTINUE = (
    "[OneTools 12 小时自动执行·继续] 先读 {state} 和 {plan} 的第 4、5 节，然后接着做："
    "验收上一轮、提交、派发下一轮五路子代理、更新状态。剩余约 {minutes} 分钟。"
    "不向用户提问；第 4.3 节列的事不做。"
)
WRAPUP = (
    "[OneTools 12 小时自动执行·收尾] 剩余约 {minutes} 分钟，不再派发新单元。"
    "按 {plan} 第 9 节收尾：全部检查从头重跑、提交、写 REPORT.md，写入 DONE 或 PAUSE 后停机。"
)
RESCUE = (
    "[OneTools 12 小时自动执行·出错后自救一次] 上一回合异常结束。先读 {state} 和同目录的 gates.log "
    "找到真实报错，不要原样重试，换一个做法继续。再次异常结束会自动暂停。"
)


def emit(message=None):
    # ensure_ascii：Windows 上管道的默认编码不是 UTF-8，转义成纯 ASCII 才不会乱码。
    payload = {"followup_message": message} if message else {}
    sys.stdout.write(json.dumps(payload, ensure_ascii=True) + "\n")
    sys.exit(0)


def pause():
    try:
        PAUSE.touch()
    except OSError:
        pass
    emit()


def read(path):
    try:
        return path.read_text(encoding="utf-8-sig").strip()
    except OSError:
        return ""


def arm(hours):
    AFK.mkdir(parents=True, exist_ok=True)
    if ACTIVE.exists():
        sys.exit("已有挂机任务处于 ACTIVE，先停掉它。")
    for stale in (PAUSE, DONE, ERROR_RETRY):
        stale.unlink(missing_ok=True)
    MAX_LOOPS.write_text(f"{LOOP_CAP}\n", encoding="utf-8")
    DEADLINE.write_text(f"{int(time.time() + hours * 3600)}\n", encoding="utf-8")
    ACTIVE.write_text("", encoding="utf-8")
    print(f"armed: deadline={read(DEADLINE)} max_loops={read(MAX_LOOPS)}")


def main():
    raw = sys.stdin.buffer.read()
    if PAUSE.exists() or DONE.exists() or not ACTIVE.exists():
        emit()
    max_loops, deadline = read(MAX_LOOPS), read(DEADLINE)
    if not (max_loops.isdigit() and int(max_loops) > 0 and deadline.isdigit()):
        pause()  # 没有循环上限或截止时间就不续跑

    try:
        data = json.loads(raw)
        conversation, status, loop = data["conversation_id"], data["status"], data["loop_count"]
        valid = (
            isinstance(conversation, str) and bool(conversation)
            and status in ("completed", "aborted", "error")
            and isinstance(loop, (int, float)) and not isinstance(loop, bool)
            and loop >= 0 and loop == int(loop)
        )
    except Exception:
        valid = False
    if not valid:
        emit()  # 输入读不懂：这一回合放行，不锁暂停

    owner = read(ACTIVE)
    if not owner:  # 第一次触发时绑定到当前对话，之后别的对话一律放行
        try:
            ACTIVE.write_text(conversation + "\n", encoding="utf-8")
        except OSError:
            pause()
        owner = conversation
    if owner != conversation:
        emit()

    remaining = int(deadline) - int(time.time())
    if int(loop) >= int(max_loops) or status == "aborted" or remaining <= -GRACE:
        pause()

    retrying = read(ERROR_RETRY) == conversation
    if status == "error":
        if retrying:
            pause()  # 连续第二次异常
        try:
            ERROR_RETRY.write_text(conversation + "\n", encoding="utf-8")
        except OSError:
            pause()
        emit(RESCUE.format(state=STATE))
    if retrying:
        ERROR_RETRY.unlink(missing_ok=True)

    template = WRAPUP if remaining <= WRAPUP_WINDOW else CONTINUE
    emit(template.format(state=STATE, plan=PLAN, minutes=max(remaining // 60, 0)))


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--arm":
        arm(float(sys.argv[2]))
    else:
        main()
```

### 10.3 发车前的离线测试

在一个临时目录里测，不碰真的控制文件：

```powershell
$hook = "$env:USERPROFILE\.cursor\hooks\afk-loop.py"
$env:ONETOOLS_AFK_DIR = Join-Path $env:TEMP 'afk-selftest'
Remove-Item -Recurse -Force $env:ONETOOLS_AFK_DIR -ErrorAction SilentlyContinue
$in = '{"conversation_id":"c1","status":"completed","loop_count":0}'

$in | python $hook                         # 1. 没启动：预期输出 {}
python $hook --arm 12                      #    预期输出 armed: ...
$in | python $hook                         # 2. 已启动：预期输出含 followup_message
$in.Replace('c1','c2') | python $hook      # 3. 别的对话：预期输出 {}
python -c "import os,pathlib; pathlib.Path(os.environ['ONETOOLS_AFK_DIR'],'DEADLINE').write_text('1\n')"
$in | python $hook                         # 4. 已过截止时间：预期输出 {}，且目录里出现 PAUSE

Remove-Item -Recurse -Force $env:ONETOOLS_AFK_DIR
Remove-Item Env:ONETOOLS_AFK_DIR
```

四条都符合预期后，执行 `python $hook --arm 12` 启动真的计时。

### 10.4 控制文件

都在 `C:\Users\Administrator\.cursor\afk\`。

| 文件 | 含义 |
|---|---|
| `ACTIVE` | 存在才续跑。第一次触发时写入当前对话的编号，别的对话不受影响 |
| `PAUSE` | 存在就停。你手工建它就是急停 |
| `DONE` | 全部判据通过后由我写入 |
| `DEADLINE` | 截止时间 |
| `MAX_LOOPS` | 续跑次数上限，40 |

---

## 11. 附录

### 11.1 子代理任务书模板

每次派发按这个模板填。子代理看不到这个对话，所以任务书必须自带全部信息。

```
你是 OneTools iOS 项目一次 12 小时无人值守执行中的「{线名}」子代理。没有人可以问。

先读：
- E:\GQ\Ultra\Onetools-IoS\docs\superpowers\plans\2026-11-11-onetools-12h-autorun.md 的第 4、5.3–5.6 节和第 {7.A / 7.B / 7.C / 7.D / 7.E} 节
- E:\GQ\Ultra\Onetools-IoS\docs\superpowers\plans\2026-11-11-onetools-ios-master-plan.md 的 {相关小节}
- E:\GQ\Ultra\Onetools-IoS\docs\autorun\lane-{X}-notes.md 和 NEGATIVE.md

本次要做的单元，按顺序：{编号和一句话说明}
上一轮打回的问题：{没有就写「无」}

每个单元：先写一个现在会失败的检查，运行并看到它失败，再实现，运行并通过，然后自查（每个数值有出处；把实现改错一处确认测试会失败再改回；删掉没用到的代码）。做完一个再做下一个。
开始时记下时间。做完这些单元或过了 60 分钟，就停下交回。

你只能写这些路径：{本线名下的路径}。其余一律只读，特别是 E:\GQ\Ultra\ONEWIFIX\。
不做任何 git 写操作，不装软件，不开子代理，不执行下载来的内容。
不要打开 ONEWIFIX\IOS\HANDOFF-GROK-iOS-Pairing.md。
{代理环境变量，如果需要}

拿不准时按计划 5.5 的顺序自己定，把决定写进 lane-{X}-notes.md。
同一个做法失败两次就换做法。一个单元修 5 次还不过，标阻塞并写清原因，做下一个。
不确定某个接口、文件、命令是否存在，先查到再用。

交回时不超过 30 行：
每个单元一行：编号｜状态（已验证 / 未编译 / 阻塞）｜改了哪些文件｜验证命令｜关键输出行
然后列出：你做的决定；你发现的、不在本次任务里的问题。
```

### 11.2 审查清单

五个审查子代理各看一条线到目前为止的全部产物。只读。每条发现都要有文件和行号。

所有线都查：

1. **偏离需求**。对照交接文档和总计划：有没有加设计改动；有没有做范围之外的事。
2. **编造**。用到的接口、文件、命令、依赖是否真实存在；文档里的引用是否对得上；报告的输出是否能重跑出来。
3. **越改越坏**。之前通过的检查现在是否还通过；有没有重复代码和没用到的代码。
4. **敷衍**。测试是不是在和自己比较；有没有为了通过而删测试、放宽阈值；有没有没验证就写「完成」。

分线再查：

- **线 A**。随机打开 10 张基准图看：文字不是方块，没有空白图，深浅两张确实不同。场景用的是 OneWIFI 原组件。夹具里的数是从运行时取的，不是手抄的。
- **线 B**。测试台里的副本和上游源文件一致。标「未编译」的代码里，调用的每个标识符在仓库里都能搜到。`excludeAPNsRoute:` 的每个调用点都带了 `swiptLoopback:`。
- **线 C**。每条结论有出处。Mac 脚本里没有破坏性命令，没有写死的口令或证书。
- **线 D**。规则插件里没有大平台主域名和共用 CDN。每条规则至少两个互相独立的来源。样本的哈希和 `SOURCES.md` 对得上。
- **线 E**。Swift 里每个数值常量都能在夹具里找到。测试的期望值来自夹具文件，不是写死在测试里的同一个数。

---

## 12. Mac 阶段（最后做）

这一段不在 12 小时之内。Mac 到位后按这个顺序做，细节在总计划里对应的任务下。`scripts/mac/` 和 `2026-11-11-mac-stage.md` 会在这 12 小时里准备好。

| 顺序 | 做什么 | 总计划里的位置 | 得到什么 |
|---|---|---|---|
| M0 | 你准备：Mac；Bundle ID 前缀和 Team ID；朋友账号里的四个 App ID 和描述文件 | T0.5、4.3 的 I2 | 能签名装机 |
| M1 | 装环境 | T2.1 | — |
| M2 | 把 12 小时里标「未编译」的全编一遍，Swift 单测全跑一遍 | `scripts/mac/40-verify-windows-work.sh` | 这 12 小时的产物在 Mac 上是否成立 |
| M3 | Clash-Client 原版编译装机；「Swipt 兼容」开关真机验证 | T2.2、T3.5 | — |
| M4 | Swipt、Feather 原版各跑通一次 | T2.4、T2.5 | 闸门 G1 |
| M5 | 双 Go 运行时实验 | T2.6 | 闸门 G2，决定 Swipt 怎么并入 |
| M6 | OneUI 的五个技术实验 | T2.7 | 闸门 G3，决定界面层怎么写 |
| M7 | Loon 插件真机实测，对照这 12 小时里的清单 | T2.8 | 解析器要补哪些 |
| M8 | OneUI 界面层，逐组件和基准图对拍 | P4 | 闸门 G4a、G4b |
| M9 | 外壳和模块并入；去广告补缺；自签增强；按页换肤；收尾 | P5 到 P8、P10 | 闸门 G5、G6 |
| M10 | 电话短信互通 | P9 | 先单独做规格 |
