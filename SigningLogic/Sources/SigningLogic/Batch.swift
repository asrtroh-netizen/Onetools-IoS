import Foundation

public struct BatchSuccess<Item, Value> {
    public let item: Item
    public let value: Value

    public init(item: Item, value: Value) {
        self.item = item
        self.value = value
    }
}

public struct BatchFailure<Item> {
    public let item: Item
    public let errorDescription: String

    public init(item: Item, errorDescription: String) {
        self.item = item
        self.errorDescription = errorDescription
    }
}

public struct BatchReport<Item, Value> {
    public let successes: [BatchSuccess<Item, Value>]
    public let failures: [BatchFailure<Item>]

    public init(
        successes: [BatchSuccess<Item, Value>],
        failures: [BatchFailure<Item>]
    ) {
        self.successes = successes
        self.failures = failures
    }
}

public enum Batch {
    public static func run<Item, Value>(
        _ items: [Item],
        operation: (Item) throws -> Value
    ) -> BatchReport<Item, Value> {
        var successes: [BatchSuccess<Item, Value>] = []
        var failures: [BatchFailure<Item>] = []
        for item in items {
            do {
                let value = try operation(item)
                successes.append(BatchSuccess(item: item, value: value))
            } catch {
                failures.append(BatchFailure(item: item, errorDescription: message(for: error)))
            }
        }
        return BatchReport(successes: successes, failures: failures)
    }

    private static func message(for error: Error) -> String {
        if let localized = error as? LocalizedError, let description = localized.errorDescription {
            return description
        }
        return error.localizedDescription
    }
}
