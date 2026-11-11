import SwiftUI

/// 组件总览页：在 Xcode 预览或 App 的调试入口里对照 OneWIFI 原版验收。
public struct OneGallery: View {
    @State private var hero: HeroState = .inactive
    @State private var mode = "rule"
    @State private var picked = 0

    public init() {}

    public var body: some View {
        OnePage {
            PageHead("OneUI", desc: "One 家族玻璃设计系统") {
                GlassActionButton("切换", systemImage: "arrow.triangle.2.circlepath") {
                    hero = HeroState(rawValue: (hero.rawValue + 1) % 3) ?? .inactive
                }
            }

            StatusHero(
                state: hero,
                eyebrow: "Clash",
                title: "代理",
                pill: hero == .ready ? "已连接" : hero == .activating ? "连接中" : "未连接",
                stageLabels: ["配置", "隧道", "就绪"],
                subtitle: "VPN 未开启",
                detail: "开启后同时为 Swipt 提供环回地址",
                primary: HeroAction("连接") { hero = .activating },
                secondary: HeroAction("选择配置") {}
            )

            MetricGrid {
                MetricCard("上传", value: "1.2 MB/s", sub: "累计 3.4 GB", systemImage: "arrow.up", tone: .green)
                MetricCard("下载", value: "8.6 MB/s", sub: "累计 21 GB", systemImage: "arrow.down", tone: .teal)
            }

            OneSection("当前节点", systemImage: "globe.asia.australia.fill", tone: .teal) {
                GlassActionButton("测速", systemImage: "bolt.fill") {}
            } content: {
                VStack(alignment: .leading, spacing: OneMetrics.space12) {
                    CardHeadRow("香港 01", systemImage: "server.rack") {
                        Nameplate.ready("在线", detail: "42 ms")
                    }
                    StageRow([("DNS", .ready), ("TLS", .ready), ("规则", .active), ("MITM", .pending), ("脚本", .failed)])
                    ThinProgress(62, tone: .green)
                    ChoiceChips([("rule", "规则"), ("global", "全局"), ("direct", "直连")], selection: $mode)
                }
            }

            OneSection("详情", systemImage: "info.circle") {
                SoftLabelGrid([
                    SoftLabel("内核", value: "mihomo 1.19.33"),
                    SoftLabel("模式", value: mode),
                    SoftLabel("环回地址", value: "10.7.0.1", mono: true),
                    SoftLabel("证书", value: "未信任", danger: true),
                    SoftLabel("模块", value: "12 个", sub: "3 个有忽略项"),
                ])
            }

            HStack(spacing: OneMetrics.space10) {
                ForEach(0..<3) { i in
                    GlassTile(selected: picked == i, action: { picked = i }) {
                        Text(["去广告", "自签", "互通"][i]).font(OneText.labelLarge())
                    }
                }
            }
        }
    }
}

#if DEBUG
struct OneGallery_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OneGallery().oneTheme().preferredColorScheme(.light)
            OneGallery().oneTheme().preferredColorScheme(.dark)
        }
    }
}
#endif
