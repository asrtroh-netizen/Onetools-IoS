import Foundation

public struct SceneRect: Equatable {
    public let left: Double
    public let top: Double
    public let width: Double
    public let height: Double

    public init(left: Double, top: Double, width: Double, height: Double) {
        self.left = left
        self.top = top
        self.width = width
        self.height = height
    }
}

public enum BlurNumbers {
    /// tokens.json glass.blurPanel；glass.dart:89。
    /// glass.dart:199-200 把这个数传给 ImageFilter.blur 的 sigmaX / sigmaY，不是半径。
    public static let blurPanelSigma: Double = 18.0

    /// tokens.json glass.blurBar；glass.dart:92。sigma，不是半径。
    public static let blurBarSigma: Double = 24.0

    /// tokens.json glass.blurDock；layout.json dock.blur；glass.dart:54。sigma，不是半径。
    public static let blurDockSigma: Double = 12.0

    /// tokens.json glass.blurLiquid；glass.dart:98。sigma，不是半径。
    public static let blurLiquidSigma: Double = 10.0

    /// tokens.json glass.liquidRefraction；glass.dart:101。
    public static let liquidRefraction: Double = 0.04

    /// glass.dart:142。有真模糊的栏，浅色填充 alpha。
    public static let blurredBarFillAlphaLight: Double = 0.60

    /// glass.dart:141。有真模糊的栏，深色填充 alpha。
    public static let blurredBarFillAlphaDark: Double = 0.34

    /// glass.dart:149。liquidDockFill 浅色 alpha。
    public static let liquidDockFillAlphaLight: Double = 0.12

    /// glass.dart:149。liquidDockFill 深色 alpha。
    public static let liquidDockFillAlphaDark: Double = 0.06

    /// layout.json scenes.dock_static_0.light.dock
    /// left, top, width, height
    public static let dockStatic0LightDock = SceneRect(
        left: 0.0,
        top: 780.0,
        width: 390.0,
        height: 64.0
    )

    /// layout.json scenes.dock_static_0.light.indicator
    public static let dockStatic0LightIndicator = SceneRect(
        left: 20.0,
        top: 784.0,
        width: 87.5,
        height: 48.0
    )

    /// layout.json scenes.dock_static_0.dark.dock
    public static let dockStatic0DarkDock = SceneRect(
        left: 0.0,
        top: 780.0,
        width: 390.0,
        height: 64.0
    )

    /// layout.json scenes.dock_static_0.dark.indicator
    public static let dockStatic0DarkIndicator = SceneRect(
        left: 20.0,
        top: 784.0,
        width: 87.5,
        height: 48.0
    )
}
