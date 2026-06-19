internal import SwiftUI

/// The personalized home screen. Surfaces one adaptive "practice for today",
/// lets the user retune its intensity, and tracks the weekly practice goal.
struct TodayView: View {
    @Environment(AppState.self) private var app
    @State private var animateBackground = false
    @State private var intensityOverride: PracticeIntensity?
    @State private var showSession = false
    @State private var showWhy = false

    init() {}

    private var plan: DailyPlan {
        AdaptivePlanEngine.plan(for: app, intensity: intensityOverride)
    }

    var body: some View {
        let plan = self.plan
        return NavigationStack {
            ZStack {
                AnimatedGradientBackground(animate: $animateBackground)
                ScrollView {
                    VStack(spacing: 20) {
                        greeting
                        TodayPlanCard(plan: plan) { showSession = true }
                        IntensitySelector(selection: $intensityOverride)
                        WhyThisCard(plan: plan, expanded: $showWhy)
                        WeeklyGoalCard(done: app.sessionsThisWeek,
                                       target: app.weeklyTargetDays,
                                       progress: app.weeklyGoalProgress)
                        QuickActionsRow()
                        StatsCard(minutes: app.completedMinutes, streak: app.streakDays, mood: app.mood)
                        LevelBanner()
                    }
                    .padding()
                }
            }
            .navigationTitle("Today")
        }
        .onAppear { animateBackground = true }
        .fullScreenCover(isPresented: $showSession) {
            GuidedSessionView(plan: self.plan)
        }
    }

    private var greeting: some View {
        let hour = Calendar.current.component(.hour, from: Date())
        let key = hour < 12 ? "Good morning" : (hour < 18 ? "Good afternoon" : "Good evening")
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(key))
                    .font(.title2.bold())
                Text("Here's your practice for today")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
        }
    }
}

// MARK: - Plan card

private struct TodayPlanCard: View {
    let plan: DailyPlan
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(L(plan.title))
                    .font(.title2.bold())
                Spacer()
                Label(L("%lld min", plan.totalMinutes), systemImage: "clock")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.white.opacity(0.2), in: Capsule())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(plan.rationaleChips.enumerated()), id: \.offset) { _, chip in
                        Text(L(chip))
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(.black.opacity(0.25), in: Capsule())
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(plan.poses.enumerated()), id: \.element.id) { i, pose in
                    HStack(spacing: 10) {
                        Text("\(i + 1)")
                            .font(.caption.bold().monospacedDigit())
                            .frame(width: 22, height: 22)
                            .background(.white.opacity(0.25), in: Circle())
                        Text(pose.name)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text(L("%lld sec", pose.holdSeconds))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                if let breath = plan.breath {
                    HStack(spacing: 10) {
                        Image(systemName: "wind")
                            .frame(width: 22, height: 22)
                            .background(.white.opacity(0.25), in: Circle())
                        Text(breath.title)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                    }
                }
            }

            Button(action: onStart) {
                Label("Start practice", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white.opacity(0.22), in: Capsule())
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: plan.gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 28)
        )
    }
}

// MARK: - Intensity selector

private struct IntensitySelector: View {
    @Binding var selection: PracticeIntensity?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tune today's energy")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
            HStack(spacing: 8) {
                chip(title: L("intensity.auto"), icon: "wand.and.stars", active: selection == nil) {
                    selection = nil
                }
                ForEach(PracticeIntensity.allCases) { intensity in
                    chip(title: intensity.title, icon: intensity.icon, active: selection == intensity) {
                        selection = (selection == intensity) ? nil : intensity
                    }
                }
            }
        }
    }

    private func chip(title: String, icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                Text(title).font(.caption2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(active ? AnyShapeStyle(Color.mint.opacity(0.85)) : AnyShapeStyle(Color.white.opacity(0.08)),
                        in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(active ? .black : .white)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Why this card

private struct WhyThisCard: View {
    let plan: DailyPlan
    @Binding var expanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button { withAnimation { expanded.toggle() } } label: {
                HStack {
                    Label("Why this practice?", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                }
                .foregroundStyle(.white)
            }
            if expanded {
                Text(L("Tailored to your goal of %@, your focus on %@, and today's energy.",
                       plan.rationaleChips.first ?? "", plan.focusLabel))
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Weekly goal

private struct WeeklyGoalCard: View {
    let done: Int
    let target: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(.white.opacity(0.15), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(Color.mint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(done)/\(target)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.mint)
            }
            .frame(width: 64, height: 64)
            .animation(.easeOut(duration: 0.5), value: progress)

            VStack(alignment: .leading, spacing: 4) {
                Text("Weekly goal")
                    .font(.headline)
                Text(progress >= 1
                     ? L("Goal reached — beautiful work!")
                     : L("%lld of %lld practice days this week", done, target))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
