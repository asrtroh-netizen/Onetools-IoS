import SwiftUI
import UIKit

/// 尺寸标度：8pt 栅格 + 圆角 + 描边，与 `glass.dart` / `one_tokens.dart` 一一对应。
/// Flutter 版有 Glass 与 OneSpacing/OneRadii 两套同值别名，这里只留一套。
public enum OneMetrics {
    // 圆角（全部用 .continuous，统一了 Flutter 版 circular / superellipse 混用的问题）
    public static let radiusCard: CGFloat = 18
    public static let radiusTile: CGFloat = 14
    public static let radiusChip: CGFloat = 10
    public static let radiusHero: CGFloat = 22

    // 间距
    public static let space2: CGFloat = 2
    public static let space4: CGFloat = 4
    public static let space6: CGFloat = 6
    public static let space8: CGFloat = 8
    public static let space10: CGFloat = 10
    public static let space12: CGFloat = 12
    public static let space16: CGFloat = 16
    public static let space20: CGFloat = 20
    public static let space24: CGFloat = 24

    /// 一级 / 二级页统一左右外边距。
    public static let pageMargin: CGFloat = 16
    /// 竖直堆叠的卡片间距。
    public static let cardGap: CGFloat = 14
    /// 卡内统一内边距。
    public static let cardPadding: CGFloat = 16

    public static let stroke: CGFloat = 0.8
    public static let minimumTarget: CGFloat = 44
    public static let control: CGFloat = 52
}

// MARK: - 状态色

/// 语义色。Flutter 版 `PlateTone` 有 6 个值，但 blue 早已等于 green、purple 等于 teal，
/// 这里收敛成实际存在的 4 种，避免「选了蓝色却显示绿色」。
public enum OneTone: Sendable, Hashable {
    case neutral
    /// 通畅 / 就绪 / 进行中。
    case green
    /// 信息 / 品牌青。
    case teal
    /// 失败。
    case red

    var base: UIColor? {
        switch self {
        case .neutral: nil
        case .green: UIColor(hex: 0x34D399)
        case .teal: UIColor(hex: 0x2DD4BF)
        case .red: UIColor(hex: 0xF87171)
        }
    }

    /// 图形色（圆点、阶段条、描边）。neutral 走 onSurface。
    public var color: Color {
        guard let base else { return OnePalette.onSurface }
        return Color(uiColor: base)
    }

    /// 文字色：浅色模式把亮色压暗一档（黑 .38 叠加），否则对比度不够。
    public var ink: Color {
        guard let base else { return OnePalette.onSurface }
        let darkened = base.mixed(with: .black, 0.38)
        return Color.dynamic(darkened, base)
    }

    /// 选中态边缘高光用的提亮色。
    var bright: UIColor? { base?.mixed(with: .white, 0.4) }

    /// 浅 / 深色各自的透明度取值。
    func tint(light: CGFloat, dark: CGFloat) -> Color {
        guard let base else {
            return OnePalette.onSurface.opacity(Double(light))
        }
        return Color.dynamic(base.withAlphaComponent(light), base.withAlphaComponent(dark))
    }
}

// MARK: - 投影

/// 深色单层柔黑影；浅色双层（接触影 + 环境影），与 `Glass.shadow` 数值一致。
/// Flutter blurRadius ≈ 2 × SwiftUI radius，已换算。
struct OneShadow: ViewModifier {
    var strong = false
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        if scheme == .dark {
            content.shadow(
                color: .black.opacity(strong ? 0.32 : 0.28),
                radius: strong ? 11 : 9, y: strong ? 10 : 8
            )
        } else {
            content
                .shadow(color: .black.opacity(strong ? 0.10 : 0.08), radius: strong ? 4 : 3, y: strong ? 3 : 2)
                .shadow(color: .black.opacity(strong ? 0.20 : 0.16), radius: strong ? 14 : 11, y: strong ? 12 : 10)
        }
    }
}

extension View {
    func oneShadow(strong: Bool = false) -> some View {
        modifier(OneShadow(strong: strong))
    }
}
