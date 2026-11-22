import CoreText
import OneUICore
import SwiftUI

/// Material Icons font-backed glyph. The codepoint catalog is generated from
/// the bundled font cmap and is the single source of truth for names.
public struct MaterialIcon: View {
    public static let postScriptFace = "MaterialIcons-Regular"

    public let name: String
    public let size: CGFloat
    public let color: Color?
    private let explicitCodePoint: UInt32?

    private static let registered: Void = {
        guard let url = Bundle.module.url(
            forResource: postScriptFace,
            withExtension: "otf",
            subdirectory: "Icons"
        ) ?? Bundle.module.url(forResource: postScriptFace, withExtension: "otf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }()

    public init(name: String, size: CGFloat = 24, color: Color? = nil) {
        self.name = name
        self.size = size
        self.color = color
        self.explicitCodePoint = nil
    }

    public init(codePoint: UInt32, size: CGFloat = 24, color: Color? = nil) {
        self.name = ""
        self.size = size
        self.color = color
        self.explicitCodePoint = codePoint
    }

    public var body: some View {
        _ = Self.registered
        let resolvedCodePoint: UInt32? = {
            if let explicitCodePoint { return explicitCodePoint }
            if name == "eye" { return MaterialIconCodepoints.visibility_outlined }
            if name == "eye_slash" { return MaterialIconCodepoints.visibility_off_outlined }
            return MaterialIconCodepoints.codePoint(for: name)
        }()
        let glyph = resolvedCodePoint.flatMap { UnicodeScalar($0) }.map { String($0) } ?? "\u{FFFD}"
        return Text(glyph)
            .font(.custom(Self.postScriptFace, size: size))
            .foregroundStyle(color ?? OnePalette.onSurface)
            .frame(width: size, height: size, alignment: .center)
            .accessibilityHidden(true)
    }

    public static func glyph(_ name: String, size: CGFloat = 24, color: Color? = nil) -> MaterialIcon {
        MaterialIcon(name: name, size: size, color: color)
    }
}
