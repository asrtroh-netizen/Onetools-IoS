import OneUICore
import SwiftUI

private struct InkRippleState {
    var point: CGPoint = .zero
    var radius: CGFloat = 0
    var opacity: Double = 0
    var active = false
}

public struct InkRipple: ViewModifier {
    public var overlayColor: Color?
    public var enabled: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var ripple = InkRippleState()
    @State private var hostSize: CGSize = .zero

    public init(overlayColor: Color? = nil, enabled: Bool = true) {
        self.overlayColor = overlayColor
        self.enabled = enabled
    }

    public func body(content: Content) -> some View {
        let decorated = content.overlay {
            GeometryReader { proxy in
                Canvas { context, size in
                    guard ripple.active else { return }
                    let target = hypot(size.width, size.height) / 2
                    let circle = Path(ellipseIn: CGRect(
                        x: ripple.point.x - ripple.radius,
                        y: ripple.point.y - ripple.radius,
                        width: ripple.radius * 2,
                        height: ripple.radius * 2
                    ))
                    let fallback = colorScheme == .dark
                        ? Color.white.opacity(Double(OneUICore.InkRippleModel.splashAlphaDark) / 255)
                        : Color.gray.opacity(Double(OneUICore.InkRippleModel.splashAlphaLight) / 255)
                    context.fill(circle, with: .color((overlayColor ?? fallback).opacity(ripple.opacity)))
                    if ripple.radius < target + 5 {
                        context.stroke(circle, with: .color((overlayColor ?? fallback).opacity(0.16)), lineWidth: 0.5)
                    }
                }
                .clipShape(ContainerRelativeShape())
                .allowsHitTesting(false)
                .onAppear { hostSize = proxy.size }
                .onChange(of: ripple.active) { active in
                    if active { animate(to: proxy.size) }
                }
            }
        }
        .contentShape(Rectangle())
        if enabled {
            decorated.simultaneousGesture(gesture)
        } else {
            decorated
        }
    }

    private var gesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !ripple.active {
                    ripple.point = value.location
                    let targetRadius = hypot(hostSize.width, hostSize.height) / 2
                    ripple.radius = 0.3 * targetRadius
                    ripple.opacity = 1
                    ripple.active = true
                }
            }
            .onEnded { _ in
                withAnimation(.easeOut(duration: 0.225)) {
                    ripple.radius += 5
                }
                withAnimation(.easeIn(duration: 0.375).delay(0.225)) {
                    ripple.opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    ripple.active = false
                }
            }
    }

    private func animate(to size: CGSize) {
        let target = hypot(size.width, size.height) / 2
        withAnimation(.easeOut(duration: 0.075)) { ripple.opacity = 1 }
        withAnimation(.easeInOut(duration: 1.0)) { ripple.radius = target + 5 }
    }
}

public extension View {
    func inkRipple(_ overlayColor: Color? = nil, enabled: Bool = true) -> some View {
        modifier(InkRipple(overlayColor: overlayColor, enabled: enabled))
    }

    func inkRipple(overlayColor: Color?, enabled: Bool = true) -> some View {
        modifier(InkRipple(overlayColor: overlayColor, enabled: enabled))
    }
}
