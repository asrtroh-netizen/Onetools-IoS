import SwiftUI

/// 框右上角的小动作钮（WEB `.ow-btn--ghost`）：玻璃底 + 发丝边 + SF Symbol + 短词。
/// 视觉 36pt 高，可点范围撑到 44pt。
public struct GlassActionButton: View {
    let title: String
    let systemImage: String?
    let busy: Bool
    let selected: Bool
    let action: () -> Void

    @Environment(\.isEnabled) private var enabled

    public init(_ title: String, systemImage: String? = nil, busy: Bool = false, selected: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.busy = busy
        self.selected = selected
        self.action = action
    }

    public var body: some View {
        let active = enabled && !busy
        let ink: Color = !active ? OnePalette.onSurface.opacity(0.38) : selected ? OneTone.green.ink : OnePalette.onSurface
        Button(action: action) {
            HStack(spacing: OneMetrics.space6) {
                if busy {
                    ProgressView().controlSize(.mini).tint(ink)
                } else if let systemImage {
                    Image(systemName: systemImage).font(.system(size: 13, weight: .semibold))
                }
                Text(title).font(OneText.labelMedium(.semibold)).lineLimit(1)
            }
            .foregroundStyle(ink)
            .padding(.horizontal, OneMetrics.space12)
            .padding(.vertical, OneMetrics.space8)
            .glassSurface(.sheer, radius: OneMetrics.radiusChip,
                          stroke: selected ? OneTone.green.color.opacity(0.9) : nil, elevated: false)
            .frame(minWidth: OneMetrics.minimumTarget, minHeight: OneMetrics.minimumTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
        .disabled(busy)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// 单选芯片行（`ChoiceChipRow`）。放不下时横向滚动，不再挤压。
public struct ChoiceChips<Value: Hashable>: View {
    let options: [(value: Value, label: String)]
    @Binding var selection: Value

    public init(_ options: [(value: Value, label: String)], selection: Binding<Value>) {
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: OneMetrics.space8) {
                ForEach(options.indices, id: \.self) { i in
                    let option = options[i]
                    let on = option.value == selection
                    Button {
                        selection = option.value
                    } label: {
                        Text(option.label)
                            .font(OneText.labelLarge(on ? .semibold : .medium))
                            .foregroundStyle(on ? OnePalette.surface : OnePalette.onSurface)
                            .padding(.horizontal, OneMetrics.space16)
                            .frame(minHeight: OneMetrics.minimumTarget - 8)
                            .background {
                                RoundedRectangle(cornerRadius: OneMetrics.radiusChip, style: .continuous)
                                    .fill(on ? OnePalette.onSurface : OneGlass.fill)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: OneMetrics.radiusChip, style: .continuous)
                                    .strokeBorder(OneGlass.stroke, lineWidth: OneMetrics.stroke)
                            }
                            .frame(minHeight: OneMetrics.minimumTarget)
                    }
                    .buttonStyle(PressableStyle())
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: selection)
    }
}
