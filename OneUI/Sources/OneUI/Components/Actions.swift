import SwiftUI

public struct GlassActionButton: View {
    let title: String
    let icon: String?
    let busy: Bool
    let selected: Bool
    let action: () -> Void
    @Environment(\.isEnabled) private var enabled
    public init(_ title: String, systemImage: String? = nil, busy: Bool = false, selected: Bool = false, action: @escaping () -> Void) {
        self.title = title; self.icon = systemImage; self.busy = busy; self.selected = selected; self.action = action
    }
    public var body: some View {
        let active = enabled && !busy
        let ink = active ? (selected ? OneTone.green.ink : OnePalette.onSurface) : OnePalette.onSurface.opacity(0.38)
        Button(action: action) {
            HStack(spacing: OneMetrics.space6) {
                if busy { ProgressView().controlSize(.mini).tint(ink) }
                else if let icon { MaterialIcon(name: icon, size: 16, color: ink) }
                Text(title).font(OneText.labelMedium()).lineLimit(1)
            }
            .foregroundStyle(ink).padding(.horizontal, OneMetrics.space12).padding(.vertical, OneMetrics.space8)
            .glassSurface(.sheer, radius: OneMetrics.radiusChip, stroke: selected ? OneTone.green.color.opacity(0.9) : nil, elevated: false)
            .frame(minWidth: OneMetrics.minimumTarget, minHeight: OneMetrics.minimumTarget).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .inkRipple(overlayColor: selected ? OneTone.green.color.opacity(0.10) : OnePalette.onSurface.opacity(0.10))
        .disabled(busy).accessibilityAddTraits(selected ? .isSelected : [])
    }
}
public typealias GlassAction = GlassActionButton

public struct ChoiceChips<Value: Hashable>: View {
    let options: [(value: Value, label: String)]
    @Binding var selection: Value
    public init(_ options: [(value: Value, label: String)], selection: Binding<Value>) { self.options = options; self._selection = selection }
    public var body: some View {
        OneWrapLayout(spacing: OneMetrics.space8) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]; let selected = option.value == selection
                Button { selection = option.value } label: {
                    Text(option.label).font(OneText.labelLarge()).foregroundStyle(selected ? OnePalette.surface : OnePalette.onSurface)
                        .padding(.horizontal, OneMetrics.space16).frame(minHeight: OneMetrics.minimumTarget)
                        .background { RoundedRectangle(cornerRadius: OneMetrics.radiusChip, style: .continuous).fill(selected ? OnePalette.onSurface : OneGlass.fill) }
                        .overlay { RoundedRectangle(cornerRadius: OneMetrics.radiusChip, style: .continuous).strokeBorder(OneGlass.stroke, lineWidth: OneMetrics.stroke) }
                }
                .buttonStyle(.plain).inkRipple(overlayColor: OnePalette.onSurface.opacity(0.10))
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }.animation(.easeOut(duration: 0.2), value: selection)
    }
}

public struct OneWrapLayout<Content: View>: View {
    let spacing: CGFloat; let content: Content
    public init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) { self.spacing = spacing; self.content = content() }
    public var body: some View {
        if #available(iOS 16.0, *) { AnyLayout(WrapLayout(spacing: spacing)) { content } }
        else { VStack(alignment: .leading, spacing: spacing) { content } }
    }
}

@available(iOS 16.0, *)
private struct WrapLayout: Layout {
    let spacing: CGFloat
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude; var width: CGFloat = 0; var height: CGFloat = 0; var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if width > 0 && width + spacing + size.width > maxWidth { height += rowHeight + spacing; width = 0; rowHeight = 0 }
            width += (width == 0 ? 0 : spacing) + size.width; rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: min(maxWidth, width), height: height + rowHeight)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX; var y = bounds.minY; var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX { x = bounds.minX; y += rowHeight + spacing; rowHeight = 0 }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size)); x += size.width + spacing; rowHeight = max(rowHeight, size.height)
        }
    }
}

