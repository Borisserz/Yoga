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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L(plan.title))
                    .font(.title2.bold())
                Spacer()
                Label(L("%lld min", plan.totalMinutes), systemImage: "clock")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(.white.opacity(0.15), in: Capsule())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(plan.rationaleChips.enumerated()), id: \.offset) { _, chip in
                        Text(L(chip))
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(.black.opacity(0.35), in: Capsule())
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(plan.poses.enumerated()), id: \.element.id) { i, pose in
                    HStack(spacing: 12) {
                        Text("\(i + 1)")
                            .font(.caption.bold().monospacedDigit())
                            .frame(width: 22, height: 22)
                            .background(.white.opacity(0.18), in: Circle())
                        Text(pose.name)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text(L("%lld sec", pose.holdSeconds))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                if let breath = plan.breath {
                    HStack(spacing: 12) {
                        Image(systemName: "wind")
                            .font(.caption)
                            .frame(width: 22, height: 22)
                            .background(.white.opacity(0.18), in: Circle())
                        Text(breath.title)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 4)

            Button(action: onStart) {
                Label("Start practice", systemImage: "play.fill")
                    .font(.headline.bold())
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.mint, in: Capsule())
                    .shadow(color: Color.mint.opacity(0.35), radius: 10, y: 5)
            }
            .buttonStyle(.tactile)
        }
        .foregroundStyle(.white)
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
        .background(
            LinearGradient(colors: plan.gradient.map { $0.opacity(0.28) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
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
                .foregroundStyle(.white.opacity(0.75))
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
                    .font(.body)
                Text(title).font(.caption2.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(active ? AnyShapeStyle(Color.mint) : AnyShapeStyle(Color.white.opacity(0.06)),
                        in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(active ? Color.mint.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(active ? .black : .white.opacity(0.85))
        }
        .buttonStyle(.tactile)
    }
}

// MARK: - Why this card

private struct WhyThisCard: View {
    let plan: DailyPlan
    @Binding var expanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    expanded.toggle()
                }
            } label: {
                HStack {
                    Label("Why this practice?", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.mint)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            
            if expanded {
                Text(L("Tailored to your goal of %@, your focus on %@, and today's energy.",
                       plan.rationaleChips.first ?? "", plan.focusLabel))
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Weekly goal

private struct WeeklyGoalCard: View {
    let done: Int
    let target: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.08), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        AngularGradient(colors: [.mint, .teal, .mint], center: .center),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .mint.opacity(0.35), radius: 4)
                Text("\(done)/\(target)")
                    .font(.system(.subheadline, design: .rounded).bold().monospacedDigit())
                    .foregroundStyle(.mint)
            }
            .frame(width: 60, height: 60)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)

            VStack(alignment: .leading, spacing: 4) {
                Text("Weekly goal")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(progress >= 1
                     ? L("Goal reached — beautiful work!")
                     : L("%lld of %lld practice days this week", done, target))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
