/// Ink ripple numerical model from `_golden/fixtures/ripple.json`.
/// Values are the fixture numbers; this is not a touch-handling implementation.
public struct RippleConstant: Equatable {
    public let name: String
    public let line: Int
    public let ms: Int?
    public let number: Double?
    public let text: String?

    public static func duration(name: String, line: Int, ms: Int) -> RippleConstant {
        RippleConstant(name: name, line: line, ms: ms, number: nil, text: nil)
    }

    public static func number(name: String, line: Int, value: Double) -> RippleConstant {
        RippleConstant(name: name, line: line, ms: nil, number: value, text: nil)
    }

    public static func text(name: String, line: Int, value: String) -> RippleConstant {
        RippleConstant(name: name, line: line, ms: nil, number: nil, text: value)
    }

    public var fixtureTree: OneTokenValue {
        var group: [String: OneTokenValue] = [
            "name": .text(name),
            "line": .number(Double(line)),
        ]
        if let ms {
            group["ms"] = .number(Double(ms))
        }
        if let number {
            group["value"] = .number(number)
        }
        if let text {
            group["value"] = .text(text)
        }
        return .group(group)
    }
}

public struct RippleSample: Equatable {
    public let ms: Int
    public let radius: Double
    public let alpha: Int
    public let opacity: Double

    public init(ms: Int, radius: Double, alpha: Int, opacity: Double) {
        self.ms = ms
        self.radius = radius
        self.alpha = alpha
        self.opacity = opacity
    }

    public var fixtureTree: OneTokenValue {
        .group([
            "ms": .number(Double(ms)),
            "radius": .number(radius),
            "alpha": .number(Double(alpha)),
            "opacity": .number(opacity),
        ])
    }
}

public enum InkRippleModel {
    public static let source = "_ref/flutter-3.44.9/material/ink_ripple.dart"

    public static let constants: [RippleConstant] = [
        RippleConstant.duration(name: "_kUnconfirmedRippleDuration", line: 19, ms: 1000),
        RippleConstant.duration(name: "_kFadeInDuration", line: 20, ms: 75),
        RippleConstant.duration(name: "_kRadiusDuration", line: 21, ms: 225),
        RippleConstant.duration(name: "_kFadeOutDuration", line: 22, ms: 375),
        RippleConstant.duration(name: "_kCancelDuration", line: 23, ms: 75),
        RippleConstant.number(name: "_kFadeOutIntervalStart", line: 26, value: 0.6),
        RippleConstant.number(name: "radiusBeginFactor", line: 159, value: 0.3),
        RippleConstant.number(name: "radiusEndExtra", line: 159, value: 5.0),
        RippleConstant.text(name: "easeCurve", line: 193, value: "Curves.ease")
    ]

    public static let referenceBoxWidth = 44.0
    public static let referenceBoxHeight = 44.0
    public static let referenceBoxSource = "OneSizes.minimumTarget"

    public static let targetRadius = 31.11269837220809

    public static let splashAlphaLight = 102
    public static let splashAlphaDark = 64
    public static let splashAlphaLine = 502
    public static let splashAlphaFile = "_ref/flutter-3.44.9/material/theme_data.dart"

    public static let holdLight: [RippleSample] = [
                RippleSample(ms: 0, radius: 9.333809511662427, alpha: 0, opacity: 0.0),
                RippleSample(ms: 75, radius: 10.92177318601048, alpha: 102, opacity: 0.4),
                RippleSample(ms: 200, radius: 17.281207662277865, alpha: 102, opacity: 0.4),
                RippleSample(ms: 500, radius: 30.810270987357445, alpha: 102, opacity: 0.4),
                RippleSample(ms: 1000, radius: 36.11269837220809, alpha: 102, opacity: 0.4)
    ]
    public static let holdDark: [RippleSample] = [
                RippleSample(ms: 0, radius: 9.333809511662427, alpha: 0, opacity: 0.0),
                RippleSample(ms: 75, radius: 10.92177318601048, alpha: 64, opacity: 0.25098039215686274),
                RippleSample(ms: 200, radius: 17.281207662277865, alpha: 64, opacity: 0.25098039215686274),
                RippleSample(ms: 500, radius: 30.810270987357445, alpha: 64, opacity: 0.25098039215686274),
                RippleSample(ms: 1000, radius: 36.11269837220809, alpha: 64, opacity: 0.25098039215686274)
    ]
    public static let confirmLight: [RippleSample] = [
                RippleSample(ms: 0, radius: 9.333809511662427, alpha: 0, opacity: 0.0),
                RippleSample(ms: 75, radius: 24.766963473019842, alpha: 102, opacity: 0.4),
                RippleSample(ms: 225, radius: 36.11269837220809, alpha: 102, opacity: 0.4),
                RippleSample(ms: 400, radius: 36.11269837220809, alpha: 0, opacity: 0.0),
                RippleSample(ms: 600, radius: 36.11269837220809, alpha: 0, opacity: 0.0)
    ]
    public static let confirmDark: [RippleSample] = [
                RippleSample(ms: 0, radius: 9.333809511662427, alpha: 0, opacity: 0.0),
                RippleSample(ms: 75, radius: 24.766963473019842, alpha: 64, opacity: 0.25098039215686274),
                RippleSample(ms: 225, radius: 36.11269837220809, alpha: 64, opacity: 0.25098039215686274),
                RippleSample(ms: 400, radius: 36.11269837220809, alpha: 0, opacity: 0.0),
                RippleSample(ms: 600, radius: 36.11269837220809, alpha: 0, opacity: 0.0)
    ]

    public static var fixtureTree: OneTokenValue {
        .group([
            "source": .text(source),
            "constants": .list(constants.map { $0.fixtureTree }),
            "referenceBox": .group([
                "width": .number(referenceBoxWidth),
                "height": .number(referenceBoxHeight),
                "source": .text(referenceBoxSource),
            ]),
            "targetRadius": .number(targetRadius),
            "splashAlpha": .group([
                "light": .number(Double(splashAlphaLight)),
                "dark": .number(Double(splashAlphaDark)),
                "line": .number(Double(splashAlphaLine)),
                "file": .text(splashAlphaFile),
            ]),
            "hold": .group([
                "light": .list(holdLight.map { $0.fixtureTree }),
                "dark": .list(holdDark.map { $0.fixtureTree }),
            ]),
            "confirm": .group([
                "light": .list(confirmLight.map { $0.fixtureTree }),
                "dark": .list(confirmDark.map { $0.fixtureTree }),
            ]),
        ])
    }
}
