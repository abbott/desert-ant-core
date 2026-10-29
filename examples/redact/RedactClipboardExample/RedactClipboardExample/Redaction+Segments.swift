import Redact

extension Redaction {
    /// `source`, the text this redaction came from, cut into plain runs and
    /// items, in order. With each item read as its placeholder, the runs join
    /// to `redactedText`.
    ///
    /// Cut by UTF-16 offset, as Redact builds `redactedText`: a String index
    /// that is not on a character boundary would be rounded and shift a run.
    func segments(of source: String) -> [(text: String, item: Item?)] {
        let units = Array(source.utf16)
        func text(_ start: Int, _ end: Int) -> String { String(decoding: units[start..<end], as: UTF16.self) }
        var out: [(text: String, item: Item?)] = []
        var cursor = 0
        for item in items {
            let start = item.range.lowerBound.utf16Offset(in: source)
            guard start >= cursor else { continue }
            if start > cursor { out.append((text(cursor, start), nil)) }
            out.append((item.placeholder, item))
            cursor = item.range.upperBound.utf16Offset(in: source)
        }
        if cursor < units.count { out.append((text(cursor, units.count), nil)) }
        return out
    }
}
