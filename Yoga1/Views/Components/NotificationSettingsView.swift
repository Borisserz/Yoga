internal import SwiftUI

struct NotificationSettingsView: View {
    @Environment(AppState.self) private var app
    @State private var dailyRemindersEnabled = true
    @State private var reminderTime = Date()
    @State private var streakProtectionEnabled = true
    @State private var animateBackground = false

    init() {}

    var body: some View {
        ZStack {
            AnimatedGradientBackground(animate: $animateBackground)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header card
                    VStack(spacing: 8) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.mint)
                        Text("Stay Mindful")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text("Set quiet reminders to keep your practice regular.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 10)

                    // Daily reminder card
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $dailyRemindersEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "clock.fill")
                                    .foregroundStyle(.mint)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Daily Practice Reminder")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text("Nudge yourself when it's time to flow")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                        }
                        .tint(.mint)
                        
                        if dailyRemindersEnabled {
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .tint(.mint)
                            
                            // Guide label
                            let habitualHour = NotificationManager.shared.habitualHour(from: app.sessions)
                            Text(String(format: "Your practice sweet-spot is typically around %02d:00.", habitualHour))
                                .font(.caption2)
                                .italic()
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )

                    // Streak protection card
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $streakProtectionEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Streak Shield")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text("Evening nudge if your streak is at risk")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                        }
                        .tint(.mint)
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )

                    Spacer()

                    // Save Button
                    Button {
                        saveSettings()
                    } label: {
                        Text("Save preferences")
                            .font(.headline.bold())
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.mint, in: Capsule())
                            .shadow(color: Color.mint.opacity(0.3), radius: 8, y: 4)
                    }
                    .buttonStyle(.tactile)
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateBackground = true
            loadCurrentSettings()
        }
    }

    private func loadCurrentSettings() {
        let habitualHour = NotificationManager.shared.habitualHour(from: app.sessions)
        var comps = DateComponents()
        comps.hour = habitualHour
        comps.minute = 0
        reminderTime = Calendar.current.date(from: comps) ?? Date()
    }

    private func saveSettings() {
        HapticsManager.shared.playSuccess()
        NotificationManager.shared.requestAuthorization()
        
        if dailyRemindersEnabled {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            NotificationManager.shared.scheduleDailyReminder(hour: comps.hour ?? 8, minute: comps.minute ?? 0)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_yoga_reminder"])
        }
        
        NotificationManager.shared.refreshSchedules(
            sessions: app.sessions,
            streakDays: app.streakDays,
            practicedToday: app.practicedToday
        )
    }
}
