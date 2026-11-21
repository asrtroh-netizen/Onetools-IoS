import OneUICore
import SwiftUI

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

    public init(items: [Item], selectedIndex: Binding<Int>, onSelect: ((Int) -> Void)? = nil) {
        self.items = items
        self._selectedIndex = selectedIndex
        self.onSelect = onSelect
    }

    public var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button {
                        select(index)
                    } label: {
                        VStack(spacing: 4) {
                            MaterialIcon(name: item.icon, size: 20, color: index == selectedIndex ? OnePalette.accent : OnePalette.onSurfaceVariant)
                            Text(item.label)
                                .font(OneText.labelSmall(index == selectedIndex ? .semibold : .medium))
                                .foregroundStyle(index == selectedIndex ? OnePalette.accent : OnePalette.onSurfaceVariant)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .inkRipple(OnePalette.accent.opacity(0.10))
                }
            }
            .padding(.horizontal, OneMetrics.space4)
            .frame(height: CGFloat(Glass.dockHeight))
            .background {
                RoundedRectangle(cornerRadius: OneMetrics.radiusDock, style: .circular)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.12))
                    .background {
                        OneBackdropBlurView(sigma: CGFloat(Glass.blurDock))
                            .clipShape(RoundedRectangle(cornerRadius: OneMetrics.radiusDock, style: .circular))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: OneMetrics.radiusDock, style: .circular)
                            .strokeBorder(
                                AngularGradient(
                                    colors: colorScheme == .dark
                                        ? [.white.opacity(0.55), .white.opacity(0.10), .white.opacity(0.28)]
                                        : [.white.opacity(0.72), .white.opacity(0.18), .white.opacity(0.32)],
                                    center: .center
                                ),
                                lineWidth: 1.25
                            )
                    }
            }
            .overlay(alignment: .leading) { indicator(width: indicatorWidth(proxy.size.width)) }
            .padding(.horizontal, OneMetrics.pageMargin)
            .padding(.bottom, CGFloat(Glass.dockBottomGap) + proxy.safeAreaInsets.bottom)
        }
        .frame(height: CGFloat(Glass.dockHeight + Glass.dockBottomGap))
    }

    private func indicator(width: CGFloat) -> some View {
        let count = max(items.count, 1)
        let cell = max(width / CGFloat(count), 1)
        return RoundedRectangle(cornerRadius: OneMetrics.radiusDock - 4, style: .circular)
            .fill(OnePalette.accent.opacity(0.08))
            .overlay {
                RoundedRectangle(cornerRadius: OneMetrics.radiusDock - 4, style: .circular)
                    .strokeBorder(AngularGradient(colors: [.mint, .cyan, .blue, .purple, .pink], center: .center), lineWidth: 1.2)
            }
            .frame(width: cell, height: CGFloat(Glass.dockIndicatorHeight))
            .offset(x: CGFloat(selectedIndex) * cell + OneMetrics.space4, y: 0)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.48), value: selectedIndex)
            .allowsHitTesting(false)
    }

    private func indicatorWidth(_ total: CGFloat) -> CGFloat {
        let horizontal = 2 * OneMetrics.pageMargin + 2 * OneMetrics.space4
        return max(0, total - horizontal)
    }

    private func select(_ index: Int) {
        selectedIndex = index
        onSelect?(index)
    }
}
