import Foundation

/// Lightweight localization helper for dynamic keys and formatted strings.
///
/// Static UI strings are localized automatically by SwiftUI (`Text("...")`,
/// `Label`, `Button`, `Section`, `.navigationTitle`, ...), which resolve the
/// English literal as a key against the `Localizable` String Catalog.
///
/// `L(_:_:)` is used wherever the key is computed at runtime (e.g. pose content
/// looked up by a stable key) or where a value must be interpolated into a
/// localized format string before being shown via `Text(String)`.
@inline(__always)
public func L(_ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, comment: "")
    guard !args.isEmpty else { return format }
    return String(format: format, locale: .current, arguments: args)
}
