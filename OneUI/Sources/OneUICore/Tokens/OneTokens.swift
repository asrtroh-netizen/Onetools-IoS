public enum OneTokenValue: Equatable {
    case text(String)
    case number(Double)
    case group([String: OneTokenValue])
    case list([OneTokenValue])
}

public enum OneTokens {
    public static var fixtureTree: OneTokenValue {
        .group([
            "schemes": .group([
                "oneBlackWhiteLight": schemeTokens(OnePalette.oneBlackWhiteLight),
                "oneBlackWhiteDark": schemeTokens(OnePalette.oneBlackWhiteDark),
            ]),
            "glass": .group(Glass.metrics.mapValues { .number($0) }),
            "resolved": .group([
                "light": resolvedTokens(Glass.resolved(dark: false)),
                "dark": resolvedTokens(Glass.resolved(dark: true)),
            ]),
        ])
    }
}

public enum OneColors {
    public static let lightBackground = OnePalette.oneBlackWhiteLight.surface
    public static let lightBackgroundLift = OneColor.white
    public static let lightInk = OnePalette.ink
    public static let lightMuted = OnePalette.oneBlackWhiteLight["onSurfaceVariant"]
    public static let darkBackground = OnePalette.oneBlackWhiteDark.surface
    public static let darkBackgroundLift = OnePalette.oneBlackWhiteDark.surfaceContainerLow
    public static let darkInk = OnePalette.oneBlackWhiteDark.onSurface
    public static let darkMuted = OnePalette.oneBlackWhiteDark["onSurfaceVariant"]
    public static let negative = OnePalette.oneBlackWhiteLight.error
    public static let transparent = OneColor(argb: "00000000")

    public static func glass(dark: Bool) -> GlassPaint {
        Glass.fill(dark: dark)
    }

    public static func hairline(dark: Bool) -> GlassPaint {
        Glass.stroke(dark: dark)
    }

    public static func focus(dark: Bool) -> OneColor {
        dark ? OneColor.white : OnePalette.ink
    }
}

public enum OneFocus {
    public static let width: Double = 2
    public static let offset: Double = 2
    public static let overlayOpacity: Double = 0.16
}

public enum OneSpacing {
    public static let hairline = Glass.strokeWidth
    public static let nano = Glass.space2
    public static let tight = Glass.space6
    public static let micro = Glass.space4
    public static let small = Glass.space8
    public static let item = Glass.space12
    public static let medium = Glass.space16
    public static let page = Glass.pageMargin
    public static let section = Glass.space24
    public static let large: Double = 36
}

public enum OneRadii {
    public static let control = Glass.radiusTile
    public static let panel = Glass.radiusCard
    public static let hero = Glass.radiusHero
    public static let dock = Glass.radiusDock
}

public enum OneSizes {
    public static let minimumTarget: Double = 44
    public static let control: Double = 52
    public static let dock = Glass.dockHeight
    public static let icon: Double = 22
}

public struct OneEdgeInsets: Equatable {
    public let top: Double
    public let left: Double
    public let bottom: Double
    public let right: Double

    public init(top: Double, left: Double, bottom: Double, right: Double) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }

    public static func all(_ value: Double) -> OneEdgeInsets {
        OneEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    public static func symmetric(horizontal: Double, vertical: Double) -> OneEdgeInsets {
        OneEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}

public enum OneInsets {
    public static let page = OneEdgeInsets.symmetric(horizontal: Glass.pageMargin, vertical: Glass.space16)
    public static let panel = OneEdgeInsets.all(Glass.padCard)
    public static let hero = OneEdgeInsets.all(Glass.space24)
    public static let dock = OneEdgeInsets.all(Glass.space8)
}

private func schemeTokens(_ scheme: OneColorScheme) -> OneTokenValue {
    var group: [String: OneTokenValue] = ["brightness": .text(scheme.brightness)]
    for (name, color) in scheme.colors {
        group[name] = .text(color.argb)
    }
    return .group(group)
}

private func paintTokens(_ paint: GlassPaint) -> OneTokenValue {
    .group([
        "argb": .text(paint.argb),
        "alpha": .text(paint.alpha),
    ])
}

private func shadowTokens(_ layer: GlassShadowLayer) -> OneTokenValue {
    .group([
        "argb": .text(layer.argb),
        "alpha": .text(layer.alpha),
        "blurRadius": .number(layer.blurRadius),
        "offsetX": .number(layer.offsetX),
        "offsetY": .number(layer.offsetY),
        "spreadRadius": .number(layer.spreadRadius),
    ])
}

private func resolvedTokens(_ resolved: GlassResolved) -> OneTokenValue {
    .group([
        "fill": paintTokens(resolved.fill),
        "fillStrong": paintTokens(resolved.fillStrong),
        "barFill": paintTokens(resolved.barFill),
        "modalFill": paintTokens(resolved.modalFill),
        "dialogFill": paintTokens(resolved.dialogFill),
        "stroke": paintTokens(resolved.stroke),
        "shadow": .group([
            "normal": .list(resolved.shadowNormal.map(shadowTokens)),
            "strong": .list(resolved.shadowStrong.map(shadowTokens)),
        ]),
        "backdrop": .group([
            "begin": .text(resolved.backdropBegin),
            "end": .text(resolved.backdropEnd),
            "top": paintTokens(resolved.backdropTop),
            "bottom": paintTokens(resolved.backdropBottom),
        ]),
        "accent": paintTokens(resolved.accent),
    ])
}
