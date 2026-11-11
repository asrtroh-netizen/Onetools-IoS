# SP-08 去广告（总计划 P6）

未在 Mac 上运行。

6.0 和 6.1 还没做。B4 没做。C6 是推断，没有跑解析器。6.2 的自有规则已经在本机写下并核对过。

## 解析器：Linux 上的测试台不可行

- 产品源码 `Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleJQ/ModuleJQ.swift:1` 是 `#if os(iOS) || os(macOS)`。同目录 `ModuleJSONText.swift:1` 也是这一行。
- 测试台拷贝 `_harness/ModuleParser/Sources/ParserHarness/ModuleJQ.swift:1` 同样是这一行。
- `docs/decisions/W-parser-harness.md:3-7`：结论是不可行。Linux 上这些文件是空的，调用方报 `cannot find`。B4 不做。`:32-38` 的命令是 WSL 上的 `swift build --package-path _harness/ModuleParser`，工具链 `Swift 6.4.2`，`x86_64-unknown-linux-gnu`，退出码 1。
- `docs/autorun/DECISIONS.md:22`：B3 判不可行，B4 不做，改做 C6。
- C6 是推断。`docs/findings/loon-ignored-predicted.md:1` 原文是「推断，未经解析器实测」。`:7` 写明没有调用 `ModuleParser.parse`。那份文件后面的行号是读源码做的推断，不是解析器跑出来的忽略清单。

未做：

- 6.0：宿主单测 target `ClashiOSTests` 没加，没在模拟器上跑 `xcodebuild test`。
- 6.1：Loon `script(...)`、QX `[Argument]`、BoxJS 这三项都没按「先失败测试再改解析器」做。B4 没做，所以这一步没有解析器实测可以当成完成。
- 总计划的预期（重新导入后不再出现在忽略列表里）未做。

## 6.2 自有规则（本机已核对）

- 清单 `adblock/sdk-list.json:2` 来源是 `Swiplets/skip-chinese-ads/src/rules.ts`，`:3` 的 `count` 是 21。
- 插件 `adblock/onetools-cn-ads.plugin` 有 12 条规则，都在 `[Rule]` 下：`:6-11` 六条百度，`:13` `e.kuaishou.com`，`:15` `gdt.qq.com`，`:17-19` 三条 pangolin，`:21` `dc.sigmob.cn`。
- 这 12 条覆盖 8 个 SDK，`status: ruled` 在 `docs/findings/ad-sdk-domains.md`：baidu `:25`，bytedance `:76`，csj `:105`，gdt `:149`，kuaishou `:165`，pangle `:181`，sigmob `:210`，tencent `:221`。
- bytedance、csj、pangle 共用三条 pangolin 主机。依据：`:77`、`:106`、`:182`。gdt 与 tencent 共用 `gdt.qq.com`。依据：`:150`、`:222`。
- 另外 13 个写了未收原因，同一文件的 `reason` 行：adgain `:21`，beizi `:72`，cjzf `:101`，cxh `:130`，cxjs `:135`，dcloud `:140`，flink `:145`，jd `:161`，meishu `:177`，sdm `:206`，tobid `:233`，ubix `:238`，xhLaunchAd `:243`。
- 收录规则在该文件 `:3`：一个域名要在两份互相独立的公开规则里作为规则目标才收。主域名和共用 CDN 不收，例子在 `:16`。`anti-ad-domains.txt` 和 `acl4ssr-banad.list` 不当来源，见 `:12`。
- 检查记录在 `docs/autorun/lane-D-notes.md:44` 和 `:46`：插件 12 条，8 个 SDK 有规则；`loon_lint.py` 输出 `ok`；`check_ad_coverage.py` 输出 21 行 `ok`。
