import Foundation

/// Dock numbers from `_golden/fixtures/layout.json`.
/// Keys that already live on Glass read those constants.
/// `slideMs` is GlassDock._slideDuration and is absent from Glass.metrics.
public enum LayoutDock {
    public static let slideMs: Double = 480

    public static var fixtureTree: OneTokenValue {
        .group([
            "height": .number(Glass.dockHeight),
            "radius": .number(Glass.radiusDock),
            "bottomGap": .number(Glass.dockBottomGap),
            "blur": .number(Glass.blurDock),
            "tabInset": .number(Glass.dockTabInset),
            "indicatorHeight": .number(Glass.dockIndicatorHeight),
            "slideMs": .number(slideMs),
        ])
    }
}
