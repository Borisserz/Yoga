import SwiftUI

public struct ContentView: View {
    @Environment(AppState.self) private var app

    public init() {}

    public var body: some View {
        ZStack {
            if !app.hasCompletedOnboarding {
                OnboardingFlowView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: app.hasCompletedOnboarding)
    }
}
