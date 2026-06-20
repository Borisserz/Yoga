internal import SwiftUI
import SwiftData

struct CourseDayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var app

    @Bindable var day: CourseDay
    @State private var breathingPulse = false

    init(day: CourseDay) {
        self.day = day
    }

    var body: some View {
        let pose = YogaLibrary.poses.first { $0.key == day.poseName }
        let palette = pose?.gradient ?? [.mint, .teal]
        
        ZStack {
            // Dark premium background
            Color.black.ignoresSafeArea()
            
            // Soft ambient glow matching pose gradient
            VStack {
                Circle()
                    .fill(LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(y: -100)
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                
                // Pulsing Yoga Figure (simulating breathing wave)
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.08))
                        .frame(width: 200, height: 200)
                        .scaleEffect(breathingPulse ? 1.15 : 0.95)
                        .blur(radius: 5)
                    
                    Circle()
                        .stroke(LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.2), lineWidth: 1.5)
                        .frame(width: 170, height: 170)
                        .scaleEffect(breathingPulse ? 1.1 : 0.98)
                    
                    Image(systemName: "figure.yoga")
                        .font(.system(size: 80))
                        .foregroundStyle(LinearGradient(colors: palette, startPoint: .top, endPoint: .bottom))
                        .shadow(color: palette.first?.opacity(0.4) ?? .clear, radius: 10)
                        .scaleEffect(breathingPulse ? 1.03 : 0.98)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                        breathingPulse = true
                    }
                }
                
                VStack(spacing: 8) {
                    Text(L("Day %lld", day.dayNumber))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(palette.first ?? .mint)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background((palette.first ?? .mint).opacity(0.15), in: Capsule())
                    
                    Text(YogaLibrary.displayName(forKey: day.poseName))
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    if let pose {
                        Text(pose.sanskrit)
                            .font(.system(.body, design: .serif).italic())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.top, 8)
                
                Spacer()
                
                // Details Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TARGET DURATION")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white.opacity(0.4))
                            Label("\(day.durationMinutes) Minutes", systemImage: "clock")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("DIFFICULTY")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white.opacity(0.4))
                            Label(poseDifficulty(pose?.level ?? 1), systemImage: "chart.bar.fill")
                                .font(.subheadline.bold())
                                .foregroundStyle(palette.first ?? .mint)
                        }
                    }
                    
                    if let pose {
                        Divider()
                            .background(Color.white.opacity(0.08))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("FOCUS CATEGORY")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                Text(poseCategoryName(pose.category))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("XP REWARD")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                Text("+\(day.durationMinutes * 15) XP")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                )
                .padding(.horizontal, 24)
                
                Spacer()

                // Bottom Action Layout
                if day.isCompleted {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title2)
                        Text("Day Completed")
                            .font(.headline.bold())
                    }
                    .foregroundStyle(.green)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.12), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.green.opacity(0.3), lineWidth: 1.5))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                } else {
                    Button {
                        completeDay()
                    } label: {
                        Text("Complete Session")
                            .font(.headline.bold())
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: Capsule()
                            )
                            .shadow(color: palette.first?.opacity(0.45) ?? .clear, radius: 10, y: 4)
                    }
                    .buttonStyle(.tactile)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Session Focus")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func completeDay() {
        withAnimation {
            day.isCompleted = true
            try? modelContext.save()
        }

        HapticsManager.shared.playSuccess()

        // Complete session in AppState to award minutes + XP
        app.completeSession(minutes: day.durationMinutes, poseKey: day.poseName, accuracy: nil)

        Task {
            let startDate = Date().addingTimeInterval(Double(-day.durationMinutes * 60))
            await HealthKitManager.shared.saveYogaWorkout(
                durationMinutes: day.durationMinutes,
                calories: Double(day.durationMinutes * 5),
                startDate: startDate,
                endDate: Date()
            )
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }

    private func poseDifficulty(_ level: Int) -> String {
        switch level {
        case 3: return "Advanced"
        case 2: return "Intermediate"
        default: return "Beginner"
        }
    }

    private func poseCategoryName(_ category: PoseCategory) -> String {
        switch category {
        case .strength: return "Strength"
        case .flexibility: return "Flexibility"
        case .balance: return "Balance"
        case .restorative: return "Restorative"
        }
    }
}
