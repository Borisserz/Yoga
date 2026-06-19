import SwiftUI

public struct ContentView: View {
    @Environment(AppStateManager.self) private var appState

    public init() {}

    public var body: some View {
        ZStack {
            if !appState.hasCompletedOnboarding {
                OnboardingFlowView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: appState.hasCompletedOnboarding)
    }
}
