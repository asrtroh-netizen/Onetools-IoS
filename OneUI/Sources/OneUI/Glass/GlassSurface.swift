import SwiftUI

/// 玻璃面的三档材质，对应 Flutter 版的三种做法：
/// - `.sheer` / `.card`：半透明填充 + 发丝边，不模糊（列表卡用，性能优先）
/// - `.frosted`：真模糊（GlassPanel / StatusHero 这类少数高价值面）
/// - `.liquid`：iOS 26+ 用系统 Liquid Glass；更早系统退回 `.frosted` + 顶边高光
public enum GlassMaterial: Sendable {
    case sheer
    case card
    case frosted
    case liquid
}

public struct GlassSurface: ViewModifier {
    var material: GlassMaterial
    var radius: CGFloat
    var tint: Color?
    var stroke: Color?
    var elevated: Bool

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        content
            .background { fillLayer(shape) }
            .overlay { shape.strokeBorder(stroke ?? OneGlass.stroke, lineWidth: OneMetrics.stroke) }
            .clipShape(shape)
            .modifier(OptionalShadow(enabled: elevated))
    }

    @ViewBuilder
    private func fillLayer(_ shape: RoundedRectangle) -> some View {
        if reduceTransparency {
            // 「降低透明度」：所有玻璃退回实底，tint 仍然叠上去保留语义色。
            ZStack {
                shape.fill(OneGlass.solid)
                if let tint { shape.fill(tint) }
            }
        } else {
            switch material {
            case .sheer:
                shape.fill(tint ?? OneGlass.fill)
            case .card:
                shape.fill(tint ?? OneGlass.fillStrong)
            case .frosted:
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill(tint ?? OneGlass.fillStrong)
                }
            case .liquid:
                LiquidBackground(shape: shape, tint: tint)
            }
        }
    }
}

private struct LiquidBackground: View {
    let shape: RoundedRectangle
    let tint: Color?

    var body: some View {
        if #available(iOS 26.0, *) {
            // 系统 Liquid Glass 自带折射与高光，不再手搓透镜矩阵。
            Color.clear.glassEffect(
                tint.map { Glass.regular.tint($0) } ?? .regular,
                in: shape
            )
        } else {
            ZStack {
                shape.fill(.ultraThinMaterial)
                shape.fill(tint ?? OneGlass.fill)
                shape.fill(LiquidHighlight.gradient)
            }
        }
    }
}

/// 没有系统 Liquid Glass 时的顶边高光 + 底边内阴影（`Glass.liquidHighlight`）。
enum LiquidHighlight {
    static let gradient = LinearGradient(
        stops: [
            .init(color: .dynamic(UIColor.white.withAlphaComponent(0.38), UIColor.white.withAlphaComponent(0.16)), location: 0),
            .init(color: .dynamic(UIColor.white.withAlphaComponent(0.06), UIColor.white.withAlphaComponent(0.02)), location: 0.42),
            .init(color: .dynamic(UIColor.black.withAlphaComponent(0.05), UIColor.black.withAlphaComponent(0.12)), location: 1),
        ],
        startPoint: .top, endPoint: .bottom
    )
}

private struct OptionalShadow: ViewModifier {
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled { content.oneShadow(strong: true) } else { content }
    }
}

extension View {
    /// 给任意视图套 One 玻璃皮。
    public func glassSurface(
        _ material: GlassMaterial = .card,
        radius: CGFloat = OneMetrics.radiusCard,
        tint: Color? = nil,
        stroke: Color? = nil,
        elevated: Bool = true
    ) -> some View {
        modifier(GlassSurface(material: material, radius: radius, tint: tint, stroke: stroke, elevated: elevated))
    }
}

// MARK: - 应用底

/// 玻璃要有东西可透：全屏渐变底。中性色板走亮度差（顶亮底沉），不染色。
public struct OneBackdrop: View {
    public init() {}

    public var body: some View {
        LinearGradient(
            colors: [OnePalette.backdropTop, OnePalette.backdropBottom],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
