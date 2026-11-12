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
