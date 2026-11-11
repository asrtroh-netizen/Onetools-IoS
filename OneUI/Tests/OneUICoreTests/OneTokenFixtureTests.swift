import Foundation
import XCTest
@testable import OneUICore

final class OneTokenFixtureTests: XCTestCase {
    func testEveryTokensJsonKeyMatchesSwiftCatalog() throws {
        let url = try tokensFixtureURL()
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        let fixture = try OneTokenValue.decode(json)
        let fixtureKeys = fixture.keyCount
        var visited = 0
        assertCovered(
            fixture: fixture,
            swift: OneTokens.fixtureTree,
            path: "tokens",
            visited: &visited
        )
        XCTAssertGreaterThan(fixtureKeys, 0)
        XCTAssertEqual(visited, fixtureKeys)
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

extension OneTokenValue {
    var keyCount: Int {
        switch self {
        case let .group(children):
            return children.values.reduce(children.count) { $0 + $1.keyCount }
        case let .list(children):
            return children.reduce(children.count) { $0 + $1.keyCount }
        case .text, .number:
            return 0
        }
    }

    static func decode(_ json: Any) throws -> OneTokenValue {
        if let text = json as? String {
            return .text(text)
        }
        if let dictionary = json as? [String: Any] {
            var group: [String: OneTokenValue] = [:]
            for (key, value) in dictionary {
                group[key] = try decode(value)
            }
            return .group(group)
        }
        if let dictionary = json as? NSDictionary {
            var group: [String: OneTokenValue] = [:]
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

private struct FixtureReadError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

private func tokensFixtureURL() throws -> URL {
    var url = URL(fileURLWithPath: #filePath)
    let root = URL(fileURLWithPath: "/")
    while url.standardizedFileURL != root {
        if url.lastPathComponent == "OneUI" {
            return url
                .deletingLastPathComponent()
                .appendingPathComponent("_golden")
                .appendingPathComponent("fixtures")
                .appendingPathComponent("tokens.json")
        }
        url.deleteLastPathComponent()
    }
    throw FixtureReadError("OneUI root not found from \(#filePath)")
}
