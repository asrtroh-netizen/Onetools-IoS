import Foundation

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
}

public enum RippleNumbers {
    /// ripple.json constants _kUnconfirmedRippleDuration.ms；ink_ripple.dart:19
    public static let unconfirmedRippleDurationMs: Int = 1000

    /// ripple.json constants _kFadeInDuration.ms；ink_ripple.dart:20
    public static let fadeInDurationMs: Int = 75

    /// ripple.json constants _kRadiusDuration.ms；ink_ripple.dart:21
    public static let radiusDurationMs: Int = 225

    /// ripple.json constants _kFadeOutDuration.ms；ink_ripple.dart:22
    public static let fadeOutDurationMs: Int = 375

    /// ripple.json constants _kCancelDuration.ms；ink_ripple.dart:23
    public static let cancelDurationMs: Int = 75

    /// ripple.json constants _kFadeOutIntervalStart.value
    /// ink_ripple.dart:26 写的是 225.0 / 375.0，夹具记为 0.6。
    public static let fadeOutIntervalStart: Double = 0.6

    /// ripple.json constants radiusBeginFactor.value；ink_ripple.dart:159 的 0.30
    public static let radiusBeginFactor: Double = 0.3

    /// ripple.json constants radiusEndExtra.value；ink_ripple.dart:159 的 5.0
    public static let radiusEndExtra: Double = 5.0

    /// ripple.json constants easeCurve.value；ink_ripple.dart:193
    public static let easeCurve = "Curves.ease"

    /// ripple.json referenceBox.width
    /// one_tokens.dart:65 OneSizes.minimumTarget
    public static let referenceBoxWidth: Double = 44.0

    /// ripple.json referenceBox.height
    /// one_tokens.dart:65 OneSizes.minimumTarget
    public static let referenceBoxHeight: Double = 44.0

    /// ripple.json targetRadius
    public static let targetRadius: Double = 31.11269837220809

    /// ripple.json splashAlpha.light；theme_data.dart:502 浅色 Color(0x66C8C8C8) 的 alpha
    public static let splashAlphaLight: Int = 102

    /// ripple.json splashAlpha.dark；theme_data.dart:502 深色 Color(0x40CCCCCC) 的 alpha
    public static let splashAlphaDark: Int = 64

    /// ripple.json hold.light
    public static let holdLight: [RippleSample] = [
        // ripple.json hold.light[0]
        RippleSample(ms: 0, radius: 9.333809511662427, alpha: 0, opacity: 0.0),
        // ripple.json hold.light[1]
        RippleSample(ms: 75, radius: 10.92177318601048, alpha: 102, opacity: 0.4),
        // ripple.json hold.light[2]
        RippleSample(ms: 200, radius: 17.281207662277865, alpha: 102, opacity: 0.4),
        // ripple.json hold.light[3]
        RippleSample(ms: 500, radius: 30.810270987357445, alpha: 102, opacity: 0.4),
        // ripple.json hold.light[4]
        RippleSample(ms: 1000, radius: 36.11269837220809, alpha: 102, opacity: 0.4),
    ]

    /// ripple.json hold.dark
    public static let holdDark: [RippleSample] = [
        // ripple.json hold.dark[0]
        RippleSample(ms: 0, radius: 9.333809511662427, alpha: 0, opacity: 0.0),
        // ripple.json hold.dark[1]
        RippleSample(ms: 75, radius: 10.92177318601048, alpha: 64, opacity: 0.25098039215686274),
        // ripple.json hold.dark[2]
        RippleSample(ms: 200, radius: 17.281207662277865, alpha: 64, opacity: 0.25098039215686274),
        // ripple.json hold.dark[3]
        RippleSample(ms: 500, radius: 30.810270987357445, alpha: 64, opacity: 0.25098039215686274),
        // ripple.json hold.dark[4]
        RippleSample(ms: 1000, radius: 36.11269837220809, alpha: 64, opacity: 0.25098039215686274),
    ]

    /// ripple.json confirm.light
    public static let confirmLight: [RippleSample] = [
        // ripple.json confirm.light[0]
        RippleSample(ms: 0, radius: 9.333809511662427, alpha: 0, opacity: 0.0),
        // ripple.json confirm.light[1]
        RippleSample(ms: 75, radius: 24.766963473019842, alpha: 102, opacity: 0.4),
        // ripple.json confirm.light[2]
        RippleSample(ms: 225, radius: 36.11269837220809, alpha: 102, opacity: 0.4),
        // ripple.json confirm.light[3]
        RippleSample(ms: 400, radius: 36.11269837220809, alpha: 0, opacity: 0.0),
        // ripple.json confirm.light[4]
        RippleSample(ms: 600, radius: 36.11269837220809, alpha: 0, opacity: 0.0),
    ]

    /// ripple.json confirm.dark
    public static let confirmDark: [RippleSample] = [
        // ripple.json confirm.dark[0]
        RippleSample(ms: 0, radius: 9.333809511662427, alpha: 0, opacity: 0.0),
        // ripple.json confirm.dark[1]
        RippleSample(ms: 75, radius: 24.766963473019842, alpha: 64, opacity: 0.25098039215686274),
        // ripple.json confirm.dark[2]
        RippleSample(ms: 225, radius: 36.11269837220809, alpha: 64, opacity: 0.25098039215686274),
        // ripple.json confirm.dark[3]
        RippleSample(ms: 400, radius: 36.11269837220809, alpha: 0, opacity: 0.0),
        // ripple.json confirm.dark[4]
        RippleSample(ms: 600, radius: 36.11269837220809, alpha: 0, opacity: 0.0),
    ]

    /// layout.json scenes.dock_pressed.light.dock
    public static let dockPressedLightDock = SceneRect(
        left: 0.0,
        top: 780.0,
        width: 390.0,
        height: 64.0
    )

    /// layout.json scenes.dock_pressed.light.indicator
    public static let dockPressedLightIndicator = SceneRect(
        left: 20.0,
        top: 784.0,
        width: 87.5,
        height: 48.0
    )

    /// layout.json scenes.dock_pressed.dark.dock
    public static let dockPressedDarkDock = SceneRect(
        left: 0.0,
        top: 780.0,
        width: 390.0,
        height: 64.0
    )

    /// layout.json scenes.dock_pressed.dark.indicator
    public static let dockPressedDarkIndicator = SceneRect(
        left: 20.0,
        top: 784.0,
        width: 87.5,
        height: 48.0
    )
}
