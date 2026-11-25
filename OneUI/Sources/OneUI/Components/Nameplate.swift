import SwiftUI
import UIKit

/// 铭牌：小圆点 + 短词（WEB `overview-badge`）。亮度在圆点辉光上，牌面只透一点色。
public struct Nameplate: View {
    public enum Size { case compact, regular, hero }

    let label: String
    let detail: String?
    let tone: OneTone
    let size: Size
    let isLifted: Bool

    public init(
        _ label: String,
        detail: String? = nil,
        tone: OneTone = .neutral,
        size: Size = .compact,
        lifted: Bool = false
    ) {
        self.label = label
        self.detail = detail
        self.tone = tone
        self.size = size
        self.isLifted = lifted
    }

    /// 「已连接」快捷写法。
    public static func ready(_ label: String, detail: String? = nil) -> Nameplate {
        Nameplate(label, detail: detail, tone: .green)
    }

    /// 花底压暗深底白字铭牌（原版 `Nameplate(lifted: true)`，`0xF2141414` 叠 `accent .32`）。
    public static func lifted(_ label: String, detail: String? = nil, tone: OneTone = .neutral) -> Nameplate {
        Nameplate(label, detail: detail, tone: tone, lifted: true)
    }

    private var lit: Bool { tone != .neutral }

    private var liftedFill: Color {
        let darkBase = UIColor(hex: 0x141414, alpha: 0.949)
        guard let accent = tone.base else { return Color(uiColor: darkBase) }
        return Color(uiColor: darkBase.mixed(with: accent, 0.32))
    }

    public var body: some View {
        let hero = size == .hero
        let radius = hero ? OneMetrics.radiusTile : OneMetrics.radiusChip
        let shape = RoundedRectangle(cornerRadius: radius, style: .circular)
        let resolvedInk: Color = isLifted ? .white : (lit ? tone.ink : OnePalette.onSurface)
        let resolvedUIColor: UIColor? = isLifted
            ? .white
            : (lit ? tone.base.map { base in
                let darkened = base.mixed(with: .black, 0.38)
                return UIColor { $0.userInterfaceStyle == .dark ? base : darkened }
            } : nil)

        HStack(spacing: hero ? 8 : 6) {
            Circle()
                .fill(lit ? tone.color : OnePalette.onSurfaceVariant.opacity(0.55))
                .frame(width: hero ? 8 : 6, height: hero ? 8 : 6)
                .shadow(color: lit ? tone.color.opacity(0.8) : .clear, radius: 5)
            if hero {
                OneStyledText(
                    label,
                    size: 14,
                    weight: 600,
                    heightMultiplier: 1.43,
                    tracking: 0.1,
                    color: resolvedUIColor,
                    lineLimit: 1
                )
            } else if isLifted {
                OneStyledText(
                    label,
                    size: 11,
                    weight: 700,
                    heightMultiplier: 1.45,
                    tracking: 0.5,
                    color: .white,
                    lineLimit: 1
                )
            } else {
                Text(label)
                    .font(OneText.labelSmall())
                    .foregroundStyle(resolvedInk)
                    .lineLimit(1)
            }
            if let detail, !detail.isEmpty {
                Text(detail)
                    .font(OneText.labelSmall())
                    .monospacedDigit()
                    .foregroundStyle(resolvedInk.opacity(0.82))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, hero ? 16 : size == .compact ? 8 : 12)
        .padding(.vertical, hero ? 10 : size == .compact ? 4 : 8)
        .background {
            if isLifted {
                shape.fill(liftedFill)
            } else {
                shape.fill(lit ? tone.tint(light: 0.10, dark: 0.12) : OneGlass.fill)
            }
        }
        .overlay {
            let border = isLifted
                ? (lit ? tone.color.opacity(0.78) : Color.white.opacity(0.24))
                : (lit ? tone.tint(light: 0.32, dark: 0.24) : OneGlass.stroke)
            shape.strokeBorder(border, lineWidth: OneMetrics.stroke)
        }
        .clipShape(shape)
        .shadow(color: isLifted ? .black.opacity(0.60) : .clear, radius: isLifted ? 4 : 0, y: isLifted ? 2 : 0)
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
                MaterialIcon(name: systemImage, size: 20, color: OnePalette.onSurface)
            }
            OneStyledText(
                title,
                size: 16,
                weight: 600,
                heightMultiplier: 1.50,
                tracking: -0.2,
                lineLimit: 1
            )
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


