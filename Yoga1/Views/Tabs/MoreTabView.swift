internal import SwiftUI

/// Identifiable wrapper so an achievement key can drive `.sheet(item:)`.
private struct ShareableAchievement: Identifiable {
    let id: String
}

struct MoreTabView: View {
    @Environment(AppState.self) private var app
    @State private var shareAchievement: ShareableAchievement?
    @State private var animateBackground = false

    init() {}

    var body: some View {
        @Bindable var app = app
        NavigationStack {
            ZStack {
                AnimatedGradientBackground(animate: $animateBackground)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Account Card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.mint.opacity(0.12))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundStyle(.mint)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    TextField("Your name", text: $app.displayName)
                                        .font(.title3.bold())
                                        .foregroundStyle(.white)
                                        .textInputAutocapitalization(.words)
                                        .submitLabel(.done)
                                    
                                    HStack(spacing: 6) {
                                        Text(app.isPremiumActivated ? "Premium Plan" : "Free Plan")
                                            .font(.caption2.bold())
                                            .foregroundStyle(app.isPremiumActivated ? .yellow : .secondary)
                                        if app.isPremiumActivated {
                                            Image(systemName: "crown.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(app.isPremiumActivated ? Color.yellow.opacity(0.15) : Color.white.opacity(0.08), in: Capsule())
                                }
                                Spacer()
                            }
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // Level & Stats Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 16) {
                                LevelRing(level: app.level, progress: app.levelProgress)
                                    .frame(width: 56, height: 56)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(L("Level %lld", app.level))
                                        .font(.headline.bold())
                                    Text(L("xp.total", app.totalXP))
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                Spacer()
                                if app.lastSessionScore > 0 {
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(L("score.percent", app.lastSessionScore))
                                            .font(.title3.bold().monospacedDigit())
                                            .foregroundStyle(.mint)
                                        Text("Last AI score")
                                            .font(.caption2.bold())
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // Community Card
                        NavigationLink {
                            LeaderboardView()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "trophy.fill")
                                    .font(.title2)
                                    .foregroundStyle(.yellow)
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Leaderboard & Challenges")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text("Compete with yogis worldwide")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.55))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            .padding(18)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.tactile)

                        // Achievements Carousel
                        if !app.earnedAchievements.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Achievements")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.horizontal, 4)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(app.earnedAchievements, id: \.self) { badge in
                                            Button {
                                                shareAchievement = ShareableAchievement(id: badge)
                                            } label: {
                                                VStack(spacing: 8) {
                                                    ZStack(alignment: .bottomTrailing) {
                                                        Image(systemName: "medal.fill")
                                                            .font(.title2)
                                                            .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                                                            .padding(14)
                                                            .background(Color.white.opacity(0.08), in: Circle())
                                                            .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
                                                        
                                                        Image(systemName: "square.and.arrow.up.circle.fill")
                                                            .font(.footnote)
                                                            .foregroundStyle(.mint)
                                                            .background(Circle().fill(.black))
                                                    }
                                                    Text(L(badge))
                                                        .font(.caption2.bold())
                                                        .foregroundStyle(.white.opacity(0.85))
                                                        .lineLimit(1)
                                                }
                                                .frame(width: 80)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 4)
                                }
                            }
                        }

                        // Settings Card
                        VStack(alignment: .leading, spacing: 0) {
                            NavigationLink {
                                NotificationSettingsView()
                            } label: {
                                SettingsRow(icon: "bell.fill", color: .mint, title: "Notifications")
                            }
                            .buttonStyle(.tactile)
                            
                            Divider().background(Color.white.opacity(0.08))
                            
                            NavigationLink {
                                HealthSettingsView()
                            } label: {
                                SettingsRow(icon: "heart.text.square.fill", color: .pink, title: "Apple Health")
                            }
                            .buttonStyle(.tactile)
                        }
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // Information Card
                        VStack(alignment: .leading, spacing: 0) {
                            Link(destination: URL(string: "https://example.com/support")!) {
                                InfoRow(icon: "questionmark.circle.fill", title: "Support")
                            }
                            Divider().background(Color.white.opacity(0.08))
                            Link(destination: URL(string: "https://example.com/privacy")!) {
                                InfoRow(icon: "lock.fill", title: "Privacy Policy")
                            }
                        }
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // Sign out / Reset Button
                        Button(role: .destructive) {
                            app.reset()
                        } label: {
                            Text("Sign out")
                                .font(.headline.bold())
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.12), in: Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.tactile)
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .onAppear { animateBackground = true }
        }
        .sheet(item: $shareAchievement) { item in
            AchievementShareSheet(achievementKey: item.id)
        }
    }
}

private struct SettingsRow: View {
    let icon: String
    let color: Color
    let title: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}

private struct InfoRow: View {
    let icon: String
    let title: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 24)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "arrow.up.right.square.fill")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}
