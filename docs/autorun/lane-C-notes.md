# 线 C 备忘

C4、C5 在 2026-11-12 落盘。C1、C2、C3 的下载没做。C6 没做。没有 git 写操作，没有改 Swipt 和 Feather 的源码。

## 决定

- `TEAM_ID` 和 `BUNDLE_BASE` 只从环境变量读。缺了 `scripts/mac/20-clash-client.sh` 就退出并打印缺哪个。不写死 Team ID。依据：总计划 T2.2 的 `--bundle-base` / `--team`，以及 `Clash-Client/scripts/configure.py` 第 12–19 行。空字符串也算缺，因为本脚本要求调用方显式传入。
- `20-clash-client.sh` 不调用 `xcodebuild`。`configure.py` 自己会跑 `xcodegen` 和 `build_cli.py` 的 `go build`，这是 T2.2 的步骤，保留。
- `35-feather.sh` 不写编译命令。`Feather/Zsign` 和 `Feather/IDeviceKitten` 是空目录，README 不在本机。脚本只 `git submodule update --init --recursive`，然后 echo「先读 Zsign/README 和 IDeviceKitten/README 再编译」。
- `40-verify-windows-work.sh` 里 ClashLogic 的预期命令是 `swift test`。OneUI 的预期命令是总计划 P4 的两条 `xcodebuild`。`swift test --package-path OneUI` 留作对照。撰写时 `OneUI/Package.swift` 只有 iOS 15，没有测试 target。
- 并入清单的数字都来自本机 `rg`。三个子模块目录为空，写成「未初始化」，不编文件数。

## 没在本次改的

- `scripts/mac/10-env.sh` 已有「未在 Mac 上运行」，原样保留。它在系统 Python 上检查 PyYAML，失败会退出；提示指向 20 号脚本的 venv。
- 上游 `Feather/Makefile` 的 `clean` / `deps` 会删目录，并从 backloop.dev 下载证书。35 号脚本不调用 `make`。

## 结论（2026-11-12 重跑）

仓库根：`E:\GQ\Ultra\Onetools-IoS`。`$rg` 是 `C:\Users\Administrator\AppData\Local\OpenAI\Codex\bin\a7d4c4900eafc659\rg.exe`。

- C4：主代理已用 Git bash `-n` 检过 `scripts/mac/10-env.sh`、`20-clash-client.sh`、`30-swipt.sh`、`35-feather.sh`、`40-verify-windows-work.sh`，五个退出码都是 0。脚本没在 Mac 上跑。
- C5 `Bundle.main`：`-c` 各行数字相加是 58（44 个文件：Clash-Client 20、Swipt 22、Feather 16）。`VPNController.swift` 三处现在是 986、1104、2664。
- C 类补上的命令（标识 / 日志 / 路径 / 本地化）重跑 36 行。扣掉归 B 或 D 的 4 行后是 32。
- B 类收紧后：`Bundle.main.url/path(forResource:)` 加 `bundleURL.appendingPathComponent` 是 10 行；`let configURL = Bundle.main.url(` 另有 2 行。合计 12。
- 文档类型命令命中 Swipt `.swiplet`、Feather `.ipa` 与 `.tipa`、Clash `public.yaml`（`project.yml:113` 和 `:118`）。`:371` 是分享扩展激活规则。
- 顶层同名类型命令 8 行：`AppDelegate`、`AppLanguage`、`HomeView`、`SettingsView`。
- 版本：swift-crypto Clash 3.15.1 / Feather 3.12.3；swift-asn1 Clash 1.7.3 / Feather 1.3.2 与 1.3.1；swift-atomics Swipt 1.3.1 / Feather 1.2.0；`golang.org/x/sys` Clash cli v0.48.0 / Swipt v0.49.0；gomobile 两边都是 v0.1.13。
- 子模块 `Feather/Zsign`、`Feather/IDeviceKitten`、`Swipt/Swipt/Resources/DeveloperDiskImage` 仍是空目录，未初始化。C1、C2、C3 没做。

主代理 2026-11-12 00:52 重跑：五个 `bash -n` 退出码 0；`Bundle.main` 各文件计数相加 58；三个子模块目录文件数为 0。`40-verify-windows-work.sh` 里关于 OneUI 没有测试 target 的句子已改成和 E1 之后的 `Package.swift` 一致。脚本仍未在 Mac 上运行。
