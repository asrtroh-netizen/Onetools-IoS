import SwiftUI
import UIKit

// MARK: - 颜色工具

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }

    /// 按 t 线性混向 other（只用于静态色）。
    func mixed(with other: UIColor, _ t: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t,
            alpha: a1 + (a2 - a1) * t
        )
    }
}

extension Color {
    /// 随系统深浅色自动切换。取代 Flutter 版到处传的 `dark` 布尔。
    static func dynamic(_ light: UIColor, _ dark: UIColor) -> Color {
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? dark : light })
    }

    static func dynamic(
        light: UInt32, _ lightAlpha: CGFloat = 1,
        dark: UInt32, _ darkAlpha: CGFloat = 1
    ) -> Color {
        dynamic(UIColor(hex: light, alpha: lightAlpha), UIColor(hex: dark, alpha: darkAlpha))
    }
}

// MARK: - One 黑白色板

/// 逐值搬自 `one_palette.dart`（OneIMS `Theme.kt` 血统）。
/// 原则不变：强调色只有黑白，报错红之外不出彩色；状态色见 `OneTone`。
public enum OnePalette {
    /// 招牌近黑。
    public static let ink = Color(uiColor: UIColor(hex: 0x1A1B20))

    public static let surface = Color.dynamic(light: 0xF9F9FF, dark: 0x111318)
    public static let onSurface = Color.dynamic(light: 0x1A1B20, dark: 0xE2E2E9)
    public static let onSurfaceVariant = Color.dynamic(light: 0x44474F, dark: 0xC4C6D0)

    public static let containerLowest = Color.dynamic(light: 0xFFFFFF, dark: 0x0C0E13)
    public static let containerLow = Color.dynamic(light: 0xF3F3FA, dark: 0x191C20)
    public static let container = Color.dynamic(light: 0xEDEDF4, dark: 0x1D2024)
    public static let containerHigh = Color.dynamic(light: 0xE7E8EE, dark: 0x282A2F)
    public static let containerHighest = Color.dynamic(light: 0xE2E2E9, dark: 0x33353A)
    public static let primaryContainer = Color.dynamic(light: 0xF0F0F4, dark: 0x2B2930)

    public static let outlineVariant = Color.dynamic(light: 0xC4C6D0, dark: 0x44474F)
    public static let error = Color.dynamic(light: 0xBA1A1A, dark: 0xFFB4AB)
    public static let errorContainer = Color.dynamic(light: 0xF9DEDC, dark: 0x93000A)

    /// 应用底渐变：顶亮底沉（中性色板不染色，避免把背景抹灰）。
    public static let backdropTop = Color.dynamic(light: 0xFFFFFF, dark: 0x282A2F)
    public static let backdropBottom = Color.dynamic(light: 0xEDEDF4, dark: 0x111318)

    /// 门面卡主按钮：白底黑字药丸，刻意不随主题漂移。
    public static let heroButton = Color.white
    public static let onHeroButton = Color.black
}

// MARK: - 玻璃填充 / 描边

/// 对应 `glass.dart` 的 fill / fillStrong / stroke / modal 等。
/// 透明度在这里一次性烘进动态色，调用方不再关心深浅色。
public enum OneGlass {
    /// 通透面：芯片、输入框、瓷片。
    public static let fill = Color.dynamic(light: 0xF9F9FF, 0.55, dark: 0x33353A, 0.22)

    /// 卡片面：可读性优先（.72 浅 / .62 深）。
    public static let fillStrong = Color.dynamic(light: 0xF3F3FA, 0.72, dark: 0x191C20, 0.62)

    /// 发丝描边。浅色是「白 .55 叠在 onSurface .10 上」的预合成结果。
    public static let stroke = Color.dynamic(light: 0xEEEEEE, 0.6, dark: 0xFFFFFF, 0.12)

    /// 模态面 / 对话框。
    public static let modal = Color.dynamic(light: 0xF3F3FA, 0.92, dark: 0x191C20, 0.92)
    public static let dialog = Color.dynamic(light: 0xF3F3FA, 0.88, dark: 0x191C20, 0.88)

    /// 「降低透明度」打开时所有玻璃面退回这块实底。
    public static let solid = OnePalette.containerLow

    /// 门面卡告警 / 忙态底色。
    public static let alertFill = Color.dynamic(light: 0xF9DEDC, 0.38, dark: 0x93000A, 0.38)
    public static let busyFill = Color.dynamic(light: 0xF0F0F4, 0.32, dark: 0x2B2930, 0.32)
}
