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

## Mac 上按 T2.6 做的步骤

第一行仍是「未在 Mac 上运行」。这一节只写步骤、要观察的东西、以及事后怎么写 `docs/decisions/G2-go-runtimes.md`。判断句不写在这里。那个决策文件现在不存在，这次也不新建。

2026-11-12 又打开过这些文件，行号如下。对不上的话以文件为准，不要沿用记忆。

- `Swipt/Frameworks` 路径不存在。`Swipt/Frameworks/LibSwipt.xcframework` 也不存在。`Swipt/.gitignore:2` 是 `/Frameworks/`。
- 生成路径在 `Swipt/internal/cmd/build_libswipt/main.go:21`：`outputPath = "Frameworks/LibSwipt.xcframework"`。`Swipt/Makefile:8-9` 的 `lib` 目标执行 `go run ./internal/cmd/build_libswipt`。工程引用在 `Swipt/Swipt.xcodeproj/project.pbxproj:30`，`path = LibSwipt.xcframework`。本次没有跑 `make lib`。
- `Clash-Client/apple/ClashClient/project.yml` 未改。`ClashiOS` 在 `:38`，`type: application` 在 `:39`，`dependencies:` 在 `:144`。`:155-156` 是 `target: Clash` 与 `embed: true`。`Clash` target 名在 `:163`，`type: framework` 在 `:164`，`platform: iOS` 在 `:165`。`CLASH_CORE_ARCHIVE` 在 `:185`，`OTHER_LDFLAGS` 的 `-Wl,-force_load` 在 `:186-187`。拷头脚本在 `:189-195`，头文件名包括 `ref.h` 和 `Universe.objc.h`。`ClashiOSExtension` 在 `:201`，`type: app-extension` 在 `:202`，`:258-260` 是 `target: Clash` 与 `embed: false`。
- `Swipt/libswipt/device.go:1` 是 `package libSwipt`。`:71` 是 `type LoopbackProbe`。`:77` 是 `func NewLoopbackProbe(remotePairingPort int32) *LoopbackProbe`。盘上没有 gomobile 生成的头，所以总计划 `:741` 的 `LibSwiptNewLoopbackProbe` 只是计划要调的名字。

不要把 `SwiptCore` 写进当前这份 `project.yml`。总计划 `:740` 的临时分支是实验当天在 Mac 上开的。本草稿不附可粘贴的 target 正文。

1. 先有产物，再做实验。在 Mac 上按 T2.4 让 `scripts/mac/30-swipt.sh` 跑到 `make lib`（该脚本开头仍是「未在 Mac 上运行」，并且不要跑 `git submodule update`）。产物应出现在 `Swipt/Frameworks/LibSwipt.xcframework`。产物还没有时，停在这一步，不要改 `project.yml`。
2. 对这个文件运行 `file`，路径相对仓库根：`Swipt/Frameworks/LibSwipt.xcframework/ios-arm64/LibSwipt.framework/LibSwipt`。把命令的整行输出抄下来。总计划 `:739` 要按这一行决定下一步怎么包；这一行现在还没有，草稿不替它选。
3. 在 Clash-Client 的临时分支上，仿照上面核对过的 `Clash` target（`:163-195`）加计划中的 `SwiptCore`，并让 `ClashiOS` 依赖且嵌入。`ClashiOSExtension` 按总计划 `:744` 不加对 `SwiptCore` 的依赖。做完把该分支的 diff 留在实验分支上，不要合进当前工作树的 `project.yml`。
4. 在 App 启动路径上调一次计划中的 `LibSwiptNewLoopbackProbe`（`:741`），对应 Go 函数是 `device.go:77` 的 `NewLoopbackProbe`。同时照常走 Clash 的配置校验。记下调用是否返回，以及返回前后的日志。
5. 观察下面各项，原样保留日志，不在本草稿里归纳成一句判断：
   - 链接日志里有没有重复符号错误（总计划 `:742` 的第一条）。
   - 启动是否崩溃。
   - Clash 能否连接；上一步的探测有没有返回。
   - 两者同时活跃时连续 30 分钟的过程日志。
   - 控制台里 `Class GoSeqRef is implemented in both` 这类句子，有就整段照抄（`:743`；两个框架都会带 gomobile 的 `ref.h` 和 `Universe.objc.h`，见 `project.yml:194`）。
   - Instruments 里扩展进程加载的镜像名单，标出有没有 `SwiptCore`（`:744`）。
   - 主 App 内存占用增量，以及安装包体积增量（`:745`）。

### 怎样写入决策文件

只在 Mac 上贴完上面的日志之后，新建 `docs/decisions/G2-go-runtimes.md`。不要用本草稿代替它。

- 第一行写实验日期、Mac 机器、Clash-Client 临时分支名、当时的 Swipt 提交，并写明已在 Mac 上运行。
- 接着贴 `file` 的整行，再按下面空表逐项贴日志。右列留到实验当天再填。总计划 `:742` 到 `:746` 的用词只在该文件里、在日志齐了之后填写。

| 观察 | 贴上的日志 | 实验当天填写 |
|---|---|---|
| `file` 整行 | | |
| 链接 | | |
| 启动 | | |
| Clash 连接 | | |
| 探测返回 | | |
| 30 分钟 | | |
| 控制台警告原文 | | |
| 扩展进程镜像名单 | | |
| 内存增量 | | |
| 安装包体积增量 | | |

- `:746` 要求：清单里有一条不满足时，把具体报错贴在这个决策文件里。满足与否由当次实验填写。本草稿不填。
