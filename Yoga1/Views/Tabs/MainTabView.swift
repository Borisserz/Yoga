internal import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var app

    init() {}

    var body: some View {
        @Bindable var app = app
        TabView(selection: $app.selectedTab) {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
                .tag(0)

            ProgramsTabView()
                .tabItem { Label("Programs", systemImage: "list.bullet.clipboard.fill") }
                .tag(1)

            SessionStudioView()
                .tabItem { Label("Practice", systemImage: "figure.yoga") }
                .tag(2)

            JournalView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(3)

            MoreTabView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(4)
        }
        .tint(.mint)
    }
}
