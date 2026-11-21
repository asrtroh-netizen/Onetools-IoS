import OneUICore
import SwiftUI
import UIKit

public struct UltraGlassDock: View {
    public struct Item: Identifiable, Sendable {
        public let id: String
        public let icon: String
        public let label: String

        public init(id: String, icon: String, label: String) {
            self.id = id
            self.icon = icon
            self.label = label
        }
    }

    public let items: [Item]
    @Binding public var selectedIndex: Int
    public let onSelect: ((Int) -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    @State private var fromIndex: Int = 0
    @State private var toIndex: Int = 0
    @State private var slideProgress: Double = 1.0
    @State private var keyboardVisible: Bool = false

    public init(items: [Item], selectedIndex: Binding<Int>, onSelect: ((Int) -> Void)? = nil) {
        self.items = items
        self._selectedIndex = selectedIndex
        self.onSelect = onSelect
    }

    public var body: some View {
        Group {
            if !keyboardVisible {
                GeometryReader { proxy in
                    let innerWidth = indicatorTrackWidth(proxy.size.width)
                    ZStack(alignment: .leading) {
                        indicator(trackWidth: innerWidth)
                        HStack(spacing: 0) {
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                let isSelected = index == selectedIndex
                                Button {
                                    select(index)
                                } label: {
                                    VStack(spacing: 4) {
                                        MaterialIcon(
                                            name: item.icon,
                                            size: 20,
                                            color: isSelected ? OnePalette.accent : OnePalette.onSurfaceVariant
                                        )
                                        if isSelected {
                                            OneStyledText(
                                                item.label,
                                                size: 11,
                                                weight: 600,
                                                heightMultiplier: 1.45,
                                                tracking: 0.5,
                                                color: UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0xE2E2E9) : UIColor(hex: 0x1A1B20) },
                                                lineLimit: 1
                                            )
                                        } else {
                                            Text(item.label)
                                                .font(OneText.labelSmall(.medium))
                                                .tracking(0.5)
                                                .foregroundStyle(OnePalette.onSurfaceVariant)
                                                .lineLimit(1)
                                        }
                                    }
                                    .dynamicTypeSize(.large)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                }
                                .buttonStyle(.plain)
                                .contentShape(Capsule())
                                .inkRipple(OnePalette.accent.opacity(0.10))
                                .accessibilityLabel(Text(item.label))
                                .accessibilityAddTraits(isSelected ? .isSelected : [])
                            }
                        }
                        .padding(.horizontal, OneMetrics.space4)
                    }
                    .frame(height: CGFloat(Glass.dockHeight))
                    .background { dockCapsuleBackground }
                    .padding(.horizontal, OneMetrics.pageMargin)
                    .padding(.bottom, CGFloat(Glass.dockBottomGap) + proxy.safeAreaInsets.bottom)
                }
                .frame(height: CGFloat(Glass.dockHeight + Glass.dockBottomGap))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            fromIndex = selectedIndex
            toIndex = selectedIndex
            slideProgress = 1.0
        }
        .onChange(of: selectedIndex) { next in
            guard next != toIndex else { return }
            fromIndex = toIndex
            toIndex = next
            if reduceMotion {
                slideProgress = 1.0
            } else {
                slideProgress = 0.0
                withAnimation(.linear(duration: 0.48)) {
                    slideProgress = 1.0
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) { keyboardVisible = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) { keyboardVisible = false }
        }
    }

    private var dockCapsuleBackground: some View {
        let shape = RoundedRectangle(cornerRadius: OneMetrics.radiusDock, style: .circular)
        let rimStops: [Gradient.Stop] = colorScheme == .dark
            ? [
                .init(color: .white.opacity(Double(0x8C) / 255.0), location: 0.0),
                .init(color: .white.opacity(Double(0x1A) / 255.0), location: 0.45),
                .init(color: .white.opacity(Double(0x47) / 255.0), location: 1.0),
            ]
            : [
                .init(color: .white.opacity(Double(0xB8) / 255.0), location: 0.0),
                .init(color: .white.opacity(Double(0x2E) / 255.0), location: 0.45),
                .init(color: .white.opacity(Double(0x52) / 255.0), location: 1.0),
            ]
        return shape
            .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.12))
            .background {
                OneBackdropBlurView(sigma: CGFloat(Glass.blurDock))
                    .clipShape(shape)
            }
            .overlay {
                shape.strokeBorder(
                    LinearGradient(stops: rimStops, startPoint: .top, endPoint: .bottom),
                    lineWidth: 1.25
                )
            }
    }

    private func indicator(trackWidth: CGFloat) -> some View {
        let count = max(items.count, 1)
        let cell = max(trackWidth / CGFloat(count), 1)
        return Color.clear
            .modifier(
                LiquidDockIndicatorModifier(
                    progress: slideProgress,
                    from: fromIndex,
                    to: toIndex,
                    cellWidth: cell,
                    dark: colorScheme == .dark
                )
            )
            .allowsHitTesting(false)
    }

    private func indicatorTrackWidth(_ total: CGFloat) -> CGFloat {
        let horizontal = 2 * OneMetrics.pageMargin + 2 * OneMetrics.space4
        return max(0, total - horizontal)
    }

    private func select(_ index: Int) {
        selectedIndex = index
        onSelect?(index)
    }
}

private struct LiquidDockIndicatorModifier: AnimatableModifier {
    var progress: Double
    let from: Int
    let to: Int
    let cellWidth: CGFloat
    let dark: Bool

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    private static func easeOutCubic(_ t: Double) -> Double {
        let inv = 1.0 - t
        return 1.0 - inv * inv * inv
    }

    private static func easeInCubic(_ t: Double) -> Double {
        t * t * t
    }

    func body(content: Content) -> some View {
        let t = min(1.0, max(0.0, progress))
        let f = Double(from)
        let d = Double(to)
        let leftEdge: Double
        let rightEdge: Double
        if d >= f {
            leftEdge = f + (d - f) * Self.easeInCubic(t)
            rightEdge = (f + 1.0) + (d - f) * Self.easeOutCubic(t)
        } else {
            leftEdge = f + (d - f) * Self.easeOutCubic(t)
            rightEdge = (f + 1.0) + (d - f) * Self.easeInCubic(t)
        }

        let spanWidth = max(cellWidth * CGFloat(rightEdge - leftEdge), 1)
        let offsetX = OneMetrics.space4 + cellWidth * CGFloat(leftEdge)
        let arc = sin(.pi * t)
        let fillAlpha = dark ? (0.10 + 0.04 * arc) : (0.08 + 0.02 * arc)
        let fillBase: Color = dark ? .white : Color(uiColor: UIColor(hex: 0x1A1B20))
        let strokeOpacity = 0.85 * arc
        let radius = OneMetrics.radiusDock - 4
        let pillShape = RoundedRectangle(cornerRadius: radius, style: .circular)

        let specularColors: [Color] = dark
            ? [
                .white.opacity((Double(0x3D) / 255.0) * strokeOpacity),
                .white.opacity((Double(0x0F) / 255.0) * strokeOpacity),
                .white.opacity((Double(0x24) / 255.0) * strokeOpacity),
                .white.opacity((Double(0x0A) / 255.0) * strokeOpacity),
                .white.opacity((Double(0x3D) / 255.0) * strokeOpacity),
            ]
            : [
                .white.opacity((Double(0x66) / 255.0) * strokeOpacity),
                .white.opacity((Double(0x14) / 255.0) * strokeOpacity),
                .black.opacity((Double(0x14) / 255.0) * strokeOpacity),
                .white.opacity((Double(0x0A) / 255.0) * strokeOpacity),
                .white.opacity((Double(0x66) / 255.0) * strokeOpacity),
            ]

        return ZStack(alignment: .leading) {
            content
            pillShape
                .fill(fillBase.opacity(fillAlpha))
                .overlay {
                    if strokeOpacity > 0.01 {
                        pillShape.strokeBorder(
                            AngularGradient(colors: specularColors, center: .center),
                            lineWidth: 1.2
                        )
                    }
                }
                .frame(width: spanWidth, height: CGFloat(Glass.dockIndicatorHeight))
                .offset(x: offsetX, y: 0)
        }
    }
}
