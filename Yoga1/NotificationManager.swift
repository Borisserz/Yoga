import Foundation
import UserNotifications

public final class NotificationManager {
    public static let shared = NotificationManager()

    private init() {}

    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            if granted {
                self?.scheduleDailyReminder()
            } else if let error = error {
                #if DEBUG
                print("Notification permission error: \(error.localizedDescription)")
                #endif
            }
        }
    }

    public func scheduleDailyReminder(hour: Int = 8, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = L("notif.title")
        content.body = L("notif.body")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_yoga_reminder", content: content, trigger: trigger)

        center.add(request) { error in
            #if DEBUG
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
            #endif
        }
    }
}
