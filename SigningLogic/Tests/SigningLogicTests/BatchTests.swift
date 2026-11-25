import Foundation
import XCTest
@testable import SigningLogic

final class BatchTests: XCTestCase {
    func testAllItemsSucceed() {
        let report = Batch.run(["a", "b", "c"]) { item in
            "signed-\(item)"
        }
        XCTAssertEqual(report.successes.map(\.item), ["a", "b", "c"])
        XCTAssertEqual(report.successes.map(\.value), ["signed-a", "signed-b", "signed-c"])
        XCTAssertEqual(report.failures.map(\.item), [])
    }

    func testOneFailureIsRecordedAndTheRestContinue() {
        var seen: [String] = []
        let report = Batch.run(["bad", "good", "bad-2"]) { item -> String in
            seen.append(item)
            if item.hasPrefix("bad") {
                throw SignError(item)
            }
            return "signed-\(item)"
        }
        XCTAssertEqual(seen, ["bad", "good", "bad-2"])
        XCTAssertEqual(report.successes.map(\.item), ["good"])
        XCTAssertEqual(report.successes.map(\.value), ["signed-good"])
        XCTAssertEqual(report.failures.map(\.item), ["bad", "bad-2"])
        XCTAssertEqual(report.failures.map(\.errorDescription), ["bad", "bad-2"])
    }

    func testEveryItemCanFail() {
        let report = Batch.run(["a", "b"]) { item -> String in
            throw SignError("fail-\(item)")
        }
        XCTAssertEqual(report.successes.map(\.item), [])
        XCTAssertEqual(report.failures.map(\.item), ["a", "b"])
        XCTAssertEqual(report.failures.map(\.errorDescription), ["fail-a", "fail-b"])
    }

    func testEmptyInputDoesNoWork() {
        let report = Batch.run([String]()) { (item: String) -> String in
            XCTFail("operation should not run")
            return item
        }
        XCTAssertTrue(report.successes.isEmpty)
        XCTAssertTrue(report.failures.isEmpty)
    }

    func testRunAsyncIsolatesFailuresAndContinues() async {
        let report = await Batch.runAsync(["ipa-1", "bad-ipa", "ipa-3"]) { item async throws -> String in
            if item == "bad-ipa" {
                throw SignError("corrupt bundle")
            }
            return "signed:\(item)"
        }
        XCTAssertEqual(report.successes.map(\.item), ["ipa-1", "ipa-3"])
        XCTAssertEqual(report.successes.map(\.value), ["signed:ipa-1", "signed:ipa-3"])
        XCTAssertEqual(report.failures.map(\.item), ["bad-ipa"])
        XCTAssertEqual(report.failures.map(\.errorDescription), ["corrupt bundle"])
    }

}

private struct SignError: LocalizedError {
    let errorDescription: String?

    init(_ message: String) {
        errorDescription = message
    }
}
