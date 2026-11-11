#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public struct OneChannels: Equatable {
    public let a: Double
    public let r: Double
    public let g: Double
    public let b: Double

    public init(a: Double, r: Double, g: Double, b: Double) {
        self.a = a
        self.r = r
        self.g = g
        self.b = b
    }
}

public struct OneColor: Equatable {
    public let value: UInt32

    public init(value: UInt32) {
        self.value = value
    }

    public init(argb: String) {
        let hex = argb.uppercased()
        precondition(hex.count == 8, "ARGB must be 8 hex digits")
        precondition(hex.allSatisfy(\.isHexDigit), "ARGB must be hex")
        self.value = UInt32(hex, radix: 16)!
    }

    public static let white = OneColor(argb: "FFFFFFFF")
    public static let black = OneColor(argb: "FF000000")

    public var argb: String {
        let digits = Array("0123456789ABCDEF")
        var chars: [Character] = []
        chars.reserveCapacity(8)
        for shift in stride(from: 28, through: 0, by: -4) {
            let nibble = Int((value >> UInt32(shift)) & 0xF)
            chars.append(digits[nibble])
        }
        return String(chars)
    }

    public var alpha: Double { Self.unit((value >> 24) & 0xFF) }
    public var red: Double { Self.unit((value >> 16) & 0xFF) }
    public var green: Double { Self.unit((value >> 8) & 0xFF) }
    public var blue: Double { Self.unit(value & 0xFF) }

    public var channels: OneChannels {
        OneChannels(a: alpha, r: red, g: green, b: blue)
    }

    public func withAlpha(_ alpha: Double) -> OneChannels {
        OneChannels(a: alpha, r: red, g: green, b: blue)
    }

    public var luminance: Double {
        0.2126 * Self.linearize(red) + 0.7152 * Self.linearize(green) + 0.0722 * Self.linearize(blue)
    }

    public var saturation: Double {
        let high = max(red, green, blue)
        let low = min(red, green, blue)
        if low == high {
            return 0
        }
        let lightness = (high + low) / 2
        return min(1, max(0, (high - low) / (1 - abs(2 * lightness - 1))))
    }

    public static func fromChannels(_ channels: OneChannels) -> OneColor {
        let packed = (byte(channels.a) << 24)
            | (byte(channels.r) << 16)
            | (byte(channels.g) << 8)
            | byte(channels.b)
        return OneColor(value: packed)
    }

    public static func alphaBlend(_ foreground: OneChannels, onto background: OneChannels) -> OneChannels {
        let alpha = foreground.a
        if alpha == 0 {
            return background
        }
        let inverse = 1 - alpha
        if background.a == 1 {
            return OneChannels(
                a: 1,
                r: alpha * foreground.r + inverse * background.r,
                g: alpha * foreground.g + inverse * background.g,
                b: alpha * foreground.b + inverse * background.b
            )
        }
        let back = background.a * inverse
        let out = alpha + back
        return OneChannels(
            a: out,
            r: (foreground.r * alpha + background.r * back) / out,
            g: (foreground.g * alpha + background.g * back) / out,
            b: (foreground.b * alpha + background.b * back) / out
        )
    }

    public static func alphaText(_ alpha: Double) -> String {
        let rounded = dartRound(alpha * 10000)
        let sign = rounded < 0 ? "-" : ""
        let absolute = abs(rounded)
        let whole = absolute / 10000
        let frac = absolute % 10000
        var digits = Array("0000")
        var rest = frac
        for index in stride(from: 3, through: 0, by: -1) {
            digits[index] = Character(String(rest % 10))
            rest /= 10
        }
        return "\(sign)\(whole).\(String(digits))"
    }

    private static func unit(_ byte: UInt32) -> Double {
        Double(byte) / 255
    }

    private static func byte(_ channel: Double) -> UInt32 {
        let rounded = dartRound(channel * 255)
        return UInt32(min(255, max(0, rounded)))
    }

    private static func linearize(_ component: Double) -> Double {
        if component <= 0.03928 {
            return component / 12.92
        }
        return pow((component + 0.055) / 1.055, 2.4)
    }

    // Dart `round` is half away from zero. Positive values match trunc(x + 0.5).
    private static func dartRound(_ value: Double) -> Int {
        if value >= 0 {
            return Int(value + 0.5)
        }
        return -Int((-value) + 0.5)
    }
}

public struct OneColorScheme: Equatable {
    public let brightness: String
    public let colors: [String: OneColor]

    public init(brightness: String, colors: [String: OneColor]) {
        self.brightness = brightness
        self.colors = colors
    }

    public subscript(name: String) -> OneColor {
        guard let color = colors[name] else {
            preconditionFailure("missing color \(name)")
        }
        return color
    }

    public var primary: OneColor { self["primary"] }
    public var onSurface: OneColor { self["onSurface"] }
    public var surface: OneColor { self["surface"] }
    public var surfaceContainerLowest: OneColor { self["surfaceContainerLowest"] }
    public var surfaceContainerLow: OneColor { self["surfaceContainerLow"] }
    public var surfaceContainer: OneColor { self["surfaceContainer"] }
    public var surfaceContainerHigh: OneColor { self["surfaceContainerHigh"] }
    public var surfaceContainerHighest: OneColor { self["surfaceContainerHighest"] }
    public var error: OneColor { self["error"] }
    public var tertiary: OneColor { self["tertiary"] }
}

public enum OnePalette {
    public static let ink = OneColor(argb: "FF1A1B20")

    public static let oneBlackWhiteLight = OneColorScheme(
        brightness: "light",
        colors: schemeColors([
            "primary": "FF1A1B20",
            "onPrimary": "FFFFFFFF",
            "primaryContainer": "FFF0F0F4",
            "onPrimaryContainer": "FF1A1B20",
            "primaryFixed": "FF1A1B20",
            "primaryFixedDim": "FF1A1B20",
            "onPrimaryFixed": "FFFFFFFF",
            "onPrimaryFixedVariant": "FFFFFFFF",
            "secondary": "FF575E71",
            "onSecondary": "FFFFFFFF",
            "secondaryContainer": "FFE8E8EF",
            "onSecondaryContainer": "FF141B2C",
            "secondaryFixed": "FF575E71",
            "secondaryFixedDim": "FF575E71",
            "onSecondaryFixed": "FFFFFFFF",
            "onSecondaryFixedVariant": "FFFFFFFF",
            "tertiary": "FF5F5E62",
            "onTertiary": "FFFFFFFF",
            "tertiaryContainer": "FFE8E8EF",
            "onTertiaryContainer": "FF1B1B1F",
            "tertiaryFixed": "FF5F5E62",
            "tertiaryFixedDim": "FF5F5E62",
            "onTertiaryFixed": "FFFFFFFF",
            "onTertiaryFixedVariant": "FFFFFFFF",
            "error": "FFBA1A1A",
            "onError": "FFFFFFFF",
            "errorContainer": "FFF9DEDC",
            "onErrorContainer": "FF410E0B",
            "surface": "FFF9F9FF",
            "onSurface": "FF1A1B20",
            "surfaceVariant": "FFF9F9FF",
            "surfaceDim": "FFDAD9E0",
            "surfaceBright": "FFF9F9FF",
            "surfaceContainerLowest": "FFFFFFFF",
            "surfaceContainerLow": "FFF3F3FA",
            "surfaceContainer": "FFEDEDF4",
            "surfaceContainerHigh": "FFE7E8EE",
            "surfaceContainerHighest": "FFE2E2E9",
            "onSurfaceVariant": "FF44474F",
            "outline": "FF74777F",
            "outlineVariant": "FFC4C6D0",
            "shadow": "FF000000",
            "scrim": "FF000000",
            "inverseSurface": "FF2F3036",
            "onInverseSurface": "FFF0F0F7",
            "inversePrimary": "FFFFFFFF",
            "surfaceTint": "FF74777F",
            "background": "FFF9F9FF",
            "onBackground": "FF1A1B20",
        ])
    )

    public static let oneBlackWhiteDark = OneColorScheme(
        brightness: "dark",
        colors: schemeColors([
            "primary": "FFFFFFFF",
            "onPrimary": "FF1A1B20",
            "primaryContainer": "FF2B2930",
            "onPrimaryContainer": "FFE2E2E9",
            "primaryFixed": "FFFFFFFF",
            "primaryFixedDim": "FFFFFFFF",
            "onPrimaryFixed": "FF1A1B20",
            "onPrimaryFixedVariant": "FF1A1B20",
            "secondary": "FFC8C5D0",
            "onSecondary": "FF2A3042",
            "secondaryContainer": "FF3F4759",
            "onSecondaryContainer": "FFE4E7F6",
            "secondaryFixed": "FFC8C5D0",
            "secondaryFixedDim": "FFC8C5D0",
            "onSecondaryFixed": "FF2A3042",
            "onSecondaryFixedVariant": "FF2A3042",
            "tertiary": "FFC8C5D0",
            "onTertiary": "FF303034",
            "tertiaryContainer": "FF48464C",
            "onTertiaryContainer": "FFE5E1E6",
            "tertiaryFixed": "FFC8C5D0",
            "tertiaryFixedDim": "FFC8C5D0",
            "onTertiaryFixed": "FF303034",
            "onTertiaryFixedVariant": "FF303034",
            "error": "FFFFB4AB",
            "onError": "FF690005",
            "errorContainer": "FF93000A",
            "onErrorContainer": "FFFFDAD6",
            "surface": "FF111318",
            "onSurface": "FFE2E2E9",
            "surfaceVariant": "FF111318",
            "surfaceDim": "FF111318",
            "surfaceBright": "FF37393E",
            "surfaceContainerLowest": "FF0C0E13",
            "surfaceContainerLow": "FF191C20",
            "surfaceContainer": "FF1D2024",
            "surfaceContainerHigh": "FF282A2F",
            "surfaceContainerHighest": "FF33353A",
            "onSurfaceVariant": "FFC4C6D0",
            "outline": "FF8E9099",
            "outlineVariant": "FF44474F",
            "shadow": "FF000000",
            "scrim": "FF000000",
            "inverseSurface": "FFE2E2E9",
            "onInverseSurface": "FF2F3036",
            "inversePrimary": "FF1A1B20",
            "surfaceTint": "FF8E9099",
            "background": "FF111318",
            "onBackground": "FFE2E2E9",
        ])
    )
}

public enum OneHero {
    public static let surface = OneColor.white
    public static let onSurface = OnePalette.ink
    public static let buttonSurface = OneColor.white
    public static let onButtonSurface = OneColor.black
}

private func schemeColors(_ hexes: [String: String]) -> [String: OneColor] {
    var colors: [String: OneColor] = [:]
    for (name, hex) in hexes {
        colors[name] = OneColor(argb: hex)
    }
    return colors
}
