# 子模块快照（C3）

2026-11-12 只读清点。三个目录是 zipball 副本，登记仍在各自的 `.gitmodules` 里。盘上没有 `.git`（三处 `Test-Path` 均为 false）。没有跑 `git submodule update`，没有编译，没有下载，没有执行目录里的脚本。文件数用 `Get-ChildItem -Recurse -Force -File`（含点文件），与主代理 2026-11-12 02:50 的 247 / 25 / 6 一致，字节数与 `.mimocode/r0-6-submodules-ready.txt` 第 2–4 行一致。提交号只写在 `.mimocode/r0-6-*-ready.txt` 的 zip URL 里；本目录没有 `.git`，这次没有重下 zip，树内对不上那个提交。

## Zsign

路径 `Feather/Zsign`。`Feather/.gitmodules:1-4`：`path = Zsign`，`url = https://github.com/khcrysalis/Zsign-Package`，`branch = package`。

是什么：跨平台 iOS 重签名工具。`Feather/Zsign/README.md:11` 写明它是 iOS 12+ 的开源跨平台 `codesign` 替代。同一棵树还是 Swift 包：`Package.swift:7` 包名 `Zsign`，产品 `zsignc`（`:17`）和 `Zsign`（`:21`）。C++ / Objective-C++ 源列在 `Package.swift:39-53`，排除 `src/zsign.cpp`（`:37`）。Feather 工程把它当本地包：`Feather/Feather.xcodeproj/project.pbxproj:512` 的 `relativePath = Zsign`，产品名 `Zsign`（`:575`）。

盘上：247 个文件，29 个目录，73,644,372 字节。没有 `bin/`（`Test-Path` 为 false），没有名为 `zsign` 的可执行文件。体积大头是已在树里的 `build/windows/vs2022/lib/openssl/x64/mt/libcrypto.lib`（57,184,898 字节）和 `libssl.lib`（12,535,234 字节）。另有 `test/dylib/bin/demo1.dylib`、`demo2.dylib`（各 51,296 字节）。README 没写这两份 `.lib` 要不要再编。

要不要现编：给 Feather 用要现编这些源，不是拿盘上的成品库。`Package.swift` 没有 `binaryTarget`。README 另写了一条独立 CLI，本次没跑。中文命令在 `Feather/Zsign/README.zh-CN.md`：

- macOS `:51-54`：`brew install pkg-config openssl`，然后 `git clone https://github.com/zhlynn/zsign.git`，`cd zsign/build/macos`，`make clean && make`。英文同段在 `README.md:50-53`。
- Ubuntu / Debian `:62-65`：`sudo apt-get install -y git g++ pkg-config libssl-dev`，同样 clone，`cd zsign/build/linux`，`make clean && make`。英文 `README.md:61-64`。
- RHEL 系 `:73` 为 `sudo yum -y install epel-release`，`:79-82` 安装 gcc-c++、pkg-config、openssl-devel 后同样 clone 和 `make clean && make`。英文 `README.md:72` 与 `:78-81`。
- Windows `:87`：用 Visual Studio 2022 打开 `build/windows/vs2022/zsign.sln` 再构建。该 sln 在目录里。英文 `README.md:86`。

这些命令写的是再 clone `zhlynn/zsign`，不是「就在当前目录 make」。当前树里有 `build/macos/Makefile` 和 `build/linux/Makefile`。`build/macos/Makefile:8-9` 用 `pkg-config` 找 OpenSSL；`:2` 是 `-std=c++11`。Swift 包是另一套：`Package.swift:26` 依赖 `https://github.com/krzyzanowskim/OpenSSL`（from 3.3.3001），`:59` 是 `-std=c++17`。这份快照的 README 没有写 `swift build`。`Makefile:14-18` 用 `git describe` 取版本，取不到则为 `0.0.0-dev`。本目录没有 `.git`。

许可：`LICENSE:1` 为 “MIT License”，`:3` 为 “Copyright (c) 2026 zhlynn”。`README.md:263` 为 “zsign is licensed under the MIT License.” `README.zh-CN.md:4` 的徽章链到 LICENSE。

## IDeviceKit（目录名 IDeviceKitten）

路径 `Feather/IDeviceKitten`。`Feather/.gitmodules:5-7`：`path = IDeviceKitten`，`url = https://github.com/khcrysalis/IDeviceKit`。这份 `.gitmodules` 没有 `branch` 行。

是什么：`README.md:1` 只有 “# IDeviceKit”，没有别的说明。`Package.swift:5` 包名 `IDeviceKit`。产品 `IDevice`（`:12-13`）和 `IDeviceSwift`（`:16-17`）。`IDevice` 是 `binaryTarget`（`:21-24`），URL 为 `https://github.com/jkcoxson/idevice/releases/download/v0.1.57/IDevice.xcframework.zip`，checksum 为 `40cd5c769b60d1879a96c9caa27666037f9d5321844addec40ae99727b142d10`。`IDeviceSwift` 是源码 target（`:26-29`），`Sources/IDeviceSwift/Heartbeat/Heartbeat.swift:11` 为 `import IDevice`。Feather 本地包：`project.pbxproj:504` 的 `relativePath = IDeviceKitten`，产品名 `IDeviceSwift`（`:588`）。

盘上：25 个文件，13 个目录，46,693 字节。没有 `Cargo.toml`，没有 xcframework，没有上述 zip。`.gitignore:1-93` 是 Xcode 模板，没有写 xcframework。

要不要现编：这份快照里没有 Rust 源，README 没有编译命令，所以不在本目录现编 Rust。`IDevice` 按 `Package.swift` 是远程预编译包，预编译文件不在盘上。`IDeviceSwift` 是 Swift 源，随引用方编译；它 import 的 `IDevice` 不在这 25 个文件里。本次没有解析包，没有下载。

许可：`LICENSE:1` 为 “MIT License”，`:3` 为 “Copyright (c) 2025 khcrysalis”。README 没有许可句。

## DeveloperDiskImage

路径 `Swipt/Swipt/Resources/DeveloperDiskImage`。`Swipt/.gitmodules:1-3`：`path = Swipt/Resources/DeveloperDiskImage`（相对 Swipt 仓库），`url = https://github.com/swipt-automation/DeveloperDiskImage.git`。没有 `branch` 行。

是什么：`README.md:3` 写明这是 Swipt 挂到设备上的 iOS Developer Disk Image，只有 cryptex 变体。`:5` 写来自 Xcode 27.2（DDI build 27B52），个性化变体和 `Restore.plist` 留在外面，资源改成固定的 `Image.dmg*` 文件名。`:7` 写更新方法是换成更新 Xcode 的文件并在这里记下版本。使用处：`Swipt/Swipt/Platform/Platform.swift:88` 把包内资源目录 `DeveloperDiskImage` 赋给 `diskImageDirectory`。

盘上：6 个文件，0 个子目录，18,046,187 字节。`BuildManifest.plist` 804,156；`Image.dmg` 17,239,040；`Image.dmg.cryptex_info` 428；`Image.dmg.root_hash` 229；`Image.dmg.trustcache` 1,851；`README.md` 483。没有 `Restore.plist`。这份快照里没有 Makefile、Package.swift、脚本。

要不要现编：不编。README 只写替换文件（`:7`），没有编译命令。

许可：这份快照里没有 LICENSE。README 第 1–7 行没有许可句。
