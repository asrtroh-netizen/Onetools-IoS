import SwiftUI
import UIKit
import OneUICore

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
        let title = UIFont(name: "Montserrat-Regular", size: 17) ?? .systemFont(ofSize: 17)
        let large = UIFont(name: "Montserrat-Regular", size: 34) ?? .systemFont(ofSize: 34)
        let nav = UINavigationBar.appearance()
        nav.titleTextAttributes = [.font: title]
        nav.largeTitleTextAttributes = [.font: large]
    }()

    static func configureAppearance() { _ = configured }
}

public extension View {
    func oneTheme() -> some View { modifier(OneThemeModifier()) }

    /// Standard page margins plus enough bottom reserve for UltraGlassDock.
    func onePage() -> some View {
        padding(.horizontal, OneMetrics.pageMargin)
            .padding(.vertical, OneMetrics.space16)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: CGFloat(Glass.dockHeight + Glass.dockBottomGap) + OneMetrics.space16)
            }
    }
}

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
