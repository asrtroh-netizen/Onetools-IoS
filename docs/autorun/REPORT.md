# OneTools 自动执行报告

阻塞停（A4/N5 的 `icons.json`、E3 图标码点仍缺；其余本机能验证的已验证或标未编译）。

- 12 小时段：2026-11-11 18:00:13–2026-11-12 06:00:13 +08:00。该段结束时最后提交是 `886992d`（04:43:50）。当时没有 `docs/autorun/REPORT.md`，N14 未满足。
- 本轮：计划 `docs/superpowers/plans/2026-11-12-onetools-complete-polish-18.md`，起点 2026-11-12 09:45，截止 18:00:00 +08:00。Q0 `99b49e5`，Q1 `b50bcd7`（门禁 09:49:24–09:51:15，退出码 0，证据在 `docs/autorun/closeout-2026-11-12/`），Q2 `65082e1`（本文件首次提交），Q3 `f28e45c`（部分 E3），Q4 `68fadb5`（五线审查），Q5 `7e39df4`（并入清单订正）。
- 没有改系统代理或全局 git，没有推送，没有跑 `git submodule update`，没有写 `DONE`/`PAUSE`（AFK 已结束）。
- Q3–Q5 已补进本文件，不改 N1–N14 的条文。第一行结论不变：图标夹具仍阻塞。

---

## 1. 判据 N1–N14（收尾命令与证据）

发车时冻结的条文不改。做不到的标「阻塞」，不把缺文件说成通过。

| # | 状态 | 证据（2026-11-12 09:49–09:51 +08:00，除非另注） |
|---|---|---|
| N1 | 已验证 | 六个上游工作区 `git status --porcelain` 均为空。`upstreams.lock.json` 的修订都在对应仓库里，且是当前分支的祖先或等于 HEAD。有 `onetools` 的三个仓：Clash-Client 的 HEAD 是 `1358825`（锁 `e3e647283b1593a61dba622f13cd499deeda9b8b` 是祖先，exit=0，线 B 的提交在上面）；Swipt、Feather 的 HEAD 等于锁，分支均为 `onetools`。没有开 `onetools` 的三个仓 HEAD 等于锁：Clash-Core `e6334ad`（`main`）、Swiplets `3e37730`（`main`）、zsign `9299685`（`master`）。全文：`closeout-2026-11-12/N1-upstreams.txt`。 |
| N2 | 已验证 | `R0-8-material-count`：`src=200 dst=200`，exit=0。`R0-8-icons`：`lines=121`，exit=0。`ow_icons.txt` 仍是 121 行，未改成 119。 |
| N3 | 已验证 | `_golden` 里 `flutter test` 两次均为 `00:27 +271: All tests passed!`，exit=0（`00:27` 是分:秒，约 27 秒）。270 张 PNG 的 sha256 在跑前、第一次后、第二次后都是 `51d437c1c04373e13b9c6362d7dfdd876cebb5e2e3ec4cbd67c06be386fe3a33`，`HASH_SAME`。总计划 T1.3 的 56 个场景在 A11 时已有深浅各一张（112 张，提交 `7768714`）；P1 又加了宽 320、430 和按钮状态，现为 135 对、270 张，总览页 `png=270 html=270`。 |
| N4 | 已验证 | `python tools/check_golden_coverage.py` 输出 `32/32`，exit=0。 |
| N5 | 五份已验证，`icons.json` 阻塞 | `python tools/check_fixtures.py` 输出 `ok tokens.json typography.json dock_edges.json ripple.json layout.json`，exit=0。磁盘上没有 `icons.json`。该脚本只检查已存在的 A4 文件，所以缺图标时仍可能输出 `ok`。N5 的完整条文要求六个夹具齐全：图标夹具按 2026-11-12 决定阻塞（不写成 119、不造假 121）。N2 的 121 行 `ow_icons.txt` 未改。 |
| N6 | 已验证 | `python -m pytest tools -q`：`46 passed in 3.37s`，exit=0。日志：`closeout-2026-11-12/N6-pytest-tools.log`。 |
| N7 | 对 `tokens.json`、`typography.json`、`dock_edges.json`、`ripple.json` 已验证；图标码点阻塞 | Q1 时 `swift test --package-path OneUI` 为 `Executed 4 tests, with 0 failures`。Q3（09:54–09:55）之后为 `Executed 7 tests, with 0 failures`，退出码 0。往 `typography.json` 加 `__probe` 失败：`swift missing typography.__probe`，退出码 1；夹具已按 sha256 `bccea24b1bb311ea6280f5db025912beb6acc113cf3dc14a6652e2bcc91a29ea` 撤掉后再过。图标码点没有 Swift 实现，见 A4 决定。不算 E3 全部通过。 |
| N8 | 环回已验证；P3 其余代码语法通过、未编译 | `python tools/sync_harness.py --check`：`same ...SwiptLoopbackTests.swift`，exit=0。`swift test --package-path _harness/ClashLogic`：`Executed 5 tests, with 0 failures`，exit=0。B2 按设计不在本机完整编译（需要 Xcode）。B3 在 Linux 不可行，B4 未做，P3 阻塞。 |
| N9 | 已验证 | Skia：`_ref/NOTES.md` 结论与交接文档 §3.3.2 一致（提交 `f549fcb`）。内核环回：`docs/decisions/W-kernel-loopback.md`（与 B3 结论一同提交 `b71db82`）。子模块：`docs/findings/submodules.md`（`3eb8715`），zipball 就位，Zsign 247 文件 / 73,644,372 字节，IDeviceKitten 25 / 46,693，DeveloperDiskImage 6 / 18,046,187；本轮 09:50 重数一致，三处都没有 `.git`。 |
| N10 | 已验证（结论：不可行） | `docs/decisions/W-parser-harness.md`。Linux 上 `swift build --package-path _harness/ModuleParser` 退出码 1：`cannot find 'ModuleJQ'`、`cannot find 'ModuleJSONText'`，原文件第 1 行是 `#if os(iOS) \|\| os(macOS)`。 |
| N11 | 已验证 | `python tools/loon_lint.py adblock/onetools-cn-ads.plugin`：`ok`。`python tools/check_ad_coverage.py`：21 行 `ok`（末行 `ok xhLaunchAd`）。D4 覆盖测试 `6 passed`。插件 12 条规则覆盖 8 个 SDK，其余 13 个写了未收原因；每条规则至少两个来源（anti-AD 与 ACL4SSR 未用作第二来源，见决定）。 |
| N12 | 已验证（脚本未在 Mac 上运行）；清单过时段落已订正 | C4 提交 `37f542c`：脚本曾过 `bash -n`，仍标「未在 Mac 上运行」。Q5（`7e39df4`）把 `docs/findings/integration-inventory.md` 的子模块段落改为指向 `docs/findings/submodules.md`，并写入 09:50 重数（247 / 25 / 6），不跑 `git submodule update`。 |
| N13 | 已验证 | `git -C E:\GQ\Ultra\ONEWIFIX\IOS status --porcelain` 为空；HEAD=`7a8839e871d7ff776712129df57452eebede6aee`（短 `7a8839e`）。`closeout-2026-11-12/N13-onewifix.txt`。 |
| N14 | 本文件即证据 | 各条命令的完整输出在 `docs/autorun/closeout-2026-11-12/`（含 `gates/*.log`、`flutter-test-2.log`、`SUMMARY.txt`）。`docs/autorun/gates.log` 有同一轮追加。 |

Q1 门禁表（全部 pass）：

```
R0-5-branches                pass     Feather=onetools
R0-8-material-count          pass     src=200 dst=200
R0-8-icons                   pass     lines=121
D1-export-ad-sdks            pass     4 passed in 0.33s
D2-check-samples             pass     ok XWebAds.plugin b6d218d58a709cd72559fbe9c6d5eed5e6e5e2f003e7329fc34c2477cf785649
A2-golden-diff               pass     4 passed in 0.82s
A1-flutter-test              pass     00:27 +271: All tests passed!
R0-7-swift-smoke             pass     Build complete! (1.25 secs)  （日志内：Test run with 1 test ... passed）
B1-sync-check                pass     same Clash-Client\apple\ClashClientUI\Tests\ClashClientUITests\SwiptLoopbackTests.swift
B1-swift-test                pass     Executed 5 tests, with 0 failures
E2-swift-test                pass     Executed 4 tests, with 0 failures
E1-swift-test                pass     Executed 4 tests, with 0 failures
D3-loon-lint                 pass     17 passed in 1.67s
A3-check-fixtures            pass     ok tokens.json typography.json dock_edges.json ripple.json layout.json
D4-ad-coverage               pass     ok xhLaunchAd
D4-plugin-lint               pass     ok adblock\onetools-cn-ads.plugin
D4-coverage-tests            pass     6 passed in 0.88s
A10-golden-coverage          pass     32/32
A11-contact-sheet            pass     png=270 html=270
P4-signing-test              pass     Executed 13 tests, with 0 failures
A1-flutter-test-2            pass     00:27 +271: All tests passed!
Q1-goldens-hash              pass     HASH_SAME 51d437c1c04373e13b9c6362d7dfdd876cebb5e2e3ec4cbd67c06be386fe3a33 count=270
N6-pytest-tools              pass     46 passed in 3.37s
N1-upstreams                 pass
N13-onewifix                 pass     HEAD=7a8839e
```

---

## 2. 全部单元状态

### 第 0 轮

| 编号 | 状态 | 提交或证据 |
|---|---|---|
| R0-1 到 R0-9 | 已验证 | 见 `STATE.md`。R0-6 用 zipball，三个仓已 unshallow；子模块不要再 `git submodule update` |
| R0-8 | 已验证 | `06414ac` |

### 线 A

| 编号 | 状态 | 提交 |
|---|---|---|
| A1 | 已验证 | `50841f4` |
| A2 | 已验证 | `b6786ad` |
| A3 | 已验证 | `1e6d526` |
| A4 | 阻塞 | 缺 `icons.json`。`Icons.eye`、`Icons.eye_slash` 来自 `obscurable_field.dart:51` 的 Cupertino，Material 解析只有 119。决定：不造假 |
| A5 | 已验证 | `aa3a000` |
| A6 | 已验证 | `216e385` |
| A7 | 已验证 | `505cb42` |
| A8 | 已验证 | `deb497d` |
| A9 | 已验证 | `1efb4a6` |
| A10 | 已验证 | `e1b038d` |
| A11 | 已验证 | `7768714`（当时 112 张）；P1 后总览 270 |
| P1 | 已验证 | `fd4172e`；本轮两次 271 项仍通过 |
| P2 | 已验证 | `67307f2`（40 个数：23 一致、17 未收录，无同一键对不上） |

### 线 B

| 编号 | 状态 | 提交 |
|---|---|---|
| B1 | 已验证 | `658c29c` / `f9de3b9`；本轮 5 个测试通过 |
| B2 | 语法通过，未编译 | `1358825`。不在本机完整编译 |
| B3 | 不可行 | `b71db82` |
| B4 | 未做 | 因 B3 |
| P3 | 阻塞 | 因 B3 |

### 线 C

| 编号 | 状态 | 提交 |
|---|---|---|
| C1 | 已验证 | `f549fcb` |
| C2 | 已验证 | `b71db82` |
| C3 | 已验证 | `3eb8715` |
| C4 | 已验证（脚本未运行） | `37f542c` |
| C5 | 已验证；过时段落已订正 | `37f542c`；Q5 `7e39df4` |
| C6 | 已验证（推断，未经解析器实测） | `e420389` |
| P5 | 已验证 | `7b63afb` |
| P7 | 草稿已核对，未运行，未改工程 | `a1e216d`。G2 结论未定 |
| P8 | 草稿已核对 | `4d2020b`。六项未决定 |

### 线 D

| 编号 | 状态 | 提交 |
|---|---|---|
| D1 | 已验证 | `01f9839` |
| D2 | 已验证 | `881dbcf` |
| D3 | 已验证 | `460b6e6` |
| D4 | 已验证 | `a4b3bd4` |

### 线 E

| 编号 | 状态 | 提交 |
|---|---|---|
| E1 | 已验证 | `cb3fcdc`；本轮 4 个测试通过 |
| E2 | 已验证 | `6a4ad75` |
| E3 | 部分通过（图标仍阻塞） | `f28e45c`。字号、底栏、水波纹已验证；图标码点未写。不算全部通过 |
| P4 | 已验证 | `5dc7d76`；本轮 13 个测试通过 |
| P6 | 语法通过，未编译；四项实现未选定 | `886992d` |

### 本轮队列

| 编号 | 状态 | 说明 |
|---|---|---|
| Q0 | 已验证 | `99b49e5` |
| Q1 | 已验证 | 全量门禁，见第 1 节；本提交纳入证据目录 |
| Q2 | 已验证 | 本文件首次提交 `65082e1`。Q1 证据 `b50bcd7` |
| Q3 | 部分通过 | `f28e45c`。7 项 `swift test` 通过；假键探测失败后已撤掉。图标仍阻塞 |
| Q4 | 已验证 | `68fadb5`。`docs/autorun/reviews/2026-11-12-lane-*.md` |
| Q5 | 已验证 | `7e39df4` |
| Q6 | 无新增 | 审查未要求改检查行为。本机可做且不违反禁区的打磨已做完。Mac 项与图标策略仍等。 |
| Q7 | 已更新（09:58） | 本文件已写入 Q3–Q5。到 18:00 若仓库无新变化即可保持。 |

---

## 3. 未编译与未运行的文件

**语法通过，未编译**

- 线 B 的 P3 其余代码（B2），在 Clash-Client 的 `onetools` 上：`apple/ClashClient/Sources/ConfigStore/ConfigTransforms.swift`、`ProfileActivationCoordinator.swift`、`Sources/VPNController.swift`、`Sources/Mac/VPNController.swift`、`Sources/ConfigUI/TunnelSettingsView.swift`，以及三种语言的 `Localizable.strings`（见提交 `1358825`）。未改 `ClashtvOS` 的 `project.yml`（已有决定）。
- `experiments/G3/`：`Package.swift`、`Sources/G3Numbers/{Text,Blur,Shadow,Ripple}Numbers.swift`、`NOTES.md`。只过了 `swiftc -parse`。文字、模糊、投影、水波纹触摸都未选定实现。
- OneUI 现有 14 个界面文件（`Sources/OneUI/` 下组件、主题、Gallery 等）。Linux 上不参与 `swift test`。界面层等 Mac 上的 G3 实验。

**未运行**

- `scripts/mac/10-env.sh`、`20-clash-client.sh`、`30-swipt.sh`、`35-feather.sh`、`40-verify-windows-work.sh`，以及 `docs/superpowers/plans/2026-11-11-mac-stage.md`：语法检查过，未在 Mac 上跑。
- `docs/drafts/g2-go-runtimes.md`：工程配置草稿，产物不在盘上，未改工程，未在 Mac 上运行。
- 通话规格 `docs/superpowers/plans/2026-11-11-onetools-p9-calls-design.md`：只是文档。

**阻塞、没有产物**

- `_golden/fixtures/icons.json`、`MaterialIconCodepoints.swift`、`tools/gen_icon_codepoints.py`。
- B4 的 `docs/findings/loon-ignored.md`（实测清单）未做；只有 C6 的推断稿 `loon-ignored-predicted.md`。

---

## 4. 执行中的决定

详见 `docs/autorun/DECISIONS.md`。与收尾仍相关的包括：

- 下载改直连，不改系统代理和全局 git。
- Swift 走 WSL Ubuntu-24.04 的 6.4.2（`/opt/swift`）；Windows 工具链放弃，见 `NEGATIVE.md`。
- 内核与子模块用 GitHub API zipball，不跑 `git submodule update`；zipball 树没有 `.git`。
- A4 不把 `icons.json` 写成 119 或造假 121。
- B3 判不可行，B4 不做；P3 因 B3 阻塞。
- 不改 `ClashtvOS` 的 `project.yml`。
- D4 第二来源只用 EasyList China、秋风、ADgk。
- OneUI 的 `Package.swift` 在非 macOS 上只声明 `OneUICore`。
- 本轮不重启 AFK 钩子，不写 `DONE`/`PAUSE`。

本轮到写本报告时没有新的长期决定。Q1 用独立脚本跑与 `gates.json` 相同的命令并保存全文日志，再加第二次 `flutter test` 和 N1/N6/N13；没有删改已有门禁项。

---

## 5. 发现的问题与对总计划的建议

1. **12 小时截止时没有报告。** 自动循环在 06:00:13 停了，N14 未交。本轮把报告补上。以后收尾应把「写报告」放到截止前至少 40 分钟，不要只依赖 AFK 最后一轮。
2. **`check_fixtures.py` 在缺 `icons.json` 时仍输出 `ok`。** 这是脚本「有文件才查 A4」的既有行为，不是本轮改的。报告和验收不能把这一行当成 N5 全部通过。若以后补图标夹具，再让脚本在缺文件时失败也可以，但不要为了过关而改 N5 条文。
3. **并入清单过时（已订正）。** 初稿写子模块「未初始化」。Q5（`7e39df4`）已改为指向 `docs/findings/submodules.md`，不跑 `git submodule update`。
4. **Flutter 测试耗时。** 日志里的 `00:25`、`00:27` 是分:秒（约半分钟），不是 25 分钟。先前按 25 分钟估全量门禁偏大。本轮两次合计约在 09:49:27–09:51:15 的窗口内完成（整次 Q1 约 1 分 51 秒）。
5. **图标夹具的结构性缺口。** Cupertino 的 `Icons.eye` / `Icons.eye_slash` 进了 `ow_icons.txt`，Material 解析得不到码点。要做完 A4/E3，需要你改冻结证据或单独列出 Cupertino 图标；执行侧不能自行放宽。
6. **解析器测试台只能在 Apple 平台编。** 总计划若写「Windows 上验证解析器」，应改成「Mac 上用原工程」，或接受 Linux 上不可行。
7. **`ConfigTransforms.swift` 若 `import ClashClientUI`，未依赖该包的 `ClashtvOS` 会在 Mac 上编不过。** 已决定不改 `project.yml`；Mac 阶段要给 ClashtvOS 补依赖，或把合并改成不依赖该模块。

---

## 6. Mac 阶段开始前需要你做的事

沿用 12 小时计划第 12 节 M0–M10，并加上本机关不掉的阻塞：

1. **M0 准备：** Mac；Bundle ID 前缀和 Team ID；朋友账号里的四个 App ID 和描述文件。
2. **图标夹具：** 若要做完 A4 和 E3 的码点表，请决定是单独列出两个 Cupertino 图标，还是改冻结的 121 项要求。不要让执行侧造假。
3. **在 Mac 上编 Clash 解析器**（B3 重做），通过后再考虑 B4、P3。
4. **跑 `scripts/mac/40-verify-windows-work.sh`：** 把标「未编译」的编一遍，Swift 单测全跑一遍（M2）。注意 ClashtvOS 与 ClashClientUI 的依赖。
5. **G3 五个实验**（文字、模糊、投影、水波纹触摸，以及相关闸门）：选定实现后才能写 OneUI 界面层。不要把 `experiments/G3/` 的草稿当成已选方案。
6. **双 Go 运行时实验（G2）：** 草稿在 `docs/drafts/g2-go-runtimes.md`，不要在有结论前改 Clash-Client 工程。
7. **通话六项未决：** 规格草稿已有，先拍板再实现。
8. **不要** 对 zipball 就位的子模块跑 `git submodule update`，那些目录没有 `.git`。

环境仍是：Halo 上 Windows Swift 不可用，走 WSL；不要改系统代理和全局 git。
