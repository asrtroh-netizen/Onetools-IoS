# 并入清单：Clash-Client、Swipt、Feather

> 未在 Mac 上运行。本文件是 2026-11-12 在 Windows 上的只读扫描。
> 仓库根目录：`E:\GQ\Ultra\Onetools-IoS`。下面每条命令都在这个目录执行。
> 本机 PATH 里没有 `rg`。命令使用 `C:\Users\Administrator\AppData\Local\OpenAI\Codex\bin\a7d4c4900eafc659\rg.exe`。下文写成 `$rg`。

```powershell
$rg = 'C:\Users\Administrator\AppData\Local\OpenAI\Codex\bin\a7d4c4900eafc659\rg.exe'
```

子模块已用 zipball 就位（不是 `git submodule update`），清点见已验收的 [C3 `docs/findings/submodules.md`](submodules.md) 和 `.mimocode/r0-6-submodules-ready.txt`。这些目录没有 `.git`，不要再对它们跑 submodule update。本轮 2026-11-12 09:50 按与 C3 相同的方式重数，结果一致：

| 路径 | 状态（2026-11-12 重数） | 出处 |
|---|---|---|
| `Feather/Zsign` | 247 个文件，73,644,372 字节，没有 `.git` | `docs/findings/submodules.md`「Zsign」；`Feather/.gitmodules` 的 `path = Zsign` |
| `Feather/IDeviceKitten` | 25 个文件，46,693 字节，没有 `.git` | 同上「IDeviceKit」；`Feather/.gitmodules` 的 `path = IDeviceKitten` |
| `Swipt/Swipt/Resources/DeveloperDiskImage` | 6 个文件，18,046,187 字节，没有 `.git` | 同上「DeveloperDiskImage」；`Swipt/.gitmodules` 的 `path = Swipt/Resources/DeveloperDiskImage` |

2026-11-12 上午的并入清单初稿曾把这三处写成「未初始化」。那是 C3 完成之前的扫描，已经过时，以 `submodules.md` 为准。

重跑（PowerShell，在仓库根目录）：

```powershell
function Count-Tree($p) {
  $files = Get-ChildItem -LiteralPath $p -Recurse -Force -File -ErrorAction Stop
  [pscustomobject]@{
    Path = $p
    Files = $files.Count
    Bytes = ($files | Measure-Object Length -Sum).Sum
    HasGit = Test-Path (Join-Path $p '.git')
  }
}
Count-Tree 'Feather/Zsign'
Count-Tree 'Feather/IDeviceKitten'
Count-Tree 'Swipt/Swipt/Resources/DeveloperDiskImage'
```

预期：文件数与字节数为上表三行，`HasGit` 均为 `False`。不要用「没有任何文件」当作预期。

---
## 1. Bundle.main

58 处。Clash-Client 20，Swipt 22，Feather 16。搜索范围是三个仓库里的 `*.swift`，排除 `build/` 和 `.build/`。

```powershell
& $rg -c -g "*.swift" -g "!**/build/**" -g "!**/.build/**" "Bundle\.main" Clash-Client Swipt Feather
```

把每行冒号后面的数字相加，应得 58。

分类：

| 类 | 含义 | 处数 |
|---|---|---|
| A | 读 Info.plist：`object(forInfoDictionaryKey:)`、`infoDictionary`、`localizedInfoDictionary` | 12 |
| B | 读包内资源：`url(forResource:)`、`path(forResource:)`、用 `bundleURL` 拼资源或辅助二进制 | 12 |
| C | 标识、日志 subsystem、`bundlePath`、`executableURL`、本地化列表、显示名 | 32 |
| D | 打开自身 App | 2 |

并入规则按总计划 5.2：读 Info.plist 键的保留，并把键加到宿主 Info.plist；读资源的改成框架自己的 bundle。

### A 读 Info.plist（12）

| 位置 | 读的键 |
|---|---|
| `Swipt/Swipt/Automation/SwipletStore.swift:437` | `SwiptChannel`。`Swipt/Swipt/Info.plist` 里没有这个键 |
| `Swipt/Swipt/App/ContinuedTask.swift:29` | `BGTaskSchedulerPermittedIdentifiers` |
| `Swipt/Swipt/Platform/Platform.swift:85` | `CFBundleShortVersionString` |
| `Swipt/Swipt/Platform/Platform.swift:86` | `CFBundleVersion` |
| `Swipt/Swipt/Model/AppDirectory.swift:11` | `AppGroupIdentifier` |
| `Swipt/Swipt/Device/PairingSession.swift:19` | `localizedInfoDictionary ?? infoDictionary` |
| `Clash-Client/apple/ClashClient/Extension/PacketTunnelProvider.swift:60` | `infoDictionary` |
| `Clash-Client/apple/ClashClient/Extension/ExtensionProvider.swift:1322` | `CFBundleVersion` |
| `Clash-Client/apple/ClashClient/Shared/PreappliedTunnelSettings.swift:105` | `CFBundleVersion` |
| `Clash-Client/apple/ClashClient/Sources/LogExportDeviceFacts.swift:32` | `infoDictionary` |
| `Clash-Client/apple/ClashClient/Sources/ConfigUI/ClientUserAgent.swift:34` | `CFBundleShortVersionString` |
| `Clash-Client/apple/ClashClient/Sources/ConfigUI/ClientUserAgent.swift:36` | `CFBundleVersion` |

```powershell
& $rg -n -g "*.swift" -g "!**/build/**" -g "!**/.build/**" "Bundle\.main\.(object\(forInfoDictionaryKey:|infoDictionary|localizedInfoDictionary)" Clash-Client Swipt Feather
```

`ClientUserAgent.swift` 的调用换了行，这条正则对得上 `object(forInfoDictionaryKey:)` 那一行。

### B 读包内资源（12）

| 位置 | 资源 |
|---|---|
| `Swipt/Swipt/Automation/SwipletInterface.swift:297` | `main.jsbundle` |
| `Swipt/Swipt/Platform/Platform.swift:88` | `DeveloperDiskImage`（zipball 已就位，见 `docs/findings/submodules.md`） |
| `Feather/Feather/FeatherApp.swift:207` | `signing-assets` |
| `Feather/Feather/Backend/Server/ServerInstaller+TLS.swift:91` | `url(forResource:withExtension:)` |
| `Feather/Feather/Utilities/Handlers/TweakHandler.swift:36` | `ellekit.deb` |
| `Feather/Feather/Views/Settings/App Icon/AppIconView.swift:29` | `bundleURL` 下的 AppIcon PNG |
| `Clash-Client/apple/ClashClientUI/Sources/ClashClientUI/Design/ClashCopy.swift:148` | `lproj` |
| `Clash-Client/apple/ClashClient/Sources/VPNController.swift:986` | `url(forResource:)`，`forResource` 在下一行 |
| `Clash-Client/apple/ClashClient/Sources/VPNController.swift:1104` | `url(forResource:)`，`forResource` 在下一行 |
| `Clash-Client/apple/ClashClient/Sources/VPNController.swift:2664` | `config.yaml` |
| `Clash-Client/apple/ClashClient/Sources/ConfigStore/ModuleCertificateStore.swift:387` | `lproj` |
| `Clash-Client/apple/ClashClient/Sources/ConfigUI/ExternalControllerSettingsView.swift:384` | `Contents/Helpers/clash-cli` |

```powershell
& $rg -n -g '*.swift' -g '!**/build/**' -g '!**/.build/**' 'Bundle\.main\.(url|path)\(forResource:|Bundle\.main\.bundleURL\.appendingPathComponent' Clash-Client Swipt Feather
& $rg -n -g '*.swift' -H 'let configURL = Bundle\.main\.url\(' Clash-Client/apple/ClashClient/Sources/VPNController.swift
```

2026-11-12 重跑：第一条 10 行，第二条 2 行（`VPNController.swift:986` 和 `:1104`）。合起来 12。

### C 标识、日志、路径、本地化（32）

Swipt 13 处：`AppLanguage.swift:7`（`localizations`）、`AppLanguage.swift:11`（`bundleIdentifier`）、`ContinuedTask.swift:8`、`ErrorAlert.swift:15`、`DeviceConnection.swift:9`、`SetupView.swift:110`（`preferredLocalizations`）、`Platform.swift:15`、`Platform.swift:84`（`appBundleID`）、`LibSwiptLog.swift:6`、`PairingSetupView.swift:50`、`ServiceResolver.swift:6`、`BackgroundAssertion.swift:18`、`AppDirectory.swift:5`。前五个日志和后三个日志用 `bundleIdentifier` 做 `Logger` subsystem。

Feather 12 处：`UIApplication+suspend.swift:22`、`SourcesView.swift:127`（`.name`）、`Logger++.swift:11`、`FRAppIconView.swift:114`（`bundleURL`）、`InstallPreviewView.swift:139`、`InstallPreviewView.swift:142`（`.name`）、`InstallPreviewView.swift:173`、`AboutView.swift:38`（`.exec`）、`AboutView.swift:45`（`.version`）、`BackgroundTaskManager.swift:18`、`SettingsView.swift:111`（`.name`）、`ResetView.swift:193`。

Clash-Client 7 处：`ConfigurationFieldCopy.swift:42`（`preferredLocalizations`）、`ClashLogStore.swift:532`（`bundlePath` 是否以 `.appex` 结尾）、`ClashMainThreadHangSampler.swift:156`（`bundlePath`）、`ActivationStopwatch.swift:29`（`executableURL`）、`ModuleCertificateStore.swift:391`（`preferredLocalizations`）、`ModuleJQ.swift:227`、`ModuleParser.swift:514`。

```powershell
& $rg -n -g '*.swift' -g '!**/build/**' -g '!**/.build/**' 'Bundle\.main\.(bundleIdentifier|localizations|preferredLocalizations|bundlePath|executableURL|bundleURL|name|exec|version)' Clash-Client Swipt Feather
```

2026-11-12 重跑是 36 行。其中 4 行归 B 或 D：`SettingsView.swift:140`、`App Icon/AppIconView.swift:29`、`ExternalControllerSettingsView.swift:384`、`ClashMacApp.swift:7925`。其余 32 行是这一类。

### D 打开自身（2）

| 位置 | 做法 |
|---|---|
| `Swipt/Swipt/Settings/SettingsView.swift:140` | `NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, ...)` |
| `Clash-Client/apple/ClashClient/Sources/Mac/ClashMacApp.swift:7925` | `open` 自身 `bundlePath` |

```powershell
& $rg -n -g '*.swift' 'openApplication\(at: Bundle\.main\.bundleURL' Swipt
& $rg -n -g '*.swift' '/usr/bin/open' Clash-Client/apple/ClashClient/Sources/Mac/ClashMacApp.swift
```

---

## 2. Info.plist 键

现成的 `Info.plist` 只有两份。Clash 的键写在 `apple/ClashClient/project.yml` 的 `info.properties` 里（`GENERATE_INFOPLIST_FILE: true`，`project.yml:15`）。

```powershell
& $rg --files -g "Info.plist" -g "!**/build/**" -g "!**/.build/**" Clash-Client Swipt Feather
```

预期两行：`Swipt\Swipt\Info.plist`、`Feather\Feather\Resources\Info.plist`。

### Swipt `Swipt/Swipt/Info.plist`

| 键 | 值 |
|---|---|
| `AppGroupIdentifier` | `$(APP_GROUP_IDENTIFIER)` |
| `BGTaskSchedulerPermittedIdentifiers` | `$(PRODUCT_BUNDLE_IDENTIFIER).pairing.*` |
| `CADisableMinimumFrameDurationOnPhone` | true |
| `CFBundleDocumentTypes` | Swiplet，`io.nekohasekai.swipt.swiplet` |
| `LSApplicationQueriesSchemes` | `localdevvpn` |
| `NSBonjourServices` | `_remotepairing._tcp`、`_remotepairing-pairable-host._tcp`、`_swipt._tcp` |
| `UIApplicationSceneManifest` | `UIApplicationSupportsMultipleScenes` true |
| `UIBackgroundModes` | `location` |
| `UIFileSharingEnabled` | true |
| `UTExportedTypeDeclarations` | 扩展名 `swiplet`，MIME `application/vnd.swipt.swiplet+zip` |

`SwiptChannel` 只在 `SwipletStore.swift:437` 被读取，plist 里没有。全仓库再搜一次也只有这一处：

```powershell
& $rg -n "SwiptChannel" Swipt
```

### Feather `Feather/Feather/Resources/Info.plist`

| 键 | 值 |
|---|---|
| `BGTaskSchedulerPermittedIdentifiers` | `$(PRODUCT_BUNDLE_IDENTIFIER).userTask.*` |
| `CFBundleDocumentTypes` | `.ipa`（`thewonderofyou.Feather.ipa`）、`.tipa`（`thewonderofyou.Feather.tipa`） |
| `CFBundleIcons` | 备用图标 Donor、V0、V1、V1Mac、V2Mac、Wing |
| `CFBundleURLTypes` | scheme `feather`，名称 `thewonderofyou.Feather` |
| `LSApplicationQueriesSchemes` | `localdevvpn` |
| `UIBackgroundModes` | `audio` |
| `UIFileSharingEnabled` | true |
| `UILaunchScreen` | false |
| `UTExportedTypeDeclarations` | `ipa`、`tipa` |
| `NSAppTransportSecurity` | `claration.dev` 允许不安全 HTTP |

plist 和 `project.yml` 里没有把 `.p12`、`.mobileprovision` 声明成文档类型。

```powershell
& $rg -n -g "*.plist" -g "*.yml" "p12|mobileprovision" Clash-Client Swipt Feather
```

### Clash `ClashiOS`（`project.yml` 的 `info.properties`，约 90–129 行）

`CFBundleDisplayName` Clash；`NSAppTransportSecurity` / `NSAllowsArbitraryLoads` true；`ITSAppUsesNonExemptEncryption` false；`ClashSourceRevision`；`NSCameraUsageDescription`；`NSLocalNetworkUsageDescription`；URL scheme 见下一节；文档类型 `public.yaml`；`LSSupportsOpeningDocumentsInPlace` true；`BGTaskSchedulerPermittedIdentifiers` = `$(CLASH_BUNDLE_BASE).refresh`；`UIBackgroundModes` = `fetch`、`processing`；`NSUbiquitousContainers` 的键是 `iCloud.org.example.clash`。Debug 配置另有 `INFOPLIST_KEY_UIFileSharingEnabled: YES`（`project.yml:76`）。

同一份 `project.yml` 里还有 macOS（约 473–495 行，`PRODUCT_MODULE_NAME: ClashmacOS`）和 tvOS（约 808–824 行，`ClashtvOS`）的 info。tvOS 的后台模式只有 `fetch`。

```powershell
& $rg -n -g "project.yml" "BGTaskSchedulerPermittedIdentifiers|UIBackgroundModes|NSBonjourServices|UIFileSharingEnabled|LSApplicationQueriesSchemes" Clash-Client Swipt Feather
```

---

## 3. URL scheme 和文档类型

| 工程 | URL scheme | 查询 scheme | 文档类型 |
|---|---|---|---|
| Clash iOS `project.yml:106–118` | `clash`、`clashmeta`、`flclash`、`clash`（`clash` 写了两次） | 无 `LSApplicationQueriesSchemes` | `public.yaml`，角色 Viewer |
| Clash macOS `project.yml:481–488` | 同样四个，含重复的 `clash` | 无 | 这段 info 没有 `CFBundleDocumentTypes` |
| Swipt `Info.plist:13–31` | 无 `CFBundleURLTypes` | `localdevvpn` | `.swiplet` |
| Feather `Info.plist:9–126` | `feather` | `localdevvpn` | `.ipa`、`.tipa` |

总计划 5.2：并入后 Swipt 的 `localdevvpn` 不再需要。Feather 和 Swipt 现在都声明了它。

```powershell
& $rg -n -g "*.plist" -g "project.yml" -A 6 "CFBundleURLSchemes|LSApplicationQueriesSchemes" Clash-Client Swipt Feather
& $rg -n -g '*.plist' -g 'project.yml' 'CFBundleDocumentTypes|UTTypeIdentifier|public\.yaml|<string>swiplet</string>|<string>ipa</string>|<string>tipa</string>' Clash-Client Swipt Feather
```

文档类型那一条 2026-11-12 重跑命中：Swipt 的 `CFBundleDocumentTypes`、`UTTypeIdentifier`、`swiplet`；Feather 的 `CFBundleDocumentTypes`、两处 `UTTypeIdentifier`、`ipa`、`tipa`；Clash `project.yml:113` 的 `CFBundleDocumentTypes` 和 `:118` 的 `public.yaml`。`project.yml:371` 也含 `public.yaml`，那是分享扩展的激活规则，不是文档类型。

---

## 4. Entitlements

磁盘上的 `.entitlements` 文件只有三份。Clash 的 iOS / macOS / tvOS 权益写在 `project.yml` 的 `entitlements.properties` 里，对应文件要等 `xcodegen` 才生成。

```powershell
& $rg --files -g "*.entitlements" Clash-Client Swipt Feather
```

预期：

- `Feather\Feather\Supporting Files\Feather.entitlements`：只有 `get-task-allow` = true
- `Swipt\Swipt\Swipt.entitlements`：只有 `com.apple.security.application-groups` = `$(APP_GROUP_IDENTIFIER)`
- `Clash-Client\cli\clash-cli.entitlements`：`com.apple.security.app-sandbox`、`com.apple.security.network.client`

`project.yml` 里已有的权益：

| 位置 | 键 |
|---|---|
| `ClashiOS` 130–143 行 | App Group `$(CLASH_APP_GROUP)`；`packet-tunnel-provider`；`com.apple.developer.icloud-services` = CloudDocuments、CloudKit；iCloud container；ubiquity container |
| `ClashiOSExtension` 242–248 行 | App Group；`packet-tunnel-provider` |
| `ClashControlsExtension` 316–320 行 | App Group |
| `ClashShareExtension` 354–358 行 | App Group |
| macOS target 496–513 行 | sandbox、network.client、user-selected.read-write、camera、App Group、`packet-tunnel-provider`、iCloud 三组键 |
| `ClashtvOS` 825–836 行 | App Group、`packet-tunnel-provider`、iCloud container、`icloud-services` = CloudKit、`aps-environment` = development |
| `ClashtvOSExtension` 870–876 行 | App Group、`packet-tunnel-provider` |

总计划 T2.2 要求以后从 `ClashiOS` 拿掉三个 iCloud 键。这次只记录，没有改 `project.yml`。

```powershell
& $rg -n -g "project.yml" -g "*.entitlements" "com\.apple\.(developer|security)\.|get-task-allow" Clash-Client Swipt Feather
```

这条也会命中 `SigningHandler.swift`、`sideload.ts` 和 Go 源码里的同名字符串。权益本体以上面的文件和 `project.yml` 行号为准。

宿主已有 App Group（`CLASH_APP_GROUP` = `group.$(CLASH_BUNDLE_BASE)`，`project.yml:11`）。Swipt 的 App Group 是 `$(APP_GROUP_IDENTIFIER)`。总计划 5.2：并入时改指宿主那一个。

---

## 5. 同名类型

行首的顶层类型，三个仓库里同名的有 4 个。总计划 5.2 要求分 target，就是为了这些名字。

| 类型 | 位置 |
|---|---|
| `class AppDelegate` | `Feather/Feather/FeatherApp.swift:154`；`Swipt/Swipt/SwiptApp.swift:61`（`final class`） |
| `enum AppLanguage` | `Clash-Client/apple/ClashClient/Sources/ConfigUI/AppPreferences.swift:4`；`Swipt/Swipt/Settings/AppLanguage.swift:3` |
| `struct HomeView` | `Clash-Client/apple/ClashClient/Sources/HomeView.swift:5`；`Swipt/Swipt/App/HomeView.swift:20` |
| `struct SettingsView` | `Feather/Feather/Views/Settings/SettingsView.swift:15`；`Swipt/Swipt/Settings/SettingsView.swift:6` |

```powershell
& $rg -n -g "*.swift" -g "!**/build/**" -g "!**/.build/**" -g "!**/Tests/**" "^(final class AppDelegate|class AppDelegate|struct SettingsView|struct HomeView|enum AppLanguage)\b" Clash-Client Swipt Feather
```

预期 8 行。

另外扫过带缩进的嵌套声明：28 个名字出现在至少两个仓库（`CodingKeys`、`Action`、`Key`、`Coordinator`、`Certificate`、`Storage` 等）。它们留在各自 target 里不会链到一起。倒进同一个 target 才会撞。这次并入按总计划走独立 target。

语言模式和最低系统（工程文件里的值）：

| 工程 | 最低系统 | Swift |
|---|---|---|
| Clash `project.yml:4–14` | iOS 15.0，macOS 13.0，tvOS 17.0 | 5.9 |
| Swipt `Swipt.xcodeproj/project.pbxproj` | iOS 16.4（399、456 行），macOS 14.0（591、641 行） | 6.0（509、557、608、658 行） |
| Feather `Feather.xcodeproj/project.pbxproj` | iOS 16.0（381、445 行） | 5.0（404、467 行） |

```powershell
& $rg -n "SWIFT_VERSION|IPHONEOS_DEPLOYMENT_TARGET|MACOSX_DEPLOYMENT_TARGET" Swipt/Swipt.xcodeproj/project.pbxproj Feather/Feather.xcodeproj/project.pbxproj Clash-Client/apple/ClashClient/project.yml
```

---

## 6. 同一个第三方包的不同版本

### 跨仓库

| 包 | Clash-Client | Swipt | Feather |
|---|---|---|---|
| swift-crypto | `project.yml:33` `exactVersion: 3.15.1` | 无 | 两份 `Package.resolved` 都是 3.12.3 |
| swift-asn1 | `project.yml:36` `exactVersion: 1.7.3` | 无 | `Feather.xcodeproj/.../Package.resolved` 1.3.2；`Feather.xcworkspace/.../Package.resolved` 1.3.1 |
| swift-atomics | `project.yml` 未声明 | `Package.resolved` 与 `project.pbxproj:708` 都是 1.3.1 | 两份 `Package.resolved` 都是 1.2.0 |
| golang.org/x/sys | `cli/go.mod:7` v0.48.0 | `go.mod:23` v0.49.0 | 无 go.mod |
| github.com/sagernet/gomobile | `Dependencies.lock.json:11` v0.1.13 | `go.mod:14` v0.1.13 | 无。这两处版本相同 |

Clash 另外钉死 `swift-certificates` 1.9.0（`project.yml:30`）。仓库里没有 Clash 的 `Package.resolved`。

```powershell
& $rg -n -g 'Package.resolved' -A 6 'identity. : .swift-crypto|identity. : .swift-asn1|identity. : .swift-atomics' Clash-Client Swipt Feather
& $rg -n "exactVersion:" Clash-Client/apple/ClashClient/project.yml
& $rg -n "golang.org/x/sys|sagernet/gomobile" Clash-Client/cli/go.mod Clash-Client/Dependencies.lock.json Swipt/go.mod
```

### Feather 自己的两份锁文件

`Feather.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` 是 version 3。`Feather.xcworkspace/xcshareddata/swiftpm/Package.resolved` 是 version 2。直接依赖在 `Feather.xcodeproj/project.pbxproj`：vapor 4.104.0（522 行）、Nuke 12.8.0（530 行）、Zip 2.1.2（538 行）、SWCompression 4.8.7（546 行）。

两份锁文件版本不同的包（前者是 xcodeproj 那份，后者是 xcworkspace 那份）：

| 包 | xcodeproj resolved | xcworkspace resolved |
|---|---|---|
| routing-kit | 4.9.2 | 4.9.1 |
| swcompression | 4.8.6 | 4.8.7 |
| swift-asn1 | 1.3.2 | 1.3.1 |
| swift-http-structured-headers | 1.2.2 | 1.2.1 |
| swift-http-types | 1.4.0 | 1.3.1 |
| swift-metrics | 2.7.0 | 2.6.1 |
| swift-nio | 2.82.1 | 2.82.0 |
| swift-nio-extras | 1.26.0 | 1.25.0 |
| swift-nio-http2 | 1.36.0 | 1.35.0 |
| swift-nio-ssl | 2.30.0 | 2.29.3 |
| swift-nio-transport-services | 1.24.0 | 1.23.1 |
| websocket-kit | 2.16.0 | 2.15.0 |

`swcompression` 在 pbxproj 里是 exact 4.8.7，和 xcworkspace 锁文件一致，和 xcodeproj 那份锁文件的 4.8.6 不一致。

```powershell
& $rg -n -g 'Package.resolved' -A 6 'identity. : .swcompression|identity. : .routing-kit|identity. : .swift-nio[^a-z0-9-]' Feather
& $rg -n "version = " Feather/Feather.xcodeproj/project.pbxproj
```
