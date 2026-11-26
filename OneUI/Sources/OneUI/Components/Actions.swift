import SwiftUI

private struct OneActionPressButtonStyle: ButtonStyle {
    let scale: CGFloat
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(OneSpringPressModifier(isPressed: configuration.isPressed, targetScale: scale))
    }
}

public struct GlassActionButton: View {
    let title: String
    let icon: String?
    let busy: Bool
    let selected: Bool
    let action: () -> Void
    @Environment(\.isEnabled) private var enabled

    public init(_ title: String, systemImage: String? = nil, busy: Bool = false, selected: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = systemImage
        self.busy = busy
        self.selected = selected
        self.action = action
    }

    public var body: some View {
        let active = enabled && !busy
        let ink = active ? (selected ? OneTone.green.ink : OnePalette.onSurface) : OnePalette.onSurface.opacity(0.38)
        Button(action: action) {
            HStack(spacing: OneMetrics.space6) {
                if busy {
                    OneRhythmBars(color: ink, height: 13)
                } else if let icon {
                    MaterialIcon(name: icon, size: 16, color: ink)
                }
                Text(title).font(OneText.labelMedium()).lineLimit(1)
            }
            .foregroundStyle(ink)
            .padding(.horizontal, OneMetrics.space12)
            .padding(.vertical, OneMetrics.space8)
            .glassSurface(.sheer, radius: OneMetrics.radiusChip, stroke: selected ? OneTone.green.color.opacity(0.9) : nil, elevated: false)
            .frame(minWidth: OneMetrics.minimumTarget, minHeight: OneMetrics.minimumTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(OneActionPressButtonStyle(scale: 0.97))
        .inkRipple(overlayColor: selected ? OneTone.green.color.opacity(0.10) : OnePalette.onSurface.opacity(0.10))
        .disabled(busy)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

public typealias GlassAction = GlassActionButton

public struct ChoiceChips<Value: Hashable>: View {
    let options: [(value: Value, label: String)]
    @Binding var selection: Value

    public init(_ options: [(value: Value, label: String)], selection: Binding<Value>) {
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                OneWrapLayout(spacing: OneMetrics.space8) {
                    ForEach(options.indices, id: \.self) { index in
                        chipButton(for: options[index])
                    }
                }
            } else {
                LegacyChipFlow(options: options, spacing: OneMetrics.space8) { option in
                    chipButton(for: option)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: selection)
    }

    private func chipButton(for option: (value: Value, label: String)) -> some View {
        let selected = option.value == selection
        let shape = RoundedRectangle(cornerRadius: OneMetrics.radiusChip, style: .continuous)
        return Button {
            selection = option.value
        } label: {
            Text(option.label)
                .font(OneText.labelLarge())
                .foregroundStyle(selected ? OnePalette.surface : OnePalette.onSurface)
                .padding(.horizontal, OneMetrics.space16)
                .frame(minHeight: OneMetrics.minimumTarget)
                .background { shape.fill(selected ? OnePalette.onSurface : OneGlass.fill) }
                .overlay { shape.strokeBorder(OneGlass.stroke, lineWidth: OneMetrics.stroke) }
        }
        .buttonStyle(.plain)
        .clipShape(shape)
        .inkRipple(overlayColor: OnePalette.onSurface.opacity(0.10))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Horizontal wrap container on iOS 16+, with an alignment-guide flow fallback on iOS 15.
public struct OneWrapLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    public init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        if #available(iOS 16.0, *) {
            AnyLayout(WrapLayout(spacing: spacing)) { content }
        } else {
            HStack(spacing: spacing) { content }
        }
    }
}

private struct LegacyChipFlow<Value: Hashable, ItemView: View>: View {
    let options: [(value: Value, label: String)]
    let spacing: CGFloat
    let itemView: ((value: Value, label: String)) -> ItemView

    @State private var totalHeight: CGFloat = 44

    var body: some View {
        GeometryReader { geo in
            flowContent(in: geo.size.width)
                .background(
                    GeometryReader { inner in
                        Color.clear.preference(key: FlowHeightPreferenceKey.self, value: inner.size.height)
                    }
                )
        }
        .frame(height: totalHeight)
        .onPreferenceChange(FlowHeightPreferenceKey.self) { totalHeight = max(44, $0) }
    }

    private func flowContent(in maxWidth: CGFloat) -> some View {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        return ZStack(alignment: .topLeading) {
            ForEach(options.indices, id: \.self) { index in
                itemView(options[index])
                    .alignmentGuide(.leading) { dim in
                        if abs(currentX - dim.width) > maxWidth && currentX < 0 {
                            currentX = 0
                            currentY -= (dim.height + spacing)
                        }
                        let result = currentX
                        if index == options.count - 1 {
                            currentX = 0
                        } else {
                            currentX -= (dim.width + spacing)
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = currentY
                        if index == options.count - 1 {
                            currentY = 0
                        }
                        return result
                    }
            }
        }
    }
}

private struct FlowHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 44
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

@available(iOS 16.0, *)
private struct WrapLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if width > 0 && width + spacing + size.width > maxWidth {
                height += rowHeight + spacing
                width = 0
                rowHeight = 0
            }
            width += (width == 0 ? 0 : spacing) + size.width
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: min(maxWidth, width), height: height + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
