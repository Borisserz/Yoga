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

                // Frosted card container
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
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 15, y: 10)
                .padding(.horizontal)

                Spacer()

                // Control Button
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
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
        StepScaffold(title: "Your level?") {
            VStack(spacing: 12) {
                ForEach(levels, id: \.self) { level in
                    SelectRow(title: L(level), selected: experienceLevel == level) {
                        experienceLevel = level
                    }
                }
            }
        }
    }

    private var goalStep: some View {
        StepScaffold(title: "Main goal?") {
            VStack(spacing: 12) {
                ForEach(goals, id: \.self) { goal in
                    SelectRow(title: L(goal), selected: mainGoal == goal) {
                        mainGoal = goal
                    }
                }
            }
        }
    }

    private var focusStep: some View {
        StepScaffold(title: "What needs love?", subtitle: "Pick any — or none.") {
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
        StepScaffold(title: "How many days a week?") {
            VStack(spacing: 12) {
                ForEach(targets, id: \.self) { n in
                    SelectRow(title: n == 7 ? L("Every day") : L("%lld days a week", n),
                              selected: weeklyTarget == n) {
                        weeklyTarget = n
                    }
                }
            }
        }
    }

    private var timeStep: some View {
        StepScaffold(title: "When do you practice?") {
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
        StepScaffold(title: "Session length?") {
            VStack(spacing: 12) {
                ForEach(lengths, id: \.self) { mins in
                    SelectRow(title: L("%lld min", mins), selected: sessionLength == mins) {
                        sessionLength = mins
                    }
                }
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

// MARK: - Reusable bits

private struct StepScaffold<Content: View>: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    @ViewBuilder let content: Content

    init(title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 18) {
            Text(title)
                .font(.system(.title2, design: .rounded).bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
            }
            content
        }
    }
}

private struct SelectRow: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
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
