import SwiftUI

/// 门面卡三态：需要动手 → 忙 → 办妥（`OneChannelState`）。
public enum HeroState: Int, Sendable, CaseIterable {
    case inactive, activating, ready

    var isAlert: Bool { self == .inactive }
    var isBusy: Bool { self == .activating }
    /// 稳态：收起副文案与主按钮，只留标题 + 药丸。
    var isSettled: Bool { self == .ready }
    var litStages: Int { rawValue + 1 }

    var systemImage: String {
        switch self {
        case .inactive: "exclamationmark.triangle.fill"
        case .activating: "arrow.clockwise"
        case .ready: "checkmark.circle.fill"
        }
    }
}

/// 门面卡动作。
public struct HeroAction {
    let title: String
    let action: () -> Void
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

/// One 家族门面卡：三态 + 阶段进度 + 状态药丸 + 点阵脸（`OneStatusHero`）。
public struct StatusHero<Trailing: View>: View {
    let state: HeroState
    let eyebrow: String?
    let title: String
    let pill: String
    let stageLabels: [String]?
    let subtitle: String?
    let detail: String?
    let primary: HeroAction?
    let secondary: HeroAction?
    let actionNote: String?
    let busyLabel: String
    let trailing: Trailing

    public init(
        state: HeroState,
        eyebrow: String? = nil,
        title: String,
        pill: String,
        stageLabels: [String]? = nil,
        subtitle: String? = nil,
        detail: String? = nil,
        primary: HeroAction? = nil,
        secondary: HeroAction? = nil,
        actionNote: String? = nil,
        busyLabel: String = "处理中",
        @ViewBuilder trailing: () -> Trailing
    ) {
        precondition(stageLabels == nil || stageLabels!.count == 3, "阶段进度固定三段，与三态一一对应")
        self.state = state
        self.eyebrow = eyebrow
        self.title = title
        self.pill = pill
        self.stageLabels = stageLabels
        self.subtitle = subtitle
        self.detail = detail
        self.primary = primary
        self.secondary = secondary
        self.actionNote = actionNote
        self.busyLabel = busyLabel
        self.trailing = trailing()
    }

    private var fill: Color? {
        switch state {
        case .inactive: OneGlass.alertFill
        case .activating: OneGlass.busyFill
        case .ready: nil
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            if let stageLabels {
                StageDots(labels: stageLabels, lit: state.litStages)
            }
            if !state.isSettled, primary != nil {
                actions
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(OneMetrics.space24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(.frosted, radius: OneMetrics.radiusHero, tint: fill)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: state)
        .sensoryFeedbackCompat(state)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 18) {
            Image(systemName: state.systemImage)
                .font(.system(size: 32, weight: .semibold))
                .frame(width: 38, height: 38)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: OneMetrics.space4) {
                if let eyebrow {
                    Text(eyebrow).font(OneText.labelMedium())
                        .foregroundStyle(OnePalette.onSurface.opacity(0.72)).lineLimit(1)
                }
                // 大字号下标题与药丸改竖排，不再挤成省略号
                ViewThatFitsCompat {
                    HStack(spacing: OneMetrics.space10) { titleText; pillView }
                    VStack(alignment: .leading, spacing: OneMetrics.space6) { titleText; pillView }
                }
                if !state.isSettled {
                    if let subtitle { Text(subtitle).font(OneText.bodyLarge()) }
                    if let detail {
                        Text(detail).font(OneText.bodySmall())
                            .foregroundStyle(OnePalette.onSurface.opacity(0.78))
                    }
                }
            }
            Spacer(minLength: 0)
            DotMatrixFace(mood: state.isSettled ? .smile : .frown)
                .padding(OneMetrics.space8)
                .glassSurface(.card, radius: OneMetrics.radiusTile, elevated: false)
                .accessibilityHidden(true)
            trailing
        }
        .accessibilityElement(children: .combine)
    }

    private var titleText: some View {
        Text(title).font(OneText.titleLarge()).lineLimit(1)
            .accessibilityAddTraits(.isHeader)
    }

    private var pillView: some View {
        Text(pill)
            .font(OneText.labelLarge())
            .lineLimit(1)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(OnePalette.onSurface.opacity(0.14)))
    }

    @ViewBuilder
    private var actions: some View {
        VStack(alignment: .leading, spacing: OneMetrics.space8) {
            if state.isBusy {
                Button {} label: {
                    HStack(spacing: OneMetrics.space10) {
                        ProgressView().tint(OnePalette.onHeroButton)
                        Text(busyLabel)
                    }
                }
                .buttonStyle(HeroButtonStyle())
                .disabled(true)
            } else {
                HStack(spacing: OneMetrics.space10) {
                    if let secondary {
                        Button(secondary.title, action: secondary.action).buttonStyle(HeroButtonStyle())
                    }
                    if let primary {
                        Button(primary.title, action: primary.action).buttonStyle(HeroButtonStyle())
                    }
                }
            }
            if let actionNote {
                Text(actionNote).font(OneText.bodySmall())
                    .foregroundStyle(OnePalette.onSurface.opacity(0.72))
                    .padding(.horizontal, OneMetrics.space4)
            }
        }
    }
}

extension StatusHero where Trailing == EmptyView {
    public init(
        state: HeroState, eyebrow: String? = nil, title: String, pill: String,
        stageLabels: [String]? = nil, subtitle: String? = nil, detail: String? = nil,
        primary: HeroAction? = nil, secondary: HeroAction? = nil,
        actionNote: String? = nil, busyLabel: String = "处理中"
    ) {
        self.init(state: state, eyebrow: eyebrow, title: title, pill: pill, stageLabels: stageLabels,
                  subtitle: subtitle, detail: detail, primary: primary, secondary: secondary,
                  actionNote: actionNote, busyLabel: busyLabel) { EmptyView() }
    }
}

/// 家族主按钮：白底黑字药丸，52pt 高，不吃主题色。
public struct HeroButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(OneText.labelLarge())
            .lineLimit(1)
            .foregroundStyle(OnePalette.onHeroButton)
            .frame(maxWidth: .infinity, minHeight: OneMetrics.control)
            .padding(.horizontal, OneMetrics.space16)
            .background(Capsule().fill(OnePalette.heroButton))
            .opacity(enabled ? 1 : 0.38)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

/// 三段阶段进度：圆点 + 连线 + 标签。
struct StageDots: View {
    let labels: [String]
    let lit: Int

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(labels.indices, id: \.self) { i in
                let on = i < lit
                if i > 0 {
                    Rectangle()
                        .fill(OnePalette.onSurface.opacity(on ? 0.55 : 0.18))
                        .frame(height: 2)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity)
                }
                VStack(spacing: OneMetrics.space6) {
                    Circle().fill(OnePalette.onSurface.opacity(on ? 1 : 0.32)).frame(width: 10, height: 10)
                    Text(labels[i]).font(OneText.labelSmall())
                        .foregroundStyle(OnePalette.onSurface.opacity(on ? 1 : 0.32))
                        .lineLimit(1).fixedSize()
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("进度"))
        .accessibilityValue(Text(labels[max(0, min(lit, labels.count) - 1)]))
    }
}
