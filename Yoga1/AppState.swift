import SwiftUI
import Foundation
import Observation

/// Single source of truth for app-wide state.
///
/// Replaces the previous split between `YogaAppState` (an `ObservableObject`)
/// and `AppStateManager` (an `@Observable`). All progress is now persisted, so
/// streaks, minutes, journal entries and achievements survive app restarts.
@Observable
public final class AppState {

    // MARK: Persisted progress
    public var hasCompletedOnboarding: Bool = false
    public var isPremiumActivated: Bool = false
    public var earnedAchievements: [String] = []          // achievement keys
    public var completedMinutes: Int = 0
    public var streakDays: Int = 0
    public var lastSessionDate: Date?
    public var moodKey: String = "mood.calm"
    public var journalEntries: [JournalEntry] = []
    public var sessions: [SessionRecord] = []

    // MARK: Transient UI state (not persisted)
    public var selectedTab: Int = 0
    public var activePose: YogaPose?
    public var pulseAnimation: Bool = false

    /// Set by `AuthManager` once Firebase resolves the user.
    public var currentUserId: String = "local_user"

    private let storageKey = "yoga_app_state_v1"

    public init() {
        load()
    }

    // MARK: - Display helpers

    public var mood: String { L(moodKey) }

    /// Minutes practiced per weekday for the last 7 days (oldest first).
    public var weeklyActivity: [(label: String, minutes: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let fmt = DateFormatter()
        fmt.locale = .current
        fmt.dateFormat = "EEE"
        return (0..<7).reversed().compactMap { offset -> (label: String, minutes: Int)? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let minutes = sessions
                .filter { cal.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.durationMinutes }
            return (fmt.string(from: day), minutes)
        }
    }

    // MARK: - Mutations

    public func completeOnboarding() {
        hasCompletedOnboarding = true
        unlockAchievement("achievement.first_step")
        persist()
    }

    public func activatePremium() {
        isPremiumActivated = true
        unlockAchievement("achievement.vip")
        persist()
    }

    public func unlockAchievement(_ key: String) {
        guard !earnedAchievements.contains(key) else { return }
        earnedAchievements.append(key)
        HapticsManager.shared.playSuccess()
        AnalyticsManager.shared.log(event: "achievement_unlocked", parameters: ["key": key])
        persist()
    }

    /// Records a completed practice session and updates streak + totals.
    public func completeSession(minutes: Int, poseKey: String? = nil) {
        completedMinutes += minutes
        sessions.append(SessionRecord(durationMinutes: minutes, poseKey: poseKey))
        updateStreak()
        pulseAnimation.toggle()

        AnalyticsManager.shared.log(event: "session_complete",
                                    parameters: ["minutes": minutes, "pose": poseKey ?? "free"])
        FirebaseManager.shared.saveUserStats(userId: currentUserId,
                                             minutes: completedMinutes,
                                             streak: streakDays)
        Task {
            let end = Date()
            let start = end.addingTimeInterval(TimeInterval(-minutes * 60))
            await HealthKitManager.shared.saveMindfulMinutes(minutes: minutes, startDate: start, endDate: end)
        }
        persist()
    }

    private func updateStreak() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        if let last = lastSessionDate {
            let lastDay = cal.startOfDay(for: last)
            if cal.isDate(lastDay, inSameDayAs: today) {
                // already counted today — no change
            } else if let yesterday = cal.date(byAdding: .day, value: -1, to: today),
                      cal.isDate(lastDay, inSameDayAs: yesterday) {
                streakDays += 1
            } else {
                streakDays = 1   // streak broken
            }
        } else {
            streakDays = 1
        }
        lastSessionDate = today

        if streakDays >= 7 { unlockAchievement("achievement.streak_7") }
        if streakDays >= 30 { unlockAchievement("achievement.streak_30") }
    }

    public func addEntry(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        journalEntries.insert(JournalEntry(text: trimmed), at: 0)
        persist()
    }

    public func reset() {
        hasCompletedOnboarding = false
        isPremiumActivated = false
        earnedAchievements = []
        completedMinutes = 0
        streakDays = 0
        lastSessionDate = nil
        journalEntries = []
        sessions = []
        selectedTab = 0
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var hasCompletedOnboarding: Bool
        var isPremiumActivated: Bool
        var earnedAchievements: [String]
        var completedMinutes: Int
        var streakDays: Int
        var lastSessionDate: Date?
        var moodKey: String
        var journalEntries: [JournalEntry]
        var sessions: [SessionRecord]
    }

    private func persist() {
        let snapshot = Snapshot(
            hasCompletedOnboarding: hasCompletedOnboarding,
            isPremiumActivated: isPremiumActivated,
            earnedAchievements: earnedAchievements,
            completedMinutes: completedMinutes,
            streakDays: streakDays,
            lastSessionDate: lastSessionDate,
            moodKey: moodKey,
            journalEntries: journalEntries,
            sessions: sessions
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            // Migrate the legacy onboarding flag if present.
            hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            return
        }
        hasCompletedOnboarding = snapshot.hasCompletedOnboarding
        isPremiumActivated = snapshot.isPremiumActivated
        earnedAchievements = snapshot.earnedAchievements
        completedMinutes = snapshot.completedMinutes
        streakDays = snapshot.streakDays
        lastSessionDate = snapshot.lastSessionDate
        moodKey = snapshot.moodKey
        journalEntries = snapshot.journalEntries
        sessions = snapshot.sessions
    }
}
