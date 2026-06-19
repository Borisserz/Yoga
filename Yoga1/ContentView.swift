import SwiftUI

public struct ContentView: View {
    @EnvironmentObject private var state: YogaAppState

    public init() {}

    public var body: some View {
        TabView(selection: $state.selectedTab) {
            HomeDashboardView()
                .tabItem { Label("Дом", systemImage: "house.fill") }
                .tag(0)

            SessionStudioView()
                .tabItem { Label("Практика", systemImage: "figure.yoga") }
                .tag(1)

            BreathCoachView()
                .tabItem { Label("Дыхание", systemImage: "wind") }
                .tag(2)

            ChallengeArenaView()
                .tabItem { Label("Квесты", systemImage: "flame.fill") }
                .tag(3)

            JournalView()
                .tabItem { Label("Дневник", systemImage: "book.fill") }
                .tag(4)
        }
        .accentColor(.mint)
    }
}
