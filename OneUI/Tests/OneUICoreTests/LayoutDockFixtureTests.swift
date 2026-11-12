import Foundation
import XCTest
@testable import OneUICore

final class LayoutDockFixtureTests: XCTestCase {
    func testEveryLayoutDockKeyMatchesSwiftCatalog() throws {
        let root = try layoutRoot()
        guard case let .group(top) = root,
              let dockValue = top["dock"],
              let sourcesValue = top["sources"],
              case let .group(sources) = sourcesValue
        else {
            XCTFail("layout.json missing dock or sources")
            return
        }

        let fixtureKeys = dockValue.keyCount
        var visited = 0
        assertCovered(
            fixture: dockValue,
            swift: LayoutDock.fixtureTree,
            path: "dock",
            visited: &visited
        )
        XCTAssertGreaterThan(fixtureKeys, 0)
        XCTAssertEqual(visited, fixtureKeys)

        guard case let .group(dock) = dockValue,
              case let .group(catalog) = LayoutDock.fixtureTree
        else {
            XCTFail("dock is not a group")
            return
        }

        var glassChecks = 0
        for key in dock.keys.sorted() {
            guard case let .text(source) = sources[key] else { continue }
            guard source.hasPrefix("Glass.") else { continue }
            let metric = String(source.dropFirst("Glass.".count))
            guard let glassValue = Glass.metrics[metric] else {
                XCTFail("Glass.metrics missing \(metric) for dock.\(key)")
                continue
            }
            guard case let .number(fixtureNumber) = dock[key] else {
                XCTFail("dock.\(key) is not a number")
                continue
            }
            guard case let .number(catalogNumber) = catalog[key] else {
                XCTFail("swift missing dock.\(key)")
                continue
            }
            XCTAssertEqual(glassValue, fixtureNumber, accuracy: 1e-9, "Glass vs fixture dock.\(key)")
            XCTAssertEqual(catalogNumber, glassValue, accuracy: 1e-9, "catalog vs Glass dock.\(key)")
            glassChecks += 1
        }
        XCTAssertGreaterThan(glassChecks, 0)
        XCTAssertNil(Glass.metrics["slideMs"])
    }

    func testSceneRectsRemainFixtureRecords() throws {
        let root = try layoutRoot()
        guard case let .group(top) = root, let scenesValue = top["scenes"],
              case let .group(scenes) = scenesValue
        else {
            XCTFail("layout.json missing scenes")
            return
        }
        XCTAssertGreaterThan(scenes.count, 0)
        var rects = 0
        for (name, scene) in scenes {
            let found = countSceneRects(scene, path: "scenes.\(name)")
            XCTAssertGreaterThan(
                found,
                0,
                "scenes.\(name) has Flutter-measured rects in the fixture; this does not claim a UI match"
            )
            rects += found
        }
        XCTAssertGreaterThan(rects, 0)
    }
}

private func countSceneRects(_ value: OneTokenValue, path: String) -> Int {
    guard case let .group(children) = value else {
        XCTFail("\(path) is not a group")
        return 0
    }
    let rectKeys = ["left", "top", "width", "height"]
    let present = rectKeys.filter { children[$0] != nil }
    if present.count == 4 {
        for key in rectKeys {
            guard case let .number(number) = children[key] else {
                XCTFail("\(path).\(key) is not a number")
                return 0
            }
            XCTAssertTrue(number.isFinite, path)
        }
        return 1
    }
    if !present.isEmpty {
        XCTFail("\(path) has a partial rect")
        return 0
    }
    return children.reduce(0) { partial, element in
        partial + countSceneRects(element.value, path: "\(path).\(element.key)")
    }
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

private func layoutRoot() throws -> OneTokenValue {
    let url = try layoutFixtureURL()
    let data = try Data(contentsOf: url)
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    return try OneTokenValue.decode(json)
}

private func layoutFixtureURL() throws -> URL {
    var url = URL(fileURLWithPath: #filePath)
    let root = URL(fileURLWithPath: "/")
    while url.standardizedFileURL != root {
        if url.lastPathComponent == "OneUI" {
            return url
                .deletingLastPathComponent()
                .appendingPathComponent("_golden")
                .appendingPathComponent("fixtures")
                .appendingPathComponent("layout.json")
        }
        url.deleteLastPathComponent()
    }
    throw LayoutFixtureError("OneUI root not found from \(#filePath)")
}

private struct LayoutFixtureError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}
