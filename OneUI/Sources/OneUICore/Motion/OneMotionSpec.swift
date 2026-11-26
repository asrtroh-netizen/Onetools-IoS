import Foundation

/// Standardized motion timing and Bento numeric split rules (`DESIGN.md` §3 & §4).
public enum OneMotionSpec {
    public static let pressScale: Double = 0.97
    public static let heroPressScale: Double = 0.95
    public static let pressResponse: Double = 0.16
    public static let pressDamping: Double = 0.82

    public static let tabExitDuration: Double = 0.12
    public static let tabEnterDuration: Double = 0.18
    public static let tabMicroOffsetPt: Double = 4.0

    public static let slidingPillDuration: Double = 0.24
    public static let digitSwapDuration: Double = 0.18
    public static let toastDuration: Double = 0.20
    public static let maxMicroInteractionDuration: Double = 0.30

    public static let bentoUnitScaleRatio: Double = 0.76
}

public struct OneSplitMetricValue: Equatable, Sendable {
    public let prefix: String
    public let integer: String
    public let suffix: String

    public init(prefix: String, integer: String, suffix: String) {
        self.prefix = prefix
        self.integer = integer
        self.suffix = suffix
    }
}

public enum OneMetricFormatter {
    private static let metricRegex = try! NSRegularExpression(
        pattern: #"^([+-]?\s*(?:[↓↑¥$€]\s*)?)(\d+(?:,\d{3})*|\d+)((?:\.\d+)?(?:\s*(?:GiB/s|MiB/s|KiB/s|GB/s|MB/s|KB/s|B/s|GiB|MiB|KiB|dBm|ms|GB|MB|KB|B|%|s))?)$"#,
        options: [.caseInsensitive]
    )

    /// Splits a formatted metric string (e.g. `"12.48 MB/s"`, `"+22.2%"`, `"86 ms"`) into
    /// `prefix` (`"+"`), primary bold `integer` (`"12"`), and `76%`-scaled `suffix` (`".48 MB/s"`).
    /// Non-metric strings such as IPv4 addresses (`"10.7.0.1"`) or version strings stay whole.
    public static func split(_ raw: String) -> OneSplitMetricValue {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return OneSplitMetricValue(prefix: "", integer: "—", suffix: "")
        }

        let nsRange = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
        guard let match = metricRegex.firstMatch(in: trimmed, options: [], range: nsRange),
              let r1 = Range(match.range(at: 1), in: trimmed),
              let r2 = Range(match.range(at: 2), in: trimmed),
              let r3 = Range(match.range(at: 3), in: trimmed) else {
            return OneSplitMetricValue(prefix: "", integer: trimmed, suffix: "")
        }

        return OneSplitMetricValue(
            prefix: String(trimmed[r1]),
            integer: String(trimmed[r2]),
            suffix: String(trimmed[r3])
        )
    }
}
