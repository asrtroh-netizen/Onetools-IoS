import SwiftUI

// MARK: - 卡片

/// 列表卡：半透明 + 发丝边，不模糊（`GlassListCard`）。给 `selected` 时走绿色选中光。
public struct GlassCard<Content: View>: View {
    let selected: OneTone?
    let padding: CGFloat
    let content: Content

    public init(selected: OneTone? = nil, padding: CGFloat = OneMetrics.cardPadding, @ViewBuilder content: () -> Content) {
        self.selected = selected
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassSurface(.card, stroke: selected.map { $0.tint(light: 0.28, dark: 0.18) })
            .overlay { if let selected { SelectedSheen(tone: selected, radius: OneMetrics.radiusCard) } }
    }
}

/// 高价值面板：真模糊（`GlassPanel`）。只给首页门面、悬浮层用，别放进长列表。
public struct GlassPanel<Content: View>: View {
    let padding: CGFloat
    let content: Content

    public init(padding: CGFloat = OneMetrics.cardPadding, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassSurface(.frosted)
    }
}

/// 选中态：左上角一笔边缘高光 + 1px 细环（WEB `is-glow-green`）。不染底。
struct SelectedSheen: View {
    let tone: OneTone
    let radius: CGFloat

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        ZStack {
            shape.fill(
                LinearGradient(
                    stops: [
                        .init(color: Color(uiColor: tone.bright ?? .white).opacity(0.20), location: 0),
                        .init(color: tone.color.opacity(0.065), location: 0.24),
                        .init(color: .white.opacity(0.01), location: 0.52),
                        .init(color: tone.color.opacity(0.045), location: 1),
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            // 顶边、左边各一根渐隐亮线（Flutter 版 SelectedEdgeLight 用两个 Positioned 拼，这里用描边渐变一次画完）
            shape.strokeBorder(
                LinearGradient(
                    colors: [Color(uiColor: tone.bright ?? .white).opacity(0.34), .clear],
                    startPoint: .topLeading, endPoint: .center
                ),
                lineWidth: 1
            )
        }
        .allowsHitTesting(false)
        .shadow(color: tone.color.opacity(0.10), radius: 1)
        .shadow(color: tone.color.opacity(0.045), radius: 24)
    }
}

// MARK: - 分区

/// 带标题行的分区卡（`OwSection`）：着色图标方块 + 标题 + 右上角动作。
public struct OneSection<Content: View, Actions: View>: View {
    let title: String
    let desc: String?
    let systemImage: String?
    let tone: OneTone?
    let actions: Actions
    let content: Content

    public init(
        _ title: String,
        desc: String? = nil,
        systemImage: String? = nil,
        tone: OneTone? = nil,
        @ViewBuilder actions: () -> Actions,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.desc = desc
        self.systemImage = systemImage
        self.tone = tone
        self.actions = actions()
        self.content = content()
    }

    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: OneMetrics.space10) {
                    if let systemImage, let tone {
                        TitleIcon(systemImage: systemImage, tone: tone)
                    } else if let systemImage {
                        MaterialIcon(name: systemImage, size: 17, color: OnePalette.onSurface)
                    }
                    Text(title)
                        .font(OneText.titleMedium())
                        .tracking(-0.2)
                        .lineLimit(1)
                        .layoutPriority(1)
                        .accessibilityAddTraits(.isHeader)
                    Spacer(minLength: OneMetrics.space8)
                    actions
                }
                if let desc, !desc.isEmpty {
                    Text(desc)
                        .font(OneText.bodySmall())
                        .foregroundStyle(OnePalette.onSurfaceVariant)
                        .padding(.top, OneMetrics.space4)
                }
                content.padding(.top, OneMetrics.space16)
            }
        }
    }
}

extension OneSection where Actions == EmptyView {
    public init(_ title: String, desc: String? = nil, systemImage: String? = nil, tone: OneTone? = nil, @ViewBuilder content: () -> Content) {
        self.init(title, desc: desc, systemImage: systemImage, tone: tone, actions: { EmptyView() }, content: content)
    }
}

/// 框头左侧着色图标方块（`PanelTitleIcon`）。
public struct TitleIcon: View {
    let systemImage: String
    let tone: OneTone
    var side: CGFloat = 30

    public init(systemImage: String, tone: OneTone, side: CGFloat = 30) {
        self.systemImage = systemImage
        self.tone = tone
        self.side = side
    }

    public var body: some View {
        MaterialIcon(name: systemImage, size: side * 0.52, color: tone.ink)
            .frame(width: side, height: side)
            .glassSurface(.sheer, radius: OneMetrics.radiusChip,
                          tint: tone.tint(light: 0.12, dark: 0.16),
                          stroke: tone.color.opacity(0.32), elevated: false)
            .accessibilityHidden(true)
    }
}

// MARK: - 页头

/// 页面大标题 + 淡描述（`OwPageHead`）。
public struct PageHead<Actions: View>: View {
    let title: String
    let desc: String?
    let actions: Actions

    public init(_ title: String, desc: String? = nil, @ViewBuilder actions: () -> Actions) {
        self.title = title
        self.desc = desc
        self.actions = actions()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: OneMetrics.space4) {
                Text(title).font(OneText.headline()).tracking(-0.4)
                    .accessibilityAddTraits(.isHeader)
                if let desc, !desc.isEmpty {
                    Text(desc).font(OneText.bodySmall())
                        .foregroundStyle(OnePalette.onSurfaceVariant.opacity(0.78))
                }
            }
            Spacer(minLength: OneMetrics.space8)
            actions
        }
    }
}

extension PageHead where Actions == EmptyView {
    public init(_ title: String, desc: String? = nil) {
        self.init(title, desc: desc) { EmptyView() }
    }
}

// 原版 API 别名，保留业务页使用的 Ow* 命名。
public typealias OwPageHead<Actions: View> = PageHead<Actions>
public typealias OwSection<Content: View, Actions: View> = OneSection<Content, Actions>
public typealias GlassListCard<Content: View> = GlassCard<Content>

/// One 品牌几何标志。
public struct OneMark: View {
    public var size: CGFloat
    public init(size: CGFloat = 40) { self.size = size }
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous).fill(OnePalette.onSurface)
            Text("O").font(.system(size: size * 0.48, weight: .black, design: .rounded)).foregroundStyle(OnePalette.surface)
        }.frame(width: size, height: size).accessibilityLabel(Text("One"))
    }
}

/// 密码输入框，采用 Material 眼睛图标并保持 44pt 触点。
public struct ObscurableField: View {
    let title: String
    @Binding var text: String
    @State private var obscured = true
    public init(_ title: String, text: Binding<String>) { self.title = title; self._text = text }
    public var body: some View {
        HStack(spacing: OneMetrics.space8) {
            Group { if obscured { SecureField(title, text: $text) } else { TextField(title, text: $text) } }
            Button { obscured.toggle() } label: { MaterialIcon(name: obscured ? "visibility_outlined" : "visibility_off_outlined", size: 20, color: OnePalette.onSurfaceVariant).frame(width: 44, height: 44) }.buttonStyle(.plain)
        }.padding(.horizontal, OneMetrics.space16).glassSurface(.sheer, radius: OneMetrics.radiusTile, elevated: false)
    }
}

public struct FeatureFailureNotice: View {
    let title: String; let message: String; let retry: (() -> Void)?
    public init(_ title: String = "暂时不可用", message: String, retry: (() -> Void)? = nil) { self.title = title; self.message = message; self.retry = retry }
    public var body: some View {
        HStack(alignment: .top, spacing: OneMetrics.space12) {
            MaterialIcon(name: "error_outline", size: 24, color: OnePalette.error)
            VStack(alignment: .leading, spacing: OneMetrics.space4) { Text(title).font(OneText.titleSmall()); Text(message).font(OneText.bodySmall()).foregroundStyle(OnePalette.onSurfaceVariant); if let retry { Button("重试", action: retry).font(OneText.labelLarge()) } }
            Spacer(minLength: 0)
        }.padding(OneMetrics.space16).glassSurface(.card, radius: OneMetrics.radiusTile, tint: OnePalette.errorContainer.opacity(0.42), elevated: false)
    }
}

public struct OneGlassDialog<Content: View>: View {
    let title: String; let content: Content; let onCancel: (() -> Void)?; let onConfirm: (() -> Void)?
    public init(_ title: String, onCancel: (() -> Void)? = nil, onConfirm: (() -> Void)? = nil, @ViewBuilder content: () -> Content) { self.title = title; self.onCancel = onCancel; self.onConfirm = onConfirm; self.content = content() }
    public var body: some View {
        VStack(alignment: .leading, spacing: OneMetrics.space16) { Text(title).font(OneText.titleLarge()); content; HStack { Spacer(); if let onCancel { OneTextButton("取消", action: onCancel) }; if let onConfirm { OneFilledButton("确定", action: onConfirm) } } }
            .padding(OneMetrics.space24).glassSurface(.frosted, radius: 22, tint: OneGlass.dialog, elevated: true)
    }
}

public struct OneGlassPopupFrame<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View { content.padding(OneMetrics.space16).glassSurface(.frosted, radius: 22, tint: OneGlass.modal, elevated: true) }
}


