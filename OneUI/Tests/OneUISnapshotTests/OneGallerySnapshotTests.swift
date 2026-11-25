#if canImport(UIKit)
import SwiftUI
import UIKit
import XCTest
@testable import OneUI
import OneUICore

@MainActor
final class OneGallerySnapshotTests: XCTestCase {
    func testBundledFontsRegisterAndLoad() {
        OneFont.register()
        _ = MaterialIcon(name: "dashboard_outlined").body

        XCTAssertNotNil(
            UIFont(name: OneFont.postScriptFace, size: 16),
            "Bundled Montserrat-Regular.ttf must register via CoreText"
        )
    }

    func testOneGalleryAndCoreComponentsRenderNonEmptySnapshots() throws {
        OneFont.register()

        let lightData = renderPNG(
            OneGallery().oneTheme().preferredColorScheme(.light),
            size: CGSize(width: 390, height: 844),
            style: .light
        )
        let darkData = renderPNG(
            OneGallery().oneTheme().preferredColorScheme(.dark),
            size: CGSize(width: 390, height: 844),
            style: .dark
        )
        let heroData = renderPNG(
            OneStatusHero(
                tone: .healthy,
                title: "环回兼容已开启",
                subtitle: "Clash 隧道已注入 10.7.0.1",
                detail: "单 VPN 通道同时承载代理与 Swipt"
            )
            .padding(16)
            .oneTheme()
            .preferredColorScheme(.dark),
            size: CGSize(width: 390, height: 300),
            style: .dark
        )

        XCTAssertGreaterThan(lightData.count, 8_000, "Light gallery PNG should be non-trivial")
        XCTAssertGreaterThan(darkData.count, 8_000, "Dark gallery PNG should be non-trivial")
        XCTAssertGreaterThan(heroData.count, 4_000, "StatusHero PNG should be non-trivial")

        if let outDir = ProcessInfo.processInfo.environment["ONETOOLS_SNAPSHOT_DIR"], !outDir.isEmpty {
            let dirURL = URL(fileURLWithPath: outDir, isDirectory: true)
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
            try lightData.write(to: dirURL.appendingPathComponent("one_gallery_light.png"))
            try darkData.write(to: dirURL.appendingPathComponent("one_gallery_dark.png"))
            try heroData.write(to: dirURL.appendingPathComponent("status_hero_healthy_dark.png"))
        }
    }

    private func renderPNG<V: View>(
        _ view: V,
        size: CGSize,
        style: UIUserInterfaceStyle
    ) -> Data {
        let host = UIHostingController(rootView: view)
        host.overrideUserInterfaceStyle = style
        host.view.frame = CGRect(origin: .zero, size: size)
        host.view.backgroundColor = style == .dark
            ? UIColor(red: 0x11 / 255.0, green: 0x13 / 255.0, blue: 0x18 / 255.0, alpha: 1.0)
            : UIColor(red: 0xF8 / 255.0, green: 0xF9 / 255.0, blue: 0xFF / 255.0, alpha: 1.0)

        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.overrideUserInterfaceStyle = style
        window.rootViewController = host
        window.isHidden = false
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))

        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.pngData { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
    }
}
#endif
