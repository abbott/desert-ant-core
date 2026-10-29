import Redact

// In a file of its own because SwiftUI has a `Label` view too, which makes
// `Label` ambiguous wherever both are imported. `Redact.Label` does not help:
// `Redact` names the class before the module.
extension Options {
    /// Redact's default labels without URL.
    static let keepingURLs = Options(labels: Label.defaultEnabled.subtracting([.url]))
}
