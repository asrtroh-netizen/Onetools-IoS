import CoreText
import OneUICore
import SwiftUI

/// OneWIFI ships one Montserrat face. Requests below 600 use it directly and
/// requests at 600/700 use the same face with synthetic-bold metrics from Core.
public enum OneFont {
    private static let file = "Montserrat-Regular"

    private static let registered: Void = {
        guard let url = Bundle.module.url(forResource: file, withExtension: "ttf", subdirectory: "Fonts")
            ?? Bundle.module.url(forResource: file, withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }()

    public static func register() { _ = registered }

    public static func postScriptName(_ weight: Font.Weight = .regular) -> String { file }

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
            return .custom(file, size: size, relativeTo: style)
        }
        return .custom(file, size: size)
    }

    public static func syntheticStrokeWidth(for size: CGFloat, weight: Int) -> CGFloat {
        CGFloat(SyntheticBoldMetrics.shouldSynthesize(weight: weight)
            ? SyntheticBoldMetrics.strokeWidthPercent(for: Double(size))
            : 0)
    }
}

/// Material 3 text styles. The optional weight only changes synthetic metrics
/// for consumers that render an attributed label. SwiftUI keeps the Regular face.
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
