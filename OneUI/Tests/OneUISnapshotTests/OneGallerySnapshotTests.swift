#if canImport(UIKit)
import CoreGraphics
import SwiftUI
import UIKit
import XCTest
@testable import OneUI
import OneUICore

@MainActor
final class OneGallerySnapshotTests: XCTestCase {
    func testBundledFontsRegisterAndLoad() {
        OneFont.register()
        MaterialIcon.register()

        XCTAssertNotNil(
            UIFont(name: OneFont.postScriptFace, size: 16),
            "Bundled Montserrat-Regular.ttf must register via CoreText"
        )
        XCTAssertNotNil(
            UIFont(name: MaterialIcon.postScriptFace, size: 24),
            "Bundled MaterialIcons-Regular.otf must register via CoreText"
        )
    }

    func testOneGalleryAndCoreComponentsRenderNonEmptySnapshots() throws {
        OneFont.register()
        MaterialIcon.register()

        let lightShot = try renderImage(
            OneGallery()
                .oneTheme()
                .environment(\.colorScheme, .light),
            size: CGSize(width: 390, height: 844),
            style: .light
        )
        let darkShot = try renderImage(
            OneGallery()
                .oneTheme()
                .environment(\.colorScheme, .dark),
            size: CGSize(width: 390, height: 844),
            style: .dark
        )
        let heroShot = try renderImage(
            OneStatusHero(
                tone: .healthy,
                title: "环回兼容已开启",
                subtitle: "Clash 隧道已注入 10.7.0.1",
                detail: "单 VPN 通道同时承载代理与 Swipt"
            )
            .padding(16)
            .oneTheme()
            .environment(\.colorScheme, .dark),
            size: CGSize(width: 390, height: 300),
            style: .dark
        )

        XCTAssertGreaterThan(distinctSampledColors(in: lightShot.image), 6, "Light gallery must render multi-color UI")
        XCTAssertGreaterThan(distinctSampledColors(in: darkShot.image), 6, "Dark gallery must render multi-color UI")
        XCTAssertGreaterThan(distinctSampledColors(in: heroShot.image), 4, "StatusHero must render multi-color UI")

        if let outDir = ProcessInfo.processInfo.environment["ONETOOLS_SNAPSHOT_DIR"], !outDir.isEmpty {
            let dirURL = URL(fileURLWithPath: outDir, isDirectory: true)
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
            try lightShot.png.write(to: dirURL.appendingPathComponent("one_gallery_light.png"))
            try darkShot.png.write(to: dirURL.appendingPathComponent("one_gallery_dark.png"))
            try heroShot.png.write(to: dirURL.appendingPathComponent("status_hero_healthy_dark.png"))
        }
    }

    private func renderImage<V: View>(
        _ view: V,
        size: CGSize,
        style: UIUserInterfaceStyle
    ) throws -> (image: UIImage, png: Data) {
        let bg = style == .dark
            ? Color(red: 0x11 / 255.0, green: 0x13 / 255.0, blue: 0x18 / 255.0)
            : Color(red: 0xF8 / 255.0, green: 0xF9 / 255.0, blue: 0xFF / 255.0)
        let framed = view
            .frame(width: size.width, height: size.height)
            .background(bg)

        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: framed)
            renderer.scale = 3.0
            renderer.isOpaque = true
            if let uiImage = renderer.uiImage, let png = uiImage.pngData(), distinctSampledColors(in: uiImage) > 4 {
                return (uiImage, png)
            }
        }

        let host = UIHostingController(rootView: framed)
        host.overrideUserInterfaceStyle = style
        host.view.bounds = CGRect(origin: .zero, size: size)
        host.view.frame = CGRect(origin: .zero, size: size)
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0
        format.opaque = true
        let fallbackRenderer = UIGraphicsImageRenderer(size: size, format: format)
        let uiImage = fallbackRenderer.image { context in
            host.view.layer.render(in: context.cgContext)
        }
        guard let png = uiImage.pngData() else {
            throw NSError(domain: "OneUISnapshotTests", code: 1)
        }
        return (uiImage, png)
    }

    private func distinctSampledColors(in image: UIImage) -> Int {
        guard let cg = image.cgImage,
              let data = cg.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else {
            return 0
        }
        let length = CFDataGetLength(data)
        let bpp = max(cg.bitsPerPixel / 8, 4)
        let strideStep = max((length / bpp) / 500, 1) * bpp
        var colors = Set<UInt32>()
        var offset = 0
        while offset + 2 < length {
            let packed = (UInt32(ptr[offset]) << 16) | (UInt32(ptr[offset + 1]) << 8) | UInt32(ptr[offset + 2])
            colors.insert(packed)
            offset += strideStep
        }
        return colors.count
    }
}
#endif
