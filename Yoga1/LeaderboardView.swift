import SwiftUI

/// Community leaderboard backed by Firestore (with a sample fallback). Players
/// compete on practice minutes, streak length or total XP, and a rotating
/// community challenge highlights the current leader.
public struct LeaderboardView: View {
    @Environment(AppState.self) private var app

    @State private var scope: LeaderboardScope = .minutes
    @State private var entries: [LeaderboardEntry] = []
    @State private var isLoading = true

    public init() {}

    private var me: LeaderboardEntry {
        LeaderboardEntry(
            id: app.currentUserId,
            name: app.displayName,
            minutes: app.completedMinutes,
            streak: app.streakDays,
            xp: app.totalXP,
            level: app.level
        )
    }

    private var myRank: Int? {
        entries.firstIndex { $0.id == app.currentUserId }.map { $0 + 1 }
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("Scope", selection: $scope) {
                    ForEach(LeaderboardScope.allCases) { s in
                        Text(s.title).tag(s)
                    }
                }
                .pickerStyle(.segmented)

                ChallengeBanner(scope: scope, leader: entries.first)

                if isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 10) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardRow(
                                rank: index + 1,
                                entry: entry,
                                scope: scope,
                                isCurrentUser: entry.id == app.currentUserId
                            )
                        }
                    }

                    if let rank = myRank {
                        Text(L("You're ranked #%lld", rank))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Leaderboard")
        .task(id: scope) { await load() }
    }

    private func load() async {
        isLoading = true
        entries = await FirebaseManager.shared.fetchLeaderboard(scope: scope, currentUser: me)
        isLoading = false
    }
}

// MARK: - Community challenge banner

private struct ChallengeBanner: View {
    let scope: LeaderboardScope
    let leader: LeaderboardEntry?

    private var title: String {
        switch scope {
        case .minutes: return L("challenge.minutes.title")
        case .streak:  return L("challenge.streak.title")
        case .xp:      return L("challenge.xp.title")
        }
    }

    private var leaderLine: String {
        guard let leader else { return L("challenge.empty") }
        switch scope {
        case .minutes: return L("%@ leads with %lld min", leader.name, leader.minutes)
        case .streak:  return L("%@ leads with a %lld-day streak", leader.name, leader.streak)
        case .xp:      return L("%@ leads with %lld XP", leader.name, leader.xp)
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.title)
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(leaderLine)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

// MARK: - Row

private struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    let scope: LeaderboardScope
    let isCurrentUser: Bool

    private var metric: String {
        switch scope {
        case .minutes: return L("%lld min", entry.minutes)
        case .streak:  return L("%lld 🔥", entry.streak)
        case .xp:      return L("%lld XP", entry.xp)
        }
    }

    private var medal: String? {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return nil
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Group {
                if let medal {
                    Text(medal).font(.title3)
                } else {
                    Text("\(rank)")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 32)

            Text(entry.name)
                .font(.headline)
                .lineLimit(1)
            if isCurrentUser {
                Text("You")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.mint.opacity(0.3), in: Capsule())
            }
            Spacer()
            Text(metric)
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(.mint)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            (isCurrentUser ? AnyShapeStyle(Color.mint.opacity(0.15)) : AnyShapeStyle(Color.white.opacity(0.05))),
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isCurrentUser ? Color.mint.opacity(0.6) : .clear, lineWidth: 1)
        )
    }
}
