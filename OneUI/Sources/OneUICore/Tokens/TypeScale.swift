/// Numerical type scale from `_golden/fixtures/typography.json`.
/// Light and dark themes share the same metrics in that fixture.
public struct TypeStyle: Equatable {
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

    public var fixtureTree: OneTokenValue {
        .group([
            "fontSize": .number(fontSize),
            "fontWeight": .number(Double(fontWeight)),
            "height": .number(height),
            "letterSpacing": .number(letterSpacing),
            "measuredHeight": .number(measuredHeight),
            "fontFamily": .text(fontFamily),
        ])
    }
}

public enum TypeScale {
    public static let sample = "Hamburgefonstiv 0123456789"

    public static let styles: [String: TypeStyle] = [
        "displayLarge": TypeStyle(
            fontSize: 57.0,
            fontWeight: 400,
            height: 1.12,
            letterSpacing: -0.25,
            measuredHeight: 64.0,
            fontFamily: "Montserrat"
        ),
        "displayMedium": TypeStyle(
            fontSize: 45.0,
            fontWeight: 400,
            height: 1.16,
            letterSpacing: 0.0,
            measuredHeight: 52.0,
            fontFamily: "Montserrat"
        ),
        "displaySmall": TypeStyle(
            fontSize: 36.0,
            fontWeight: 400,
            height: 1.22,
            letterSpacing: 0.0,
            measuredHeight: 44.0,
            fontFamily: "Montserrat"
        ),
        "headlineLarge": TypeStyle(
            fontSize: 32.0,
            fontWeight: 400,
            height: 1.25,
            letterSpacing: 0.0,
            measuredHeight: 40.0,
            fontFamily: "Montserrat"
        ),
        "headlineMedium": TypeStyle(
            fontSize: 28.0,
            fontWeight: 400,
            height: 1.29,
            letterSpacing: 0.0,
            measuredHeight: 36.0,
            fontFamily: "Montserrat"
        ),
        "headlineSmall": TypeStyle(
            fontSize: 24.0,
            fontWeight: 400,
            height: 1.33,
            letterSpacing: 0.0,
            measuredHeight: 32.0,
            fontFamily: "Montserrat"
        ),
        "titleLarge": TypeStyle(
            fontSize: 22.0,
            fontWeight: 400,
            height: 1.27,
            letterSpacing: 0.0,
            measuredHeight: 28.0,
            fontFamily: "Montserrat"
        ),
        "titleMedium": TypeStyle(
            fontSize: 16.0,
            fontWeight: 500,
            height: 1.5,
            letterSpacing: 0.15,
            measuredHeight: 24.0,
            fontFamily: "Montserrat"
        ),
        "titleSmall": TypeStyle(
            fontSize: 14.0,
            fontWeight: 500,
            height: 1.43,
            letterSpacing: 0.1,
            measuredHeight: 20.0,
            fontFamily: "Montserrat"
        ),
        "bodyLarge": TypeStyle(
            fontSize: 16.0,
            fontWeight: 400,
            height: 1.5,
            letterSpacing: 0.5,
            measuredHeight: 24.0,
            fontFamily: "Montserrat"
        ),
        "bodyMedium": TypeStyle(
            fontSize: 14.0,
            fontWeight: 400,
            height: 1.43,
            letterSpacing: 0.25,
            measuredHeight: 20.0,
            fontFamily: "Montserrat"
        ),
        "bodySmall": TypeStyle(
            fontSize: 12.0,
            fontWeight: 400,
            height: 1.33,
            letterSpacing: 0.4,
            measuredHeight: 16.0,
            fontFamily: "Montserrat"
        ),
        "labelLarge": TypeStyle(
            fontSize: 14.0,
            fontWeight: 500,
            height: 1.43,
            letterSpacing: 0.1,
            measuredHeight: 20.0,
            fontFamily: "Montserrat"
        ),
        "labelMedium": TypeStyle(
            fontSize: 12.0,
            fontWeight: 500,
            height: 1.33,
            letterSpacing: 0.5,
            measuredHeight: 16.0,
            fontFamily: "Montserrat"
        ),
        "labelSmall": TypeStyle(
            fontSize: 11.0,
            fontWeight: 500,
            height: 1.45,
            letterSpacing: 0.5,
            measuredHeight: 16.0,
            fontFamily: "Montserrat"
        )
    ]

    public static let light = styles
    public static let dark = styles

    public static var fixtureTree: OneTokenValue {
        .group([
            "sample": .text(sample),
            "light": themeTree(light),
            "dark": themeTree(dark),
        ])
    }
}

private func themeTree(_ styles: [String: TypeStyle]) -> OneTokenValue {
    .group(styles.mapValues { $0.fixtureTree })
}
