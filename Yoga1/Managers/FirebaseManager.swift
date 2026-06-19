import Foundation
import Observation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

// MARK: - Leaderboard model

/// A single ranked competitor on the community leaderboard.
struct LeaderboardEntry: Identifiable, Hashable, Sendable {
    let id: String          // user id
    let name: String
    let minutes: Int
    let streak: Int
    let xp: Int
    let level: Int

    init(id: String, name: String, minutes: Int, streak: Int, xp: Int, level: Int) {
        self.id = id
        self.name = name
        self.minutes = minutes
        self.streak = streak
        self.xp = xp
        self.level = level
    }
}

/// Scope of the leaderboard / challenge ranking.
enum LeaderboardScope: String, CaseIterable, Identifiable, Sendable {
    case minutes
    case streak
    case xp

    var id: String { rawValue }
    var title: String { L("leaderboard.scope.\(rawValue)") }

    /// Firestore field this scope orders by.
    var field: String {
        switch self {
        case .minutes: return "totalMinutes"
        case .streak:  return "currentStreak"
        case .xp:      return "totalXP"
        }
    }
}

@Observable
final class FirebaseManager {
    static let shared = FirebaseManager()

    init() {}

    // MARK: - Write

    /// Upserts the player's stats into the shared `leaderboard` collection.
    func saveUserStats(userId: String,
                              name: String,
                              minutes: Int,
                              streak: Int,
                              xp: Int,
                              level: Int) {
        guard !userId.isEmpty && userId != "Unknown" else { return }

        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let payload: [String: Any] = [
            "displayName": name,
            "totalMinutes": minutes,
            "currentStreak": streak,
            "totalXP": xp,
            "level": level,
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        // Mirror to the private user doc and the leaderboard doc.
        db.collection("users").document(userId).setData(payload, merge: true)
        db.collection("leaderboard").document(userId).setData(payload, merge: true) { error in
            if let error = error {
                print("Error saving leaderboard entry: \(error.localizedDescription)")
            } else {
                print("Successfully synced leaderboard entry.")
            }
        }
        #else
        print("FirebaseFirestore not imported. Mocking sync for \(name) (\(userId)): \(minutes) mins, \(streak) streak, \(xp) XP.")
        #endif
    }

    // MARK: - Read

    /// Fetches the top competitors for a scope. Falls back to sample data when
    /// Firestore is unavailable so the UI is always demonstrable.
    func fetchLeaderboard(scope: LeaderboardScope,
                                 limit: Int = 25,
                                 currentUser: LeaderboardEntry? = nil) async -> [LeaderboardEntry] {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let snapshot = try? await db.collection("leaderboard")
            .order(by: scope.field, descending: true)
            .limit(to: limit)
            .getDocuments()

        let entries: [LeaderboardEntry] = snapshot?.documents.compactMap { doc in
            let data = doc.data()
            return LeaderboardEntry(
                id: doc.documentID,
                name: data["displayName"] as? String ?? "Yogi",
                minutes: data["totalMinutes"] as? Int ?? 0,
                streak: data["currentStreak"] as? Int ?? 0,
                xp: data["totalXP"] as? Int ?? 0,
                level: data["level"] as? Int ?? 1
            )
        } ?? []

        return merge(entries, with: currentUser, scope: scope, limit: limit)
        #else
        let sample = Self.sampleLeaderboard()
        return merge(sample, with: currentUser, scope: scope, limit: limit)
        #endif
    }

    /// Inserts/refreshes the current user into the list and re-sorts by scope.
    private func merge(_ entries: [LeaderboardEntry],
                       with currentUser: LeaderboardEntry?,
                       scope: LeaderboardScope,
                       limit: Int) -> [LeaderboardEntry] {
        var combined = entries
        if let me = currentUser {
            combined.removeAll { $0.id == me.id }
            combined.append(me)
        }
        let sorted = combined.sorted { lhs, rhs in
            switch scope {
            case .minutes: return lhs.minutes > rhs.minutes
            case .streak:  return lhs.streak > rhs.streak
            case .xp:      return lhs.xp > rhs.xp
            }
        }
        return Array(sorted.prefix(limit))
    }

    /// Believable mock competitors used when Firebase isn't configured.
    private static func sampleLeaderboard() -> [LeaderboardEntry] {
        [
            LeaderboardEntry(id: "s1", name: "Maya",    minutes: 920, streak: 41, xp: 9300, level: 10),
            LeaderboardEntry(id: "s2", name: "Leo",     minutes: 760, streak: 22, xp: 7600, level: 9),
            LeaderboardEntry(id: "s3", name: "Aisha",   minutes: 540, streak: 30, xp: 5400, level: 8),
            LeaderboardEntry(id: "s4", name: "Daniel",  minutes: 410, streak: 12, xp: 4100, level: 7),
            LeaderboardEntry(id: "s5", name: "Sofia",   minutes: 305, streak: 18, xp: 3050, level: 6),
            LeaderboardEntry(id: "s6", name: "Noah",    minutes: 220, streak: 7,  xp: 2200, level: 5),
            LeaderboardEntry(id: "s7", name: "Emma",    minutes: 140, streak: 4,  xp: 1400, level: 4)
        ]
    }
}
