


import SwiftUI

#if canImport(FirebaseCore)
import FirebaseCore
#endif

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
        return true
    }
}

@main
public struct YogaEpicApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var state = YogaAppState()
    @State private var appState = AppStateManager()
    @State private var authManager = AuthManager()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .environment(appState)
                .environment(authManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    if appState.hasCompletedOnboarding == false {
                        authManager.signInAnonymously()
                    }
                }
        }
    }
}
