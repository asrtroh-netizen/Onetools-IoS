# SP-06 外壳与 Swipt（总计划 5.0、5.1）

未在 Mac 上运行。

5.0 和 5.1 的勾选项都还没做。G2 没有结论，共存路线和冲突路线都还没选。G5 检查单未做。

## 已核对

- `Clash-Client/apple/ClashClient/project.yml:5` 仍是 `iOS: '15.0'`。在这份 `project.yml` 里搜 `OneUI`、`SwiptCore`、`FeatherUI` 没有命中。总计划 5.0 要改成 `16.4` 并加上 `OneUI`，这两处都还没改。
- Mac 脚本在 `scripts/mac/`：`10-env.sh`、`20-clash-client.sh`、`30-swipt.sh`、`35-feather.sh`、`40-verify-windows-work.sh`。五个文件的第 2 行都是「未在 Mac 上运行」。`docs/autorun/lane-C-notes.md:22` 和 `:35`：五个 `bash -n` 退出码都是 0。脚本没有在 Mac 上跑。
- `scripts/mac/30-swipt.sh:3-4` 写的是撰写时 `DeveloperDiskImage` 为空、未初始化。这句停在撰写当时。当前盘面以 `docs/findings/submodules.md` 为准，脚本本文没改，也没在 Mac 上执行。
- DeveloperDiskImage 不编译。`Swipt/Swipt/Resources/DeveloperDiskImage/README.md:7` 只写替换文件。`docs/findings/submodules.md:44` 写明没有编译命令。`:40-42` 是当前快照：6 个文件，没有 `Restore.plist`，没有 Makefile / Package.swift / 脚本。
- 锁定内核有 `loopback-address`。`_ref/kernel-4b7d5f5/config/config.go:307` 是 `LoopbackAddress`，YAML 键 `loopback-address`。
- 锁定树 `_ref/kernel-4b7d5f5/third_party/sing-tun/ip_rewrite.go:50-53`：目的地址在环回列表里就返回 `IPRewriteReflect`。`:82-86` 命中后调 `swapPacketAddresses` 并写回。`:114-124` 交换源地址和目的地址：IPv4 是字节 12:16 与 16:20，IPv6 是 8:24 与 24:40。
- 工作区 `Clash-Core/third_party/sing-tun/ip_rewrite.go` 也交换源和目的。`:165-167` 在 `IPRewriteReflect` 里调 `swapPacketAddresses`。`:195-204` 的交换位置与锁定树 `:114-124` 相同。两份文件的行号不一样，引用时带上树的路径。结论全文在 `docs/decisions/W-kernel-loopback.md`。
- 这一步没改内核，也没改 Swipt。Clash-Client 里「Swipt 兼容」的纯逻辑和设置项已经写进源码：纯逻辑提交 `658c29c`，运行时配置和设置项提交 `1358825`，后者标未编译。接进 Swipt 设置流程和真机验收还没做，那一步在 Mac 上的 5.1。

## 还没做

- 5.0：`project.yml` 的部署目标、`OneUI` 依赖、四个页签的根视图，都没做。装机后切页签这一步没跑。
- 5.1：G2 没有共存或冲突的结论。`SwiptCore` / `SwiptUI` 没进 `project.yml`。`@main`、`Bundle.main`、Info.plist、`LoopbackSetupView`、首次装「跳过中国广告」、蜂窝网络实验，都没做。
- G5 五条真机检查没做。没装 LocalDevVPN 的那组验收没跑。
- P5 出口要的安装包体积和冷启动时间没量。
