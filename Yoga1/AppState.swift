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

    // MARK: Personalization profile (captured during onboarding)
    /// Focus areas / pain points the user wants to work on (e.g. "onb.focus.back").
    public var focusAreaKeys: [String] = []
    /// Target number of practice days per week.
    public var weeklyTargetDays: Int = 3
    /// Preferred time of day for practice (e.g. "onb.time.morning").
    public var preferredTimeKey: String = "onb.time.morning"
    /// Preferred session length in minutes.
    public var sessionLengthMinutes: Int = 10

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

    /// Distinct days a session was logged in the current calendar week.
    public var sessionsThisWeek: Int {
        let cal = Calendar.current
        guard let week = cal.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        let days = Set(sessions.filter { week.contains($0.date) }.map { cal.startOfDay(for: $0.date) })
        return days.count
    }

    /// 0...1 progress toward this week's practice-day goal.
    public var weeklyGoalProgress: Double {
        weeklyTargetDays > 0 ? min(1, Double(sessionsThisWeek) / Double(weeklyTargetDays)) : 0
    }

    /// Whether a session has already been recorded today.
    public var practicedToday: Bool {
        guard let last = lastSessionDate else { return false }
        return Calendar.current.isDate(last, inSameDayAs: Date())
    }

    /// Days since the last session (nil if the user has never practiced).
    public var daysSinceLastSession: Int? {
        guard let last = lastSessionDate else { return nil }
        let cal = Calendar.current
        return cal.dateComponents([.day], from: cal.startOfDay(for: last),
                                  to: cal.startOfDay(for: Date())).day
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

    public func completeOnboarding(levelKey: String? = nil,
                                   goalKey: String? = nil,
                                   focusAreas: [String]? = nil,
                                   weeklyTarget: Int? = nil,
                                   preferredTime: String? = nil,
                                   sessionLength: Int? = nil) {
        hasCompletedOnboarding = true
        if let levelKey { onboardingLevelKey = levelKey }
        if let goalKey { onboardingGoalKey = goalKey }
        if let focusAreas { focusAreaKeys = focusAreas }
        if let weeklyTarget { weeklyTargetDays = weeklyTarget }
        if let preferredTime { preferredTimeKey = preferredTime }
        if let sessionLength { sessionLengthMinutes = sessionLength }
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
        totalXP = 0
        lastSessionScore = 0
        onboardingLevelKey = "onb.level.beginner"
        onboardingGoalKey = "onb.goal.flexibility"
        focusAreaKeys = []
        weeklyTargetDays = 3
        preferredTimeKey = "onb.time.morning"
        sessionLengthMinutes = 10
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
        var focusAreaKeys: [String]?
        var weeklyTargetDays: Int?
        var preferredTimeKey: String?
        var sessionLengthMinutes: Int?
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
            focusAreaKeys: focusAreaKeys,
            weeklyTargetDays: weeklyTargetDays,
            preferredTimeKey: preferredTimeKey,
            sessionLengthMinutes: sessionLengthMinutes
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
        focusAreaKeys = snapshot.focusAreaKeys ?? []
        weeklyTargetDays = snapshot.weeklyTargetDays ?? 3
        preferredTimeKey = snapshot.preferredTimeKey ?? "onb.time.morning"
        sessionLengthMinutes = snapshot.sessionLengthMinutes ?? 10
    }
}
