import OneUICore
import SwiftUI

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
        let shape = RoundedRectangle(cornerRadius: radius, style: .circular)
        content
            .background { fillLayer(shape) }
            .overlay { shape.strokeBorder(stroke ?? OneGlass.stroke, lineWidth: OneMetrics.stroke) }
            .clipShape(shape)
            .modifier(OptionalShadow(enabled: elevated))
    }

    @ViewBuilder
    private func fillLayer(_ shape: RoundedRectangle) -> some View {
        if reduceTransparency {
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
                    OneBackdropBlurView(sigma: CGFloat(Glass.blurPanel))
                    shape.fill(tint ?? OneGlass.fillStrong)
                }
            case .liquid:
                ZStack {
                    OneBackdropBlurView(sigma: CGFloat(Glass.blurLiquid))
                    shape.fill(tint ?? OneGlass.fill)
                    shape.fill(LiquidHighlight.gradient)
                }
            }
        }
    }
}

enum LiquidHighlight {
    static let gradient = LinearGradient(
        stops: [
            .init(color: .dynamic(UIColor.white.withAlphaComponent(0.38), UIColor.white.withAlphaComponent(0.16)), location: 0),
            .init(color: .dynamic(UIColor.white.withAlphaComponent(0.06), UIColor.white.withAlphaComponent(0.02)), location: 0.42),
            .init(color: .dynamic(UIColor.black.withAlphaComponent(0.05), UIColor.black.withAlphaComponent(0.12)), location: 1),
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

private struct OptionalShadow: ViewModifier {
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled { content.oneShadow(strong: true) } else { content }
    }
}

extension View {
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

public struct OneBackdrop: View {
    public init() {}
    public var body: some View {
        LinearGradient(
            colors: [OnePalette.backdropTop, OnePalette.backdropBottom],
            startPoint: .top,
            endPoint: .bottom
        ).ignoresSafeArea()
    }
}
