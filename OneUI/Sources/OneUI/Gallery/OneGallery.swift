import SwiftUI

public struct OneGallery: View {
    @State private var hero: HeroState = .inactive
    @State private var mode = "rule"
    @State private var picked = 0
    @State private var dockTab = 0
    @State private var username = ""
    @State private var secret = ""
    @State private var toggle = true

    private let dockItems: [UltraGlassDock.Item] = [
        .init(id: "overview", icon: "dashboard_outlined", label: "总览"),
        .init(id: "proxy", icon: "router_outlined", label: "代理"),
        .init(id: "adblock", icon: "shield_outlined", label: "去广告"),
        .init(id: "settings", icon: "settings_outlined", label: "设置"),
    ]

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            OnePage {
                PageHead("OneUI", desc: "One 家族玻璃设计系统") {
                    GlassActionButton("切换", systemImage: "refresh_rounded") {
                        hero = HeroState(rawValue: (hero.rawValue + 1) % 3) ?? .inactive
                    }
                }
                StatusHero(
                    state: hero,
                    eyebrow: "Clash",
                    title: "代理",
                    pill: hero == .ready ? "就绪" : hero == .activating ? "处理中" : "注意",
                    stageLabels: ["关闭", "处理中", "就绪"],
                    subtitle: "VPN 未开启",
                    detail: "开启后同时为 Swipt 提供 10.7.0.1 环回地址",
                    primary: HeroAction("连接") { hero = .activating },
                    secondary: HeroAction("选择配置") {}
                )
                OneSection("状态组件", systemImage: "check_circle_rounded", tone: .green) {
                    VStack(alignment: .leading, spacing: OneMetrics.space12) {
                        OneSlidingPill(
                            [
                                .init("rule", title: "规则路由"),
                                .init("global", title: "全局代理"),
                                .init("direct", title: "全直连"),
                            ],
                            selection: $mode
                        )
                        MetricGrid {
                            MetricCard("上传", value: "1.28 MB/s", sub: "累计 3.4 GB", systemImage: "upload_file_outlined", tone: .green, indexTag: "01")
                            MetricCard("下载", value: "18.6 MB/s", sub: "累计 21 GB", systemImage: "download_outlined", tone: .teal, indexTag: "02")
                        }
                        StageRow([("DNS", .ready), ("TLS", .ready), ("规则", .active), ("MITM", .pending), ("脚本", .failed)])
                        ThinProgress(62, tone: .green)
                        OneSwipeConfirm("右滑体验阻尼防误触确认", tone: .amber) {}
                    }
                }
                OneSection("控件", systemImage: "tune_rounded", tone: .teal) {
                    VStack(alignment: .leading, spacing: OneMetrics.space12) {
                        HStack(spacing: OneMetrics.space8) {
                            OneFilledButton("确定") {}
                            OneOutlinedButton("描边") {}
                            OneTextButton("文本") {}
                        }
                        HStack(spacing: OneMetrics.space12) {
                            OneIconButton("settings_outlined") {}
                            SystemSwitch(isOn: $toggle)
                            SystemSpinner()
                        }
                        OneTextField("用户名", text: $username)
                        ObscurableField("密码", text: $secret)
                        OneDivider()
                        OneSnackBarBanner("配置已保存", actionTitle: "撤销") {}
                    }
                }
                OneSection("瓷片与标签", systemImage: "dashboard_outlined") {
                    SoftLabelGrid([
                        SoftLabel("内核", value: "mihomo 1.19.33"),
                        SoftLabel("模式", value: mode),
                        SoftLabel("环回地址", value: "10.7.0.1", mono: true),
                        SoftLabel("证书", value: "未信任", danger: true),
                    ])
                }
                HStack(spacing: OneMetrics.space10) {
                    ForEach(0..<3, id: \.self) { i in
                        GlassTile(selected: picked == i, action: { picked = i }) {
                            Text(["去广告", "自签", "互通"][i]).font(OneText.labelLarge())
                        }
                    }
                }
                FeatureFailureNotice(message: "示例错误信息", retry: {})
                HStack(spacing: OneMetrics.space12) {
                    OneMark(size: 36)
                    Nameplate.ready("在线", detail: "42 ms")
                    DotMatrixFace(mood: .smile)
                }
            }
            UltraGlassDock(items: dockItems, selectedIndex: $dockTab)
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
