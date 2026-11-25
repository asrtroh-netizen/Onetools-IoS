import Foundation
import XCTest
@testable import OneUICore

final class PartialE3FixtureTests: XCTestCase {
    func testEveryTypographyJsonKeyMatchesSwiftCatalog() throws {
        try assertFixture("typography.json", matches: TypeScale.fixtureTree, root: "typography")
    }

    func testEveryDockEdgesJsonKeyMatchesSwiftCatalog() throws {
        try assertFixture("dock_edges.json", matches: DockEdges.fixtureTree, root: "dock_edges")
    }

    func testEveryRippleJsonKeyMatchesSwiftCatalog() throws {
        try assertFixture("ripple.json", matches: InkRippleModel.fixtureTree, root: "ripple")
    }

    func testEveryIconsJsonKeyMatchesSwiftCatalog() throws {
        XCTAssertEqual(MaterialIconCodepoints.all.count, 121)
        try assertFixture("icons.json", matches: MaterialIconCodepoints.fixtureTree, root: "icons")
    }

    func testAll121IconCodepointsExistInBundledFontCmap() throws {
        let cmap = try loadMaterialIconsCmap()
        XCTAssertEqual(MaterialIconCodepoints.all.count, 121)
        for item in MaterialIconCodepoints.all {
            XCTAssertTrue(
                cmap.contains(item.codePoint),
                "Missing glyph in MaterialIcons-Regular.otf for \(item.name) (0x\(String(item.codePoint, radix: 16)))"
            )
        }
    }

    func testSyntheticBoldMetricsMatchSkiaInterpolation() {
        XCTAssertFalse(SyntheticBoldMetrics.shouldSynthesize(weight: 400))
        XCTAssertFalse(SyntheticBoldMetrics.shouldSynthesize(weight: 500))
        XCTAssertTrue(SyntheticBoldMetrics.shouldSynthesize(weight: 600))
        XCTAssertTrue(SyntheticBoldMetrics.shouldSynthesize(weight: 700))

        XCTAssertEqual(SyntheticBoldMetrics.strokeWidthPercent(for: 9), -(100.0 / 24.0), accuracy: 1e-9)
        XCTAssertEqual(SyntheticBoldMetrics.strokeWidthPercent(for: 36), -(100.0 / 32.0), accuracy: 1e-9)
        XCTAssertEqual(SyntheticBoldMetrics.strokeWidthPercent(for: 6), -(100.0 / 24.0), accuracy: 1e-9)
        XCTAssertEqual(SyntheticBoldMetrics.strokeWidthPercent(for: 48), -(100.0 / 32.0), accuracy: 1e-9)
        let mid16 = SyntheticBoldMetrics.strokeWidthPercent(for: 16)
        XCTAssertLessThan(mid16, -(100.0 / 32.0))
        XCTAssertGreaterThan(mid16, -(100.0 / 24.0))
    }

    func testDockEdgesRuntimeSolverMatchesFixtureSamples() {
        for transition in DockEdges.transitions {
            for sample in transition.samples {
                let solved = DockEdges.edges(
                    from: Double(transition.from),
                    to: Double(transition.to),
                    t: sample.t,
                    count: DockEdges.count
                )
                XCTAssertEqual(solved.left, sample.left, accuracy: 5e-3, "from \(transition.from) to \(transition.to) t=\(sample.t) left")
                XCTAssertEqual(solved.right, sample.right, accuracy: 5e-3, "from \(transition.from) to \(transition.to) t=\(sample.t) right")
            }
        }
    }
}

private func assertFixture(_ name: String, matches swift: OneTokenValue, root: String) throws {
    let url = try fixtureURL(name)
    let data = try Data(contentsOf: url)
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    let fixture = try OneTokenValue.decode(json)
    let fixtureKeys = fixture.keyCount
    var visited = 0
    assertCovered(fixture: fixture, swift: swift, path: root, visited: &visited)
    XCTAssertGreaterThan(fixtureKeys, 0)
    XCTAssertEqual(visited, fixtureKeys)
}


private func assertCovered(
    fixture: OneTokenValue,
    swift: OneTokenValue,
    path: String,
    visited: inout Int
) {
    switch (fixture, swift) {
    case let (.group(expected), .group(actual)):
        for key in expected.keys.sorted() {
            visited += 1
            let next = "\(path).\(key)"
            guard let child = actual[key] else {
                XCTFail("swift missing \(next)")
                continue
            }
            assertCovered(fixture: expected[key]!, swift: child, path: next, visited: &visited)
        }
        for key in actual.keys.sorted() where expected[key] == nil {
            XCTFail("swift extra \(path).\(key)")
        }
    case let (.list(expected), .list(actual)):
        if expected.count != actual.count {
            XCTFail("\(path) count \(actual.count) != \(expected.count)")
            return
        }
        for index in expected.indices {
            visited += 1
            assertCovered(
                fixture: expected[index],
                swift: actual[index],
                path: "\(path)[\(index)]",
                visited: &visited
            )
        }
    case let (.text(expected), .text(actual)):
        XCTAssertEqual(actual, expected, path)
    case let (.number(expected), .number(actual)):
        XCTAssertEqual(actual, expected, accuracy: 1e-9, path)
    default:
        XCTFail("type mismatch at \(path)")
    }
}

private func fixtureURL(_ name: String) throws -> URL {
    var url = URL(fileURLWithPath: #filePath)
    let root = URL(fileURLWithPath: "/")
    while url.standardizedFileURL != root {
        if url.lastPathComponent == "OneUI" {
            return url
                .deletingLastPathComponent()
                .appendingPathComponent("_golden")
                .appendingPathComponent("fixtures")
                .appendingPathComponent(name)
        }
        url.deleteLastPathComponent()
    }
    throw FixtureFileError("OneUI root not found from \(#filePath)")
}

private struct FixtureFileError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

private func loadMaterialIconsCmap() throws -> Set<UInt32> {
    var url = URL(fileURLWithPath: #filePath)
    let root = URL(fileURLWithPath: "/")
    while url.standardizedFileURL != root {
        if url.lastPathComponent == "OneUI" {
            break
        }
        url.deleteLastPathComponent()
    }
    let fontURL = url
        .appendingPathComponent("Sources")
        .appendingPathComponent("OneUI")
        .appendingPathComponent("Resources")
        .appendingPathComponent("Icons")
        .appendingPathComponent("MaterialIcons-Regular.otf")
    let data = try Data(contentsOf: fontURL)
    let numTables = readUInt16BE(data, at: 4)
    var cmapOffset: Int?
    for index in 0..<Int(numTables) {
        let entry = 12 + index * 16
        let tag = String(decoding: data[entry..<(entry + 4)], as: UTF8.self)
        if tag == "cmap" {
            cmapOffset = Int(readUInt32BE(data, at: entry + 8))
            break
        }
    }
    guard let cmapStart = cmapOffset else {
        throw FixtureFileError("cmap table not found in MaterialIcons-Regular.otf")
    }
    let numSubtables = Int(readUInt16BE(data, at: cmapStart + 2))
    var codepoints = Set<UInt32>()
    for sub in 0..<numSubtables {
        let subOffset = cmapStart + Int(readUInt32BE(data, at: cmapStart + 4 + sub * 8 + 4))
        let format = readUInt16BE(data, at: subOffset)
        if format == 12 {
            let numGroups = Int(readUInt32BE(data, at: subOffset + 12))
            for group in 0..<numGroups {
                let groupPos = subOffset + 16 + group * 12
                let startChar = readUInt32BE(data, at: groupPos)
                let endChar = readUInt32BE(data, at: groupPos + 4)
                for cp in startChar...endChar {
                    codepoints.insert(cp)
                }
            }
        }
    }
    return codepoints
}

private func readUInt16BE(_ data: Data, at offset: Int) -> UInt16 {
    (UInt16(data[offset]) << 8) | UInt16(data[offset + 1])
}

private func readUInt32BE(_ data: Data, at offset: Int) -> UInt32 {
    (UInt32(data[offset]) << 24)
        | (UInt32(data[offset + 1]) << 16)
        | (UInt32(data[offset + 2]) << 8)
        | UInt32(data[offset + 3])
}
