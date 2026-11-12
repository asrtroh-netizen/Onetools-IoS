未在 Mac 上运行。推断稿不能当成实测。

# M7 / T2.8：在 Mac 上对照 C6，写出真实忽略清单

这是检查单。写它的这台机器没有调用 `ModuleParser.parse`，也没有生成 `docs/findings/loon-ignored.md`。该文件现在不存在，B4 未做。C6 仍是 `docs/findings/loon-ignored-predicted.md`：第 1 行原文是「推断，未经解析器实测」，第 7 行写明没有调用 `ModuleParser.parse`。对照时保留这份推断稿，只把 Mac 上的输出写进尚不存在的 `docs/findings/loon-ignored.md`。

总计划 T2.8（`docs/superpowers/plans/2026-11-11-onetools-ios-master-plan.md:759-762`）要求：逐个打开模块，把被忽略的条目和原因抄下，按原因分组计数。Mac 阶段 M7（`docs/superpowers/plans/2026-11-11-mac-stage.md:131-133`，标题是「M7 Loon 插件真机实测」）指向同一个文件。

## 前置

与 MB-1 的 Mac 重做检查单互相引用，未编过解析器不要跑实测。

`docs/findings/mac-parser-rehearsal.md` 写本文时不在仓库里。等那份检查单写上「原工程解析器已在 Mac 上编过」之后，再按它里的工作目录和命令做本节的调用。本节不另给一套编译命令。

已打开的依据（读源码，不是本次编译结果）：

- `Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleJQ/ModuleJQ.swift:1` 与 `ModuleJSONText.swift:1` 都是 `#if os(iOS) || os(macOS)`。
- `docs/decisions/W-parser-harness.md:3-7`：Linux 上的 `_harness/ModuleParser` 得不到上游解析器的忽略清单。实测用 Clash-Client 原工程。
- 本次对照不要执行 `scripts/mac/20-clash-client.sh`。该脚本第 4 行写明 `configure.py` 会改 `apple/ClashClient/project.yml`。第 23 行只说明原工程目录是仓库根下的 `Clash-Client`。

## 怎么调用

对下面五份样本的原始字节调用 `ModuleParser.parse`（`ModuleParser.swift:90-94`）：

- `data`：文件字节。先对照下表 SHA-256，对不上就停，不要换一份正文再解。
- `sourceURL`：仓库相对路径（下表第一列）。
- `fetchedAt`：`nil`。
- `platform`：显式传 `.ios`。`ModuleIR.swift:34-36` 在 macOS 上把 `ModulePlatform.current` 定成 `.mac`。C6 第 3 行按 iOS。用 `.current` 跑出来的清单不能拿来否掉 C6。
- `argumentValues`：默认空字典。
- `check`：默认的 `ModuleRuleMapping.kernelCheck`（`ModuleParser.swift:94`）。保持原工程里的实现，不要换成空检查。

成功时只抄 `ModuleIR.ignored`。每条是 `text`、`reason`、`origin`（`ModuleIR.swift:1521-1525`）。`origin` 是段名和行号（`ModuleIR.swift:265-271`）。失败时只记 `ModuleRefusal`（`ModuleIR.swift:1597-1603`）。`notAModule` 在 `ModuleParser.swift:1177` 返回；C6 第 13–15 行写明失败结果不带上循环里那些 `unreadableLine`。`ModuleCopy.swift:372` 的英文只是界面文案，清单以枚举为准。

同一输入连跑两遍。两遍文本一致，再写入 `docs/findings/loon-ignored.md`（12 小时计划对 B4 的要求在 `docs/superpowers/plans/2026-11-11-onetools-12h-autorun.md:340`）。两遍不同就两份都留下，不挑一份当成清单。

空行，以及以 `#`、`//`、`;` 开头的行，C6 第 5 行写明不进忽略清单。实测里缺了这些行，不算和推断稿不一致。

## 样本

只解析这五份。路径和哈希以 `adblock/samples/SOURCES.md` 的 `<!-- sample -->` 段为准。同一文件第 64–93 行的三份 domain-list 不送解析器。

| 样本 | SOURCES.md | SHA-256 | 本次打开核对过的行 |
|---|---|---|---|
| `adblock/samples/adblock4limbo.list` | 25–32，哈希在第 28 行 | `5fec42de94e30ae0a27ae0528e7c3f88bac57ffab4f0d31f99ee73a299f54909` | 第 24 行是 `DOMAIN-SUFFIX,go.mnaspm.com,reject`；文件 796 行 |
| `adblock/samples/youtube-ads.sgmodule` | 15–22，哈希在第 18 行 | `d0902612cfcfd2fb3f80e17aeacb0b088a62808442809c355bc68af1e0dfaba3` | 全文 19 行：第 11–12、14–15、17、19 行 |
| `adblock/samples/weibo.plugin` | 35–42，哈希在第 38 行 | `6fb8f00e4d2b02b347388c824ea5ae9621c3ac9777ec88ee6823776b48f66a0e` | 第 24、28–29、32、72、93、116、142 行；文件 142 行 |
| `adblock/samples/WeChatMiniAds.plugin` | 45–52，哈希在第 48 行 | `f8ef8e7cfa747bbb4ed57f9752fc0544a1f08187b8f1a4dca58aa3a0543c50c7` | 第 7 行 `#!system` 为空；第 16–27 行 6 条 `DOMAIN`；第 288–289、329 行；文件 329 行 |
| `adblock/samples/XWebAds.plugin` | 55–62，哈希在第 58 行 | `b6d218d58a709cd72559fbe9c6d5eed5e6e5e2f003e7329fc34c2477cf785649` | 全文 17 行：第 10、14、17 行 |

## 预期对照

下表是 C6 的推断，用来对照，本身不是实测。实测写完之前，不要把这一列抄进 `loon-ignored.md` 冒充结果。

| 样本 | C6 | 推断结果 |
|---|---|---|
| `adblock/samples/adblock4limbo.list` | 第 9–15 行 | 整份 `.failure(.notAModule)`。第 11 行写 548 条非注释行、第 24 行起、文件 796 行、没有段名。第 15 行：这 548 条不出现在忽略清单里 |
| `adblock/samples/youtube-ads.sgmodule` | 第 17–24 行 | 解析成功，`ignored` 为空。对照点是第 11–12、14–15、17、19 行 |
| `adblock/samples/weibo.plugin` | 第 26–35 行 | 解析成功，`ignored` 为空。对照点是第 24、28–29、32–63、72、93、116、142 行 |
| `adblock/samples/WeChatMiniAds.plugin` | 第 37–44 行 | 解析成功，`ignored` 为空。对照点是 `[Rule]` 的 6 条、第 288–289 行、`[Script]`、第 329 行（行内有 `capis*.didapinche.com`） |
| `adblock/samples/XWebAds.plugin` | 第 46–48 行 | 解析成功，`ignored` 为空。对照点是第 14 行脚本和第 17 行 `x.com` |

每份样本在实测清单里各占一节，依次写：路径、SHA-256、成功或失败枚举、`ignored` 条数、按 `reason` 分组的计数、逐条 `origin.line` / `origin.section` / `reason` / `text`。再加一小节「与 C6 对照」，行里写 C6 行号、推断一句、实测一句、一致或不一致。

## 与推断稿不一致时怎么记

只写在 `docs/findings/loon-ignored.md` 的「与推断稿不一致」节。每条一行四样东西：样本路径、C6 行号、样本行号（`origin.line`；整份失败则写失败枚举）、实测的 `reason` 或 `ModuleRefusal`。推断句子抄 C6 原文，不改写。

下面这些都算不一致，要逐条写，不要并成「大体一致」：

- `adblock4limbo.list` 的结果不是 `.notAModule`，或者失败之外还带上了忽略条目。
- 另四份的 `ignored` 不是空，或者解析失败。
- 条目的 `reason` 和 C6 对应小节写的去向不同。

不改 `docs/findings/loon-ignored-predicted.md`，不改 `adblock/` 下的规则和样本，不把 anti-AD 或 ACL4SSR 加进来源。推断稿第 1 行继续保持「推断，未经解析器实测」。

`loon-ignored.md` 写成后，第一行写明这是 Mac 上的实测、日期、以及对应的 MB-1 编译记录。在那一行写上之前，这份清单仍然只是未运行的步骤。

## 附：SDK 对照简表（MD-2）

这一节只复述已验收的收录结论，方便在 Mac 上对照。不改 `docs/findings/ad-sdk-domains.md`，不新增来源，不把某个 `no-rule` 改成已收。

两来源原则在 `ad-sdk-domains.md:3` 和 `:14`：一个域名要在两份互相独立的公开规则里作为规则目标出现才收。目标指 `DOMAIN` / `DOMAIN-SUFFIX` 逗号后的主机，或 Adblock 的 `||主机^`。两份都用后缀形式时，插件用 `DOMAIN-SUFFIX`；只有一份是后缀、另一份是精确 `DOMAIN` 时，插件用精确 `DOMAIN`。四份文件是 `:7-10`：`adblock/samples/adblock4limbo.list`、`adblock/lists/easylistchina.txt`、`adblock/lists/AWAvenue-Ads-Rule.txt`、`adblock/lists/ADgk.txt`。`:12` 写明 `adblock/lists/anti-ad-domains.txt` 与 `adblock/lists/acl4ssr-banad.list` 不当来源。

`adblock/sdk-list.json:3` 的 `count` 是 21。`tools/check_ad_coverage.py:94-137` 按这个数组顺序每个 id 打一行。2026-11-12 重跑 `python tools/check_ad_coverage.py`，stdout 依次是下表这 21 行 `ok <id>`。其中 8 个 `ruled`、13 个 `no-rule`。插件 `adblock/onetools-cn-ads.plugin` 有 12 条规则（第 6–11、13、15、17–19、21 行）。bytedance、csj、pangle 共用三条 pangolin 规则；gdt 与 tencent 共用 `gdt.qq.com`。

### 8 个已覆盖

| stdout | id | 规则（插件行） | 结论位置 |
|---|---|---|---|
| 2 `ok baidu` | baidu | 6–11：`cpro.baidu.com`、`pos.baidu.com`、`mobads.baidu.com`、`als.baidu.com` 为 `DOMAIN-SUFFIX`；`afd.baidu.com` 为 `DOMAIN`；`mobads-logs.baidu.com` 为 `DOMAIN-SUFFIX` | `ad-sdk-domains.md:23-67`。不收 `baidu.com` |
| 4 `ok bytedance` | bytedance | 17–19，与 csj、pangle 共用 | `:74-96` |
| 6 `ok csj` | csj | 同上三条 | `:103-125` |
| 11 `ok gdt` | gdt | 15：`DOMAIN-SUFFIX,gdt.qq.com,REJECT`，与 tencent 共用 | `:147-156`。不收 `qq.com` |
| 13 `ok kuaishou` | kuaishou | 13：`DOMAIN-SUFFIX,e.kuaishou.com,REJECT` | `:163-172`。不收 `kuaishou.com`、`yximgs.com` |
| 15 `ok pangle` | pangle | 同 bytedance 的三条 | `:179-201` |
| 17 `ok sigmob` | sigmob | 21：`DOMAIN-SUFFIX,dc.sigmob.cn,REJECT` | `:208-217`。`adservice.sigmob.cn`、`track.sigmob.cn`、`sigmob.com` 只有一份，不收 |
| 18 `ok tencent` | tencent | 15：与 gdt 同一条 `gdt.qq.com` | `:219-228` |

三条共用规则是：`DOMAIN-SUFFIX,pangolin-sdk-toutiao-b.com,REJECT`；`DOMAIN,pangolin.snssdk.com,REJECT`；`DOMAIN-SUFFIX,log-api.pangolin-sdk-toutiao.com,REJECT`。

### 13 个未收

| stdout | id | 原因（`ad-sdk-domains.md` 原文） |
|---|---|---|
| 1 `ok adgain` | adgain | `:21` 只有秋风第 953 行写出 xadsmartget.adgain.cn，没有第二份 |
| 3 `ok beizi` | beizi | `:72` 只有秋风写出 beizi.biz（第 294 行）、sdk.beizi.biz（第 743 行）和 api-htp.beizi.biz（第 251 行） |
| 5 `ok cjzf` | cjzf | `:101` 这四份名单和五个样本里都没有 CJZF 的广告域名 |
| 7 `ok cxh` | cxh | `:130` 这四份名单和五个样本里都没有 CXH 的广告域名 |
| 8 `ok cxjs` | cxjs | `:135` 这四份名单和五个样本里都没有 CXJS 的广告域名 |
| 9 `ok dcloud` | dcloud | `:140` EasyList 只有 dcloud.net.cn 的元素隐藏，不是域名规则。dcloud.net.cn 是 uni-app 主站，不收。没有第二份广告专用子域 |
| 10 `ok flink` | flink | `:145` 这四份名单和五个样本里都没有 FLink 的广告域名 |
| 12 `ok jd` | jd | `:161` ads-union.jd.com 只在 EasyList China 第 7015 行。jd.com 主域名不收 |
| 14 `ok meishu` | meishu | `:177` 没有美数专用域名同时出现在两份名单。秋风里的 1rtb.com 和 sdk.1rtb.net 只有这一份，不把它们当成美数 |
| 16 `ok sdm` | sdm | `:206` anythinktech.com 和 toponad.com 只在秋风，没有第二份 |
| 19 `ok tobid` | tobid | `:233` 没有 WindMill 或 ToBid 专用域名。dc.sigmob.cn 只记在 sigmob 下，不记到这个聚合 id |
| 20 `ok ubix` | ubix | `:238` ubixioe.com 只在秋风第 979 行，没有第二份 |
| 21 `ok xhLaunchAd` | xhLaunchAd | `:243` 本地开屏控件，样本和名单里没有它的广告域名 |

`ad-sdk-domains.md:16` 看见但不收的还有：`baidu.com`、`qq.com`、`kuaishou.com`、`jd.com`、`toutiao.com`、`snssdk.com`、`yximgs.com`、`baidustatic.com`、`bcebos.com`、`gtimg.com`，以及同一段里的 `cpro.baidustatic.com`、`e.qq.com`、`trace.qq.com`、`adslvfile.qq.com`。`pangolin-sdk-toutiao.com` 整域只在 limbo 第 487 行。这些继续不收。
