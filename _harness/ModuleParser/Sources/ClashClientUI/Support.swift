import ClashClientKit

public enum ClashDisplayText: Equatable, Hashable, Sendable {
    case copy(String)
    case verbatim(String)
    case format(String, [String])
    case formatCopy(String, [String])
}

public protocol ClashAuthoredError: Error {
    var displayText: ClashDisplayText { get }
}
