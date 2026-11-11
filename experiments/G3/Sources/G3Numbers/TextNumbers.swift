import Foundation

public struct TextRole: Equatable {
    public let fontSize: Double
    public let fontWeight: Int
    public let height: Double
    public let letterSpacing: Double
    public let measuredHeight: Double
    public let fontFamily: String

    public init(
        fontSize: Double,
        fontWeight: Int,
        height: Double,
        letterSpacing: Double,
        measuredHeight: Double,
        fontFamily: String
    ) {
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.height = height
        self.letterSpacing = letterSpacing
        self.measuredHeight = measuredHeight
        self.fontFamily = fontFamily
    }
}

public enum TextNumbers {
    /// typography.json sample
    public static let sample = "Hamburgefonstiv 0123456789"

    /// typography.json light.displayLarge
    /// fontSize, fontWeight, height, letterSpacing, measuredHeight, fontFamily
    public static let lightDisplayLarge = TextRole(
        fontSize: 57.0,
        fontWeight: 400,
        height: 1.12,
        letterSpacing: -0.25,
        measuredHeight: 64.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.displayMedium
    public static let lightDisplayMedium = TextRole(
        fontSize: 45.0,
        fontWeight: 400,
        height: 1.16,
        letterSpacing: 0.0,
        measuredHeight: 52.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.displaySmall
    public static let lightDisplaySmall = TextRole(
        fontSize: 36.0,
        fontWeight: 400,
        height: 1.22,
        letterSpacing: 0.0,
        measuredHeight: 44.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.headlineLarge
    public static let lightHeadlineLarge = TextRole(
        fontSize: 32.0,
        fontWeight: 400,
        height: 1.25,
        letterSpacing: 0.0,
        measuredHeight: 40.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.headlineMedium
    public static let lightHeadlineMedium = TextRole(
        fontSize: 28.0,
        fontWeight: 400,
        height: 1.29,
        letterSpacing: 0.0,
        measuredHeight: 36.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.headlineSmall
    public static let lightHeadlineSmall = TextRole(
        fontSize: 24.0,
        fontWeight: 400,
        height: 1.33,
        letterSpacing: 0.0,
        measuredHeight: 32.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.titleLarge
    public static let lightTitleLarge = TextRole(
        fontSize: 22.0,
        fontWeight: 400,
        height: 1.27,
        letterSpacing: 0.0,
        measuredHeight: 28.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.titleMedium
    public static let lightTitleMedium = TextRole(
        fontSize: 16.0,
        fontWeight: 500,
        height: 1.5,
        letterSpacing: 0.15,
        measuredHeight: 24.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.titleSmall
    public static let lightTitleSmall = TextRole(
        fontSize: 14.0,
        fontWeight: 500,
        height: 1.43,
        letterSpacing: 0.1,
        measuredHeight: 20.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.bodyLarge
    public static let lightBodyLarge = TextRole(
        fontSize: 16.0,
        fontWeight: 400,
        height: 1.5,
        letterSpacing: 0.5,
        measuredHeight: 24.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.bodyMedium
    public static let lightBodyMedium = TextRole(
        fontSize: 14.0,
        fontWeight: 400,
        height: 1.43,
        letterSpacing: 0.25,
        measuredHeight: 20.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.bodySmall
    public static let lightBodySmall = TextRole(
        fontSize: 12.0,
        fontWeight: 400,
        height: 1.33,
        letterSpacing: 0.4,
        measuredHeight: 16.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.labelLarge
    public static let lightLabelLarge = TextRole(
        fontSize: 14.0,
        fontWeight: 500,
        height: 1.43,
        letterSpacing: 0.1,
        measuredHeight: 20.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.labelMedium
    public static let lightLabelMedium = TextRole(
        fontSize: 12.0,
        fontWeight: 500,
        height: 1.33,
        letterSpacing: 0.5,
        measuredHeight: 16.0,
        fontFamily: "Montserrat"
    )

    /// typography.json light.labelSmall
    public static let lightLabelSmall = TextRole(
        fontSize: 11.0,
        fontWeight: 500,
        height: 1.45,
        letterSpacing: 0.5,
        measuredHeight: 16.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.displayLarge
    public static let darkDisplayLarge = TextRole(
        fontSize: 57.0,
        fontWeight: 400,
        height: 1.12,
        letterSpacing: -0.25,
        measuredHeight: 64.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.displayMedium
    public static let darkDisplayMedium = TextRole(
        fontSize: 45.0,
        fontWeight: 400,
        height: 1.16,
        letterSpacing: 0.0,
        measuredHeight: 52.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.displaySmall
    public static let darkDisplaySmall = TextRole(
        fontSize: 36.0,
        fontWeight: 400,
        height: 1.22,
        letterSpacing: 0.0,
        measuredHeight: 44.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.headlineLarge
    public static let darkHeadlineLarge = TextRole(
        fontSize: 32.0,
        fontWeight: 400,
        height: 1.25,
        letterSpacing: 0.0,
        measuredHeight: 40.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.headlineMedium
    public static let darkHeadlineMedium = TextRole(
        fontSize: 28.0,
        fontWeight: 400,
        height: 1.29,
        letterSpacing: 0.0,
        measuredHeight: 36.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.headlineSmall
    public static let darkHeadlineSmall = TextRole(
        fontSize: 24.0,
        fontWeight: 400,
        height: 1.33,
        letterSpacing: 0.0,
        measuredHeight: 32.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.titleLarge
    public static let darkTitleLarge = TextRole(
        fontSize: 22.0,
        fontWeight: 400,
        height: 1.27,
        letterSpacing: 0.0,
        measuredHeight: 28.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.titleMedium
    public static let darkTitleMedium = TextRole(
        fontSize: 16.0,
        fontWeight: 500,
        height: 1.5,
        letterSpacing: 0.15,
        measuredHeight: 24.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.titleSmall
    public static let darkTitleSmall = TextRole(
        fontSize: 14.0,
        fontWeight: 500,
        height: 1.43,
        letterSpacing: 0.1,
        measuredHeight: 20.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.bodyLarge
    public static let darkBodyLarge = TextRole(
        fontSize: 16.0,
        fontWeight: 400,
        height: 1.5,
        letterSpacing: 0.5,
        measuredHeight: 24.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.bodyMedium
    public static let darkBodyMedium = TextRole(
        fontSize: 14.0,
        fontWeight: 400,
        height: 1.43,
        letterSpacing: 0.25,
        measuredHeight: 20.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.bodySmall
    public static let darkBodySmall = TextRole(
        fontSize: 12.0,
        fontWeight: 400,
        height: 1.33,
        letterSpacing: 0.4,
        measuredHeight: 16.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.labelLarge
    public static let darkLabelLarge = TextRole(
        fontSize: 14.0,
        fontWeight: 500,
        height: 1.43,
        letterSpacing: 0.1,
        measuredHeight: 20.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.labelMedium
    public static let darkLabelMedium = TextRole(
        fontSize: 12.0,
        fontWeight: 500,
        height: 1.33,
        letterSpacing: 0.5,
        measuredHeight: 16.0,
        fontFamily: "Montserrat"
    )

    /// typography.json dark.labelSmall
    public static let darkLabelSmall = TextRole(
        fontSize: 11.0,
        fontWeight: 500,
        height: 1.45,
        letterSpacing: 0.5,
        measuredHeight: 16.0,
        fontFamily: "Montserrat"
    )

    /// _golden/test/scenes/a2_weights_test.dart:23
    public static let weightSample = "Hamburgefonstiv"

    /// _golden/test/scenes/a2_weights_test.dart:14-19
    /// 600 与 700 不在 typography.json 里，合成加粗的画法未选。
    public static let weightSampleValues: [Int] = [400, 500, 600, 700]

    /// _golden/test/scenes/a2_weights_test.dart:21
    public static let weightSampleSizes: [Double] = [11, 12, 14, 16, 22, 24]

    /// _golden/test/scenes/a2_weights_test.dart:41
    public static let weightSampleHeight: Double = 1.05
}
