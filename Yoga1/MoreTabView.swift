internal import SwiftUI

/// Identifiable wrapper so an achievement key can drive `.sheet(item:)`.
private struct ShareableAchievement: Identifiable {
    let id: String
}

struct MoreTabView: View {
    @Environment(AppState.self) private var app
    @State private var shareAchievement: ShareableAchievement?

    init() {}

    var body: some View {
        @Bindable var app = app
        NavigationStack {
            List {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.mint)
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Your name", text: $app.displayName)
                                .font(.headline)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                            Text(app.isPremiumActivated ? "Premium Plan 👑" : "Free plan")
                                .font(.caption)
                                .foregroundStyle(app.isPremiumActivated ? .yellow : .secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Community") {
                    NavigationLink {
                        LeaderboardView()
                    } label: {
                        Label("Leaderboard & challenges", systemImage: "trophy.fill")
                    }
                }

                Section("Level") {
                    HStack(spacing: 16) {
                        LevelRing(level: app.level, progress: app.levelProgress)
                            .frame(width: 56, height: 56)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("Level %lld", app.level))
                                .font(.headline)
                            Text(L("xp.total", app.totalXP))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if app.lastSessionScore > 0 {
                            VStack(spacing: 2) {
                                Text(L("score.percent", app.lastSessionScore))
                                    .font(.headline)
                                    .foregroundStyle(.mint)
                                Text("Last AI score")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                if !app.earnedAchievements.isEmpty {
                    Section("Achievements") {
                        Text("Tap a badge to share it")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(app.earnedAchievements, id: \.self) { badge in
                                    Button {
                                        shareAchievement = ShareableAchievement(id: badge)
                                    } label: {
                                        VStack {
                                            ZStack(alignment: .bottomTrailing) {
                                                Image(systemName: "medal.fill")
                                                    .font(.title)
                                                    .foregroundStyle(.yellow)
                                                    .padding()
                                                    .background(Color.mint.opacity(0.2), in: Circle())
                                                Image(systemName: "square.and.arrow.up.circle.fill")
                                                    .font(.callout)
                                                    .foregroundStyle(.mint)
                                                    .background(Circle().fill(.background))
                                            }
                                            Text(L(badge))
                                                .font(.caption)
                                                .bold()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                Section("Settings") {
                    NavigationLink("Notifications") {
                        Text("Notification settings")
                    }
                    NavigationLink("Apple Health") {
                        Text("HealthKit synchronization")
                    }
                }

                Section("Information") {
                    Link("Support", destination: URL(string: "https://example.com/support")!)
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                }

                Section {
                    Button(role: .destructive) {
                        app.reset()
                    } label: {
                        Text("Sign out")
                    }
                }
            }
            .navigationTitle("Profile")
        }
        .sheet(item: $shareAchievement) { item in
            AchievementShareSheet(achievementKey: item.id)
        }
    }
}
