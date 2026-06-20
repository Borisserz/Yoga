internal import SwiftUI

struct StreakDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    
    // Multi-layered flame animation states
    @State private var flameScaleInner: CGFloat = 0.96
    @State private var flameScaleMiddle: CGFloat = 0.96
    @State private var flameScaleOuter: CGFloat = 0.96
    @State private var flameOffsetMiddle: CGFloat = 0
    @State private var flameOffsetOuter: CGFloat = 0
    @State private var flameRotationMiddle: Double = 0
    @State private var flameRotationOuter: Double = 0
    
    @State private var animateBackground = false

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
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
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
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .padding(.bottom, 4)

                    // Hero Multi-layered Flame View
                    VStack(spacing: 12) {
                        ZStack {
                            // Layer 0: Deep Ambient Pulsing Aura
                            Circle()
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 140, height: 140)
                                .blur(radius: 8)
                                .scaleEffect(flameScaleOuter * 1.05)
                            
                            // Layer 1: Red Flame (Back)
                            Image(systemName: "flame.fill")
                                .font(.system(size: 78))
                                .foregroundStyle(LinearGradient(colors: [.red, .orange.opacity(0.6)], startPoint: .bottom, endPoint: .top))
                                .opacity(0.55)
                                .scaleEffect(flameScaleOuter)
                                .offset(y: flameOffsetOuter)
                                .rotationEffect(.degrees(flameRotationOuter))
                                .blur(radius: 1.0)
                            
                            // Layer 2: Orange Flame (Middle)
                            Image(systemName: "flame.fill")
                                .font(.system(size: 66))
                                .foregroundStyle(LinearGradient(colors: [.orange, .yellow.opacity(0.8)], startPoint: .bottom, endPoint: .top))
                                .opacity(0.85)
                                .scaleEffect(flameScaleMiddle)
                                .offset(y: flameOffsetMiddle)
                                .rotationEffect(.degrees(flameRotationMiddle))
                            
                            // Layer 3: Yellow Flame (Inner Core)
                            Image(systemName: "flame.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(LinearGradient(colors: [.yellow, .white], startPoint: .bottom, endPoint: .top))
                                .scaleEffect(flameScaleInner)
                                .shadow(color: .yellow, radius: 6)
                        }
                        .frame(width: 150, height: 150)
                        
                        Text("\(app.streakDays) Day Streak")
                            .font(.system(.title, design: .rounded).bold())
                            .foregroundStyle(.white)
                            .shadow(color: .orange.opacity(0.2), radius: 6)
                        
                        Text("You're building a beautiful habit!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    // 14-Day Calendar Grid
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last 14 Days")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("Flame signals active practice days")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            Spacer()
                            Image(systemName: "calendar.badge.clock")
                                .font(.title3)
                                .foregroundStyle(.orange)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 16) {
                            ForEach(last14Days, id: \.self) { date in
                                let completed = didPractice(on: date)
                                let isToday = Calendar.current.isDateInToday(date)
                                
                                VStack(spacing: 8) {
                                    Text(dayLetter(for: date))
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.45))
                                    
                                    ZStack {
                                        if completed {
                                            // Glowing Spark
                                            Circle()
                                                .fill(
                                                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                                                )
                                                .frame(width: 38, height: 38)
                                                .shadow(color: .orange.opacity(0.6), radius: 6, y: 2)
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(isToday ? Color.white : Color.clear, lineWidth: 1.5)
                                                )
                                            
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 15))
                                                .foregroundStyle(.white)
                                                .shadow(color: .white.opacity(0.8), radius: 2)
                                        } else {
                                            // Recessed Ember Socket
                                            Circle()
                                                .fill(Color.black.opacity(0.5))
                                                .frame(width: 38, height: 38)
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(
                                                            isToday
                                                            ? AnyShapeStyle(LinearGradient(colors: [.orange, .clear], startPoint: .top, endPoint: .bottom))
                                                            : AnyShapeStyle(Color.white.opacity(0.06)),
                                                            lineWidth: 1.5
                                                        )
                                                )
                                            
                                            Text(dayNumber(for: date))
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white.opacity(0.35))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.15), .white.opacity(0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)

                    // Streak Achievements Milestones (Card Deck)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Milestones")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        MilestoneCard(
                            title: "First Step",
                            description: "Start your first yoga session",
                            unlocked: app.earnedAchievements.contains("achievement.first_step"),
                            icon: "checkmark.circle.fill",
                            color: .mint
                        )
                        .card3DTilt()
                        
                        MilestoneCard(
                            title: "7-Day Streak",
                            description: "Practice 7 days in a row",
                            unlocked: app.streakDays >= 7 || app.earnedAchievements.contains("achievement.streak_7"),
                            icon: "flame.fill",
                            color: .orange
                        )
                        .card3DTilt()
                        
                        MilestoneCard(
                            title: "30-Day Streak",
                            description: "Practice 30 days in a row",
                            unlocked: app.streakDays >= 30 || app.earnedAchievements.contains("achievement.streak_30"),
                            icon: "crown.fill",
                            color: .purple
                        )
                        .card3DTilt()
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.15), .white.opacity(0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                }
                .padding()
            }
        }
        .onAppear {
            animateBackground = true
            
            // Loop flame animation core
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                flameScaleInner = 1.08
                flameOffsetMiddle = -4
            }
            // Loop flame middle
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                flameScaleMiddle = 1.05
                flameRotationMiddle = 5
            }
            // Loop flame outer/ambient
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                flameScaleOuter = 1.03
                flameRotationOuter = -5
                flameOffsetOuter = -2
            }
        }
    }
}

private struct MilestoneCard: View {
    let title: String
    let description: String
    let unlocked: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Badge icon container
            ZStack {
                Circle()
                    .fill(unlocked ? color.opacity(0.15) : Color.white.opacity(0.03))
                    .frame(width: 46, height: 46)
                
                if unlocked {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(color)
                        .shadow(color: color.opacity(0.45), radius: 5)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(unlocked ? .white : .white.opacity(0.55))
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(unlocked ? 0.65 : 0.35))
            }
            
            Spacer()
            
            if unlocked {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .orange.opacity(0.4), radius: 4)
            } else {
                Text("Locked")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.25))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.04), in: Capsule())
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(unlocked ? Color.white.opacity(0.02) : Color.white.opacity(0.005), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    unlocked ? color.opacity(0.15) : Color.white.opacity(0.04),
                    lineWidth: 1.0
                )
        )
        .shadow(color: unlocked ? color.opacity(0.04) : .clear, radius: 6)
    }
}
