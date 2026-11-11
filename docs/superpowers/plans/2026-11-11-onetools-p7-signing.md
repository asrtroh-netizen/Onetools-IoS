# SP-09 自签（总计划 P7）

未在 Mac 上运行。

日期计算和批处理失败隔离已经在本机跑过。真机通知、读证书到期日、一键重签、装机，都还没做。

## 已核对

- 纯逻辑在 `SigningLogic/`。`SigningLogic/Package.swift:4-12` 没有外部依赖，只有 target `SigningLogic` 和测试 target。
- 源码只引入 Foundation：`SigningLogic/Sources/SigningLogic/ExpiryReminderPlanner.swift:1`，`Batch.swift:1`。没有通知框架，也没有证书解析。
- 提前 7 天和提前 1 天各一条，其余不发。`ExpiryReminderPlanner.swift:56-57` 在日历日相差为 7 时返回 `.sevenDays`，`:59-60` 相差为 1 时返回 `.oneDay`，`:62` 其余返回 nil。已过期（相差为负）和当天到期（相差为 0）都走 `:62`，不发。
- 对应测试：`SigningLogic/Tests/SigningLogicTests/ExpiryReminderTests.swift:18` 正好 7 天一条，`:25` 正好 1 天一条，`:32` 已过期不发，`:42` 当天不发，`:49` 提前 6 天不发。另有 `:56`、`:67`、`:74`、`:85`。共 9 个测试。
- 单个失败不影响其余。`Batch.swift:43-49` 逐个调用，`catch` 之后继续下一个。测试 `SigningLogic/Tests/SigningLogicTests/BatchTests.swift:6`、`:15`、`:31`、`:40`，共 4 个。
- 两个文件合计 13 个测试。`docs/autorun/lane-E-notes.md:11`：实现后 `Executed 13 tests, with 0 failures`，退出码 0。把提前 7 天改成 6 天后是 13 个测试、4 个失败，已改回再跑，仍是 0 失败。同一行写明：只比日历日，不解析证书，不发通知。
- 本机 `swift test` 的工具链记录是 WSL `Swift version 6.4.2 (swift-6.4.2-RELEASE)`，见 `docs/autorun/STATE.md:19`。

## 还没做

- 真机本地通知没做。包里没有排程、授权或投递通知的代码。
- 读证书和描述文件的到期日没做。现在的入口是调用方传进来的 `Date`（`ExpiryReminderPlanner.swift:4-5`）。
- 一键重签没做。批量签名的界面、选 IPA、装机，都没做。
- 总计划的真机预期（选 3 个 IPA 签完并装上；系统时间调到到期前 6 天收到通知）没跑。到期前 6 天在纯逻辑里不发，见上文 `:49`；真机那条「收到通知」仍然没做。
