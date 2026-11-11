import Foundation

public struct ShadowLayer: Equatable {
    public let argb: String
    public let alpha: String
    public let blurRadius: Double
    public let offsetX: Double
    public let offsetY: Double
    public let spreadRadius: Double

    public init(
        argb: String,
        alpha: String,
        blurRadius: Double,
        offsetX: Double,
        offsetY: Double,
        spreadRadius: Double
    ) {
        self.argb = argb
        self.alpha = alpha
        self.blurRadius = blurRadius
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.spreadRadius = spreadRadius
    }
}

public enum ShadowNumbers {
    /// tokens.json resolved.light.shadow.normal[0]
    /// glass.dart:254-256；spreadRadius 取自夹具，Dart 这一层没写 spread。
    public static let lightNormal0 = ShadowLayer(
        argb: "14000000",
        alpha: "0.0800",
        blurRadius: 6.0,
        offsetX: 0.0,
        offsetY: 2.0,
        spreadRadius: 0.0
    )

    /// tokens.json resolved.light.shadow.normal[1]
    /// glass.dart:259-261
    public static let lightNormal1 = ShadowLayer(
        argb: "29000000",
        alpha: "0.1600",
        blurRadius: 22.0,
        offsetX: 0.0,
        offsetY: 10.0,
        spreadRadius: 0.0
    )

    /// tokens.json resolved.light.shadow.strong[0]
    /// glass.dart:254-256 的 strong 分支
    public static let lightStrong0 = ShadowLayer(
        argb: "1A000000",
        alpha: "0.1000",
        blurRadius: 8.0,
        offsetX: 0.0,
        offsetY: 3.0,
        spreadRadius: 0.0
    )

    /// tokens.json resolved.light.shadow.strong[1]
    /// glass.dart:259-261 的 strong 分支
    public static let lightStrong1 = ShadowLayer(
        argb: "33000000",
        alpha: "0.2000",
        blurRadius: 28.0,
        offsetX: 0.0,
        offsetY: 12.0,
        spreadRadius: 0.0
    )

    /// tokens.json resolved.dark.shadow.normal[0]
    /// glass.dart:246-248
    public static let darkNormal0 = ShadowLayer(
        argb: "47000000",
        alpha: "0.2800",
        blurRadius: 18.0,
        offsetX: 0.0,
        offsetY: 8.0,
        spreadRadius: 0.0
    )

    /// tokens.json resolved.dark.shadow.strong[0]
    /// glass.dart:246-248 的 strong 分支
    public static let darkStrong0 = ShadowLayer(
        argb: "52000000",
        alpha: "0.3200",
        blurRadius: 22.0,
        offsetX: 0.0,
        offsetY: 10.0,
        spreadRadius: 0.0
    )

    /// glass.dart:360。cardTheme elevation，浅色。
    public static let cardElevationLight: Int = 1

    /// glass.dart:360。cardTheme elevation，深色。
    public static let cardElevationDark: Int = 0

    /// glass.dart:361。cardTheme shadowColor alpha，浅色。
    public static let cardShadowAlphaLight: Double = 0.20

    /// glass.dart:361。cardTheme shadowColor alpha，深色。
    public static let cardShadowAlphaDark: Double = 0.14
}
