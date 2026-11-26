import SwiftUI

public struct GlassTile<Content: View>: View {
    let tone: OneTone; let selected: Bool; let action: (() -> Void)?; let content: Content
    public init(tone: OneTone = .neutral, selected: Bool = false, action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.tone = tone; self.selected = selected; self.action = action; self.content = content()
    }
    public var body: some View {
        let tint = tone == .neutral ? nil : tone.tint(light: 0.09, dark: 0.12)
        let tile = content.padding(.horizontal, 14).padding(.vertical, OneMetrics.space12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .glassSurface(.sheer, radius: OneMetrics.radiusTile, tint: tint,
                          stroke: selected ? tone.color.opacity(0.60) : (tone == .neutral ? nil : tone.color.opacity(0.34)), elevated: false)
            .overlay { if selected { SelectedSheen(tone: tone, radius: OneMetrics.radiusTile) } }
        if let action {
            Button(action: action) { tile }.buttonStyle(.plain).inkRipple(overlayColor: tone == .neutral ? OnePalette.onSurface.opacity(0.10) : tone.color.opacity(0.10))
                .accessibilityAddTraits(selected ? .isSelected : [])
        } else { tile }
    }
}
public struct SoftLabel: View {
    let title: String; let value: String; let sub: String?; let mono: Bool; let danger: Bool
    public init(_ title: String, value: String, sub: String? = nil, mono: Bool = false, danger: Bool = false) { self.title = title; self.value = value; self.sub = sub; self.mono = mono; self.danger = danger }
    public var body: some View {
        VStack(alignment: .leading, spacing: OneMetrics.space2) {
            Text(title).font(OneText.labelSmall()).tracking(0.2).foregroundStyle(OnePalette.onSurfaceVariant)
            Text(value).font(mono ? .system(.footnote, design: .monospaced) : OneText.bodyMedium()).monospacedDigit().foregroundStyle(danger ? OnePalette.error : OnePalette.onSurface).textSelection(.enabled)
            if let sub, !sub.isEmpty { Text(sub).font(OneText.labelSmall()).foregroundStyle(OnePalette.onSurfaceVariant) }
        }.frame(maxWidth: .infinity, alignment: .leading).accessibilityElement(children: .combine)
    }
}

public struct SoftLabelGrid: View {
    let items: [SoftLabel]
    @Environment(\.colorScheme) private var colorScheme
    public init(_ items: [SoftLabel]) { self.items = items }
    public var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: OneMetrics.space10), GridItem(.flexible(), spacing: OneMetrics.space10)], spacing: OneMetrics.space10) {
            ForEach(items.indices, id: \.self) { i in
                items[i]
                    .padding(.horizontal, 14)
                    .padding(.vertical, OneMetrics.space12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background {
                        RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .continuous)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.045) : Color.black.opacity(0.03))
                            .overlay(alignment: .top) {
                                RoundedRectangle(cornerRadius: OneMetrics.radiusTile, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [.white.opacity(colorScheme == .dark ? 0.10 : 0.65), .clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 0.5
                                    )
                            }
                    }
            }
        }
    }
}

public struct ThinProgress: View {
    let value: Double; let tone: OneTone
    public init(_ value: Double, tone: OneTone = .neutral) { self.value = value; self.tone = tone }
    public var body: some View {
        let clamped = value.isFinite ? min(max(value, 0), 100) / 100 : 0
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(OnePalette.outlineVariant.opacity(0.35))
                Capsule().fill(tone == .neutral ? OnePalette.onSurface.opacity(0.72) : tone.color.opacity(0.9)).frame(width: geo.size.width * clamped)
            }
        }.frame(height: 4).accessibilityElement().accessibilityValue(Text("\(Int(clamped * 100))%"))
    }
}

