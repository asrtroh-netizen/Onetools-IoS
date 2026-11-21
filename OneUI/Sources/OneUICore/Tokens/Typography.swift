import Foundation

/// Pure typography calculations shared by the SwiftUI text wrapper and Linux tests.
/// Montserrat ships as a single Regular face. Heavy requests therefore use the same
/// face with a CoreText negative stroke width, matching Skia's synthetic bold rule.
public enum SyntheticBoldMetrics {
    public static let syntheticLineHeight = 1.219

    /// CoreText's stroke width is expressed as a percentage of the font size.
    /// Skia interpolates the outline from 1/24em at 9pt to 1/32em at 36pt.
    public static func strokeWidthPercent(for fontSize: Double) -> Double {
        let clamped = min(36, max(9, fontSize))
        let t = (clamped - 9) / (36 - 9)
        let emFraction = (1.0 / 24.0) + ((1.0 / 32.0) - (1.0 / 24.0)) * t
        return -(emFraction * 100)
    }

    public static func shouldSynthesize(weight: Int) -> Bool {
        weight >= 600
    }

    public static func lineHeight(for fontSize: Double, weight: Int) -> Double {
        shouldSynthesize(weight: weight) ? fontSize * syntheticLineHeight : fontSize
    }

    /// Vertical inset for a single line when synthetic bold uses the compensated line height.
    public static func singleLineVerticalInset(for fontSize: Double, weight: Int) -> Double {
        max(0, (lineHeight(for: fontSize, weight: weight) - fontSize) / 2)
    }
}
