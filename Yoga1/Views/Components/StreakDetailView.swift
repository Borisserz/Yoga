internal import SwiftUI

struct StreakDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var pulseFlame = false

    private var last14Days: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<14).reversed().compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: today)
        }
    }

    private func didPractice(on date: Date) -> Bool {
        let cal = Calendar.current
        return app.sessions.contains { cal.isDate($0.date, inSameDayAs: date) }
    }

    private func dayLetter(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = .current
        fmt.dateFormat = "E"
        return String(fmt.string(from: date).prefix(1))
    }

    private func dayNumber(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = .current
        fmt.dateFormat = "d"
        return fmt.string(from: date)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Soft orange background glow
            VStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: 80, y: -100)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Spacer()
                        Button {
                            HapticsManager.shared.playLightImpact()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    .padding(.bottom, 8)

                    // Hero Flame View
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 130, height: 130)
                            
                            Image(systemName: "flame.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                                )
                                .scaleEffect(pulseFlame ? 1.08 : 0.96)
                                .shadow(color: .orange.opacity(0.5), radius: pulseFlame ? 16 : 8)
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                                pulseFlame = true
                            }
                        }
                        
                        Text("\(app.streakDays) Day Streak")
                            .font(.system(.title, design: .rounded).bold())
                            .foregroundStyle(.white)
                        
                        Text("You're building a beautiful habit!")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    // 14-Day Calendar Grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Last 14 Days")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 16) {
                            ForEach(last14Days, id: \.self) { date in
                                let completed = didPractice(on: date)
                                let isToday = Calendar.current.isDateInToday(date)
                                
                                VStack(spacing: 6) {
                                    Text(dayLetter(for: date))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.4))
                                    
                                    ZStack {
                                        Circle()
                                            .fill(completed ? Color.orange : Color.white.opacity(0.05))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(isToday ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1.5)
                                            )
                                        
                                        if completed {
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(.white)
                                        } else {
                                            Text(dayNumber(for: date))
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(.white.opacity(0.6))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                    )

                    // Streak Achievements Milestones
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Milestones")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        MilestoneRow(
                            title: "First Step",
                            description: "Start your first yoga session",
                            unlocked: app.earnedAchievements.contains("achievement.first_step"),
                            icon: "checkmark.circle.fill",
                            color: .mint
                        )
                        
                        MilestoneRow(
                            title: "7-Day Streak",
                            description: "Practice 7 days in a row",
                            unlocked: app.streakDays >= 7 || app.earnedAchievements.contains("achievement.streak_7"),
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        MilestoneRow(
                            title: "30-Day Streak",
                            description: "Practice 30 days in a row",
                            unlocked: app.streakDays >= 30 || app.earnedAchievements.contains("achievement.streak_30"),
                            icon: "crown.fill",
                            color: .purple
                        )
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                    )
                }
                .padding()
            }
        }
    }
}

private struct MilestoneRow: View {
    let title: String
    let description: String
    let unlocked: Bool
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(unlocked ? color.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 42, height: 42)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(unlocked ? color : Color.white.opacity(0.2))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(unlocked ? .white : .white.opacity(0.5))
                Text(description)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(unlocked ? 0.6 : 0.3))
            }
            
            Spacer()
            
            if unlocked {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
            } else {
                Image(systemName: "lock.fill")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.2))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StreakDetailView()
        .environment(AppState())
}
