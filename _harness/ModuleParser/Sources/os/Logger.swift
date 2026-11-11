public enum OSLogPrivacy {
    case auto
    case `public`
    case `private`
    case sensitive
}

public struct OSLogMessage: ExpressibleByStringInterpolation {
    public struct StringInterpolation: StringInterpolationProtocol {
        public init(literalCapacity: Int, interpolationCount: Int) {}
        public mutating func appendLiteral(_ literal: String) {}
        public mutating func appendInterpolation<T>(_ value: T) {}
        public mutating func appendInterpolation<T>(_ value: T, privacy: OSLogPrivacy) {}
    }

    public init(stringLiteral value: String) {}
    public init(stringInterpolation: StringInterpolation) {}
}

public struct Logger {
    public init(subsystem: String, category: String) {}
    public func notice(_ message: OSLogMessage) {}
    public func debug(_ message: OSLogMessage) {}
    public func info(_ message: OSLogMessage) {}
    public func error(_ message: OSLogMessage) {}
    public func warning(_ message: OSLogMessage) {}
    public func fault(_ message: OSLogMessage) {}
    public func log(_ message: OSLogMessage) {}
}
