public struct UTType: Sendable {
    private let filenameExtension: String

    public init?(filenameExtension: String) {
        guard !filenameExtension.isEmpty else { return nil }
        self.filenameExtension = filenameExtension
    }

    public var preferredMIMEType: String? {
        switch filenameExtension.lowercased() {
        case "json": return "application/json"
        case "txt", "text": return "text/plain"
        case "html", "htm": return "text/html"
        case "js": return "text/javascript"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "css": return "text/css"
        case "xml": return "application/xml"
        default: return nil
        }
    }
}
