import Foundation

/// Backwards-compatibility alias.
///
/// `AppStateManager` and `YogaAppState` were merged into a single ``AppState``.
/// This alias keeps older references compiling; prefer `AppState` in new code.
@available(*, deprecated, renamed: "AppState")
public typealias AppStateManager = AppState
