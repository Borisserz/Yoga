import SwiftUI

public struct MoreTabView: View {
    @Environment(AppState.self) private var app

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.mint)
                        VStack(alignment: .leading) {
                            Text("User")
                                .font(.headline)
                            Text(app.isPremiumActivated ? "Premium Plan 👑" : "Free plan")
                                .font(.caption)
                                .foregroundStyle(app.isPremiumActivated ? .yellow : .secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Level") {
                    HStack(spacing: 16) {
                        LevelRing(level: app.level, progress: app.levelProgress)
                            .frame(width: 56, height: 56)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("Level %lld", app.level))
                                .font(.headline)
                            Text(L("%lld XP", app.totalXP))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if app.lastSessionScore > 0 {
                            VStack(spacing: 2) {
                                Text(L("%lld%%", app.lastSessionScore))
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
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(app.earnedAchievements, id: \.self) { badge in
                                    VStack {
                                        Image(systemName: "medal.fill")
                                            .font(.title)
                                            .foregroundStyle(.yellow)
                                            .padding()
                                            .background(Color.mint.opacity(0.2), in: Circle())
                                        Text(L(badge))
                                            .font(.caption)
                                            .bold()
                                    }
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
    }
}
