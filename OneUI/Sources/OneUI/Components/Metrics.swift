import SwiftUI

// MARK: - 指标卡

/// 数值卡：着色图标块 + 小标签 / 大数值 / 副文案（`MetricCard`）。
public struct MetricCard: View {
    let label: String
    let value: String
    let sub: String
    let systemImage: String
    let tone: OneTone

    public init(_ label: String, value: String, sub: String, systemImage: String, tone: OneTone = .green) {
        self.label = label
        self.value = value
        self.sub = sub
        self.systemImage = systemImage
        self.tone = tone
    }

    public var body: some View {
        GlassCard {
            HStack(alignment: .top, spacing: OneMetrics.space12) {
                TitleIcon(systemImage: systemImage, tone: tone, side: 40)
                VStack(alignment: .leading, spacing: OneMetrics.space6) {
                    Text(label)
                        .font(OneText.labelSmall())
                        .tracking(0.4)
                        .foregroundStyle(OnePalette.onSurfaceVariant)
                    Text(value)
                        .font(OneText.headline(.medium))
                        .monospacedDigit()
                        .lineLimit(2)
                        .numericTransition()
                    Text(sub)
                        .font(OneText.labelSmall(.regular))
                        .foregroundStyle(OnePalette.onSurfaceVariant.opacity(0.78))
                        .lineLimit(2)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// 两列指标网格，窄屏 / 大字号退单列（`MetricRow`）。
public struct MetricGrid<Content: View>: View {
    let content: Content
    @Environment(\.dynamicTypeSize) private var typeSize

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        let columns = typeSize.isAccessibilitySize ? 1 : 2
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: OneMetrics.space12, alignment: .top), count: columns),
            spacing: OneMetrics.space12
        ) { content }
    }
}

// MARK: - 阶段条

public enum StageState: Sendable { case pending, active, ready, failed }

/// 一排等宽阶段条 + 条下小字（WEB `stage-row`）。就绪绿 + 辉光，失败红，未到空条。
public struct StageRow: View {
    let stages: [(label: String, state: StageState)]

    public init(_ stages: [(label: String, state: StageState)]) { self.stages = stages }

    public var body: some View {
        HStack(alignment: .top, spacing: OneMetrics.space6) {
            ForEach(stages.indices, id: \.self) { i in
                let stage = stages[i]
                VStack(spacing: OneMetrics.space6) {
                    bar(stage.state)
                    Text(stage.label)
                        .font(OneText.labelSmall(stage.state == .pending ? .regular : .semibold))
                        .foregroundStyle(tone(stage.state)?.ink ?? OnePalette.onSurfaceVariant.opacity(0.7))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(stage.label))
                .accessibilityValue(Text(Self.spoken(stage.state)))
            }
        }
        .animation(.easeOut(duration: 0.25), value: stages.map { $0.state })
    }

    private func tone(_ state: StageState) -> OneTone? {
        switch state {
        case .ready, .active: .green   // Flutter 版 blue == green，产品口径不用蓝/橙
        case .failed: .red
        case .pending: nil
        }
    }

    @ViewBuilder
    private func bar(_ state: StageState) -> some View {
        if let tone = tone(state) {
            Capsule()
                .fill(tone.color.opacity(state == .active ? 0.55 : 0.9))
                .frame(height: 6)
                .shadow(color: state == .ready ? tone.color.opacity(0.25) : .clear, radius: 8)
        } else {
            Capsule()
                .fill(OnePalette.onSurface.opacity(0.08))
                .overlay(Capsule().strokeBorder(OneGlass.stroke, lineWidth: OneMetrics.stroke))
                .frame(height: 6)
        }
    }

    static func spoken(_ state: StageState) -> String {
        switch state {
        case .pending: "未开始"
        case .active: "进行中"
        case .ready: "就绪"
        case .failed: "失败"
        }
    }
}
