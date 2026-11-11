未在 Mac 上运行。这一步不排期。

# SP-10 通话规格草稿（总计划 P9）

只列待决问题。

## 总计划里已经写明的前置条件

摘自 `docs/superpowers/plans/2026-11-11-onetools-ios-master-plan.md`。行号是该文件里的行号，文字原样。

```
918|### P9 电话短信互通（后期）
919|
920|不在本计划里排期。开工的前置条件：
921|
922|- I3 确认代码归属。
923|- 朋友的账号能开 Push Notifications。
924|- 先做规格：号码放在哪种网关、SIP 还是自有协议、后端部署在哪。交接文档 §5 的建议路线作为规格的起点。
925|- 可复用的 iOS 代码：`ONEWIFIX/IOS/ios/Runner/Calls/`（9 个文件 3,038 行）、`CallAudioBridge.swift`、`APNsBridge.swift`、`OtpNotifier.swift`、`OtpLiveActivity.swift`。`CallAudioBridge` 要去掉 Flutter 通道。
926|- 配对入口的问题（`onetools://onewifi?...` 在 Onetools 仓库里找不到实现）在规格阶段一并解决。
```

## 盘上复核

`E:\GQ\Ultra\ONEWIFIX\IOS\ios\Runner\Calls\` 存在。2026-11-12 清点该目录下的文件（含子目录）：9 个，都在这一层。

行数算法：读文件字节。换行符个数记为 N。文件以换行结尾时行数为 N，否则为 N+1。空文件为 0。这次没有空文件。

| 文件 | 行数 | 字节 |
|---|---:|---:|
| CallEventStream.swift | 178 | 8468 |
| CallGatewayClient.swift | 504 | 31218 |
| CallGatewayModels.swift | 173 | 9857 |
| CallKitCoordinator.swift | 783 | 40741 |
| CallKitPlatform.swift | 191 | 9037 |
| CallPCMTransport.swift | 560 | 28262 |
| CallPinnedTransport.swift | 449 | 17821 |
| CallPushRegistry.swift | 145 | 5411 |
| CallSessionChannel.swift | 55 | 2751 |
| 合计 | 3038 | 153566 |

`CallPushRegistry.swift` 末尾没有换行：换行符 144 个，按上面的算法是 145 行。其余 8 个文件的换行符个数等于行数。9 个文件的换行符合计 3037。

总计划第 925 行写的是「9 个文件 3,038 行」。这次按盘重数，文件数是 9，行数是 3038。上表的分文件数字是这次清点的。

总计划点名的四个文件不在 `Calls\` 里。它们在 `E:\GQ\Ultra\ONEWIFIX\IOS\ios\Runner\`：

| 文件 | 在 Calls 里 | 行数 | 字节 |
|---|---|---:|---:|
| CallAudioBridge.swift | 否 | 207 | 6981 |
| APNsBridge.swift | 否 | 218 | 7203 |
| OtpNotifier.swift | 否 | 233 | 8671 |
| OtpLiveActivity.swift | 否 | 136 | 5920 |

## 配对链接

写下本文件之前，在 `E:\GQ\Ultra\Onetools-IoS` 搜索 `onetools://`。默认搜索与 `--no-ignore`（排除 `.git`）都是 2 处命中。

- `HANDOFF.md:322`
- `docs/superpowers/plans/2026-11-11-onetools-ios-master-plan.md:926`

两处都是在写「Onetools 仓库里搜不到对应的实现」。没有第三处。上面摘录的第 926 行含有同一字符串。写完后再搜，会多出本文件里的摘录和这一节，以及线 C 备忘 P8 里的复述。

## 待决

交接文档 §5 在 `HANDOFF.md:305-323`。总计划第 924 行说它是规格的起点。下面六条都未决定。

- 号码网关：未决定。
- SIP 还是自有协议：未决定。
- 后端放哪：未决定。
- 配对入口：未决定。
- Push 权限：未决定。
- 代码归属：未决定。

总计划第 156 行的 I3 格子记着 2026-11-11 的一句答复。第 351 行的 I3 仍未勾选，第 922 行仍把确认归属写成开工前置。本草稿不把那句答复收成决定。
