# W：锁定内核 `4b7d5f5` 的 `loopback-address`

核对时间：2026-11-12 00:56:23 +08 开始读源码，同日 01:05 前落盘。只读 `_ref/kernel-4b7d5f5/` 和 `Clash-Core/`。没有改这两棵树，没有下载，没有 git 写操作。

目录 `_ref/kernel-4b7d5f5/` 里没有 `.git`（`Test-Path` 为 False）。在该树里搜 `4b7d5f5`，零命中。身份依据是 `.mimocode/r0-6-kernel-ready.txt` 第 2–5 行：zipball `4b7d5f53cff448f01cd5012b5e3f7eddc7d43e33` 解压到这个目录，3362 个文件。本次没有对这棵树重算提交哈希。两边 `UPSTREAM_VERSION` 第 1 行都是 `v1.19.33`。锁定树 `constant/version.go:5` 另有一个字符串 `Version = "1.10.0"`。

## 1. 有这个选项

有。键名是 `loopback-address`，类型是 `[]netip.Addr`。下列文件与 `Clash-Core/` 同名文件 SHA256 相同，行号一致：

- `_ref/kernel-4b7d5f5/config/config.go:307` 声明 `RawTun.LoopbackAddress`；`:1871` 把 `rawTun.LoopbackAddress` 抄进 `LC.Tun`。
- `listener/config/tun.go:32` 声明。该文件里这个标识只出现这一行，`Sort` 不排它。
- `listener/inbound/tun.go:33` 声明；`:116` 赋给 `LC.Tun`。
- `hub/route/configs.go:84` 声明为指针；`:202-203` 在补丁非空时写入。
- `bind/clash/config_api.go:34` 的 JSON 字段是 `loopbackAddresses`；`:160` 调 `sortedAddresses(raw.Tun.LoopbackAddress)`。
- 进入网卡栈之前拆成 `third_party/sing-tun/tun.go:100-101` 的 `Inet4LoopbackAddress` 和 `Inet6LoopbackAddress`。

在锁定树里搜 `loopback-address`（`*.go` / `*.yml` / `*.yaml` / `*.md`）得到 8 处，都在上面这些文件加测试里。没有第二套键名 `loopback_address`。

## 2. 怎么实现

配置里的地址列表按 IPv4 / IPv6 拆开，交给 sing-tun。目的地址命中时，在 IP 层交换源地址和目的地址再写回，TCP、UDP、ICMP 走同一条。总计划 `docs/superpowers/plans/2026-11-11-onetools-ios-master-plan.md:100` 把这件事记在 `e6334ad`，并写锁定版待确认。这份树里已经有，见下面 `ip_rewrite.go`。

1. 解析与热更新见第 1 节。
2. `listener/sing_tun/server.go:427-428` 用 `common.Filter(options.LoopbackAddress, netip.Addr.Is4)` 和 `Is6` 填进 `tun.Options`。
3. 同文件 `:535` 调用 `tun.NewStack(strings.ToLower(options.Stack.String()), stackOptions)`。
4. `third_party/sing-tun/stack.go:45-59`：空字符串和 `mips` 走 `NewMipstack`，另外三个名字是 `gvisor`、`mixed`、`system`。未知名字在 `:60-61` 返回错误。`constant/tun.go:8-20` 没有 `TunGo`。
5. `third_party/sing-tun/ip_rewrite.go:37-48` 的 `LoopbackAddresses` 做 `Unmap`、去 zone、丢掉无效地址、去重。
6. 同文件 `:50-53`：目的地址在这个列表里就返回 `IPRewriteReflect`，排在前缀表之前。
7. `:71-79` 的 `applyIPRewrite` 调用上一步。`:82-86` 的 `IPRewriteReflect` 调 `swapPacketAddresses` 并返回已处理、要写回。交换位置在 `:114-124`：IPv4 是字节 12:16 与 16:20，IPv6 是 8:24 与 24:40。这里不看传输层协议。
8. `third_party/sing-tun/ip_rewrite_loopback_test.go:16` 用地址 `10.7.0.1`。`:33-36` 的探针是 IPv4 和 IPv6 的 TCP SYN、UDP、echo。`:58-68` 断言环回地址先于前缀表被反射。`:80-86` 断言只有环回地址、没有前缀表时也反射。
9. 四套栈都接这条路径：
   - system：`stack_system.go:78-80` 保存列表；`:408-412` 的 `processPacket` 先调 `applyIPRewrite`，命中就写回并返回。`:527-534` 和 `:612-619` 还有 TCP NAT 的环回分支：目的地址相等时改写，端口参数为 0 且 `false`。这个分支在 `processPacket` 里排在 `applyIPRewrite` 之后。
   - mixed：`stack_mixed.go:16-31` 嵌入 `*System`；自己的 `processPacket` 在 `:191-195`，同样先调 `applyIPRewrite`。文件第 1 行的构建标签是 `with_gvisor`。
   - gvisor：`stack_gvisor.go:77-79` 保存列表；`:94-104` 交给 `LinkEndpointFilter` 和 `NewTCPForwarderWithLoopback`。`ip_rewrite_gvisor.go:12-47` 在送进协议栈之前做改写。`stack_gvisor_tcp.go:52-80` 在 TCP 分发时再按地址比对，命中后交换地址、重算校验和并 `WritePacket`。
   - mipstack：`stack_mipstack.go:64-66` 保存；`:275-283` 先 `applyIPRewrite`；这步未处理时 `:290-308` 再对合法环回包交换源和目的。
10. Linux `auto-redirect`：`third_party/sing-tun/redirect_nftables_rules.go:120-127` 建 `inet4_local_redirect_address_set` 和 `inet6_local_redirect_address_set`；`:777`、`:809`、`:829`、`:875`、`:879` 按集合是否为空改规则。这个文件与工作区 SHA256 相同。
11. Apple 绑定：`bind/clash/tun.go:131-146` 的 `loopbackRoutes` 把地址变成主机前缀（前缀长度是 `address.BitLen()`），经 `GetInet4LoopbackAddress` / `GetInet6LoopbackAddress` 导出。`bind/clash/service.go:862` 克隆这个切片，`:890-892` 排序，`:838` 在 `Equal` 之外再比一次。

`third_party/gvisor/pkg/tcpip/transport/tcp/endpoint.go:1708` 的 `IsV4LoopbackAddress` 判的是协议规定的环回前缀。它和本文件说的配置项是两件事。

## 3. 和 `Clash-Core/` 工作区的差

选项的声明、解析、热更新、Apple 主机路由、Linux nftables 集合，两边文本相同。数据面不同：锁定树按栈名启动 sing-tun 的 mips / gvisor / mixed / system，在栈里调 `applyIPRewrite`。工作区的监听器固定启动 Go 栈；darwin 上用 `NewIPRewriter` 做 IP 反射，Go 引擎另有一条只处理 TCP 的 hairpin。工作区的 `third_party/sing-tun/` 里已经没有这四套栈的实现文件。

2026-11-12 用 `Get-FileHash -Algorithm SHA256` 比过。下面写前 12 位。相同：

| 相对两棵树的路径 | SHA256 前 12 位 |
|---|---|
| `listener/config/tun.go` | `FCD3D6F5E556` |
| `listener/inbound/tun.go` | `E4A0E32581C8` |
| `bind/clash/tun.go` | `9A496183DB40` |
| `hub/route/configs.go` | `964A4A1A4A1F` |
| `config/config.go` | `D2456054F469` |
| `bind/clash/config_api.go` | `117D93A1CAEB` |
| `third_party/sing-tun/tun.go` | `2EAE954FB1F7` |
| `third_party/sing-tun/redirect_nftables.go` | `6D18DF6DDCA0` |
| `third_party/sing-tun/redirect_nftables_rules.go` | `61563F2BC968` |

不同的地方：

1. `listener/sing_tun/server.go` 哈希不同（锁定树 `6BC5F78F7D1D`，工作区 `1BA7A0BC5EC8`）。拆地址的两行语句相同：锁定树 `:427-428`，工作区 `:423-424`。启动栈：锁定树 `:535` 是 `tun.NewStack`；工作区 `:516-524` 是 `startGoStack`，`:561` 的日志把栈名写成 `C.TunGo`。两边都给 `tun.Options` 填了 `DeviceFailure()`：锁定树 `:450`，工作区 `:446`。
2. `constant/tun.go` 哈希不同（`C77493FDFBA5` 对 `EA172E9E8E50`）。工作区 `:13`、`:21`、`:51-52` 多了 `TunGo`（字符串 `"Go"`）。锁定树 `:8-20` 只有 gVisor、System、Mixed、Mips。
3. `third_party/sing-tun/ip_rewrite.go` 哈希不同（`3F3484607C0B` 对 `93C8A6CF612E`）。工作区的 `LoopbackAddresses` 仍在 `:37-48`。`applyIPRewrite` 在 `:152-160`。多出来的是 `NewIPRewriter`（`:84-106`）和 `newIPRewriteGate`（`:108-122`，把环回地址当全长前缀放进首字节门闩）。反射动作仍是 `:165-167` 的 `swapPacketAddresses`。锁定树里搜 `NewIPRewriter`、`SetPacketRewrite`、`func NewGo`，零命中。
4. 锁定树有、工作区 `third_party/sing-tun/` 下 `Test-Path` 为 False 的文件：`stack_system.go`、`stack_gvisor.go`、`stack_mixed.go`、`stack_mipstack.go`、`stack_gvisor_tcp.go`、`stack_gvisor_filter.go`、`ip_rewrite_gvisor.go`、`ip_rewrite_loopback_test.go`、`ip_rewrite_loopback_gvisor_test.go`。工作区的 `third_party/sing-tun/stack.go` 还在，共 37 行，只有 `Stack` 接口、`HasNextAddress`、`BroadcastAddr`，没有 `NewStack`。
5. 锁定树没有 `third_party/sing-tun-go/`（`Test-Path` False），也没有 `listener/sing_tun/go_stack.go` 和 `bind/clash/go_stack_darwin.go`。
6. 工作区监听器实际走的路径：
   - `listener/sing_tun/go_stack.go:42-51` 的 `startGoStack` 只调已注册的 factory。factory 为空时 `:37` 返回 `“the go stack is not available in this build”`。
   - 生产代码里唯一的 `SetGoStackFactory` 注册在 `bind/clash/go_stack_darwin.go:34-35`。该文件靠 `_darwin.go` 文件名约束，前 33 行没有另一行 build tag。`:110-111` 执行 `tun.NewIPRewriter(tun.LoopbackAddresses(...))` 再 `stack.SetPacketRewrite(rewriter.Apply)`。
   - `third_party/sing-tun-go/clash_packet_rewrite.go:7-13` 保存回调；`:15-37` 在命中时写回帧。
   - `third_party/sing-tun-go/stack_go_engine.go:649-654` 在 `processBurst` 里先调这个回调，命中则不进 `processFrame`。
   - 同文件 `:811-823` 的 `handleLoopbackHairpin` 只接受 TCP（`:812-814` 其余协议直接返回 false），命中后交换 IP 源和目的再 `writeData`（`:824-841`）。它排在改写回调之后。`stack_go.go:57-58` 保存两个地址列表。
7. `third_party/sing-tun-go/stack_system.go` 仍保存环回地址（`:79-80`）。TCP 分流在 `:442-443`、`:462-463` 看到环回目的就不交给 `dispatchStage`；`:557-567` 和 `:600-610` 仍按地址改写 TCP。在这个文件里搜 `applyIPRewrite` 和 `ipRewriteLoopback`，零命中。`stack_gvisor_stub.go:9-18` 的 `NewGVisor` 和 `NewMixed` 返回 `ErrGVisorNotIncluded`。`sing-tun-go/stack.go:52-65` 的 `NewStack` 默认走 `NewGo`。监听器调的是 `startGoStack`，没有调这个 `NewStack`。
8. `bind/clash/service.go` 整文件哈希不同（`DDF3BF4825CF` 对 `7B4D8BC1D034`）。环回的三段文本相同：锁定树 `:838` 比较、`:862` 克隆、`:890-892` 排序；工作区 `:825`、`:849`、`:877-879`。

## 搜过的命令

工具是工作区根上的内容搜索和下面这条 PowerShell。零命中的写在结论里。

- 模式 `loopback-address|loopback_address|LoopbackAddress|loopback address`，目录 `_ref/kernel-4b7d5f5` 与 `Clash-Core`。
- 模式 `loopback-address`，限定 `*.{go,yml,yaml,md}`，目录锁定树。8 处。
- 模式 `applyIPRewrite|NewIPRewriter|ipRewriteLoopback|Inet4LoopbackAddress|Inet6LoopbackAddress`，两棵树的 `*.go`。
- 模式 `NewIPRewriter|SetPacketRewrite|func NewGo`，锁定树的 `*.go`。零命中。
- 模式 `4b7d5f5`，锁定树的 `*.{md,txt,go,json}`。零命中。
- 模式 `SetGoStackFactory\(`，`Clash-Core` 的 `*.go`。生产注册只有 `bind/clash/go_stack_darwin.go:35`。
- 模式 `applyIPRewrite\(|ipRewriteLoopback`，`Clash-Core/third_party/sing-tun-go/stack_system.go`。零命中。
- `Get-FileHash` 加 `Test-Path`，对象是上文表里的文件，以及 `stack_*.go`、`ip_rewrite_loopback*.go`、`sing-tun-go`、`go_stack.go`、`go_stack_darwin.go`、两边的 `.git`。
