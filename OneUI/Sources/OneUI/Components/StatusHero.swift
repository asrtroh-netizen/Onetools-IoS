import SwiftUI

public enum HeroState: Int, Sendable, CaseIterable { case inactive, activating, ready
    var isAlert: Bool { self == .inactive }; var isBusy: Bool { self == .activating }; var isSettled: Bool { self == .ready }; var litStages: Int { rawValue + 1 }
    var iconName: String { switch self { case .inactive: "warning_rounded"; case .activating: "refresh_rounded"; case .ready: "check_circle_rounded" } }
}
public struct HeroAction { let title: String; let action: () -> Void; public init(_ title: String, action: @escaping () -> Void) { self.title = title; self.action = action } }

public enum OneStatusHeroTone: Sendable { case healthy, critical, attention, neutral }

public struct StatusHero<Trailing: View>: View {
    let state: HeroState; let eyebrow: String?; let title: String; let pill: String; let stageLabels: [String]?; let subtitle: String?; let detail: String?; let primary: HeroAction?; let secondary: HeroAction?; let actionNote: String?; let busyLabel: String; let trailing: Trailing
    @State private var compactHeader = false

    public init(state: HeroState, eyebrow: String? = nil, title: String, pill: String, stageLabels: [String]? = nil, subtitle: String? = nil, detail: String? = nil, primary: HeroAction? = nil, secondary: HeroAction? = nil, actionNote: String? = nil, busyLabel: String = "处理中", @ViewBuilder trailing: () -> Trailing) {
        precondition(stageLabels == nil || stageLabels!.count == 3, "阶段进度固定三段")
        self.state = state; self.eyebrow = eyebrow; self.title = title; self.pill = pill; self.stageLabels = stageLabels; self.subtitle = subtitle; self.detail = detail; self.primary = primary; self.secondary = secondary; self.actionNote = actionNote; self.busyLabel = busyLabel; self.trailing = trailing()
    }
    private var fill: Color? { switch state { case .inactive: OneGlass.alertFill; case .activating: OneGlass.busyFill; case .ready: nil } }
    public var body: some View {
        VStack(alignment: .leading, spacing: OneMetrics.space16) {
            header(compact: compactHeader)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: HeroWidthPreferenceKey.self, value: proxy.size.width)
                    }
                )
                .onPreferenceChange(HeroWidthPreferenceKey.self) { width in
                    if width > 0 {
                        compactHeader = width < 300
                    }
                }
            if let stageLabels { StageDots(labels: stageLabels, lit: state.litStages) }
            if !state.isSettled, primary != nil { actions.transition(.opacity.combined(with: .move(edge: .bottom))) }
        }
        .padding(OneMetrics.space24).frame(maxWidth: .infinity, alignment: .leading)
        .background {
            let heroShape = RoundedRectangle(cornerRadius: OneMetrics.radiusHero, style: .circular)
            ZStack {
                OneBackdropBlurView(sigma: 24)
                heroShape.fill(fill ?? OneGlass.fill)
            }
            .clipShape(heroShape)
        }
        .overlay {
            RoundedRectangle(cornerRadius: OneMetrics.radiusHero, style: .circular)
                .strokeBorder(OneGlass.stroke, lineWidth: OneMetrics.stroke)
        }
        .clipShape(RoundedRectangle(cornerRadius: OneMetrics.radiusHero, style: .circular))
        .oneShadow(strong: true)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: state)
    }
    @ViewBuilder private func header(compact: Bool) -> some View {
        if compact {
            VStack(alignment: .leading, spacing: OneMetrics.space10) {
                HStack(alignment: .top, spacing: OneMetrics.space12) { icon; titleBlock; Spacer(minLength: 0) }
                HStack(spacing: OneMetrics.space8) { DotMatrixFace(mood: state.isSettled ? .smile : .frown).padding(OneMetrics.space8).glassSurface(.card, radius: OneMetrics.radiusTile, elevated: false); trailing }
            }
        } else {
            HStack(alignment: .top, spacing: OneMetrics.space16) { icon; titleBlock; Spacer(minLength: 0); DotMatrixFace(mood: state.isSettled ? .smile : .frown).padding(OneMetrics.space8).glassSurface(.card, radius: OneMetrics.radiusTile, elevated: false); trailing }
        }
    }
    private var icon: some View { MaterialIcon(name: state.iconName, size: 38, color: OnePalette.onSurface).frame(width: 38, height: 38).accessibilityHidden(true) }
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: OneMetrics.space4) {
            if let eyebrow { Text(eyebrow).font(OneText.labelMedium()).foregroundStyle(OnePalette.onSurface.opacity(0.72)).lineLimit(1) }
            HStack(spacing: OneMetrics.space10) {
                Text(title).font(OneText.titleLarge()).lineLimit(1).accessibilityAddTraits(.isHeader)
                OneStyledText(pill, size: 14, weight: 600, heightMultiplier: 1.43, tracking: 0.1, lineLimit: 1)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(OnePalette.onSurface.opacity(0.14)))
            }
            if !state.isSettled {
                if let subtitle { Text(subtitle).font(OneText.bodyLarge()) }
                if let detail { Text(detail).font(OneText.bodySmall()).foregroundStyle(OnePalette.onSurface.opacity(0.78)) }
            }
        }
    }
    @ViewBuilder private var actions: some View {
        VStack(alignment: .leading, spacing: OneMetrics.space8) {
            if state.isBusy { Button {} label: { HStack(spacing: OneMetrics.space10) { ProgressView().tint(OnePalette.onHeroButton); Text(busyLabel) } }.buttonStyle(HeroButtonStyle()).disabled(true) }
            else { HStack(spacing: OneMetrics.space10) { if let secondary { Button(secondary.title, action: secondary.action).buttonStyle(HeroButtonStyle()) }; if let primary { Button(primary.title, action: primary.action).buttonStyle(HeroButtonStyle()) } } }
            if let actionNote { Text(actionNote).font(OneText.bodySmall()).foregroundStyle(OnePalette.onSurface.opacity(0.72)).padding(.horizontal, OneMetrics.space4) }
        }
    }
}
extension StatusHero where Trailing == EmptyView { public init(state: HeroState, eyebrow: String? = nil, title: String, pill: String, stageLabels: [String]? = nil, subtitle: String? = nil, detail: String? = nil, primary: HeroAction? = nil, secondary: HeroAction? = nil, actionNote: String? = nil, busyLabel: String = "处理中") { self.init(state: state, eyebrow: eyebrow, title: title, pill: pill, stageLabels: stageLabels, subtitle: subtitle, detail: detail, primary: primary, secondary: secondary, actionNote: actionNote, busyLabel: busyLabel) { EmptyView() } } }

public struct OneStatusHero: View {
    public static let defaultStages = ["关闭", "处理中", "就绪"]

    let tone: OneStatusHeroTone
    let title: String
    let subtitle: String?
    let detail: String?
    let showStages: Bool
    let action: HeroAction?

    public init(
        tone: OneStatusHeroTone,
        title: String,
        subtitle: String? = nil,
        detail: String? = nil,
        showStages: Bool = true,
        action: HeroAction? = nil
    ) {
        self.tone = tone
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.showStages = showStages
        self.action = action
    }

    public var body: some View {
        StatusHero(
            state: state,
            title: title,
            pill: pill,
            stageLabels: showStages ? Self.defaultStages : nil,
            subtitle: subtitle,
            detail: detail,
            primary: action
        )
    }

    private var state: HeroState {
        switch tone {
        case .healthy: .ready
        case .critical, .attention: .inactive
        case .neutral: .activating
        }
    }

    private var pill: String {
        switch tone {
        case .healthy: "就绪"
        case .critical, .attention: "注意"
        case .neutral: "处理中"
        }
    }
}

private struct HeroWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        if nextValue() > 0 { value = nextValue() }
    }
}

public struct HeroButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    public init() {}
    public func makeBody(configuration: Configuration) -> some View { configuration.label.font(OneText.labelLarge()).lineLimit(1).foregroundStyle(OnePalette.onHeroButton).frame(maxWidth: .infinity, minHeight: OneMetrics.control).padding(.horizontal, OneMetrics.space16).background(Capsule().fill(OnePalette.heroButton)).opacity(enabled ? 1 : 0.38).inkRipple(overlayColor: OnePalette.onSurface.opacity(0.10)) }
}

struct StageDots: View {
    let labels: [String]; let lit: Int
    var body: some View { HStack(alignment: .top, spacing: 0) { ForEach(labels.indices, id: \.self) { i in let on = i < lit; if i > 0 { Rectangle().fill(OnePalette.onSurface.opacity(on ? 0.55 : 0.18)).frame(height: 2).padding(.top, 4).frame(maxWidth: .infinity) }; VStack(spacing: OneMetrics.space6) { Circle().fill(OnePalette.onSurface.opacity(on ? 1 : 0.32)).frame(width: 10, height: 10); Text(labels[i]).font(OneText.labelSmall()).foregroundStyle(OnePalette.onSurface.opacity(on ? 1 : 0.32)).lineLimit(1).fixedSize() } } }.accessibilityElement(children: .ignore).accessibilityLabel(Text("进度")) }
}

