import Foundation
import UserNotifications

public final class NotificationManager {
    public static let shared = NotificationManager()

    private init() {}

    private let dailyReminderID = "daily_yoga_reminder"
    private let streakProtectionID = "streak_protection"

    /// Evening hour at which the "don't lose your streak" nudge fires.
    private let streakNudgeHour = 20
    private let streakNudgeMinute = 30

    // MARK: - Authorization

    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            if granted {
                // Default daily reminder until habits are known; AppState refines
                // this via `refreshSchedules` once sessions exist.
                self?.scheduleDailyReminder()
            } else if let error = error {
                #if DEBUG
                print("Notification permission error: \(error.localizedDescription)")
                #endif
            }
        }
    }

    // MARK: - Smart scheduling

    /// Reschedules notifications based on the user's habits and streak state:
    /// a daily reminder at the hour the user usually practices, plus an evening
    /// "don't lose your streak" nudge whenever an active streak is still at risk.
    public func refreshSchedules(sessions: [SessionRecord], streakDays: Int, practicedToday: Bool) {
        let hour = habitualHour(from: sessions)
        scheduleDailyReminder(hour: hour, minute: 0)

        if streakDays >= 1 && !practicedToday {
            scheduleStreakProtection(streakDays: streakDays)
        } else {
            cancelStreakProtection()
        }
    }

    /// The hour of day the user practices most often (defaults to 8am).
    func habitualHour(from sessions: [SessionRecord]) -> Int {
        guard !sessions.isEmpty else { return 8 }
        let cal = Calendar.current
        var counts: [Int: Int] = [:]
        // Weight recent behaviour: only consider the last 60 sessions.
        for session in sessions.suffix(60) {
            let h = cal.component(.hour, from: session.date)
            counts[h, default: 0] += 1
        }
        return counts.max { $0.value < $1.value }?.key ?? 8
    }

    public func scheduleDailyReminder(hour: Int = 8, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = L("notif.title")
        content.body = L("notif.body")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderID, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])
        center.add(request) { error in
            #if DEBUG
            if let error = error {
                print("Error scheduling daily notification: \(error.localizedDescription)")
            }
            #endif
        }
    }

    /// Schedules a one-off evening reminder so the user doesn't break a streak.
    private func scheduleStreakProtection(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = L("streak.notif.title")
        content.body = L("streak.notif.body", streakDays)
        content.sound = .default

        let cal = Calendar.current
        let now = Date()
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.hour = streakNudgeHour
        comps.minute = streakNudgeMinute

        var fireDate = cal.date(from: comps) ?? now
        // If the usual nudge time already passed today, nudge again shortly —
        // but never spill into tomorrow (that's the daily reminder's job).
        if fireDate <= now {
            let soon = now.addingTimeInterval(30 * 60)
            fireDate = cal.isDate(soon, inSameDayAs: now) ? soon : now.addingTimeInterval(60)
        }

        let triggerComps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComps, repeats: false)
        let request = UNNotificationRequest(identifier: streakProtectionID, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [streakProtectionID])
        center.add(request) { error in
            #if DEBUG
            if let error = error {
                print("Error scheduling streak notification: \(error.localizedDescription)")
            }
            #endif
        }
    }

    private func cancelStreakProtection() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [streakProtectionID])
    }
}
