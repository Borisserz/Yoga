import SwiftUI
import SwiftData

#if canImport(FirebaseCore)
import FirebaseCore
#endif

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
        return true
    }
}

@main
public struct YogaEpicApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var app = AppState()
    @State private var authManager = AuthManager()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(app)
                .environment(authManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    if !app.hasCompletedOnboarding {
                        authManager.signInAnonymously()
                    }
                    NotificationManager.shared.requestAuthorization()
                }
                .onChange(of: authManager.currentUserId) { _, newValue in
                    app.currentUserId = newValue
                    AnalyticsManager.shared.setUser(id: newValue)
                }
        }
        .modelContainer(for: [YogaCourse.self, CourseDay.self])
    }
}
