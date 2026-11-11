public struct GlassPaint: Equatable {
    public let argb: String
    public let alpha: String

    public init(_ channels: OneChannels) {
        argb = OneColor.fromChannels(channels).argb
        alpha = OneColor.alphaText(channels.a)
    }
}

public struct GlassShadowLayer: Equatable {
    public let argb: String
    public let alpha: String
    public let blurRadius: Double
    public let offsetX: Double
    public let offsetY: Double
    public let spreadRadius: Double

    public init(color: OneChannels, blurRadius: Double, offsetY: Double) {
        let paint = GlassPaint(color)
        self.argb = paint.argb
        self.alpha = paint.alpha
        self.blurRadius = blurRadius
        self.offsetX = 0
        self.offsetY = offsetY
        self.spreadRadius = 0
    }
}

public struct GlassResolved: Equatable {
    public let fill: GlassPaint
    public let fillStrong: GlassPaint
    public let barFill: GlassPaint
    public let modalFill: GlassPaint
    public let dialogFill: GlassPaint
    public let stroke: GlassPaint
    public let shadowNormal: [GlassShadowLayer]
    public let shadowStrong: [GlassShadowLayer]
    public let backdropBegin: String
    public let backdropEnd: String
    public let backdropTop: GlassPaint
    public let backdropBottom: GlassPaint
    public let accent: GlassPaint
}

public enum Glass {
    public static let radiusCard: Double = 18
    public static let radiusTile: Double = 14
    public static let radiusChip: Double = 10
    public static let radiusHero: Double = radiusCard + 4
    public static let dockHeight: Double = 56
    public static let radiusDock: Double = dockHeight / 2
    public static let dockBottomGap: Double = 8
    public static let blurDock: Double = 12
    public static let dockTabInset: Double = 4
    public static let dockIndicatorHeight: Double = 48
    public static let space2: Double = 2
    public static let space4: Double = 4
    public static let space6: Double = 6
    public static let space8: Double = 8
    public static let space12: Double = 12
    public static let space16: Double = 16
    public static let space20: Double = 20
    public static let space24: Double = 24
    public static let pageMargin: Double = 16
    public static let cardGap: Double = 14
    public static let padCard: Double = 16
    public static let blurPanel: Double = 18
    public static let blurBar: Double = 24
    public static let blurLiquid: Double = 10
    public static let liquidRefraction: Double = 0.04
    public static let strokeWidth: Double = 0.8
    public static let barAlpha: Double = 0.86
    public static let modalAlpha: Double = 0.92
    public static let dialogAlpha: Double = 0.88

    public static let fillAlphaLight: Double = 0.55
    public static let fillAlphaDark: Double = 0.22
    public static let fillStrongAlphaLight: Double = 0.72
    public static let fillStrongAlphaDark: Double = 0.62
    public static let strokeAlphaDark: Double = 0.12
    public static let strokeWhiteAlphaLight: Double = 0.55
    public static let strokeInkAlphaLight: Double = 0.10
    public static let accentLuminanceLimit: Double = 0.7
    public static let neutralSaturationLimit: Double = 0.15
    public static let backdropPrimaryAlphaDark: Double = 0.10
    public static let backdropPrimaryAlphaLight: Double = 0.07
    public static let backdropTertiaryAlphaDark: Double = 0.05
    public static let backdropTertiaryAlphaLight: Double = 0.03
    public static let backdropBegin: String = "topCenter"
    public static let backdropEnd: String = "bottomCenter"

    public static let shadowDarkAlphaNormal: Double = 0.28
    public static let shadowDarkBlurNormal: Double = 18
    public static let shadowDarkOffsetYNormal: Double = 8
    public static let shadowDarkAlphaStrong: Double = 0.32
    public static let shadowDarkBlurStrong: Double = 22
    public static let shadowDarkOffsetYStrong: Double = 10
    public static let shadowLightContactAlphaNormal: Double = 0.08
    public static let shadowLightContactBlurNormal: Double = 6
    public static let shadowLightContactOffsetYNormal: Double = 2
    public static let shadowLightAmbientAlphaNormal: Double = 0.16
    public static let shadowLightAmbientBlurNormal: Double = 22
    public static let shadowLightAmbientOffsetYNormal: Double = 10
    public static let shadowLightContactAlphaStrong: Double = 0.10
    public static let shadowLightContactBlurStrong: Double = 8
    public static let shadowLightContactOffsetYStrong: Double = 3
    public static let shadowLightAmbientAlphaStrong: Double = 0.20
    public static let shadowLightAmbientBlurStrong: Double = 28
    public static let shadowLightAmbientOffsetYStrong: Double = 12

    public static let metrics: [String: Double] = [
        "radiusCard": radiusCard,
        "radiusTile": radiusTile,
        "radiusChip": radiusChip,
        "radiusHero": radiusHero,
        "dockHeight": dockHeight,
        "radiusDock": radiusDock,
        "dockBottomGap": dockBottomGap,
        "blurDock": blurDock,
        "dockTabInset": dockTabInset,
        "dockIndicatorHeight": dockIndicatorHeight,
        "space2": space2,
        "space4": space4,
        "space6": space6,
        "space8": space8,
        "space12": space12,
        "space16": space16,
        "space20": space20,
        "space24": space24,
        "pageMargin": pageMargin,
        "cardGap": cardGap,
        "padCard": padCard,
        "blurPanel": blurPanel,
        "blurBar": blurBar,
        "blurLiquid": blurLiquid,
        "liquidRefraction": liquidRefraction,
        "strokeWidth": strokeWidth,
        "barAlpha": barAlpha,
        "modalAlpha": modalAlpha,
        "dialogAlpha": dialogAlpha,
    ]

    public static func fill(dark: Bool) -> GlassPaint {
        GlassPaint(fillChannels(dark: dark))
    }

    public static func fillStrong(dark: Bool) -> GlassPaint {
        GlassPaint(fillStrongChannels(dark: dark))
    }

    public static func barFill(dark: Bool) -> GlassPaint {
        GlassPaint(barFillChannels(dark: dark))
    }

    public static func modalFill(dark: Bool) -> GlassPaint {
        GlassPaint(modalFillChannels(dark: dark))
    }

    public static func dialogFill(dark: Bool) -> GlassPaint {
        GlassPaint(dialogFillChannels(dark: dark))
    }

    public static func stroke(dark: Bool) -> GlassPaint {
        GlassPaint(strokeChannels(dark: dark))
    }

    public static func accent(dark: Bool) -> GlassPaint {
        GlassPaint(accentChannels(dark: dark))
    }

    public static func resolved(dark: Bool) -> GlassResolved {
        let backdrop = backdropChannels(dark: dark)
        return GlassResolved(
            fill: fill(dark: dark),
            fillStrong: fillStrong(dark: dark),
            barFill: barFill(dark: dark),
            modalFill: modalFill(dark: dark),
            dialogFill: dialogFill(dark: dark),
            stroke: stroke(dark: dark),
            shadowNormal: shadowLayers(dark: dark, strong: false),
            shadowStrong: shadowLayers(dark: dark, strong: true),
            backdropBegin: backdropBegin,
            backdropEnd: backdropEnd,
            backdropTop: GlassPaint(backdrop.top),
            backdropBottom: GlassPaint(backdrop.bottom),
            accent: accent(dark: dark)
        )
    }

    private static func scheme(dark: Bool) -> OneColorScheme {
        dark ? OnePalette.oneBlackWhiteDark : OnePalette.oneBlackWhiteLight
    }

    private static func fillChannels(dark: Bool) -> OneChannels {
        let colors = scheme(dark: dark)
        if dark {
            return colors.surfaceContainerHighest.withAlpha(fillAlphaDark)
        }
        return colors.surface.withAlpha(fillAlphaLight)
    }

    private static func fillStrongChannels(dark: Bool) -> OneChannels {
        scheme(dark: dark).surfaceContainerLow.withAlpha(dark ? fillStrongAlphaDark : fillStrongAlphaLight)
    }

    private static func barFillChannels(dark: Bool) -> OneChannels {
        let colors = scheme(dark: dark)
        let base = dark ? colors.surfaceContainerLow : colors.surface
        return base.withAlpha(barAlpha)
    }

    private static func modalFillChannels(dark: Bool) -> OneChannels {
        scheme(dark: dark).surfaceContainerLow.withAlpha(modalAlpha)
    }

    private static func dialogFillChannels(dark: Bool) -> OneChannels {
        scheme(dark: dark).surfaceContainerLow.withAlpha(dialogAlpha)
    }

    private static func strokeChannels(dark: Bool) -> OneChannels {
        if dark {
            return OneColor.white.withAlpha(strokeAlphaDark)
        }
        return OneColor.alphaBlend(
            OneColor.white.withAlpha(strokeWhiteAlphaLight),
            onto: scheme(dark: dark).onSurface.withAlpha(strokeInkAlphaLight)
        )
    }

    private static func accentChannels(dark: Bool) -> OneChannels {
        let colors = scheme(dark: dark)
        if colors.primary.luminance > accentLuminanceLimit {
            return colors.onSurface.channels
        }
        return colors.primary.channels
    }

    private static func backdropChannels(dark: Bool) -> (top: OneChannels, bottom: OneChannels) {
        let colors = scheme(dark: dark)
        if dark && colors.surface.argb == OneColor.black.argb {
            return (colors.surface.channels, colors.surface.channels)
        }
        if colors.primary.saturation < neutralSaturationLimit {
            if dark {
                return (colors.surfaceContainerHigh.channels, colors.surface.channels)
            }
            return (colors.surfaceContainerLowest.channels, colors.surfaceContainer.channels)
        }
        let surface = colors.surface.channels
        let primaryAlpha = dark ? backdropPrimaryAlphaDark : backdropPrimaryAlphaLight
        let tertiaryAlpha = dark ? backdropTertiaryAlphaDark : backdropTertiaryAlphaLight
        return (
            OneColor.alphaBlend(colors.primary.withAlpha(primaryAlpha), onto: surface),
            OneColor.alphaBlend(colors.tertiary.withAlpha(tertiaryAlpha), onto: surface)
        )
    }

    private static func shadowLayers(dark: Bool, strong: Bool) -> [GlassShadowLayer] {
        if dark {
            if strong {
                return [layer(shadowDarkAlphaStrong, shadowDarkBlurStrong, shadowDarkOffsetYStrong)]
            }
            return [layer(shadowDarkAlphaNormal, shadowDarkBlurNormal, shadowDarkOffsetYNormal)]
        }
        if strong {
            return [
                layer(shadowLightContactAlphaStrong, shadowLightContactBlurStrong, shadowLightContactOffsetYStrong),
                layer(shadowLightAmbientAlphaStrong, shadowLightAmbientBlurStrong, shadowLightAmbientOffsetYStrong),
            ]
        }
        return [
            layer(shadowLightContactAlphaNormal, shadowLightContactBlurNormal, shadowLightContactOffsetYNormal),
            layer(shadowLightAmbientAlphaNormal, shadowLightAmbientBlurNormal, shadowLightAmbientOffsetYNormal),
        ]
    }

    private static func layer(_ alpha: Double, _ blur: Double, _ offsetY: Double) -> GlassShadowLayer {
        GlassShadowLayer(color: OneColor.black.withAlpha(alpha), blurRadius: blur, offsetY: offsetY)
    }
}
