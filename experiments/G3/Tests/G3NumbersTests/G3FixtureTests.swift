// 未在 Mac 上运行
// 文字、模糊、投影、水波纹触摸仍不选定实现。期望值从夹具读，不把草稿提升成界面实现。
import Foundation
import G3Numbers
import XCTest

final class G3FixtureTests: XCTestCase {
    func testBlurNumbersMatchGlassAndLayoutFixtures() throws {
        let tokens = try loadFixture("tokens.json")
        let glass = try group(try child(tokens, "glass", "tokens"), "tokens.glass")
        let catalog: [String: Double] = [
            "blurPanel": BlurNumbers.blurPanelSigma,
            "blurBar": BlurNumbers.blurBarSigma,
            "blurDock": BlurNumbers.blurDockSigma,
            "blurLiquid": BlurNumbers.blurLiquidSigma,
            "liquidRefraction": BlurNumbers.liquidRefraction,
        ]
        var visited = 0
        for key in glass.keys.sorted() where key.hasPrefix("blur") || key == "liquidRefraction" {
            guard let actual = catalog[key] else {
                XCTFail("swift missing tokens.glass.\(key)")
                continue
            }
            let expected = try number(try child(glass, key, "tokens.glass"), "tokens.glass.\(key)")
            XCTAssertEqual(actual, expected, accuracy: 1e-9, "tokens.glass.\(key)")
            visited += 1
        }
        for key in catalog.keys where glass[key] == nil {
            XCTFail("fixture missing tokens.glass.\(key)")
        }
        XCTAssertEqual(visited, catalog.count)

        let layout = try loadFixture("layout.json")
        let dockBlur = try number(
            try child(try group(try child(layout, "dock", "layout"), "layout.dock"), "blur", "layout.dock"),
            "layout.dock.blur"
        )
        XCTAssertEqual(BlurNumbers.blurDockSigma, dockBlur, accuracy: 1e-9, "layout.dock.blur")

        try assertStoredScene(
            "dock_static_0",
            lightDock: BlurNumbers.dockStatic0LightDock,
            lightIndicator: BlurNumbers.dockStatic0LightIndicator,
            darkDock: BlurNumbers.dockStatic0DarkDock,
            darkIndicator: BlurNumbers.dockStatic0DarkIndicator,
            layout: layout
        )
    }

    func testTextNumbersMatchTypographyFixture() throws {
        let root = try group(try loadFixture("typography.json"), "typography")
        for key in root.keys where !["sample", "light", "dark"].contains(key) {
            XCTFail("swift missing typography.\(key)")
        }
        guard case let .text(sample) = try child(root, "sample", "typography") else {
            XCTFail("typography.sample is not text")
            return
        }
        XCTAssertEqual(TextNumbers.sample, sample, "typography.sample")
        try assertTheme(try child(root, "light", "typography"), catalog: lightRoles(), path: "typography.light")
        try assertTheme(try child(root, "dark", "typography"), catalog: darkRoles(), path: "typography.dark")
    }

    func testShadowNumbersMatchResolvedFixture() throws {
        let tokens = try loadFixture("tokens.json")
        let resolved = try group(try child(tokens, "resolved", "tokens"), "tokens.resolved")
        try assertThemeShadows(
            try child(resolved, "light", "tokens.resolved"),
            normal: [ShadowNumbers.lightNormal0, ShadowNumbers.lightNormal1],
            strong: [ShadowNumbers.lightStrong0, ShadowNumbers.lightStrong1],
            path: "tokens.resolved.light.shadow"
        )
        try assertThemeShadows(
            try child(resolved, "dark", "tokens.resolved"),
            normal: [ShadowNumbers.darkNormal0],
            strong: [ShadowNumbers.darkStrong0],
            path: "tokens.resolved.dark.shadow"
        )
    }

    func testRippleNumbersMatchRippleFixture() throws {
        let root = try group(try loadFixture("ripple.json"), "ripple")
        let known = ["source", "constants", "referenceBox", "targetRadius", "splashAlpha", "hold", "confirm"]
        for key in root.keys where !known.contains(key) {
            XCTFail("swift missing ripple.\(key)")
        }
        guard case let .text(source) = try child(root, "source", "ripple") else {
            XCTFail("ripple.source is not text")
            return
        }
        XCTAssertFalse(source.isEmpty, "ripple.source")

        try assertConstants(try child(root, "constants", "ripple"))
        try assertReferenceBox(try child(root, "referenceBox", "ripple"))
        let target = try number(try child(root, "targetRadius", "ripple"), "ripple.targetRadius")
        XCTAssertEqual(RippleNumbers.targetRadius, target, accuracy: 1e-9, "ripple.targetRadius")
        try assertSplash(try child(root, "splashAlpha", "ripple"))
        try assertSamples(
            try child(root, "hold", "ripple"),
            light: RippleNumbers.holdLight,
            dark: RippleNumbers.holdDark,
            path: "ripple.hold"
        )
        try assertSamples(
            try child(root, "confirm", "ripple"),
            light: RippleNumbers.confirmLight,
            dark: RippleNumbers.confirmDark,
            path: "ripple.confirm"
        )

        try assertStoredScene(
            "dock_pressed",
            lightDock: RippleNumbers.dockPressedLightDock,
            lightIndicator: RippleNumbers.dockPressedLightIndicator,
            darkDock: RippleNumbers.dockPressedDarkDock,
            darkIndicator: RippleNumbers.dockPressedDarkIndicator,
            layout: try loadFixture("layout.json")
        )
    }
}

private func assertStoredScene(
    _ name: String,
    lightDock: SceneRect,
    lightIndicator: SceneRect,
    darkDock: SceneRect,
    darkIndicator: SceneRect,
    layout: FixtureNode
) throws {
    let scene = try child(try group(try child(layout, "scenes", "layout"), "layout.scenes"), name, "layout.scenes")
    var visited = 0
    try assertRect(lightDock, try child(try child(scene, "light", "layout.scenes.\(name)"), "dock", "layout.scenes.\(name).light"), path: "layout.scenes.\(name).light.dock", visited: &visited)
    try assertRect(lightIndicator, try child(try child(scene, "light", "layout.scenes.\(name)"), "indicator", "layout.scenes.\(name).light"), path: "layout.scenes.\(name).light.indicator", visited: &visited)
    try assertRect(darkDock, try child(try child(scene, "dark", "layout.scenes.\(name)"), "dock", "layout.scenes.\(name).dark"), path: "layout.scenes.\(name).dark.dock", visited: &visited)
    try assertRect(darkIndicator, try child(try child(scene, "dark", "layout.scenes.\(name)"), "indicator", "layout.scenes.\(name).dark"), path: "layout.scenes.\(name).dark.indicator", visited: &visited)
    XCTAssertEqual(visited, 16, "layout.scenes.\(name)")
}

private func assertRect(_ actual: SceneRect, _ node: FixtureNode, path: String, visited: inout Int) throws {
    let fields = try group(node, path)
    let pairs = [
        ("left", actual.left),
        ("top", actual.top),
        ("width", actual.width),
        ("height", actual.height),
    ]
    for (key, value) in pairs {
        let expected = try number(try child(fields, key, path), "\(path).\(key)")
        XCTAssertEqual(value, expected, accuracy: 1e-9, "\(path).\(key)")
        visited += 1
    }
    for key in fields.keys where !["left", "top", "width", "height"].contains(key) {
        XCTFail("swift missing \(path).\(key)")
    }
}

private func assertTheme(_ node: FixtureNode, catalog: [String: TextRole], path: String) throws {
    let roles = try group(node, path)
    for key in roles.keys.sorted() {
        guard let role = catalog[key] else {
            XCTFail("swift missing \(path).\(key)")
            continue
        }
        try assertRole(role, try child(roles, key, path), path: "\(path).\(key)")
    }
    for key in catalog.keys where roles[key] == nil {
        XCTFail("swift extra \(path).\(key)")
    }
}

private func assertRole(_ role: TextRole, _ node: FixtureNode, path: String) throws {
    let fields = try group(node, path)
    let numbers: [(String, Double)] = [
        ("fontSize", role.fontSize),
        ("fontWeight", Double(role.fontWeight)),
        ("height", role.height),
        ("letterSpacing", role.letterSpacing),
        ("measuredHeight", role.measuredHeight),
    ]
    for (key, value) in numbers {
        let expected = try number(try child(fields, key, path), "\(path).\(key)")
        XCTAssertEqual(value, expected, accuracy: 1e-9, "\(path).\(key)")
    }
    guard case let .text(family) = try child(fields, "fontFamily", path) else {
        XCTFail("\(path).fontFamily is not text")
        return
    }
    XCTAssertEqual(role.fontFamily, family, "\(path).fontFamily")
    let known = ["fontSize", "fontWeight", "height", "letterSpacing", "measuredHeight", "fontFamily"]
    for key in fields.keys where !known.contains(key) {
        XCTFail("swift missing \(path).\(key)")
    }
}

private func assertThemeShadows(
    _ theme: FixtureNode,
    normal: [ShadowLayer],
    strong: [ShadowLayer],
    path: String
) throws {
    let shadow = try group(try child(try group(theme, path), "shadow", path), path)
    for key in shadow.keys where !["normal", "strong"].contains(key) {
        XCTFail("swift missing \(path).\(key)")
    }
    try assertShadowList(normal, try child(shadow, "normal", path), path: "\(path).normal")
    try assertShadowList(strong, try child(shadow, "strong", path), path: "\(path).strong")
}

private func assertShadowList(_ actual: [ShadowLayer], _ node: FixtureNode, path: String) throws {
    guard case let .list(items) = node else {
        XCTFail("\(path) is not a list")
        return
    }
    if actual.count != items.count {
        XCTFail("\(path) count \(actual.count) != \(items.count)")
        return
    }
    for index in items.indices {
        try assertShadow(actual[index], items[index], path: "\(path)[\(index)]")
    }
}

private func assertShadow(_ actual: ShadowLayer, _ node: FixtureNode, path: String) throws {
    let fields = try group(node, path)
    let numbers: [(String, Double)] = [
        ("blurRadius", actual.blurRadius),
        ("offsetX", actual.offsetX),
        ("offsetY", actual.offsetY),
        ("spreadRadius", actual.spreadRadius),
    ]
    for (key, value) in numbers {
        let expected = try number(try child(fields, key, path), "\(path).\(key)")
        XCTAssertEqual(value, expected, accuracy: 1e-9, "\(path).\(key)")
    }
    guard case let .text(argb) = try child(fields, "argb", path),
          case let .text(alpha) = try child(fields, "alpha", path)
    else {
        XCTFail("\(path) color is not text")
        return
    }
    XCTAssertEqual(actual.argb, argb, "\(path).argb")
    XCTAssertEqual(actual.alpha, alpha, "\(path).alpha")
    let known = ["argb", "alpha", "blurRadius", "offsetX", "offsetY", "spreadRadius"]
    for key in fields.keys where !known.contains(key) {
        XCTFail("swift missing \(path).\(key)")
    }
}

private func assertConstants(_ node: FixtureNode) throws {
    guard case let .list(items) = node else {
        XCTFail("ripple.constants is not a list")
        return
    }
    let catalog: [String: FixtureNode] = [
        "_kUnconfirmedRippleDuration": .number(Double(RippleNumbers.unconfirmedRippleDurationMs)),
        "_kFadeInDuration": .number(Double(RippleNumbers.fadeInDurationMs)),
        "_kRadiusDuration": .number(Double(RippleNumbers.radiusDurationMs)),
        "_kFadeOutDuration": .number(Double(RippleNumbers.fadeOutDurationMs)),
        "_kCancelDuration": .number(Double(RippleNumbers.cancelDurationMs)),
        "_kFadeOutIntervalStart": .number(RippleNumbers.fadeOutIntervalStart),
        "radiusBeginFactor": .number(RippleNumbers.radiusBeginFactor),
        "radiusEndExtra": .number(RippleNumbers.radiusEndExtra),
        "easeCurve": .text(RippleNumbers.easeCurve),
    ]
    var seen: Set<String> = []
    for (index, item) in items.enumerated() {
        let fields = try group(item, "ripple.constants[\(index)]")
        guard case let .text(name) = try child(fields, "name", "ripple.constants[\(index)]") else {
            XCTFail("ripple.constants[\(index)].name is not text")
            continue
        }
        seen.insert(name)
        guard let actual = catalog[name] else {
            XCTFail("swift missing ripple.constants.\(name)")
            continue
        }
        if let ms = fields["ms"] {
            assertSame(actual, ms, path: "ripple.constants.\(name)")
        } else if let value = fields["value"] {
            assertSame(actual, value, path: "ripple.constants.\(name)")
        } else {
            XCTFail("ripple.constants.\(name) has no ms or value")
        }
        if let line = fields["line"] {
            _ = try number(line, "ripple.constants.\(name).line")
        }
        let known = ["name", "line", "ms", "value"]
        for key in fields.keys where !known.contains(key) {
            XCTFail("swift missing ripple.constants.\(name).\(key)")
        }
    }
    for name in catalog.keys where !seen.contains(name) {
        XCTFail("fixture missing ripple.constants.\(name)")
    }
}

private func assertReferenceBox(_ node: FixtureNode) throws {
    let fields = try group(node, "ripple.referenceBox")
    let width = try number(try child(fields, "width", "ripple.referenceBox"), "ripple.referenceBox.width")
    let height = try number(try child(fields, "height", "ripple.referenceBox"), "ripple.referenceBox.height")
    XCTAssertEqual(RippleNumbers.referenceBoxWidth, width, accuracy: 1e-9, "ripple.referenceBox.width")
    XCTAssertEqual(RippleNumbers.referenceBoxHeight, height, accuracy: 1e-9, "ripple.referenceBox.height")
    if let source = fields["source"] {
        guard case let .text(text) = source else {
            XCTFail("ripple.referenceBox.source is not text")
            return
        }
        XCTAssertFalse(text.isEmpty)
    }
    let known = ["width", "height", "source", "line", "file"]
    for key in fields.keys where !known.contains(key) {
        XCTFail("swift missing ripple.referenceBox.\(key)")
    }
}

private func assertSplash(_ node: FixtureNode) throws {
    let fields = try group(node, "ripple.splashAlpha")
    let light = try number(try child(fields, "light", "ripple.splashAlpha"), "ripple.splashAlpha.light")
    let dark = try number(try child(fields, "dark", "ripple.splashAlpha"), "ripple.splashAlpha.dark")
    XCTAssertEqual(Double(RippleNumbers.splashAlphaLight), light, accuracy: 1e-9, "ripple.splashAlpha.light")
    XCTAssertEqual(Double(RippleNumbers.splashAlphaDark), dark, accuracy: 1e-9, "ripple.splashAlpha.dark")
    if let line = fields["line"] {
        _ = try number(line, "ripple.splashAlpha.line")
    }
    if let file = fields["file"] {
        guard case let .text(text) = file else {
            XCTFail("ripple.splashAlpha.file is not text")
            return
        }
        XCTAssertFalse(text.isEmpty)
    }
    let known = ["light", "dark", "line", "file"]
    for key in fields.keys where !known.contains(key) {
        XCTFail("swift missing ripple.splashAlpha.\(key)")
    }
}

private func assertSamples(
    _ node: FixtureNode,
    light: [RippleSample],
    dark: [RippleSample],
    path: String
) throws {
    let themes = try group(node, path)
    for key in themes.keys where !["light", "dark"].contains(key) {
        XCTFail("swift missing \(path).\(key)")
    }
    try assertSampleList(light, try child(themes, "light", path), path: "\(path).light")
    try assertSampleList(dark, try child(themes, "dark", path), path: "\(path).dark")
}

private func assertSampleList(_ actual: [RippleSample], _ node: FixtureNode, path: String) throws {
    guard case let .list(items) = node else {
        XCTFail("\(path) is not a list")
        return
    }
    if actual.count != items.count {
        XCTFail("\(path) count \(actual.count) != \(items.count)")
        return
    }
    for index in items.indices {
        try assertSample(actual[index], items[index], path: "\(path)[\(index)]")
    }
}

private func assertSample(_ actual: RippleSample, _ node: FixtureNode, path: String) throws {
    let fields = try group(node, path)
    let numbers: [(String, Double)] = [
        ("ms", Double(actual.ms)),
        ("radius", actual.radius),
        ("alpha", Double(actual.alpha)),
        ("opacity", actual.opacity),
    ]
    for (key, value) in numbers {
        let expected = try number(try child(fields, key, path), "\(path).\(key)")
        XCTAssertEqual(value, expected, accuracy: 1e-9, "\(path).\(key)")
    }
    for key in fields.keys where !["ms", "radius", "alpha", "opacity"].contains(key) {
        XCTFail("swift missing \(path).\(key)")
    }
}

private func lightRoles() -> [String: TextRole] {
    [
        "displayLarge": TextNumbers.lightDisplayLarge,
        "displayMedium": TextNumbers.lightDisplayMedium,
        "displaySmall": TextNumbers.lightDisplaySmall,
        "headlineLarge": TextNumbers.lightHeadlineLarge,
        "headlineMedium": TextNumbers.lightHeadlineMedium,
        "headlineSmall": TextNumbers.lightHeadlineSmall,
        "titleLarge": TextNumbers.lightTitleLarge,
        "titleMedium": TextNumbers.lightTitleMedium,
        "titleSmall": TextNumbers.lightTitleSmall,
        "bodyLarge": TextNumbers.lightBodyLarge,
        "bodyMedium": TextNumbers.lightBodyMedium,
        "bodySmall": TextNumbers.lightBodySmall,
        "labelLarge": TextNumbers.lightLabelLarge,
        "labelMedium": TextNumbers.lightLabelMedium,
        "labelSmall": TextNumbers.lightLabelSmall,
    ]
}

private func darkRoles() -> [String: TextRole] {
    [
        "displayLarge": TextNumbers.darkDisplayLarge,
        "displayMedium": TextNumbers.darkDisplayMedium,
        "displaySmall": TextNumbers.darkDisplaySmall,
        "headlineLarge": TextNumbers.darkHeadlineLarge,
        "headlineMedium": TextNumbers.darkHeadlineMedium,
        "headlineSmall": TextNumbers.darkHeadlineSmall,
        "titleLarge": TextNumbers.darkTitleLarge,
        "titleMedium": TextNumbers.darkTitleMedium,
        "titleSmall": TextNumbers.darkTitleSmall,
        "bodyLarge": TextNumbers.darkBodyLarge,
        "bodyMedium": TextNumbers.darkBodyMedium,
        "bodySmall": TextNumbers.darkBodySmall,
        "labelLarge": TextNumbers.darkLabelLarge,
        "labelMedium": TextNumbers.darkLabelMedium,
        "labelSmall": TextNumbers.darkLabelSmall,
    ]
}

private func assertSame(_ actual: FixtureNode, _ expected: FixtureNode, path: String) {
    switch (actual, expected) {
    case let (.number(actual), .number(expected)):
        XCTAssertEqual(actual, expected, accuracy: 1e-9, path)
    case let (.text(actual), .text(expected)):
        XCTAssertEqual(actual, expected, path)
    default:
        XCTFail("type mismatch at \(path)")
    }
}

private enum FixtureNode {
    case text(String)
    case number(Double)
    case group([String: FixtureNode])
    case list([FixtureNode])
}

private func child(_ node: FixtureNode, _ key: String, _ path: String) throws -> FixtureNode {
    let fields = try group(node, path)
    guard let value = fields[key] else {
        throw FixtureReadError("fixture missing \(path).\(key)")
    }
    return value
}

private func child(_ fields: [String: FixtureNode], _ key: String, _ path: String) throws -> FixtureNode {
    guard let value = fields[key] else {
        throw FixtureReadError("fixture missing \(path).\(key)")
    }
    return value
}

private func group(_ node: FixtureNode, _ path: String) throws -> [String: FixtureNode] {
    guard case let .group(fields) = node else {
        throw FixtureReadError("\(path) is not a group")
    }
    return fields
}

private func number(_ node: FixtureNode, _ path: String) throws -> Double {
    guard case let .number(value) = node else {
        throw FixtureReadError("\(path) is not a number")
    }
    return value
}

private func loadFixture(_ name: String) throws -> FixtureNode {
    let data = try Data(contentsOf: try fixtureURL(name))
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    return try FixtureNode.decode(json)
}

private func fixtureURL(_ name: String) throws -> URL {
    var url = URL(fileURLWithPath: #filePath)
    let root = URL(fileURLWithPath: "/")
    while url.standardizedFileURL != root {
        let candidate = url
            .appendingPathComponent("_golden")
            .appendingPathComponent("fixtures")
            .appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: candidate.path) {
            return candidate
        }
        url.deleteLastPathComponent()
    }
    throw FixtureReadError("fixture \(name) not found from \(#filePath)")
}

private struct FixtureReadError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

extension FixtureNode {
    static func decode(_ json: Any) throws -> FixtureNode {
        if let text = json as? String {
            return .text(text)
        }
        if let dictionary = json as? [String: Any] {
            var group: [String: FixtureNode] = [:]
            for (key, value) in dictionary {
                group[key] = try decode(value)
            }
            return .group(group)
        }
        if let dictionary = json as? NSDictionary {
            var group: [String: FixtureNode] = [:]
            for (key, value) in dictionary {
                guard let key = key as? String else {
                    throw FixtureReadError("fixture key \(key) is not a string")
                }
                group[key] = try decode(value)
            }
            return .group(group)
        }
        if let list = json as? [Any] {
            return .list(try list.map { try decode($0) })
        }
        if let list = json as? NSArray {
            return .list(try list.map { try decode($0) })
        }
        if let number = json as? Int {
            return .number(Double(number))
        }
        if let number = json as? Double {
            return .number(number)
        }
        if let number = json as? NSNumber {
            return .number(number.doubleValue)
        }
        throw FixtureReadError("unsupported fixture node \(type(of: json))")
    }
}
