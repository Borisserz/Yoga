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

    init() {}

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: Double(step), total: Double(lastStep))
                .tint(.mint)
                .padding(.top)

            Spacer()

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
            .frame(maxWidth: .infinity)

            Spacer()

            Button {
                withAnimation {
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
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mint)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 40)
        }
        .padding()
    }

    // MARK: - Steps

    private var welcome: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.yoga")
                .font(.system(size: 80))
                .foregroundStyle(.mint)
            Text("Welcome to Yoga Epic")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Let's tailor a practice that fits you.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var levelStep: some View {
        StepScaffold(title: "Your level?") {
            ForEach(levels, id: \.self) { level in
                SelectRow(title: L(level), selected: experienceLevel == level) {
                    experienceLevel = level
                }
            }
        }
    }

    private var goalStep: some View {
        StepScaffold(title: "Main goal?") {
            ForEach(goals, id: \.self) { goal in
                SelectRow(title: L(goal), selected: mainGoal == goal) {
                    mainGoal = goal
                }
            }
        }
    }

    private var focusStep: some View {
        StepScaffold(title: "What needs love?", subtitle: "Pick any — or none.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
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
            ForEach(targets, id: \.self) { n in
                SelectRow(title: n == 7 ? L("Every day") : L("%lld days a week", n),
                          selected: weeklyTarget == n) {
                    weeklyTarget = n
                }
            }
        }
    }

    private var timeStep: some View {
        StepScaffold(title: "When do you practice?") {
            ForEach(times, id: \.self) { time in
                SelectRow(title: L(time), selected: preferredTime == time) {
                    preferredTime = time
                }
            }
        }
    }

    private var lengthStep: some View {
        StepScaffold(title: "Session length?") {
            ForEach(lengths, id: \.self) { mins in
                SelectRow(title: L("%lld min", mins), selected: sessionLength == mins) {
                    sessionLength = mins
                }
            }
        }
    }

    private var summary: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundStyle(.mint)
            Text("Your plan is ready!")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            VStack(spacing: 6) {
                summaryLine("target", L(mainGoal))
                summaryLine("figure.strengthtraining.traditional", L(experienceLevel))
                if !focusAreas.isEmpty {
                    summaryLine("heart.fill", focusAreas.map { L($0) }.joined(separator: ", "))
                }
                summaryLine("calendar", weeklyTarget == 7 ? L("Every day") : L("%lld days a week", weeklyTarget))
                summaryLine("clock", L("%lld min", sessionLength))
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
    }

    private func summaryLine(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(.mint).frame(width: 22)
            Text(text)
            Spacer()
        }
        .padding(.horizontal, 24)
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
        VStack(spacing: 16) {
            Text(title).font(.largeTitle.bold()).multilineTextAlignment(.center)
            if let subtitle {
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
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
                Text(title).font(.headline)
                Spacer()
                if selected { Image(systemName: "checkmark") }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selected ? Color.mint : Color.gray.opacity(0.2))
            .foregroundStyle(selected ? .black : .white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

private struct SelectChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selected ? Color.mint : Color.gray.opacity(0.2))
                .foregroundStyle(selected ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}
