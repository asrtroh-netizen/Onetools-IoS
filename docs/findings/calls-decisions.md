未决定

# 通话六项决策表

规格在 `docs/superpowers/plans/2026-11-11-onetools-p9-calls-design.md`。Calls 目录 9 个文件、3038 行；`CallAudioBridge.swift`、`APNsBridge.swift`、`OtpNotifier.swift`、`OtpLiveActivity.swift` 在 Runner 下，不在 Calls 里。交接文档 §5 在 `HANDOFF.md:305-323`。总计划 `:924` 把这一节当规格起点，不是已拍板的选择。

六项都是未决定。本表只把文档里已经写出的选项和后果摆开，不新增方案，不写实现。

| 项 | 状态 | 文档里已经写出的选项 | 文档里写过的后果 |
|---|---|---|---|
| 号码网关 | 未决定 | `HANDOFF.md:313` 建议号码放在网关（4G 模块或 VoWiFi）。总计划 `:924` 另把「号码放在哪种网关」列为待写规格，没有第二套已写方案。 | 未选之前 P9 不排期（规格第一行；总计划 `:918` 标成后期）。 |
| SIP 还是自有协议 | 未决定 | `:313` 建议通话走 SIP，iPhone 用 CallKit 接，音频走 WebSocket。总计划 `:924` 把「SIP 还是自有协议」列为待决，没有写自有协议的报文。 | `:313` 写这条建议是为了绕开「Android 上没法往通话上行注入音频」。选哪一边本表不填。`HANDOFF.md:337` 另写 CallKit 在中国区不允许，那是风险说明，不是协议选择。 |
| 后端放哪 | 未决定 | `HANDOFF.md:311` 点了一套 MIT 后端：`ONEWIFIX/WEB后端/internal/server/apns_*.go`、`call_push_api.go`、`internal/callmedia/`、`internal/otprelay/`。总计划 `:924` 的「后端部署在哪」没有写具体主机。 | 未决定前不把这些 Go 文件搬进本仓库，也不另指一台机器。 |
| 配对入口 | 未决定 | `HANDOFF.md:322` 与总计划 `:926` 都写：配对链接是 `onetools://onewifi?...`，Onetools 仓库里找不到实现。规格「配对链接」一节复核过：写规格之前本仓库只有这两处命中。补这个 scheme，或换一个入口，两种做法都还没写。 | `:926` 把这件事留在规格阶段。未决定前没有配对入口可以实现。不打开 `HANDOFF-GROK-iOS-Pairing.md`。 |
| Push 权限 | 未决定 | 总计划 `:923` 把「朋友的账号能开 Push Notifications」列为开工前置，没有写已经开通。开得了，或开不了，都还没记。 | 规格点名了 `CallPushRegistry.swift` 和 `APNsBridge.swift`。这一项未确认前，P9 仍不排期。本表不声称账号已经能开 Push。 |
| 代码归属 | 未决定 | 总计划 `:156` 记了 2026-11-11 的一句答复：「全部归你或你有权使用。」`:351` 的 I3 仍未勾选，`:922` 仍把确认归属写成开工前置。规格写明不把那句答复收成决定。`HANDOFF.md:318`：`ONEWIFIX/IOS` 没有 LICENSE。 | 未勾选前不把 Runner 下的 Calls 与四个点名文件搬进本仓库。`HANDOFF.md:317` 另写 `ONEWIFIX/Mac` 不能用（PolyForm Noncommercial，和 GPL 不兼容）。那不是这一项的选择。 |

六行的状态都是未决定。
