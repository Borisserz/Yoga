import SwiftUI

public struct MainTabView: View {
    @EnvironmentObject private var state: YogaAppState
    @Environment(AppStateManager.self) private var appState

    public init() {}

    public var body: some View {
        TabView(selection: Bindable(appState).selectedTab) {
            HomeDashboardView()
                .tabItem { Label("Дом", systemImage: "house.fill") }
                .tag(0)

            ProgramsTabView()
                .tabItem { Label("Курсы", systemImage: "list.bullet.clipboard.fill") }
                .tag(1)

            SessionStudioView()
                .tabItem { Label("Практика", systemImage: "figure.yoga") }
                .tag(2)

            BreathCoachView()
                .tabItem { Label("Дыхание", systemImage: "wind") }
                .tag(3)

            ChallengeArenaView()
                .tabItem { Label("Квесты", systemImage: "flame.fill") }
                .tag(4)

            JournalView()
                .tabItem { Label("Дневник", systemImage: "book.fill") }
                .tag(5)

            MoreTabView()
                .tabItem { Label("Профиль", systemImage: "person.crop.circle") }
                .tag(6)
        }
        .accentColor(.mint)
    }
}
