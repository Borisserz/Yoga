import Foundation

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif
#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

/// Thin analytics/crash-reporting facade.
///
/// Compiles whether or not the Firebase SDKs are linked yet: when they are
/// absent, events are simply logged to the console (debug builds only), so the
/// rest of the app can call `AnalyticsManager.shared.log(...)` unconditionally.
public final class AnalyticsManager {
    public static let shared = AnalyticsManager()
    private init() {}

    public func log(event: String, parameters: [String: Any] = [:]) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(event, parameters: parameters)
        #else
        #if DEBUG
        print("📊 [Analytics] \(event) \(parameters)")
        #endif
        #endif
    }

    public func setUser(id: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserID(id)
        #endif
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setUserID(id)
        #endif
    }

    public func record(error: Error) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().record(error: error)
        #else
        #if DEBUG
        print("⚠️ [Crashlytics] \(error.localizedDescription)")
        #endif
        #endif
    }
}
