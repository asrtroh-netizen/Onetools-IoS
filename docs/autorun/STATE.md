# OneTools 12 小时自动执行 · 状态

- 起点：2026-11-11 18:00:13 +08:00（发车检查通过、计时 armed）
- 截止：2026-11-12 06:00:13 +08:00（unix 1794434413）
- 续跑上限：40
- 当前阶段：第 0 轮。钩子已安装并完成 10.3 四条离线测试。本回合在 R0-2 之后结束，用来实测 Cursor stop 钩子。
- 下一动作：续跑消息到达后，从 R0-3 接着做，做到 R0-9。不要在 R0-9 完成之前派发五路子代理。

## 第 0 轮

| 编号 | 状态 | 证据 |
|---|---|---|
| R0-1 | 已验证 | `curl.exe` 访问 `https://raw.githubusercontent.com/flutter/flutter/master/README.md` 返回 `200`（1.01s）；`$env:USERPROFILE\.cursor\afk\ACTIVE` 在发车前不存在；E 盘剩余 665.04 GB |
| R0-2 | 已验证 | `hooks.json` 与 `hooks\afk-loop.py` 已写入。临时目录四条离线测试全部符合预期（未启动 `{}`、armed、已启动含 `followup_message`、别的对话 `{}`、过期输出 `{}` 且出现 `PAUSE`）。真计时 `python afk-loop.py --arm 12` 输出 `armed: deadline=1794434413 max_loops=40` |
| R0-3 | 待做 | 六个仓库 `core.filemode false`、`core.autocrlf false` |
| R0-4 | 待做 | 顶层 git init 与「执行前的现状」提交 |
| R0-5 | 待做 | Clash-Client、Swipt、Feather 建 `onetools` 分支 |
| R0-6 | 待做 | 后台 unshallow、子模块、内核锁定版 |
| R0-7 | 待做 | 安装 Swift 6.4.2 并冒烟 |
| R0-8 | 待做 | Material 源码快照、`_ref/NOTES.md`、`_ref/ow_icons.txt` |
| R0-9 | 待做 | `tools/gates.py` 与完整状态文件 |

## 五条线

都还没派发。队列保持计划第 7 节的原顺序。

| 线 | 队列 | 现状 |
|---|---|---|
| A 基准线 | A1–A11 | 未开始 |
| B Clash 线 | B1–B4 | 未开始 |
| C 调研线 | C1–C6 | 未开始 |
| D 规则线 | D1–D4 | 未开始 |
| E OneUI 线 | E1–E3 | 未开始 |

## 下载（R0-6）

未开始。
