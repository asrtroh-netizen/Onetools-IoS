# 线 E 备忘

E1 swift test 退出码：0。主代理 2026-11-12 00:48 重跑：`Executed 3 tests, with 0 failures`。

非 macOS 只声明 OneUICore 与 OneUICoreTests。Linux 上 target path 是 `Sources`，exclude 界面目录和 Fonts，资源 `.copy("OneUI/Resources/Icons")`。macOS 分支保留 iOS 15 的 OneUI，并加上 OneUICore。现有 14 个界面文件未改。
