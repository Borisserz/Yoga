internal import SwiftUI
import SwiftData

#if canImport(FirebaseCore)
import FirebaseCore
#endif

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
}

@main
struct YogaEpicApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var app: AppState
    @State private var authManager: AuthManager
    @Environment(\.scenePhase) private var scenePhase

    init() {
        #if canImport(FirebaseCore)
        // Configure Firebase before any @State property that relies on it is initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        #endif
        
        _app = State(wrappedValue: AppState())
        _authManager = State(wrappedValue: AuthManager())
    }

    var body: some Scene {
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
                    app.refreshReminders()
                }
                .onChange(of: authManager.currentUserId) { _, newValue in
                    app.currentUserId = newValue
                    AnalyticsManager.shared.setUser(id: newValue)
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    // Recompute smart reminders whenever the app becomes active so
                    // the streak nudge clears once the user has practised today.
                    if newPhase == .active {
                        app.refreshReminders()
                    }
                }
        }
        .modelContainer(for: [YogaCourse.self, CourseDay.self])
    }
}
