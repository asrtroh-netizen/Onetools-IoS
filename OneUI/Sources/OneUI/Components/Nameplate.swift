import SwiftUI

/// 铭牌：小圆点 + 短词（WEB `overview-badge`）。亮度在圆点辉光上，牌面只透一点色。
public struct Nameplate: View {
    public enum Size { case compact, regular, hero }

    let label: String
    let detail: String?
    let tone: OneTone
    let size: Size

    public init(_ label: String, detail: String? = nil, tone: OneTone = .neutral, size: Size = .compact) {
        self.label = label
        self.detail = detail
        self.tone = tone
        self.size = size
    }

    /// 「已连接」快捷写法。
    public static func ready(_ label: String, detail: String? = nil) -> Nameplate {
        Nameplate(label, detail: detail, tone: .green)
    }

    private var lit: Bool { tone != .neutral }

    public var body: some View {
        let hero = size == .hero
        HStack(spacing: hero ? 8 : 6) {
            Circle()
                .fill(lit ? tone.color : OnePalette.onSurfaceVariant.opacity(0.55))
                .frame(width: hero ? 8 : 6, height: hero ? 8 : 6)
                .shadow(color: lit ? tone.color.opacity(0.8) : .clear, radius: 5)
            Text(label)
                .font(hero ? OneText.bodyMedium(.semibold) : OneText.labelSmall())
                .foregroundStyle(lit ? tone.ink : OnePalette.onSurface)
                .lineLimit(1)
            if let detail, !detail.isEmpty {
                Text(detail)
                    .font(OneText.labelSmall())
                    .monospacedDigit()
                    .foregroundStyle((lit ? tone.ink : OnePalette.onSurface).opacity(0.82))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, hero ? 16 : size == .compact ? 8 : 12)
        .padding(.vertical, hero ? 10 : size == .compact ? 4 : 8)
        .glassSurface(
            .sheer,
            radius: hero ? OneMetrics.radiusTile : OneMetrics.radiusChip,
            tint: lit ? tone.tint(light: 0.10, dark: 0.12) : nil,
            stroke: lit ? tone.tint(light: 0.32, dark: 0.24) : nil,
            elevated: false
        )
        .accessibilityElement(children: .combine)
    }
}

/// 卡片头行：图标 + 标题 …… 右侧铭牌。标题截断，牌不挤掉标题。
public struct CardHeadRow<Trailing: View>: View {
    let title: String
    let systemImage: String?
    let trailing: Trailing

    public init(_ title: String, systemImage: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.systemImage = systemImage
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: OneMetrics.space8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(OnePalette.onSurface)
            }
            Text(title)
                .font(OneText.titleMedium())
                .tracking(-0.2)
                .lineLimit(1)
                .layoutPriority(1)
            Spacer(minLength: OneMetrics.space8)
            trailing
        }
    }
}

extension CardHeadRow where Trailing == EmptyView {
    public init(_ title: String, systemImage: String? = nil) {
        self.init(title, systemImage: systemImage) { EmptyView() }
    }
}
