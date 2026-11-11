# SP-07 Feather（总计划 5.2）

未在 Mac 上运行。

5.2 的勾选项都还没做。子模块结论在 `docs/findings/submodules.md`。这份计划只把已经打开源文件核对过的部分摘进来。

## 已核对

- `Clash-Client/apple/ClashClient/project.yml` 里搜 `FeatherUI` 没有命中。Feather 还没进宿主工程。
- Zsign 要现编。`Feather/Zsign/Package.swift:39-53` 列了 C++ / Objective-C++ 源，`:65-74` 的 `Zsign` target 是 Swift 源。整份 `Package.swift`（76 行）没有 `binaryTarget`。`docs/findings/submodules.md:13` 写明给 Feather 用要现编这些源。`:11` 写明盘上没有 `bin/`，也没有名为 `zsign` 的可执行文件。
- 独立 CLI 的命令在 `Feather/Zsign/README.zh-CN.md`，本次没跑。macOS 是 `:51-54`（另 clone `zhlynn/zsign`，再 `make clean && make`）。Ubuntu / Debian 是 `:62-65`。RHEL 系是 `:73` 和 `:79-82`。Windows 是 `:87`，打开 `build/windows/vs2022/zsign.sln`。这些命令写的是再 clone，本次没执行。
- Feather 工程把 Zsign 当本地包：`Feather/Feather.xcodeproj/project.pbxproj:512` 是 `relativePath = Zsign`。同一段里 `:504` 是 `IDeviceKitten`，`:508` 是 `AltSourceKit`，`:500` 是 `NimbleKit`。
- IDevice 是 `binaryTarget`。`Feather/IDeviceKitten/Package.swift:21-24`：名字 `IDevice`，URL 是 `https://github.com/jkcoxson/idevice/releases/download/v0.1.57/IDevice.xcframework.zip`，checksum 是 `40cd5c769b60d1879a96c9caa27666037f9d5321844addec40ae99727b142d10`。`:26-29` 的 `IDeviceSwift` 是源码 target，依赖 `IDevice`。`README.md` 只有第 1 行标题，没有编译命令。`docs/findings/submodules.md:30-32`：没有 `Cargo.toml`，没有 xcframework，上述 zip 不在盘上，不在本目录现编 Rust。
- `scripts/mac/35-feather.sh:2` 是「未在 Mac 上运行」。`:4` 仍写撰写时 Zsign 和 IDeviceKitten 是空目录。`:10` 只做 `git submodule update --init --recursive`。`:12` 打印「先读 Zsign/README 和 IDeviceKitten/README 再编译」。已读的 `:1-20` 没有编译命令，也没调用 `make`。脚本没在 Mac 上跑。当前目录是 zipball 副本，见 `docs/findings/submodules.md:3`，与脚本第 4 行的旧句子不是同一天的盘面。
- 证书下载在上游 Makefile 里，本次没跑。`Feather/Makefile:6` 是 `https://backloop.dev/pack.json`。`:12-15` 的 `clean` 会删 `$(TMP)`、`packages`、`Payload`。`:17-23` 的 `deps` 会删 `deps` 并用 `curl` 取这份 JSON，再写出 `server.crt` 和 `server.pem`。运行时会不会自己更新证书，还没查。

## 还没做

- `FeatherUI` 没进宿主 `project.yml`。远程包 Nuke、Zip、SWCompression、Vapor 没在宿主里声明。
- `FeatherApp.swift` 的 `@main` 没去，`FeatherRootView` 没接进外壳。
- 文档类型和 URL scheme 没并进宿主 Info.plist。
- 直装通道用哪种配对、地址写在哪，要等 IDevice 的预编译包落地之后再确认。这次没下载那个 xcframework zip，也没编译 Zsign。
- 合并后导入证书、签 IPA、装上并打开，这一步没做。
