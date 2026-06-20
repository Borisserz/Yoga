internal import SwiftUI

struct OnboardingFlowView: View {
    @Environment(AppState.self) private var app
    @State private var step = 0

    @State private var experienceLevel = "onb.level.beginner"
    @State private var mainGoal = "onb.goal.flexibility"
    @State private var focusAreas: Set<String> = []
    @State private var weeklyTarget = 3
    @State private var preferredTime = "onb.time.morning"
    @State private var sessionLength = 10

    private let levels = ["onb.level.beginner", "onb.level.intermediate", "onb.level.advanced"]
    private let goals = ["onb.goal.flexibility", "onb.goal.strength", "onb.goal.calm"]
    private let focusOptions = ["onb.focus.back", "onb.focus.hips", "onb.focus.shoulders",
                                "onb.focus.stress", "onb.focus.sleep", "onb.focus.balance"]
    private let times = ["onb.time.morning", "onb.time.afternoon", "onb.time.evening"]
    private let lengths = [5, 10, 15, 20]
    private let targets = [2, 3, 5, 7]

    private let lastStep = 7

    @State private var animateBackground = false

    init() {}

    private func iconForLevel(_ level: String) -> String {
        switch level {
        case "onb.level.beginner": return "leaf.fill"
        case "onb.level.intermediate": return "bolt.fill"
        default: return "flame.fill"
        }
    }

    private func iconForGoal(_ goal: String) -> String {
        switch goal {
        case "onb.goal.flexibility": return "water.waves"
        case "onb.goal.strength": return "figure.strengthtraining.traditional"
        default: return "brain.headset"
        }
    }

    var body: some View {
        ZStack {
            AnimatedGradientBackground(animate: $animateBackground)
            
            VStack(spacing: 20) {
                // Top Progress tracker
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(LinearGradient(colors: [.mint, .teal], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(step) / CGFloat(lastStep))
                            .shadow(color: .mint.opacity(0.3), radius: 4)
                    }
                }
                .frame(height: 6)
                .padding(.top, 20)
                .padding(.horizontal)

                Spacer()

                // Frosted card container with Glassmorphism 2.0 & double shadows
                VStack {
                    Group {
                        switch step {
                        case 0: welcome
                        case 1: levelStep
                        case 2: goalStep
                        case 3: focusStep
                        case 4: cadenceStep
                        case 5: timeStep
                        case 6: lengthStep
                        default: summary
                        }
                    }
                    .id(step)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.92)),
                        removal: .move(edge: .leading).combined(with: .opacity).combined(with: .scale(scale: 0.92))
                    ))
                }
                .padding(26)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.ultraThinMaterial)
                )
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(LinearGradient(colors: [.white.opacity(0.03), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.22), .white.opacity(0.02), .mint.opacity(0.15), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 12)
                .shadow(color: .mint.opacity(0.06), radius: 30, x: 0, y: -10)
                .padding(.horizontal)

                Spacer()

                // Control Button
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                        if step < lastStep {
                            step += 1
                        } else {
                            app.completeOnboarding(
                                levelKey: experienceLevel,
                                goalKey: mainGoal,
                                focusAreas: Array(focusAreas),
                                weeklyTarget: weeklyTarget,
                                preferredTime: preferredTime,
                                sessionLength: sessionLength
                            )
                        }
                    }
                } label: {
                    Text(step == lastStep ? "Begin" : "Next")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mint, in: Capsule())
                        .foregroundStyle(.black)
                        .shadow(color: Color.mint.opacity(0.3), radius: 10, y: 5)
                }
                .buttonStyle(.tactile)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            animateBackground = true
        }
    }

    // MARK: - Steps

    private var welcome: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [.mint.opacity(0.25), .clear], center: .center, startRadius: 0, endRadius: 80))
                    .frame(width: 160, height: 160)
                    .blur(radius: 10)
                
                Circle()
                    .stroke(LinearGradient(colors: [.mint, .teal], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .opacity(0.3)
                
                Image(systemName: "figure.yoga")
                    .font(.system(size: 70))
                    .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .mint.opacity(0.4), radius: 15)
            }
            .padding(.bottom, 10)
            
            Text("Welcome to Yoga Epic")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Text("Let's tailor a practice that fits you.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }

    private var levelStep: some View {
        StepScaffold(title: "Your level?", headerIcon: AnyView(LevelIndicatorView())) {
            VStack(spacing: 12) {
                ForEach(levels, id: \.self) { level in
                    SelectRow(title: L(level), icon: iconForLevel(level), selected: experienceLevel == level) {
                        experienceLevel = level
                    }
                }
            }
        }
    }

    private var goalStep: some View {
        StepScaffold(title: "Main goal?", headerIcon: AnyView(GoalIndicatorView())) {
            VStack(spacing: 12) {
                ForEach(goals, id: \.self) { goal in
                    SelectRow(title: L(goal), icon: iconForGoal(goal), selected: mainGoal == goal) {
                        mainGoal = goal
                    }
                }
            }
        }
    }

    private var focusStep: some View {
        StepScaffold(title: "What needs love?", subtitle: "Pick any — or none.", headerIcon: AnyView(FocusIndicatorView())) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(focusOptions, id: \.self) { focus in
                    SelectChip(title: L(focus), selected: focusAreas.contains(focus)) {
                        if focusAreas.contains(focus) { focusAreas.remove(focus) }
                        else { focusAreas.insert(focus) }
                    }
                }
            }
        }
    }

    private var cadenceStep: some View {
        StepScaffold(title: "How many days a week?", headerIcon: AnyView(CadenceIndicatorView())) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(targets, id: \.self) { n in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                weeklyTarget = n
                            }
                            HapticsManager.shared.playLightImpact()
                        } label: {
                            VStack(spacing: 8) {
                                Text("\(n)")
                                    .font(.system(.title2, design: .rounded).bold().monospacedDigit())
                                Text(n == 7 ? L("Every day") : L("days"))
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            .frame(width: 80, height: 80)
                            .background(weeklyTarget == n ? AnyShapeStyle(Color.mint) : AnyShapeStyle(Color.white.opacity(0.06)),
                                        in: RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(weeklyTarget == n ? Color.mint.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                            )
                            .shadow(color: weeklyTarget == n ? .mint.opacity(0.35) : .clear, radius: 8, y: 4)
                            .foregroundStyle(weeklyTarget == n ? .black : .white)
                        }
                        .buttonStyle(.tactile)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
    }

    private var timeStep: some View {
        StepScaffold(title: "When do you practice?", headerIcon: AnyView(TimeIndicatorView())) {
            VStack(spacing: 12) {
                ForEach(times, id: \.self) { time in
                    SelectRow(title: L(time), selected: preferredTime == time) {
                        preferredTime = time
                    }
                }
            }
        }
    }

    private var lengthStep: some View {
        StepScaffold(title: "Session length?", headerIcon: AnyView(LengthIndicatorView())) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(lengths, id: \.self) { mins in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                sessionLength = mins
                            }
                            HapticsManager.shared.playLightImpact()
                        } label: {
                            VStack(spacing: 8) {
                                Text("\(mins)")
                                    .font(.system(.title2, design: .rounded).bold().monospacedDigit())
                                Text("min")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            .frame(width: 80, height: 80)
                            .background(sessionLength == mins ? AnyShapeStyle(Color.mint) : AnyShapeStyle(Color.white.opacity(0.06)),
                                        in: RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(sessionLength == mins ? Color.mint.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                            )
                            .shadow(color: sessionLength == mins ? .mint.opacity(0.35) : .clear, radius: 8, y: 4)
                            .foregroundStyle(sessionLength == mins ? .black : .white)
                        }
                        .buttonStyle(.tactile)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
        }
    }

    private var summary: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [.mint.opacity(0.25), .clear], center: .center, startRadius: 0, endRadius: 60))
                    .frame(width: 120, height: 120)
                    .blur(radius: 8)
                Image(systemName: "sparkles")
                    .font(.system(size: 64))
                    .foregroundStyle(LinearGradient(colors: [.yellow, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .mint.opacity(0.4), radius: 15)
            }
            
            Text("Your plan is ready!")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 10) {
                summaryLine("target", L(mainGoal))
                summaryLine("figure.strengthtraining.traditional", L(experienceLevel))
                if !focusAreas.isEmpty {
                    summaryLine("heart.fill", focusAreas.map { L($0) }.joined(separator: ", "))
                }
                summaryLine("calendar", weeklyTarget == 7 ? L("Every day") : L("%lld days a week", weeklyTarget))
                summaryLine("clock", L("%lld min", sessionLength))
            }
        }
    }

    private func summaryLine(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.mint)
                .frame(width: 24)
            Text(text)
                .font(.subheadline.bold())
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Step Indicators

private struct LevelIndicatorView: View {
    @State private var pulse = false
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [.mint.opacity(0.2), .clear], center: .center, startRadius: 0, endRadius: 50))
                .frame(width: 100, height: 100)
                .scaleEffect(pulse ? 1.15 : 0.85)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulse)
            
            Image(systemName: "gauge.with.needle.fill")
                .font(.system(size: 48))
                .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .mint.opacity(0.4), radius: 10)
        }
        .onAppear { pulse = true }
    }
}

private struct GoalIndicatorView: View {
    @State private var rotate = false
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 6]))
                .foregroundStyle(.mint.opacity(0.4))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .animation(.linear(duration: 12).repeatForever(autoreverses: false), value: rotate)
            
            Image(systemName: "target")
                .font(.system(size: 46))
                .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .mint.opacity(0.4), radius: 10)
        }
        .onAppear { rotate = true }
    }
}

private struct FocusIndicatorView: View {
    @State private var pulse = false
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundStyle(LinearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottom))
                .scaleEffect(pulse ? 1.12 : 0.9)
                .shadow(color: .pink.opacity(0.4), radius: 12)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
        }
        .onAppear { pulse = true }
    }
}

private struct CadenceIndicatorView: View {
    @State private var float = false
    var body: some View {
        ZStack {
            Circle()
                .fill(.mint.opacity(0.12))
                .frame(width: 80, height: 80)
            
            Image(systemName: "calendar")
                .font(.system(size: 44))
                .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .offset(y: float ? -4 : 4)
                .shadow(color: .mint.opacity(0.35), radius: 8)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: float)
        }
        .onAppear { float = true }
    }
}

private struct TimeIndicatorView: View {
    @State private var rotate = false
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                .frame(width: 84, height: 84)
            
            Image(systemName: "sun.max.fill")
                .font(.system(size: 32))
                .foregroundStyle(.orange)
                .offset(y: -30)
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .shadow(color: .orange.opacity(0.4), radius: 6)
            
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 26))
                .foregroundStyle(.purple)
                .offset(y: 30)
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .shadow(color: .purple.opacity(0.4), radius: 6)
        }
        .onAppear {
            withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
                rotate = true
            }
        }
    }
}

private struct LengthIndicatorView: View {
    @State private var tilt = false
    var body: some View {
        ZStack {
            Circle()
                .fill(.mint.opacity(0.1))
                .frame(width: 80, height: 80)
            
            Image(systemName: "hourglass")
                .font(.system(size: 42))
                .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .rotationEffect(.degrees(tilt ? 15 : -15))
                .shadow(color: .mint.opacity(0.35), radius: 8)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: tilt)
        }
        .onAppear { tilt = true }
    }
}

// MARK: - Reusable bits

private struct StepScaffold<Content: View>: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    var headerIcon: AnyView? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 18) {
            if let headerIcon {
                headerIcon
                    .padding(.bottom, 6)
            }
            Text(title)
                .font(.system(.title2, design: .rounded).bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            content
        }
    }
}

private struct SelectRow: View {
    let title: String
    var icon: String? = nil
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(selected ? .black : .mint)
                        .scaleEffect(selected ? 1.15 : 1.0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.5), value: selected)
                }
                
                Text(title)
                    .font(.headline.bold())
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(selected ? AnyShapeStyle(Color.mint) : AnyShapeStyle(Color.white.opacity(0.06)),
                        in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(selected ? Color.mint.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: selected ? .mint.opacity(0.35) : .clear, radius: 8, y: 4)
            .foregroundStyle(selected ? .black : .white)
        }
        .buttonStyle(.tactile)
    }
}

private struct SelectChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selected ? AnyShapeStyle(Color.mint) : AnyShapeStyle(Color.white.opacity(0.06)),
                            in: RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(selected ? Color.mint.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: selected ? .mint.opacity(0.35) : .clear, radius: 8, y: 4)
                .foregroundStyle(selected ? .black : .white)
        }
        .buttonStyle(.tactile)
    }
}
