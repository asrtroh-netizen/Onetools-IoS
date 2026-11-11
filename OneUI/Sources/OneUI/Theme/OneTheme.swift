import SwiftUI
import UIKit

/// 根视图挂一次：注册字体、铺渐变底、统一强调色与导航栏 / 标签栏字体。
///
/// 底栏不再自绘：Flutter 版 `ultra_glass_dock.dart` 用 425 行手搓液态指示条，
/// 现在直接用系统 TabView —— iOS 26+ 自带 Liquid Glass 底栏，更早系统用磨砂材质。
public struct OneThemeModifier: ViewModifier {
    public init() {
        OneFont.register()
        Self.configureAppearance()
    }

    public func body(content: Content) -> some View {
        content
            .tint(OnePalette.onSurface)
            .font(OneText.bodyMedium())
            .foregroundStyle(OnePalette.onSurface)
            .background(OneBackdrop())
    }

    private static let configured: Void = {
        let title = UIFont(name: "Montserrat-SemiBold", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold)
        let large = UIFont(name: "Montserrat-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
        let metrics = UIFontMetrics(forTextStyle: .headline)
        let nav = UINavigationBar.appearance()
        nav.titleTextAttributes = [.font: metrics.scaledFont(for: title)]
        nav.largeTitleTextAttributes = [.font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: large)]

        if #unavailable(iOS 26.0) {
            // iOS 26 以前：底栏用磨砂，不画顶部分割线，和玻璃卡片一致。
            let tab = UITabBarAppearance()
            tab.configureWithDefaultBackground()
            tab.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
            tab.shadowColor = .clear
            let label = UIFont(name: "Montserrat-Medium", size: 10) ?? .systemFont(ofSize: 10, weight: .medium)
            for item in [tab.stackedLayoutAppearance, tab.inlineLayoutAppearance, tab.compactInlineLayoutAppearance] {
                item.normal.titleTextAttributes = [.font: label]
                item.selected.titleTextAttributes = [.font: label]
            }
            UITabBar.appearance().standardAppearance = tab
            UITabBar.appearance().scrollEdgeAppearance = tab
        }
    }()

    static func configureAppearance() { _ = configured }
}

extension View {
    /// `ContentView().oneTheme()`
    public func oneTheme() -> some View { modifier(OneThemeModifier()) }

    /// 标准页面滚动容器的内边距：左右 16，卡片间距 14。
    public func onePage() -> some View {
        padding(.horizontal, OneMetrics.pageMargin)
            .padding(.vertical, OneMetrics.space16)
    }
}

/// 标准页面：渐变底 + 滚动 + 统一外边距 + 卡片间距。
public struct OnePage<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OneMetrics.cardGap) { content }
                .onePage()
        }
        .background(OneBackdrop())
    }
}
