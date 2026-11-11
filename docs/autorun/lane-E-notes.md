# 线 E 备忘

E1 swift test 退出码：0。主代理 2026-11-12 00:48 重跑：`Executed 3 tests, with 0 failures`。

非 macOS 只声明 OneUICore 与 OneUICoreTests。Linux 上 target path 是 `Sources`，exclude 界面目录和 Fonts，资源 `.copy("OneUI/Resources/Icons")`。macOS 分支保留 iOS 15 的 OneUI，并加上 OneUICore。现有 14 个界面文件未改。

E2 先红：`OneTokenFixtureTests` 引用尚未存在的 `OneTokenValue`，`swift test` 编译失败（`cannot find type 'OneTokenValue'`，`error: fatalError`）。实现 `Sources/OneUICore/Tokens/OnePalette.swift`、`OneTokens.swift`、`Glass.swift` 后全过：`Executed 4 tests, with 0 failures`，退出码 0。把 `Glass.radiusCard` 改成 19，`tokens.glass.radiusCard` 19≠18、`radiusHero` 23≠22，退出码 1，已改回。期望值从 `_golden/fixtures/tokens.json` 读，遍历每一个键；夹具多一个键时 Swift 目录缺该键，测试失败。未改 `Package.swift`，未改 14 个界面文件。最后一行：`✔ Test run with 0 tests in 0 suites passed after 0.001 seconds.`

主代理 2026-11-12 01:50 重跑：`Executed 4 tests, with 0 failures`，退出码 0。抽查：`Glass.radiusCard` 18、`radiusHero` 22、`strokeWidth` 0.8、`barAlpha` 0.86，与 `tokens.json` 的 `glass` 一致；浅色描边 alpha `0.5950`、深色 `0.1200`，浅色 primary `FF1A1B20`。往夹具根上加 `__probe: 1` 后，`OneTokenFixtureTests` 失败：`swift missing tokens.__probe`，退出码 1。撤掉后再跑，1 个测试通过，退出码 0。
