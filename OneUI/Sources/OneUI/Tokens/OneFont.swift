import CoreText
import OneUICore
import SwiftUI
import UIKit

/// OneWIFI ships one Montserrat face. Requests below 600 use it directly and
/// requests at 600/700 use the same face with synthetic-bold metrics from Core.
public enum OneFont {
    public static let postScriptFace = "Montserrat-Regular"

    private static let registered: Void = {
        guard let url = Bundle.module.url(forResource: postScriptFace, withExtension: "ttf", subdirectory: "Fonts")
            ?? Bundle.module.url(forResource: postScriptFace, withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }()

    public static func register() { _ = registered }

    public static func postScriptName(_ weight: Font.Weight = .regular) -> String { postScriptFace }

    /// Fixed M3 sizing is the default so screenshots stay 1:1 with Flutter.
    /// Callers can opt into Dynamic Type explicitly when building an accessibility surface.
    public static func montserrat(
        _ size: CGFloat,
        _ weight: Font.Weight = .regular,
        relativeTo style: Font.TextStyle? = nil,
        scalesWithDynamicType: Bool = false
    ) -> Font {
        register()
        if scalesWithDynamicType, let style {
            return .custom(postScriptFace, size: size, relativeTo: style)
        }
        return .custom(postScriptFace, size: size)
    }

    public static func syntheticStrokeWidth(for size: CGFloat, weight: Int) -> CGFloat {
        CGFloat(SyntheticBoldMetrics.shouldSynthesize(weight: weight)
            ? SyntheticBoldMetrics.strokeWidthPercent(for: Double(size))
            : 0)
    }

    public static func numericWeight(_ weight: Font.Weight) -> Int {
        switch weight {
        case .black: return 900
        case .heavy: return 800
        case .bold: return 700
        case .semibold: return 600
        case .medium: return 500
        case .light: return 300
        case .thin: return 200
        case .ultraLight: return 100
        default: return 400
        }
    }
}

/// Material 3 text styles (2021 scale).
public enum OneText {
    public static func headline(_ weight: Font.Weight = .regular) -> Font { OneFont.montserrat(24, weight) }
    public static func titleLarge(_ weight: Font.Weight = .regular) -> Font { OneFont.montserrat(22, weight) }
    public static func titleMedium(_ weight: Font.Weight = .medium) -> Font { OneFont.montserrat(16, weight) }
    public static func titleSmall(_ weight: Font.Weight = .medium) -> Font { OneFont.montserrat(14, weight) }
    public static func bodyLarge(_ weight: Font.Weight = .regular) -> Font { OneFont.montserrat(16, weight) }
    public static func bodyMedium(_ weight: Font.Weight = .regular) -> Font { OneFont.montserrat(14, weight) }
    public static func bodySmall(_ weight: Font.Weight = .regular) -> Font { OneFont.montserrat(12, weight) }
    public static func labelLarge(_ weight: Font.Weight = .medium) -> Font { OneFont.montserrat(14, weight) }
    public static func labelMedium(_ weight: Font.Weight = .medium) -> Font { OneFont.montserrat(12, weight) }
    public static func labelSmall(_ weight: Font.Weight = .medium) -> Font { OneFont.montserrat(11, weight) }
}

/// CoreText-backed single/multi-line label that applies Skia-equivalent negative
/// stroke synthetic bold (`w600`/`w700`) and M3 `even` line-height compensation.
public struct OneStyledText: View {
    public static var pureSwiftUISnapshotMode: Bool = false

    public let text: String
    public let size: CGFloat
    public let weight: Int
    public let heightMultiplier: CGFloat
    public let tracking: CGFloat
    public let color: UIColor?
    public let lineLimit: Int

    public init(
        _ text: String,
        size: CGFloat,
        weight: Int = 400,
        heightMultiplier: CGFloat = 1.43,
        tracking: CGFloat = 0,
        color: UIColor? = nil,
        lineLimit: Int = 1
    ) {
        self.text = text
        self.size = size
        self.weight = weight
        self.heightMultiplier = heightMultiplier
        self.tracking = tracking
        self.color = color
        self.lineLimit = lineLimit
    }

    public var body: some View {
        if Self.pureSwiftUISnapshotMode {
            Text(text)
                .font(OneFont.montserrat(size, weight >= 700 ? .bold : weight >= 600 ? .semibold : weight >= 500 ? .medium : .regular))
                .tracking(tracking)
                .lineLimit(lineLimit)
                .foregroundStyle(color.map(Color.init(uiColor:)) ?? OnePalette.onSurface)
        } else {
            OneAttributedLabelRepresentable(
                text: text,
                size: size,
                weight: weight,
                heightMultiplier: heightMultiplier,
                tracking: tracking,
                color: color,
                lineLimit: lineLimit
            )
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct OneAttributedLabelRepresentable: UIViewRepresentable {
    let text: String
    let size: CGFloat
    let weight: Int
    let heightMultiplier: CGFloat
    let tracking: CGFloat
    let color: UIColor?
    let lineLimit: Int

    func makeUIView(context: Context) -> IntrinsicLabel {
        let label = IntrinsicLabel()
        label.backgroundColor = .clear
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    @available(iOS 16.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: IntrinsicLabel, context: Context) -> CGSize {
        updateUIView(uiView, context: context)
        let maxWidth = (proposal.width ?? 0) > 0 ? (proposal.width ?? .greatestFiniteMagnitude) : .greatestFiniteMagnitude
        let fitted = uiView.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: ceil(min(fitted.width, maxWidth)), height: ceil(fitted.height))
    }

    func updateUIView(_ label: IntrinsicLabel, context: Context) {
        OneFont.register()
        label.numberOfLines = lineLimit
        label.lineBreakMode = lineLimit == 1 ? .byTruncatingTail : .byWordWrapping

        let uiFont = UIFont(name: OneFont.postScriptFace, size: size) ?? .systemFont(ofSize: size, weight: .regular)
        let targetHeight = size * heightMultiplier
        let naturalHeight = size * CGFloat(SyntheticBoldMetrics.syntheticLineHeight)
        let extraHalf = max(0, (targetHeight - naturalHeight) / 2)

        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = targetHeight
        paragraph.maximumLineHeight = targetHeight
        if lineLimit != 1 {
            paragraph.lineSpacing = max(0, targetHeight - naturalHeight)
        }

        let resolvedColor = color ?? UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: 0xE2E2E9) : UIColor(hex: 0x1A1B20) }
        var attributes: [NSAttributedString.Key: Any] = [
            .font: uiFont,
            .foregroundColor: resolvedColor,
            .kern: tracking,
            .paragraphStyle: paragraph,
            .baselineOffset: extraHalf,
        ]
        let strokePercent = OneFont.syntheticStrokeWidth(for: size, weight: weight)
        if strokePercent < 0 {
            attributes[.strokeWidth] = strokePercent
            attributes[.strokeColor] = resolvedColor
        }
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.invalidateIntrinsicContentSize()
    }

    final class IntrinsicLabel: UILabel {
        override func layoutSubviews() {
            super.layoutSubviews()
            if numberOfLines != 1, preferredMaxLayoutWidth != bounds.width {
                preferredMaxLayoutWidth = bounds.width
                invalidateIntrinsicContentSize()
            }
        }
    }
}
