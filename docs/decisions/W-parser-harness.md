# 解析器测试台（B3）

结论：不可行。

卡在 `ModuleJQ` 和 `ModuleJSONText`。两者的实现整文件在 `#if os(iOS) || os(macOS)` 里。测试台把原文件编进同一个 target 之后，Linux 上这些文件是空的，调用方报 `cannot find`。不改 Clash-Client，这个条件去不掉。同一份实现里还有 Darwin 才有的 `pthread_get_stackaddr_np` 和 `pthread_get_stacksize_np`（`ModuleJQ.swift:331-332`）。

规则校验和 YAML 转换另要 `import Clash`。本机没有这个模块。即使用空类型把 jq 那一层挡过去，忽略清单也不是上游解析器的结果。B4 不做。线 C 改做 C6。

## 计划里那句话

2026-11-12 只核对 import 行。

| 文件 | import |
|---|---|
| `ModuleLineSyntax.swift` | Foundation |
| `ModuleLoonRewriteSyntax.swift` | Foundation |
| `ModuleJSONRewriteSyntax.swift` | Foundation |
| `ModuleHostMappingSyntax.swift` | ClashClientKit、Foundation |
| `ModuleRuleSetSyntax.swift` | ClashClientKit、Foundation |
| `ModuleLocalAnswerSyntax.swift` | Foundation、UniformTypeIdentifiers |
| `ModuleIR.swift` | CryptoKit、Foundation |
| `ModuleParser.swift` | Darwin、Foundation、os |

仍然成立：三个语法文件只有 Foundation（Line、LoonRewrite、JSONRewrite）；`ModuleIR.swift` 依赖 CryptoKit；`ModuleParser.swift` 依赖 Darwin 和 os。

已经对不上：名字带 Syntax 的文件是 6 个，不是 5 个。`ModuleLocalAnswerSyntax.swift` 还依赖 UniformTypeIdentifiers。`ModuleHostMappingSyntax.swift` 和 `ModuleRuleSetSyntax.swift` 依赖 ClashClientKit。

`ModuleParser.swift:32` 的 `os.majorVersion` 是局部变量 `ProcessInfo.processInfo.operatingSystemVersion`。`import os` 实际给第 514 行的 `Logger` 用。

## 编译器输出

工具链：Swift 6.4.2，`x86_64-unknown-linux-gnu`。仓库根目录执行。

```
wsl -d Ubuntu-24.04 -u root -- env PATH=/opt/swift/usr/bin:/usr/bin:/bin /opt/swift/usr/bin/swift build --package-path _harness/ModuleParser
```

退出码：1

```
ModuleJSONRewriteSyntax.swift:136:9: error: cannot find 'ModuleJSONText' in scope
ModuleJSONRewriteSyntax.swift:145:16: error: cannot find 'ModuleJSONText' in scope
ModuleJSONRewriteSyntax.swift:227:21: error: cannot find 'ModuleJQ' in scope
ModuleJSONRewriteSyntax.swift:229:30: error: cannot find type 'ModuleJQ' in scope
ModuleJSONRewriteSyntax.swift:229:73: error: cannot find 'ModuleJQ' in scope
ModuleJSONRewriteSyntax.swift:231:30: error: cannot find type 'ModuleJQ' in scope
error: Build failed
```

这一次前端命令行里已经有 `ModuleJQ.swift` 和 `ModuleJSONText.swift`。两个文件第 1 行都是 `#if os(iOS) || os(macOS)`，类型没有被定义。拷贝与 Clash-Client 逐字节相同（核过 `ModuleJQ.swift`、`ModuleJSONText.swift`、`ModuleJSONRewriteSyntax.swift`、`ModuleParser.swift`、`ModuleIR.swift` 的 SHA-256）。

`ModuleJSONRewriteSyntax.swift:136` 调用 `ModuleJSONText.parse`。第 227 行调用 `ModuleJQ.parseOnLargeStack`。`ModuleLineSyntax.swift` 和 `ModuleLoonRewriteSyntax.swift` 会走进这个 JSON 重写语法。`ModuleStore.swift:1571` 和 `:2277` 也调用 `ModuleJQ`。

Clash 探针（`_harness/ModuleParser/probe-clash.swift`，不进 package target）：

```
wsl -d Ubuntu-24.04 -u root -- env PATH=/opt/swift/usr/bin:/usr/bin:/bin /opt/swift/usr/bin/swiftc -typecheck _harness/ModuleParser/probe-clash.swift
```

退出码：1

```
probe-clash.swift:1:8: error: no such module 'Clash'
```

`Clash-Client/apple/ClashClient/ClashCore/` 里只有 `module.modulemap` 和 `ClashCoreSharedFramework.c`。modulemap 点名的 `ref.h`、`Clash.objc.h`、`Universe.objc.h`、`Clash.h` 不在树里，也没有 xcframework。

`ModuleRuleMapping.swift:39` 的 `kernelCheck` 调用 `ConfigurationTextEditing.check`。该文件第 2 行 `import Clash`，第 234 行调用 `AppCore.validateItem`。`ModuleRuleSetSyntax.swift:478` 和 `ModuleStashParser.swift:172` 调用 `ConfigTransforms.yamlToJSON`，后者第 1733 行调用 `ClashYamlToJSON`。这两个文件因为 `import Clash` 没有拷进测试台。

## 测试台里的替身

替身只写在 `_harness/ModuleParser/`。Clash-Client 没改。

为了走到上面这条错误，补过本机没有的符号：Darwin 转出 Glibc 的 `utsname` / `uname`；os 的 `Logger`；CryptoKit 的 `SHA256`（同一套 Swift 上 `import CryptoKit` 也是 `no such module`，退出码 1）；`UTType`；`CFGetTypeID` / `CFBooleanGetTypeID`（Linux 上 Foundation 不把它们放进作用域，`OrderedJSON.swift:793`；测试台再转调 CoreFoundation 里的原函数）；`clock_gettime_nsec_np` 和 `CLOCK_UPTIME_RAW`（`ModuleRegexDeadline.swift:28-37`，用 `clock_gettime` 补）；`ClashDisplayText`；`KernelLANShareOverride`（原定义在 `import Clash` 的 `ProxyShareModel.swift:624`）。`OrderedJSON.swift`、`AuthoredText.swift`、`ClashTunnelRouteShaping.swift` 是原文件拷贝。

这些替身让编译越过了计划里点名的 Foundation、CryptoKit、Darwin、os，停在 ModuleJQ 的平台条件上。测试 `ProbeTests.testLoonNameIsRead` 没有跑到，库没编过。

## 决定

B3 不可行。B4 标未做。线 C 改做 C6。

回退：删掉 `_harness/ModuleParser/`。
