未在 Mac 上运行

# G2 双 Go 运行时：工程配置草稿

这份草稿只放在 `docs/drafts/g2-go-runtimes.md`。不进 Clash-Client 分支，不改 `Clash-Client/apple/ClashClient/project.yml`。没有编译，没有下载，没有跑 `make lib`。总计划 `:740` 写的是实验当天在 Clash-Client 开一条临时分支；那一步还没做。

结论以后要贴进 `docs/decisions/G2-go-runtimes.md`（总计划 `:746`）。那个文件现在不在。本文不是结论。

## 总计划：共存还是冲突

G2 还没有结论。`docs/superpowers/plans/2026-11-11-onetools-ios-master-plan.md` 要的是一次实验，结果在共存（A）和冲突（B）里面取一个。

- `:283` 闸门：`G2 | 双 Go 运行时实验有结论：共存（A）或冲突（B） | P5 的 Swipt 路线`。
- `:737` 标题：`T2.6 双 Go 运行时实验（G2）`。
- `:214`：扩展进程里只有 Clash 一个 Go 运行时，这一点从工程配置读；主 App 里两个运行时能不能稳定共存，靠 G2。
- `:212` 是计划里的预期，不是本次实测：LibSwipt 照 `Clash` 的做法包进自己的框架时，链接期不会撞符号。运行期观察点是两个镜像里同名的 ObjC 类（gomobile 的 `ref.h` 和 `Universe.objc.h`）。
- `:742` 「共存（A）」要同时满足：链接无重复符号错误；启动无崩溃；Clash 能连、Swipt 探测能返回；两者都活跃时跑 30 分钟无崩溃；控制台里即使有 ObjC 类重复的警告也没有功能异常。
- `:743`：有 `Class GoSeqRef is implemented in both …` 这类警告就原样记下。
- `:744`：用 Instruments 看扩展进程里加载的镜像，预期没有 `SwiptCore`。
- `:745`：记主 App 的内存占用增量和安装包体积增量。
- `:746`：任一条不满足即为「冲突（B）」，具体报错贴进 `docs/decisions/G2-go-runtimes.md`。
- 结论之后的分叉在 P5，本次不做：`:844` 共存（A）才把 `SwiptCore`、`SwiptUI` 正式写进 `project.yml`；`:854` 冲突（B）时按代价从低到高三条路，文本在 `:856`–`:858`（合成一次 gomobile、Swipt 保持独立 App、改掉冲突的 Go 实现）。

## 盘上没有 LibSwipt 产物

没有 `LibSwipt.xcframework`，也没有同名二进制。本次没编过。

- 全仓库按 `LibSwipt*` 搜，零个文件。
- `Swipt` 下按 `*.xcframework` 搜，零个文件。`Swipt/Frameworks` 读取结果是路径不存在。
- 工程里只有引用：`Swipt/Swipt.xcodeproj/project.pbxproj:30` 是 `path = LibSwipt.xcframework`；`:126`–`:132` 组名 `Frameworks`，`path = Frameworks`。
- 生成命令写在源里，本次没跑：`Swipt/Makefile:8`–`:9` 的 `lib` 目标执行 `go run ./internal/cmd/build_libswipt`；`Swipt/internal/cmd/build_libswipt/main.go:21` 是 `outputPath = "Frameworks/LibSwipt.xcframework"`；`:55` 把 `-o` 指到这个路径。
- `Swipt/.gitignore:2` 是 `/Frameworks/`。忽略规则在，目录本身不在。
- CI 声明的缓存路径是 `Frameworks/LibSwipt.xcframework`（`Swipt/.github/workflows/build.yml:98`）。本机没有这个路径。

总计划 `:739` 要先对 `LibSwipt.xcframework/ios-arm64/LibSwipt.framework/LibSwipt` 跑 `file`：是 `current ar archive` 就包一层，已经是动态库就直接嵌入。产物不在，这一步做不了。草稿不假设它是静态库还是动态库。

## project.yml 里看到的 Clash 键

文件 `Clash-Client/apple/ClashClient/project.yml` 未改。依赖名 `Clash` 的地方只有两处：`:155` 和 `:259`。

`Clash` target（`:163`–`:164`，`:165`）：

```yaml
type: framework
platform: iOS
```

同一 target 的链接键（`:185`–`:187`）：

```yaml
CLASH_CORE_ARCHIVE: $(SRCROOT)/../../Clash.xcframework/$(CLASH_CORE_SLICE)/Clash.framework/Clash
OTHER_LDFLAGS:
- -Wl,-force_load,$(CLASH_CORE_ARCHIVE)
- -lresolv
```

`:189`–`:195` 的 `preBuildScripts` 名字是 `Copy the Go core's public headers out of the locked xcframework`。`:194` 拷贝的头文件是 `ref.h`、`Clash.objc.h`、`Universe.objc.h`、`Clash.h`。

嵌入方式：

- `ClashiOS`（`:38`，`type: application` 在 `:39`）的 `dependencies:`（`:144`）里，`:155`–`:156`：

```yaml
- target: Clash
  embed: true
```

- `ClashiOSExtension`（`:201`，`type: app-extension` 在 `:202`）的 `dependencies:`（`:258`）里，`:259`–`:260`：

```yaml
- target: Clash
  embed: false
```

这两个键对得上总计划 `:207` 的原文：主 App 嵌入（`embed: true`），Packet Tunnel 扩展链接（`embed: false`）。

## 实验要新增的 target、依赖、探测函数

以下都从总计划抄。写在草稿里，不写进 `project.yml`，不进 Clash-Client 分支。

- 要新增的 target 名：`SwiptCore`。`:193` 表里它是动态框架，照 `Clash` target 的做法包 `LibSwipt.xcframework`。`:740` 写明仿照 `Clash`：`type: framework`，静态库时 `OTHER_LDFLAGS` 用 `-Wl,-force_load` 指向静态库，再加一个拷头文件的脚本。
- 依赖：`:740` 让 `ClashiOS` 依赖并嵌入 `SwiptCore`（对应现在 `Clash` 的 `embed: true`）。`:207` 写 Swipt 的 Go 代码只在主 App 里用。`:744` 预期扩展进程的镜像里没有 `SwiptCore`，所以实验配置里 `ClashiOSExtension` 不加对 `SwiptCore` 的依赖。
- `:739` 的分支还没法选：静态库走 `:740` 的 `type: framework` 加 `-Wl,-force_load`；动态库则直接嵌入。指向的路径按 `:739` 是 `LibSwipt.xcframework/ios-arm64/LibSwipt.framework/LibSwipt`。头文件名单计划没有逐个写，草稿不补。计划点名的重复类观察点是 `ref.h` 和 `Universe.objc.h`（`:212`、`:743`）。
- 要调的探测函数名：`:741` 的 `LibSwiptNewLoopbackProbe`。在 App 启动时调一次，同时照常走 Clash 的配置校验。
- Go 源里对应的是 `Swipt/libswipt/device.go:1` 的 `package libSwipt`，以及 `:77` 的 `func NewLoopbackProbe(remotePairingPort int32) *LoopbackProbe`。类型在 `:71`。没有 xcframework，也没有看到 gomobile 生成的头，所以 `LibSwiptNewLoopbackProbe` 只是计划 `:741` 要调的名字，不是盘上已经存在的符号。

`SwiptUI` 写在 `:194` 和 `:846`，归 P5，等 G2 结论是共存（A）再进 `project.yml`。这份实验草稿要新增的 target 只有 `:740` 的 `SwiptCore`。
