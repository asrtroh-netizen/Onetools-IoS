import OneUICore
import SwiftUI
import UIKit

// MARK: - 1. Restrained BorderBeam Shader-Style Sweep (`ismnoiet/border-beam-ios`)

public enum OneBeamTone: Sendable {
    case neutral
    case emerald
    case amber
    case crimson

    var primaryColor: Color {
        switch self {
        case .neutral:
            return Color.dynamic(light: 0x1A1B20, 0.72, dark: 0xFFFFFF, 0.88)
        case .emerald:
            return Color(uiColor: UIColor(hex: 0x3ECF8E))
        case .amber:
            return Color(uiColor: UIColor(hex: 0xE59934))
        case .crimson:
            return Color(uiColor: UIColor(hex: 0xE55353))
        }
    }
}

public struct OneBorderBeamModifier: ViewModifier {
    let active: Bool
    let tone: OneBeamTone
    let radius: CGFloat
    let lineWidth: CGFloat
    let duration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var angle: Double = 0

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        content.overlay {
            if active {
                if reduceMotion {
                    shape
                        .strokeBorder(tone.primaryColor.opacity(0.65), lineWidth: lineWidth)
                        .allowsHitTesting(false)
                } else {
                    ZStack {
                        // Outer soft bloom pass (strictly masked to border, never tinting interior)
                        shape
                            .strokeBorder(beamGradient, lineWidth: lineWidth + 1.2)
                            .blur(radius: 3)
                            .opacity(0.42)
                        // Crisp 1.5pt specular edge pass
                        shape
                            .strokeBorder(beamGradient, lineWidth: lineWidth)
                    }
                    .allowsHitTesting(false)
                    .onAppear {
                        angle = 0
                        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                            angle = 360
                        }
                    }
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: active)
    }

    private var beamGradient: AngularGradient {
        AngularGradient(
            stops: [
                .init(color: .clear, location: 0.00),
                .init(color: .clear, location: 0.62),
                .init(color: tone.primaryColor.opacity(0.28), location: 0.78),
                .init(color: tone.primaryColor, location: 0.92),
                .init(color: .white.opacity(0.92), location: 0.96),
                .init(color: .clear, location: 1.00),
            ],
            center: .center,
            angle: .degrees(angle)
        )
    }
}

extension View {
    public func oneBorderBeam(
        active: Bool,
        tone: OneBeamTone = .neutral,
        radius: CGFloat = OneMetrics.radiusHero,
        lineWidth: CGFloat = 1.5,
        duration: Double = 3.6
    ) -> some View {
        modifier(OneBorderBeamModifier(active: active, tone: tone, radius: radius, lineWidth: lineWidth, duration: duration))
    }
}

// MARK: - 2. Tactile Spring Press (`beUI Motion` SPRING_PRESS)

public struct OneSpringPressModifier: ViewModifier {
    let isPressed: Bool
    let targetScale: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (isPressed ? targetScale : 1.0))
            .animation(
                reduceMotion
                    ? nil
                    : .spring(response: OneMotionSpec.pressResponse, dampingFraction: OneMotionSpec.pressDamping),
                value: isPressed
            )
    }
}

// MARK: - 3. Borderless 999pt Sliding Pill Switcher (`Anti-Boxiness`)

public struct OneSlidingPill<Value: Hashable>: View {
    public struct Option: Identifiable {
        public let id: Value
        public let title: String
        public let icon: String?

        public init(_ id: Value, title: String, icon: String? = nil) {
            self.id = id
            self.title = title
            self.icon = icon
        }
    }

    let options: [Option]
    @Binding var selection: Value
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var gliderNamespace

    public init(_ options: [Option], selection: Binding<Value>) {
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(options) { option in
                let isSelected = option.id == selection
                Button {
                    guard option.id != selection else { return }
                    UISelectionFeedbackGenerator().selectionChanged()
                    if reduceMotion {
                        selection = option.id
                    } else {
                        withAnimation(.timingCurve(0.22, 1.0, 0.36, 1.0, duration: OneMotionSpec.slidingPillDuration)) {
                            selection = option.id
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        if let icon = option.icon {
                            Image(systemName: icon)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        Text(option.title)
                            .font(OneText.labelMedium(isSelected ? .semibold : .medium))
                            .lineLimit(1)
                    }
                    .foregroundStyle(isSelected ? OnePalette.onSurface : OnePalette.onSurfaceVariant)
                    .frame(maxWidth: .infinity, minHeight: 34)
                    .padding(.horizontal, 10)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(
                                    colorScheme == .dark
                                        ? Color.white.opacity(0.14)
                                        : Color.white.opacity(0.92)
                                )
                                .overlay {
                                    Capsule()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(colorScheme == .dark ? 0.24 : 0.85),
                                                    .clear,
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 0.6
                                        )
                                }
                                .shadow(color: .black.opacity(colorScheme == .dark ? 0.28 : 0.06), radius: 4, y: 2)
                                .matchedGeometryEffect(id: "one.pill.glider", in: gliderNamespace)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(3)
        .background {
            Capsule()
                .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.045))
        }
    }
}

// MARK: - 4. Split-Weight Bento Metric Value (`UI Moments` + `DigitSwap`)

public struct OneBentoValueText: View {
    let raw: String
    let baseSize: CGFloat
    let color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(_ raw: String, baseSize: CGFloat = 22, color: Color = OnePalette.onSurface) {
        self.raw = raw
        self.baseSize = baseSize
        self.color = color
    }

    public var body: some View {
        let parts = OneMetricFormatter.split(raw)
        let subSize = round(baseSize * CGFloat(OneMotionSpec.bentoUnitScaleRatio))
        let baseView = HStack(alignment: .firstTextBaseline, spacing: 1) {
            if !parts.prefix.isEmpty {
                Text(parts.prefix)
                    .font(.system(size: subSize, weight: .medium))
                    .foregroundStyle(color.opacity(0.70))
            }
            Text(parts.integer)
                .font(.system(size: baseSize, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(color)
            if !parts.suffix.isEmpty {
                Text(parts.suffix)
                    .font(.system(size: subSize, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(color.opacity(0.68))
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.75)

        if #available(iOS 16.0, *), !reduceMotion {
            baseView
                .contentTransition(.numericText())
                .animation(.easeOut(duration: OneMotionSpec.digitSwapDuration), value: raw)
        } else {
            baseView
        }
    }
}

// MARK: - 5. Rhythm Pulse Loader (`UI Moments · Center Bars`)

public struct OneRhythmBars: View {
    let color: Color
    var height: CGFloat = 15

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsing = false

    public init(color: Color = OnePalette.onSurface, height: CGFloat = 15) {
        self.color = color
        self.height = height
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { idx in
                Capsule()
                    .fill(color)
                    .frame(width: 2.6, height: barHeight(for: idx))
                    .animation(
                        reduceMotion
                            ? nil
                            : .easeInOut(duration: 0.42)
                                .repeatForever(autoreverses: true)
                                .delay(Double(idx) * 0.12),
                        value: pulsing
                    )
            }
        }
        .frame(width: 16, height: height)
        .onAppear {
            guard !reduceMotion else { return }
            pulsing = true
        }
        .accessibilityHidden(true)
    }

    private func barHeight(for index: Int) -> CGFloat {
        if reduceMotion {
            return index == 1 ? height : height * 0.62
        }
        if pulsing {
            return index == 1 ? height * 0.42 : height
        } else {
            return index == 1 ? height : height * 0.45
        }
    }
}

// MARK: - 6. Damped Tactile Swipe Confirm (`UI Moments · Swipe Confirm`)

public struct OneSwipeConfirm: View {
    let title: String
    let confirmedTitle: String
    let tone: OneBeamTone
    let onConfirm: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGFloat = 0
    @State private var completed = false

    private let thumbSize: CGFloat = 40
    private let trackPadding: CGFloat = 4

    public init(
        _ title: String,
        confirmedTitle: String = "已确认执行",
        tone: OneBeamTone = .crimson,
        onConfirm: @escaping () -> Void
    ) {
        self.title = title
        self.confirmedTitle = confirmedTitle
        self.tone = tone
        self.onConfirm = onConfirm
    }

    public var body: some View {
        GeometryReader { geo in
            let maxTravel = max(1, geo.size.width - thumbSize - trackPadding * 2)
            let progress = min(max(dragOffset / maxTravel, 0), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(tone.primaryColor.opacity(0.10 + progress * 0.16))
                    .overlay {
                        Capsule()
                            .strokeBorder(tone.primaryColor.opacity(0.28), lineWidth: 0.8)
                    }

                Text(completed ? confirmedTitle : title)
                    .font(OneText.labelMedium(.semibold))
                    .foregroundStyle(tone.primaryColor)
                    .opacity(completed ? 1.0 : Double(1.0 - progress * 0.65))
                    .frame(maxWidth: .infinity)

                Circle()
                    .fill(tone.primaryColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay {
                        Image(systemName: completed ? "checkmark" : "chevron.right.2")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: trackPadding + (completed ? maxTravel : dragOffset))
                    .gesture(
                        DragGesture(minimumDistance: 2)
                            .onChanged { value in
                                guard !completed else { return }
                                dragOffset = min(max(0, value.translation.width), maxTravel)
                            }
                            .onEnded { value in
                                guard !completed else { return }
                                let finalProgress = min(max(value.translation.width / maxTravel, 0), 1)
                                if finalProgress >= 0.82 {
                                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.16)) {
                                        dragOffset = maxTravel
                                        completed = true
                                    }
                                    onConfirm()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                                            completed = false
                                            dragOffset = 0
                                        }
                                    }
                                } else {
                                    withAnimation(reduceMotion ? nil : .spring(response: 0.24, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: thumbSize + trackPadding * 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { onConfirm() }
    }
}

// MARK: - 7. View Transition Wrapper (`OneViewTransition` parity with ONEWIFIX)

public struct OneViewTransition<ID: Hashable, Content: View>: View {
    let id: ID
    let maxOffset: CGFloat
    let content: Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(id: ID, maxOffset: CGFloat = CGFloat(OneMotionSpec.tabMicroOffsetPt), @ViewBuilder content: () -> Content) {
        self.id = id
        self.maxOffset = min(max(0, maxOffset), 4.0)
        self.content = content()
    }

    public var body: some View {
        content
            .id(id)
            .transition(
                reduceMotion || maxOffset == 0
                    ? .opacity
                    : .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: maxOffset)),
                        removal: .opacity.combined(with: .offset(y: -maxOffset))
                    )
            )
            .animation(
                reduceMotion
                    ? .linear(duration: OneMotionSpec.tabExitDuration)
                    : .timingCurve(0.16, 1.0, 0.3, 1.0, duration: OneMotionSpec.tabEnterDuration),
                value: id
            )
    }
}

