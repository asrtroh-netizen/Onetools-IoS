# OneTools 三合一宿主沙盒目录与键空间所有权边界（H4）

为确保 `Clash-Client`、`Swipt` 与 `Feather` 在单一 iOS 宿主应用进程中互不误删文件、互不污染偏好设置，统一规定并由 `tools/audit_cross_module_seams.py` 自动化门禁强制校验以下隔离边界：

| 存储域 | Clash-Client（宿主与隧道） | Swipt（`ONETOOLS_EMBEDDED`） | Feather（`ONETOOLS_EMBEDDED`） | 重置/清理保护策略 |
|---|---|---|---|---|
| **App Group 共享容器** | `group.<resolved-bundle-id>/`（免签 Lite 档自动降级至 `Application Support/OneToolsLocalAppGroup/`） | 仅读取 `AppGroupIdentifier`（macOS 分支） | 不占用 App Group | 动态解析签名内嵌 `0xfade7171` 权限块，兼容 SideStore / Sideloadly / 个人证书改名 |
| **`Library/Application Support/`** | 宿主回退目录 `OneToolsLocalAppGroup/` | 专属子目录 `Application Support/Swipt/`（含 `PairingRecord.plist` 与 Swiplet 运行库） | Core Data 默认存储 `Feather.sqlite` / `-wal` / `-shm` | `Swipt` 执行 `AppDirectory.reset()` 仅清理 `Application Support/Swipt/`，绝不触碰 `Feather.sqlite` |
| **`Documents/`（文件共享可见）** | 配置文件走 App Group 容器 | 不直接散落根文件 | `Documents/{Archives,Signed,Unsigned,Certificates}` | 目录名互不重叠，支持 iOS「文件」应用直读 |
| **`Library/Caches/`** | 系统网络与常规缓存 | 专属子目录 `Caches/Swipt/`（含 `IncomingSwiplets/`） | `thewonderofyou.Feather.datacache`（上限 `150 MiB`） | 各自仅清理自有子目录与命名缓存实例 |
| **`tmp/`（临时工作区）** | 订阅拉取与内核临时解包文件 | 仅使用 `Caches/Swipt/IncomingSwiplets/` | 统一使用 `Feather*` 前缀（`FeatherImport_`、`FeatherSigning_`、`FeatherInstall_`、`FeatherTweak_`、`FeatherDownloads`、`FeatherCert_`、`FeatherCertInbox`） | `ResetView.clearWorkCache()` 强制过滤 `file.hasPrefix("Feather")`，严禁无差别清空根 `tmp/` |
| **`UserDefaults.standard`** | `onetools.shell.enabled` 等宿主键 | `AppleLanguages` 及 Swipt 内部键 | 全部以 `Feather.` 或 `feather.` 为前缀 | `ResetView.resetUserDefaults()` 内嵌模式下仅移除 `Feather.` / `feather.` 前缀键 |
