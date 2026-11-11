# 试过不行的做法

- 2026-11-11：`winget install --id Swift.Toolchain` 不带 `--skip-dependencies`。卡在依赖 Python.Python.3.10 3.10.11，错误 `0x80070020`（文件被占用）。同一条命令不再重试。
- 2026-11-11：给 git 带 `http.proxy=http://127.0.0.1:12348` 做 unshallow 和内核 fetch。端口没人听，四项都是 exit 128，约 2 秒失败。这条代理不再用。
- 2026-11-11：Windows 上的 Swift 6.4.2（`AppData\Local\Programs\Swift\Toolchains\6.4.2+Asserts`）跑不起来。`swift --version` 和 `swift-frontend --version` 退出码 `-1073741819`（访问冲突），并提示 `libSwiftScan` 不兼容。加上 `-nonlib-dependency-scanner` 后 `swiftc -parse` 退出码 1，输出 `jobFailedWithNonzeroExitCode(5, "")`。本机已有 VC++ 14.51。不再重装同一份 Windows 工具链，改走 WSL。
