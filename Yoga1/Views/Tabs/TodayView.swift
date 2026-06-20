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
                    VStack(spacing: 24) {
                        greeting
                        TodayPlanCard3D(plan: plan, onStart: { showSession = true }, expandedWhy: $showWhy)
                        IntensitySelector3D(selection: $intensityOverride)
                        ProgressHub3D(
                            weeklyDone: app.sessionsThisWeek,
                            weeklyTarget: app.weeklyTargetDays,
                            weeklyProgress: app.weeklyGoalProgress,
                            level: app.level,
                            xpProgress: app.levelProgress,
                            xpInto: app.xpIntoLevel,
                            xpNext: app.xpForNextLevel
                        )
                        BentoStatsCard(minutes: app.completedMinutes, streak: app.streakDays, mood: app.mood)
                        BentoQuickActionsRow()
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
        return HStack(spacing: 14) {
            // Profile avatar with streak indicator
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 46, height: 46)
                    .shadow(color: .mint.opacity(0.35), radius: 8)
                
                Image(systemName: "figure.yoga")
                    .font(.system(size: 20))
                    .foregroundStyle(.black)
            }
            .overlay(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 18, height: 18)
                    Text("\(app.streakDays)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(x: 4, y: 4)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(key))
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(.white)
                Text("Here's your practice for today")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 3D Plan Card

private struct TodayPlanCard3D: View {
    let plan: DailyPlan
    let onStart: () -> Void
    @Binding var expandedWhy: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header: Title & Time Capsule
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L(plan.title))
                        .font(.title2.bold())
                    Text("Today's Practice")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                Label(L("%lld min", plan.totalMinutes), systemImage: "clock")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.white.opacity(0.12), in: Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }

            // Expandable Why Info
            VStack(alignment: .leading, spacing: 8) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        expandedWhy.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.mint)
                        Text("Why this practice?")
                            .font(.caption.bold())
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(expandedWhy ? 90 : 0))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                
                if expandedWhy {
                    Text(L("Tailored to your goal of %@, your focus on %@, and today's energy.",
                           plan.rationaleChips.first ?? "", plan.focusLabel))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )

            // Horizontal Scroll of chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(plan.rationaleChips.enumerated()), id: \.offset) { _, chip in
                        Text(L(chip))
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.black.opacity(0.4), in: Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                }
            }

            // Poses List
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(plan.poses.enumerated()), id: \.element.id) { i, pose in
                    HStack(spacing: 12) {
                        Text("\(i + 1)")
                            .font(.caption.bold().monospacedDigit())
                            .frame(width: 22, height: 22)
                            .background(Color.white.opacity(0.12), in: Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        Text(pose.name)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(L("%lld sec", pose.holdSeconds))
                            .font(.caption.bold().monospacedDigit())
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                if let breath = plan.breath {
                    HStack(spacing: 12) {
                        Image(systemName: "wind")
                            .font(.caption)
                            .frame(width: 22, height: 22)
                            .background(Color.white.opacity(0.12), in: Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        Text(breath.title)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                    }
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )

            // Start Button
            Button(action: onStart) {
                Label("Start practice", systemImage: "play.fill")
                    .font(.headline.bold())
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Capsule()
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(colors: [.white.opacity(0.6), .clear], startPoint: .top, endPoint: .bottom),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.mint.opacity(0.4), radius: 12, y: 4)
            }
            .buttonStyle(.tactile)
        }
        .foregroundStyle(.white)
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .background(
            LinearGradient(colors: plan.gradient.map { $0.opacity(0.15) }, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.24), .white.opacity(0.04), .mint.opacity(0.15), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 10)
        .card3DTilt()
    }
}

// MARK: - 3D Intensity Selector

private struct IntensitySelector3D: View {
    @Binding var selection: PracticeIntensity?
    
    private let options: [PracticeIntensity?] = [nil, PracticeIntensity.restore, PracticeIntensity.balanced, PracticeIntensity.energize]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tune today's energy")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white.opacity(0.8))
            
            // Slider Track
            GeometryReader { geo in
                let trackWidth = geo.size.width
                let itemWidth = trackWidth / CGFloat(options.count)
                let selectedIndex = options.firstIndex(of: selection) ?? 0
                
                ZStack(alignment: .leading) {
                    // Deep Recessed Slot
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.5)
                        )
                    
                    // Sliding 3D Glass Capsule
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.mint)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.5), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .shadow(color: .mint.opacity(0.45), radius: 10, y: 3)
                        .frame(width: itemWidth - 6, height: 42)
                        .offset(x: CGFloat(selectedIndex) * itemWidth + 3)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
                    
                    // Text Labels / Icons Overlay
                    HStack(spacing: 0) {
                        ForEach(0..<options.count, id: \.self) { idx in
                            let opt = options[idx]
                            let isActive = (selection == opt)
                            Button {
                                withAnimation {
                                    selection = opt
                                }
                                HapticsManager.shared.playLightImpact()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: iconFor(opt))
                                        .font(.caption2.bold())
                                    Text(titleFor(opt))
                                        .font(.caption2.weight(.bold))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundStyle(isActive ? Color.black : Color.white.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(height: 48)
        }
    }
    
    private func iconFor(_ intensity: PracticeIntensity?) -> String {
        guard let intensity else { return "wand.and.stars" }
        return intensity.icon
    }
    
    private func titleFor(_ intensity: PracticeIntensity?) -> String {
        guard let intensity else { return L("intensity.auto") }
        return intensity.title
    }
}

// MARK: - 3D Concentric Progress Hub

private struct ProgressHub3D: View {
    let weeklyDone: Int
    let weeklyTarget: Int
    let weeklyProgress: Double
    let level: Int
    let xpProgress: Double
    let xpInto: Int
    let xpNext: Int

    var body: some View {
        HStack(spacing: 20) {
            // Concentric Rings
            ZStack {
                // Background recessed wells
                Circle()
                    .stroke(Color.black.opacity(0.4), lineWidth: 10)
                    .frame(width: 90, height: 90)
                Circle()
                    .stroke(Color.black.opacity(0.4), lineWidth: 10)
                    .frame(width: 66, height: 66)
                
                // Weekly goal progress ring (outer)
                Circle()
                    .trim(from: 0, to: CGFloat(max(0.01, min(weeklyProgress, 1.0))))
                    .stroke(
                        LinearGradient(colors: [.mint, .teal], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                    // Glass highlight overlay line
                    .overlay(
                        Circle()
                            .trim(from: 0, to: CGFloat(max(0.01, min(weeklyProgress, 1.0))))
                            .stroke(Color.white.opacity(0.35), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 93, height: 93)
                            .rotationEffect(.degrees(-90))
                            .blur(radius: 0.5)
                    )
                    .shadow(color: .mint.opacity(0.35), radius: 6)

                // Level progress ring (inner)
                Circle()
                    .trim(from: 0, to: CGFloat(max(0.01, min(xpProgress, 1.0))))
                    .stroke(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 66, height: 66)
                    .rotationEffect(.degrees(-90))
                    // Glass highlight overlay line
                    .overlay(
                        Circle()
                            .trim(from: 0, to: CGFloat(max(0.01, min(xpProgress, 1.0))))
                            .stroke(Color.white.opacity(0.35), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 69, height: 69)
                            .rotationEffect(.degrees(-90))
                            .blur(radius: 0.5)
                    )
                    .shadow(color: .purple.opacity(0.35), radius: 6)
                
                // Center Icon
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(.mint)
            }
            .frame(width: 100, height: 100)
            
            // Info metrics
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Goal")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.6))
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(weeklyDone)")
                            .font(.system(.title3, design: .rounded).bold().monospacedDigit())
                            .foregroundStyle(.mint)
                        Text("/ \(weeklyTarget) days")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Yoga Level \(level)")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.6))
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(xpInto)")
                            .font(.system(.subheadline, design: .rounded).bold().monospacedDigit())
                            .foregroundStyle(.purple)
                        Text("/ \(xpNext) XP")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            Spacer()
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: [.white.opacity(0.03), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.18), .white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 12, y: 8)
    }
}

// MARK: - Bento Stats Card

private struct BentoStatsCard: View {
    let minutes: Int
    let streak: Int
    let mood: String

    var body: some View {
        HStack(spacing: 12) {
            BentoStatPill(title: "Minutes", value: "\(minutes)", icon: "clock.fill", color: .mint)
            BentoStatPill(title: "Streak", value: "\(streak)", icon: "flame.fill", color: .orange)
            BentoStatPill(title: "Mood", value: mood, icon: "heart.fill", color: .pink)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct BentoStatPill: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(.title3, design: .rounded).bold().monospacedDigit())
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }
}

// MARK: - Bento Quick Actions

private struct BentoQuickActionsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            NavigationLink {
                MeditationLibraryView()
            } label: {
                BentoQuickActionCard(title: "Meditate", systemImage: "moon.stars.fill", color: .indigo)
            }
            NavigationLink {
                BreathCoachView()
            } label: {
                BentoQuickActionCard(title: "Breathing", systemImage: "wind", color: .teal)
            }
            NavigationLink {
                ChallengeArenaView()
            } label: {
                BentoQuickActionCard(title: "Quests", systemImage: "flame.fill", color: .orange)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct BentoQuickActionCard: View {
    let title: LocalizedStringKey
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .shadow(color: color.opacity(0.3), radius: 6)
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.14), .white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }
}

// MARK: - 3D Card Parallax Tilt Modifier

private struct Card3DTiltModifier: ViewModifier {
    @State private var dragOffset: CGSize = .zero

    func body(content: Content) -> some View {
        content
            // 3D rotation based on drag offset
            .rotation3DEffect(
                .degrees(Double(dragOffset.width / 12.0)),
                axis: (x: 0.0, y: 1.0, z: 0.0),
                anchor: .center,
                perspective: 0.5
            )
            .rotation3DEffect(
                .degrees(Double(-dragOffset.height / 12.0)),
                axis: (x: 1.0, y: 0.0, z: 0.0),
                anchor: .center,
                perspective: 0.5
            )
            // Specular gloss reflection overlay shifting with drag translation
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.18), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.plusLighter)
                    .offset(x: dragOffset.width * 1.5, y: dragOffset.height * 1.5)
                    .mask(
                        RoundedRectangle(cornerRadius: 28)
                    )
                }
                .allowsHitTesting(false)
            )
            // Touch gesture to track displacement
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let width = value.translation.width
                        let height = value.translation.height
                        dragOffset = CGSize(
                            width: min(max(width, -80), 80),
                            height: min(max(height, -80), 80)
                        )
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                            dragOffset = .zero
                        }
                    }
            )
    }
}

extension View {
    fileprivate func card3DTilt() -> some View {
        self.modifier(Card3DTiltModifier())
    }
}
