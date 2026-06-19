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
    public var totalXP: Int = 0
    public var lastSessionScore: Int = 0          // 0...100, from the most recent AI session
    public var onboardingLevelKey: String = "onb.level.beginner"
    public var onboardingGoalKey: String = "onb.goal.flexibility"
    /// Public name shown on the community leaderboard and shared achievement cards.
    public var displayName: String = "Yogi"

    // MARK: Transient UI state (not persisted)
    public var selectedTab: Int = 0
    public var activePose: YogaPose?
    public var pulseAnimation: Bool = false

    /// Set by `AuthManager` once Firebase resolves the user.
    public var currentUserId: String = "local_user"

    private let storageKey = "yoga_app_state_v2"

    public init() {
        load()
    }

    // MARK: - Display helpers

    public var mood: String { L(moodKey) }

    /// Whether a practice session has already been recorded today.
    public var practicedToday: Bool {
        guard let last = lastSessionDate else { return false }
        return Calendar.current.isDate(last, inSameDayAs: Date())
    }

    // MARK: - Notifications

    /// Recomputes notifications: a daily reminder at the user's habitual hour
    /// plus an evening "don't lose your streak" nudge when one is at risk.
    public func refreshReminders() {
        NotificationManager.shared.refreshSchedules(
            sessions: sessions,
            streakDays: streakDays,
            practicedToday: practicedToday
        )
    }

    // MARK: - Level / XP

    /// Current level derived from total XP. Each level needs progressively more XP.
    public var level: Int { max(1, Int((Double(totalXP) / 100.0).squareRoot()) + 1) }

    private func xpFloor(forLevel level: Int) -> Int {
        let n = max(0, level - 1)
        return n * n * 100
    }

    /// XP accumulated within the current level.
    public var xpIntoLevel: Int { totalXP - xpFloor(forLevel: level) }

    /// XP span between the current level and the next one.
    public var xpForNextLevel: Int { xpFloor(forLevel: level + 1) - xpFloor(forLevel: level) }

    /// 0...1 progress towards the next level.
    public var levelProgress: Double {
        xpForNextLevel > 0 ? min(1, Double(xpIntoLevel) / Double(xpForNextLevel)) : 0
    }

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

    public func completeOnboarding(levelKey: String? = nil, goalKey: String? = nil) {
        hasCompletedOnboarding = true
        if let levelKey { onboardingLevelKey = levelKey }
        if let goalKey { onboardingGoalKey = goalKey }
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
    public func completeSession(minutes: Int, poseKey: String? = nil, accuracy: Double? = nil) {
        completedMinutes += minutes
        sessions.append(SessionRecord(durationMinutes: minutes, poseKey: poseKey, accuracy: accuracy))

        // Award XP: time practiced plus an accuracy bonus from the AI coach.
        let accuracyBonus = Int((accuracy ?? 0) * 20)
        totalXP += minutes * 10 + accuracyBonus
        lastSessionScore = accuracy != nil ? Int((accuracy ?? 0) * 100) : 0

        updateStreak()
        pulseAnimation.toggle()

        AnalyticsManager.shared.log(event: "session_complete",
                                    parameters: ["minutes": minutes,
                                                 "pose": poseKey ?? "free",
                                                 "accuracy": Int((accuracy ?? 0) * 100)])
        FirebaseManager.shared.saveUserStats(userId: currentUserId,
                                             name: displayName,
                                             minutes: completedMinutes,
                                             streak: streakDays,
                                             xp: totalXP,
                                             level: level)
        Task {
            let end = Date()
            let start = end.addingTimeInterval(TimeInterval(-minutes * 60))
            await HealthKitManager.shared.saveMindfulMinutes(minutes: minutes, startDate: start, endDate: end)
        }
        persist()
        // Practising today removes any pending streak-protection nudge and keeps
        // the habitual reminder time up to date.
        refreshReminders()
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
        totalXP = 0
        lastSessionScore = 0
        onboardingLevelKey = "onb.level.beginner"
        onboardingGoalKey = "onb.goal.flexibility"
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
        var totalXP: Int
        var lastSessionScore: Int
        var onboardingLevelKey: String
        var onboardingGoalKey: String
        var displayName: String?
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
            sessions: sessions,
            totalXP: totalXP,
            lastSessionScore: lastSessionScore,
            onboardingLevelKey: onboardingLevelKey,
            onboardingGoalKey: onboardingGoalKey,
            displayName: displayName
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
        totalXP = snapshot.totalXP
        lastSessionScore = snapshot.lastSessionScore
        onboardingLevelKey = snapshot.onboardingLevelKey
        onboardingGoalKey = snapshot.onboardingGoalKey
        displayName = snapshot.displayName ?? "Yogi"
    }
}
