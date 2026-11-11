import XCTest
@testable import ParserHarness

final class ProbeTests: XCTestCase {
    func testLoonNameIsRead() throws {
        let text = "#!name=Probe\n[Rule]\nDOMAIN,example.com,REJECT\n"
        let parsed = try ModuleParser.parse(Data(text.utf8), sourceURL: nil, fetchedAt: nil)
        guard case .success(let ir) = parsed else {
            XCTFail("refused")
            return
        }
        XCTAssertEqual(ir.manifest.name, "Probe")
    }
}
