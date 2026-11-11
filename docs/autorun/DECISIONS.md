# 执行中的决定

| 时间 | 选了什么 | 依据 | 怎么回退 |
|---|---|---|---|
| 2026-11-11 | 不等 Cursor 的 stop 钩子，在这次 MiMo 对话里连续做第 0 轮。钩子文件留在 `C:\Users\Administrator\.cursor\` | 你说「我们就在mimo里面做」。计划 2.2：钩子结束后留在原处 | 下一次回合结束仍可以让已装的钩子续跑 |
| 2026-11-11 | 下载进程单独带 `http.proxy` / `https.proxy` = `http://127.0.0.1:12348`，不改全局 git 配置 | 注册表里系统代理已开，`ProxyServer=http://127.0.0.1:12348`。计划 R0-1 补充：只给本次进程设代理 | 去掉这两项参数就是直连 |
| 2026-11-11 | `ow_icons.txt` 用本机已有的 `C:\Users\Administrator\AppData\Local\OpenAI\Codex\bin\a7d4c4900eafc659\rg.exe`，参数与计划命令相同 | `rg` 不在 PATH 里。计划 4.3 不允许另装软件 | 以后 PATH 里有 `rg` 时，改回计划里的命令 |
| 2026-11-11 | `.gitignore` 比计划多一行 `/.mimocode/` | 那里是桌面工具的锁和计划任务，不是工程内容。首次提交时已经这样 | 从 `.gitignore` 删掉该行再提交 |
| 2026-11-11 | R0-6 的过程日志写在 `.mimocode/r0-6-logs/`，不进仓库 | 同一条忽略规则。结论只记进 `STATE.md` | 把日志拷进 `docs/autorun/` |
| 2026-11-11 | 下载改直连，不再带 `127.0.0.1:12348` | 现在注册表 `ProxyEnable=0`，`ProxyServer=127.0.0.1:18090`，18090 和 12348 都没有进程在听。计划：不改系统代理 | 代理重新听口之后，只给单次进程设 `HTTPS_PROXY` |
| 2026-11-11 | Swift 用 `winget install --id Swift.Toolchain` 加 `--skip-dependencies` | 计划里的原命令在装依赖 Python 3.10 时因 0x80070020 失败。本机已有 Python 3.14.6。安装包仍是 swift.org 的 6.4.2 | 卸掉该 Swift，改回带依赖的 winget 命令 |
| 2026-11-11 | 内核锁定版改从 GitHub API 取 zipball，不走 `git fetch` github.com | `api.github.com` 返回 302，`github.com:443` 超时。计划：单个文件走 API。目标仍是提交 `4b7d5f53cff448f01cd5012b5e3f7eddc7d43e33` | github.com 通了就改回计划里的 `git fetch --depth 1` |
| 2026-11-11 | Windows 版 Swift 崩溃后，在已有的 WSL `Ubuntu-24.04` 里装 Swift 6.4.2 官方压缩包 | 计划 R0-7：Windows 版跑不了测试才用 WSL。`download.swift.org` 的 ubuntu2404 包头返回 200 | 卸掉 `/opt/swift`，以后只在 Windows 工具链能跑 `swift test` 时改回去 |
