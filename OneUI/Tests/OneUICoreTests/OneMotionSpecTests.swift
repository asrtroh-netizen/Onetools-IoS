import XCTest
@testable import OneUICore

final class OneMotionSpecTests: XCTestCase {
    func testMotionDurationsRespectAntiSlopLatencyBudget() {
        XCTAssertLessThanOrEqual(OneMotionSpec.pressResponse, OneMotionSpec.maxMicroInteractionDuration)
        XCTAssertLessThanOrEqual(OneMotionSpec.tabExitDuration, OneMotionSpec.tabEnterDuration)
        XCTAssertLessThanOrEqual(OneMotionSpec.slidingPillDuration, OneMotionSpec.maxMicroInteractionDuration)
        XCTAssertLessThanOrEqual(OneMotionSpec.digitSwapDuration, OneMotionSpec.maxMicroInteractionDuration)
        XCTAssertLessThanOrEqual(OneMotionSpec.tabMicroOffsetPt, 4.0)
    }

    func testMetricFormatterSplitsDecimalAndThroughputUnit() {
        XCTAssertEqual(
            OneMetricFormatter.split("12.48 MB/s"),
            OneSplitMetricValue(prefix: "", integer: "12", suffix: ".48 MB/s")
        )
        XCTAssertEqual(
            OneMetricFormatter.split("+22.5%"),
            OneSplitMetricValue(prefix: "+", integer: "22", suffix: ".5%")
        )
        XCTAssertEqual(
            OneMetricFormatter.split("1,024 ms"),
            OneSplitMetricValue(prefix: "", integer: "1,024", suffix: " ms")
        )
        XCTAssertEqual(
            OneMetricFormatter.split("mihomo 1.19.33"),
            OneSplitMetricValue(prefix: "", integer: "mihomo 1.19.33", suffix: "")
        )
        XCTAssertEqual(
            OneMetricFormatter.split("10.7.0.1"),
            OneSplitMetricValue(prefix: "", integer: "10.7.0.1", suffix: "")
        )
    }
}
