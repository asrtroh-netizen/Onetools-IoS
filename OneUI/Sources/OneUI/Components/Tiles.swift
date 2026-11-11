import SwiftUI

// MARK: - 瓷片

/// 框里的小瓷片（`GlassTile`）：给 tone 透出语义色；selected 走选中光；有 action 时整片可点。
public struct GlassTile<Content: View>: View {
    let tone: OneTone
    let selected: Bool
    let action: (() -> Void)?
    let content: Content

    public init(tone: OneTone = .neutral, selected: Bool = false, action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.tone = tone
        self.selected = selected
        self.action = action
        self.content = content()
    }

    public var body: some View {
        let glow: OneTone? = selected ? (tone == .neutral ? .green : tone) : nil
        let tinted = glow == nil && tone != .neutral
        let tile = content
            .padding(.horizontal, 14)
            .padding(.vertical, OneMetrics.space12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .glassSurface(
                .sheer,
                radius: OneMetrics.radiusTile,
                tint: tinted ? tone.tint(light: 0.09, dark: 0.12) : nil,
                stroke: glow.map { $0.tint(light: 0.28, dark: 0.18) } ?? (tinted ? tone.tint(light: 0.34, dark: 0.42) : nil),
                elevated: false
            )
            .oneShadow()
            .overlay { if let glow { SelectedSheen(tone: glow, radius: OneMetrics.radiusTile) } }

        if let action {
            Button(action: action) { tile }
                .buttonStyle(PressableStyle())
                .accessibilityAddTraits(selected ? .isSelected : [])
        } else {
            tile
        }
    }
}

/// 按下轻微缩放 + 变暗，代替 Flutter 的 InkWell 水波纹（iOS 上水波纹不地道）。
public struct PressableStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - 软标签

/// 左小标签、下值（WEB `SoftLabelCard`）。
public struct SoftLabel: View {
    let title: String
    let value: String
    let sub: String?
    let mono: Bool
    let danger: Bool

    public init(_ title: String, value: String, sub: String? = nil, mono: Bool = false, danger: Bool = false) {
        self.title = title
        self.value = value
        self.sub = sub
        self.mono = mono
        self.danger = danger
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: OneMetrics.space2) {
            Text(title)
                .font(OneText.labelSmall(.regular))
                .tracking(0.2)
                .foregroundStyle(OnePalette.onSurfaceVariant)
            Text(value)
                .font(mono ? .system(.footnote, design: .monospaced) : OneText.bodyMedium())
                .monospacedDigit()
                .foregroundStyle(danger ? OnePalette.error : OnePalette.onSurface)
                .textSelection(.enabled)
            if let sub, !sub.isEmpty {
                Text(sub)
                    .font(OneText.labelSmall(.regular))
                    .foregroundStyle(OnePalette.onSurfaceVariant)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// 两列瓷片格。窄屏或大字号自动退成单列；同行等高。
/// Flutter 版靠 IntrinsicHeight 拉平（每行量两遍），这里用 Grid 原生等高。
public struct SoftLabelGrid: View {
    let items: [SoftLabel]
    @Environment(\.dynamicTypeSize) private var typeSize

    public init(_ items: [SoftLabel]) { self.items = items }

    public var body: some View {
        let columns = typeSize.isAccessibilitySize ? 1 : 2
        let spacing = OneMetrics.space10
        if #available(iOS 16.0, *) {
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
                ForEach(Array(stride(from: 0, to: items.count, by: columns)), id: \.self) { start in
                    GridRow {
                        ForEach(start..<min(start + columns, items.count), id: \.self) { i in
                            // 奇数个时最后一格独占整行
                            GlassTile { items[i] }
                                .gridCellColumns(i == items.count - 1 && (i - start) == 0 ? columns : 1)
                        }
                    }
                }
            }
        } else {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(items.indices, id: \.self) { i in GlassTile { items[i] } }
            }
        }
    }
}

// MARK: - 细进度条

public struct ThinProgress: View {
    let value: Double
    let tone: OneTone

    /// value 取 0…100（与 Flutter 版一致）。
    public init(_ value: Double, tone: OneTone = .neutral) {
        self.value = value
        self.tone = tone
    }

    public var body: some View {
        let clamped = value.isFinite ? min(max(value, 0), 100) / 100 : 0
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(OnePalette.outlineVariant.opacity(0.35))
                Capsule()
                    .fill(tone == .neutral ? OnePalette.onSurface.opacity(0.72) : tone.color.opacity(0.9))
                    .frame(width: geo.size.width * clamped)
            }
        }
        .frame(height: 4)
        .accessibilityElement()
        .accessibilityValue(Text("\(Int(clamped * 100))%"))
    }
}
