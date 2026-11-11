推断，未经解析器实测

起点 2026-11-12 01:23（+08），写完 01:38。入口是 `ModuleParser.parse`（`Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleParser.swift:90-117`）。这里的「忽略」指返回值里的 `ModuleIR.ignored`。平台按 iOS：`ModulePlatform.current` 在非 macOS、非 tvOS 时是 `.ios`（`ModuleIR.swift:34-40`）。

空行，以及以 `#`、`//`、`;` 开头的行，在 `ModuleParser.swift:1068` 跳过，不进忽略清单。五份样本里的 `#!` 行走 `readMetadata`（`ModuleParser.swift:393-423`）：已知键写进清单头，函数返回 nil，不产生 `ModuleIgnoredEntry`。

正则是否能编过，源码交给 `NSRegularExpression`（`ModuleLineSyntax.swift:120-121`）。样本里 160 条改写、脚本、Map Local 和 `URL-REGEX` 模式，用本机 Swift 6.4.2 的 Foundation 做了同一个构造，全部成功。没有调用 `ModuleParser.parse`。

## 1. adblock4limbo.list：整份拒绝

548 条非注释行都是三段：`DOMAIN-SUFFIX` 291、`DOMAIN` 223、`DOMAIN-KEYWORD` 34。第一条在第 24 行，文件共 796 行。没有 `[`段`]`。

还没有段名时，每一条会先被记成 `unreadableLine`（`ModuleParser.swift:1077-1078`）。循环结束后 `ModuleParser.swift:1177` 返回 `.failure(.notAModule)`（`ModuleIR.swift:1603`）。失败结果不带上那些记录。对外的文案是整份没加进去（`ModuleCopy.swift:372`）。

这 548 条不会出现在忽略清单里，也不会装进模块。

## 2. youtube-ads.sgmodule：解析阶段没有忽略条目

文件名不以 `.plugin` 或 `.lpx` 结尾，正文没有 `[Rewrite]`、`[Argument]`，也没有 `request if` 这类新语法。`loon` 为 false（`ModuleParser.swift:950-962`）。

- 第 11–12 行两条 `AND`。逗号在括号里不切开（`ModuleRuleMapping.swift:222-287`），成员要求整段被括号包住（`:690-709`）。`PROTOCOL,UDP` 译成 `NETWORK,udp`（`:896-899`）。`REJECT` 是内置策略（`:48-54`）。接下来 `kernelCheck`（`:36-39`）调用 `ConfigurationTextEditing.check`。本树没有 `AppCore.validateItem` 的实现，这两条不写成忽略。
- 第 14–15 行两条 Surge 脚本。`#!arguments` 的默认值能填上 `{{{}}}`（`ModuleParser.swift:295-307`、`:333-348`）。选项都在 `surgeScriptOptions` 里（`:1331-1335`），不会走到 `:1492-1493` 的 `optionsWithNoEffect`。`script-path` 是 https，不含 boxjs（`ModuleLineSyntax.swift:691-703`）。
- 第 17 行 Map Local。段名收成 `maplocal`（`ModuleParser.swift:937-938`、`:1497`）。`data-type=text` 和空的 `data=""` 做成空正文（`ModuleLocalAnswerSyntax.swift:73-103`、`:462-467`）。`loon` 为 false，不加 `:1501` 那条「另一种应用的写法」。模式能构造。
- 第 19 行 MITM。`%APPEND%` 是追加（`ModuleParser.swift:1192-1198`）。`*.googlevideo.com` 和 `youtubei.googleapis.com` 的字符都在允许集里（`ModuleHostList.swift:24`、`:41-96`），`:116-119` 不会记 `invalidHost`。

## 3. weibo.plugin：解析阶段没有忽略条目

路径以 `.plugin` 结尾，`loon` 为 true（`ModuleParser.swift:962`）。`#!system = iOS, iPadOS` 在 iOS 上放行（`:465-477`）。

- 第 24 行是 `switch`，默认 `true`（`ModuleParser.swift:752-790`）。`[Argument]` 里读得懂的行留下（`:1507-1510`）。
- 第 28–29 行 `URL-REGEX` 加 `REJECT-DROP` 走改写（`ModuleRuleMapping.swift:367-378`）。模式能构造。
- 第 32–63 行有 3 条 `DOMAIN`、27 条 `DOMAIN-SUFFIX`，策略是 `REJECT`。映射在 `ModuleRuleMapping.swift:870-876`。内核拒绝字符串不在本树，这 30 条不写成忽略。
- `[Rewrite]` 有 18 条。`reject`、`REJECT`、`reject-dict` 由 `ModuleLineSyntax.swift:275-277` 和 `:145-149` 收下。第 72、93 行是 `response-body-json-jq`，走 `:445-453`，再走 `ModuleJSONRewriteSyntax.swift:225-227`。引号里的空格仍是一个词（`ModuleLineSyntax.swift:75-85`）。`del/1` 和 `select/1` 在 `ModuleJQNatives.swift:70` 和 `:66`。词法认 `.`字段和 `[]`（`ModuleJQLexer.swift:166-173`，`ModuleJQParser.swift:475-479`）。这两条推断为能解析。
- `[Script]` 17 行的选项只有 `script-path`、`requires-body`、`timeout`、`tag`、`enable`，都在 `loonScriptOptions` 里（`ModuleParser.swift:1323-1326`）。第 116 行 `enable={MainTabFilter}` 换成默认值 `true`（`:894`、`:910-923`），脚本仍开着（`ModuleLineSyntax.swift:682-684`）。地址是 https，短于 1024 字节（`ModuleParser.swift:125`，`ModuleLineSyntax.swift:702`）。
- 第 142 行三个主机名都合法（`ModuleHostList.swift:101-122`）。Loon 把 hostname 收成 merge（`ModuleParser.swift:1389`），这一行仍留下。

## 4. WeChatMiniAds.plugin：解析阶段没有忽略条目

`#!system` 为空，`loonSystemAllows` 放行（`ModuleParser.swift:467`）。

- `[Rule]` 6 条 `DOMAIN` 加 `REJECT`，映射在 `ModuleRuleMapping.swift:875`。内核拒绝字符串不在本树，不写成忽略。
- `[Rewrite]` 107 条。其中 105 条是 `reject` 或 `reject-dict`，两个词，走第 3 节那条路。第 288–289 行是 `response-body-json-del`，动词在 `ModuleJSONRewriteSyntax.swift:43`。`data`、`data[0]`、`data[1]`、`data[2]` 能做成路径（`:66-126`）。路径里没有 `[*]`，不走 `:179` 的 `noEffect`。
- `[Script]` 12 行的选项是 `script-path`、`requires-body`、`tag`，都在 `ModuleParser.swift:1323-1326` 的集合里，不触发 `:1492-1493`。
- 第 329 行 86 个主机名，包括 `capis*.didapinche.com`。`*` 在允许字符里（`ModuleHostList.swift:24`），这一行不记 `invalidHost`。

## 5. XWebAds.plugin：解析阶段没有忽略条目

`#!system=iOS, iPadOS` 在 iOS 上放行（`ModuleParser.swift:465-477`）。第 14 行脚本和第 17 行 `x.com` 与第 3 节同一套规则，留在脚本和主机名单里。
