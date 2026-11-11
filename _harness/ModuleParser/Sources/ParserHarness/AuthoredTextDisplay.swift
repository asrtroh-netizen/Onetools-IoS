import ClashClientKit
import ClashClientUI

extension AuthoredText {
    var displayText: ClashDisplayText {
        switch self {
        case .app(let key, let arguments): return arguments.isEmpty ? .copy(key) : .format(key, arguments)
        case .verbatim(let text): return .verbatim(text)
        }
    }
}
