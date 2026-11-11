import CoreText
import SwiftUI

/// Montserrat 字体。Flutter 版只打包了 Regular，600/700 字重全靠合成加粗（发虚）；
/// 这里打包 Regular / Medium / SemiBold / Bold 四个真字重（SIL OFL 1.1，见 Resources/Fonts/OFL.txt）。
public enum OneFont {
    private static let files = [
        "Montserrat-Regular", "Montserrat-Medium", "Montserrat-SemiBold", "Montserrat-Bold",
    ]

    private static let registered: Void = {
        for name in files {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
                ?? Bundle.module.url(forResource: name, withExtension: "ttf")
            else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()

    /// App 启动时调用一次（`OneTheme` 会自动调用，重复调用无副作用）。
    public static func register() { _ = registered }

    static func postScriptName(_ weight: Font.Weight) -> String {
        switch weight {
        case .bold, .heavy, .black: "Montserrat-Bold"
        case .semibold: "Montserrat-SemiBold"
        case .medium: "Montserrat-Medium"
        default: "Montserrat-Regular"
        }
    }

    /// 跟随动态字体缩放（Dynamic Type）的 Montserrat。
    public static func montserrat(_ size: CGFloat, _ weight: Font.Weight = .regular, relativeTo style: Font.TextStyle) -> Font {
        register()
        return .custom(postScriptName(weight), size: size, relativeTo: style)
    }
}

/// 字号标度：取 Material 3 的字号（Flutter 版 textTheme 的实际值），绑定到对应的 iOS 文本样式做动态缩放。
public enum OneText {
    public static func headline(_ weight: Font.Weight = .semibold) -> Font { OneFont.montserrat(24, weight, relativeTo: .title) }
    public static func titleLarge(_ weight: Font.Weight = .semibold) -> Font { OneFont.montserrat(22, weight, relativeTo: .title2) }
    public static func titleMedium(_ weight: Font.Weight = .semibold) -> Font { OneFont.montserrat(16, weight, relativeTo: .headline) }
    public static func titleSmall(_ weight: Font.Weight = .bold) -> Font { OneFont.montserrat(14, weight, relativeTo: .subheadline) }
    public static func bodyLarge(_ weight: Font.Weight = .regular) -> Font { OneFont.montserrat(16, weight, relativeTo: .body) }
    public static func bodyMedium(_ weight: Font.Weight = .regular) -> Font { OneFont.montserrat(14, weight, relativeTo: .callout) }
    public static func bodySmall(_ weight: Font.Weight = .regular) -> Font { OneFont.montserrat(12, weight, relativeTo: .footnote) }
    public static func labelLarge(_ weight: Font.Weight = .semibold) -> Font { OneFont.montserrat(14, weight, relativeTo: .subheadline) }
    public static func labelMedium(_ weight: Font.Weight = .medium) -> Font { OneFont.montserrat(12, weight, relativeTo: .caption) }
    public static func labelSmall(_ weight: Font.Weight = .medium) -> Font { OneFont.montserrat(11, weight, relativeTo: .caption2) }
}
