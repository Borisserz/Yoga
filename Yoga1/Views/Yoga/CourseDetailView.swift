internal import SwiftUI
import SwiftData

struct CourseDetailView: View {
    let course: YogaCourse

    private var sortedDays: [CourseDay] {
        course.days.sorted { $0.dayNumber < $1.dayNumber }
    }

    init(course: YogaCourse) {
        self.course = course
    }

    var body: some View {
        ZStack {
            // Dark premium background
            Color.black.ignoresSafeArea()
            
            // Soft ambient glow matching course theme
            let palette = paletteFor(course)
            VStack {
                Circle()
                    .fill(LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(y: -120)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 1. Hero Header Panel
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.2))
                                    .frame(width: 52, height: 52)
                                Image(systemName: iconFor(course))
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(LinearGradient(colors: palette, startPoint: .top, endPoint: .bottom))
                            }
                            Spacer()
                            
                            // Difficulty Badge
                            Text(difficultyLabel(course.level))
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(difficultyColor(course.level).opacity(0.15), in: Capsule())
                                .foregroundStyle(difficultyColor(course.level))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(difficultyColor(course.level).opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(course.title)
                                .font(.system(.title, design: .rounded).bold())
                                .foregroundStyle(.white)
                            
                            Text(course.desc)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                                .lineSpacing(4)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        // Statistics Row
                        let completed = course.days.filter { $0.isCompleted }.count
                        let total = course.days.count
                        let progress = total > 0 ? Double(completed) / Double(total) : 0.0
                        
                        HStack(spacing: 20) {
                            // Completion Rate Circle
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.06), lineWidth: 5)
                                    .frame(width: 44, height: 44)
                                Circle()
                                    .trim(from: 0, to: CGFloat(progress))
                                    .stroke(LinearGradient(colors: palette, startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                    .frame(width: 44, height: 44)
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: palette.first?.opacity(0.4) ?? .clear, radius: 4)
                                
                                Text(String(format: "%.0f%%", progress * 100))
                                    .font(.system(size: 9, weight: .bold).monospacedDigit())
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("COMPLETED")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                Text("\(completed) of \(total) Days")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.03))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.15), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .padding(.horizontal)
                    
                    // 2. Day-by-Day List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Program Days")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(sortedDays) { day in
                                let isUnlocked = checkUnlocked(day: day)
                                
                                if isUnlocked {
                                    NavigationLink(destination: CourseDayDetailView(day: day)) {
                                        DayCard(day: day, isUnlocked: true, palette: palette)
                                    }
                                    .buttonStyle(.tactile)
                                } else {
                                    DayCard(day: day, isUnlocked: false, palette: palette)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Program Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func checkUnlocked(day: CourseDay) -> Bool {
        if day.dayNumber == 1 { return true }
        if day.isCompleted { return true }
        if let previousDay = sortedDays.first(where: { $0.dayNumber == day.dayNumber - 1 }) {
            return previousDay.isCompleted
        }
        return false
    }

    private func paletteFor(_ course: YogaCourse) -> [Color] {
        if course.title.contains("Flexibility") {
            return [.orange, .pink]
        } else if course.title.contains("Strength") {
            return [.red, .purple]
        } else if course.title.contains("Calm") {
            return [.indigo, .cyan]
        } else {
            return [.mint, .teal]
        }
    }

    private func iconFor(_ course: YogaCourse) -> String {
        if course.title.contains("Flexibility") {
            return "figure.stretch"
        } else if course.title.contains("Strength") {
            return "bolt.heart.fill"
        } else if course.title.contains("Calm") {
            return "heart.fill"
        } else {
            return "sparkles"
        }
    }

    private func difficultyLabel(_ level: Int) -> String {
        switch level {
        case 3: return "ADVANCED"
        case 2: return "INTERMEDIATE"
        default: return "BEGINNER"
        }
    }

    private func difficultyColor(_ level: Int) -> Color {
        switch level {
        case 3: return .red
        case 2: return .orange
        default: return .mint
        }
    }
}

// MARK: - Day Card Component

private struct DayCard: View {
    let day: CourseDay
    let isUnlocked: Bool
    let palette: [Color]

    var body: some View {
        HStack(spacing: 16) {
            // Day Number Indicator
            ZStack {
                Circle()
                    .fill(isUnlocked ? palette.first?.opacity(0.15) ?? Color.white.opacity(0.04) : Color.white.opacity(0.02))
                    .frame(width: 38, height: 38)
                Text("\(day.dayNumber)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(YogaLibrary.displayName(forKey: day.poseName))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.4))
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                    Text(L("%lld min", day.durationMinutes))
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(isUnlocked ? .white.opacity(0.5) : .white.opacity(0.2))
            }
            
            Spacer()
            
            // Completion Status / Action Arrow
            if day.isCompleted {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.green)
                }
            } else if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.2))
            } else {
                ZStack {
                    Circle()
                        .fill(palette.first?.opacity(0.2) ?? Color.white.opacity(0.08))
                        .frame(width: 28, height: 28)
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(palette.first ?? .mint)
                        .offset(x: 1)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isUnlocked ? Color.white.opacity(0.03) : Color.white.opacity(0.01))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(
                    isUnlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.02),
                    lineWidth: 1.0
                )
        )
    }
}
