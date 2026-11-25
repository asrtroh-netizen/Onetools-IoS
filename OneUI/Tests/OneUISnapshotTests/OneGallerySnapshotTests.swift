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

    @available(iOS 16.0, *)
    func testOneGalleryAndCoreComponentsRenderNonEmptySnapshots() throws {
        OneFont.register()
        MaterialIcon.register()
        OneBackdropBlurView.pureSwiftUISnapshotMode = true
        OneStyledText.pureSwiftUISnapshotMode = true
        defer {
            OneBackdropBlurView.pureSwiftUISnapshotMode = false
            OneStyledText.pureSwiftUISnapshotMode = false
        }

        let lightShot = try renderImage(
            OneSnapshotShowcase()
                .oneTheme()
                .environment(\.colorScheme, .light),
            size: CGSize(width: 390, height: 844),
            style: .light
        )
        let darkShot = try renderImage(
            OneSnapshotShowcase()
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

    @available(iOS 16.0, *)
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

        let renderer = ImageRenderer(content: framed)
        renderer.scale = 3.0
        renderer.isOpaque = true
        guard let uiImage = renderer.uiImage, let png = uiImage.pngData() else {
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

/// Non-scrolling VStack showcase of OneUI components so SwiftUI's offscreen
/// `ImageRenderer` rasterizes the entire gallery cleanly without ScrollView clipping.
private struct OneSnapshotShowcase: View {
    @State private var dockTab = 0
    @State private var mode = "rule"

    private let dockItems: [UltraGlassDock.Item] = [
        .init(id: "overview", icon: "dashboard_outlined", label: "总览"),
        .init(id: "proxy", icon: "router_outlined", label: "代理"),
        .init(id: "adblock", icon: "shield_outlined", label: "去广告"),
        .init(id: "settings", icon: "settings_outlined", label: "设置"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: OneMetrics.cardGap) {
                PageHead("OneUI", desc: "One 家族玻璃设计系统") {
                    Nameplate.ready("在线", detail: "42 ms")
                }
                StatusHero(
                    state: .ready,
                    eyebrow: "Clash",
                    title: "代理已连接",
                    pill: "就绪",
                    stageLabels: ["关闭", "处理中", "就绪"],
                    subtitle: "已注入 10.7.0.1 环回地址",
                    detail: "单 VPN 通道同时承载代理与 Swipt 自动跳过"
                )
                OneSection("状态组件", systemImage: "check_circle_rounded", tone: .green) {
                    VStack(alignment: .leading, spacing: OneMetrics.space12) {
                        MetricGrid {
                            MetricCard("上传", value: "1.2 MB/s", sub: "累计 3.4 GB", systemImage: "upload_file_outlined", tone: .green)
                            MetricCard("下载", value: "8.6 MB/s", sub: "累计 21 GB", systemImage: "download_outlined", tone: .teal)
                        }
                        StageRow([("DNS", .ready), ("TLS", .ready), ("规则", .active), ("MITM", .pending), ("脚本", .failed)])
                        ThinProgress(62, tone: .green)
                        ChoiceChips([("rule", "规则"), ("global", "全局"), ("direct", "直连")], selection: $mode)
                    }
                }
                OneSection("瓷片与标签", systemImage: "dashboard_outlined") {
                    SoftLabelGrid([
                        SoftLabel("内核", value: "mihomo 1.19.33"),
                        SoftLabel("环回地址", value: "10.7.0.1", mono: true),
                    ])
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, OneMetrics.pageMargin)
            .padding(.top, OneMetrics.space16)
            UltraGlassDock(items: dockItems, selectedIndex: $dockTab)
        }
    }
}
#endif
