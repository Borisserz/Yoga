import SwiftUI

public struct OnboardingFlowView: View {
    @Environment(AppState.self) private var app
    @State private var step = 0
    @State private var experienceLevel = "onb.level.beginner"
    @State private var mainGoal = "onb.goal.flexibility"

    private let levels = ["onb.level.beginner", "onb.level.intermediate", "onb.level.advanced"]
    private let goals = ["onb.goal.flexibility", "onb.goal.strength", "onb.goal.calm"]

    public init() {}

    public var body: some View {
        VStack {
            Spacer()

            if step == 0 {
                VStack(spacing: 20) {
                    Image(systemName: "figure.yoga")
                        .font(.system(size: 80))
                        .foregroundStyle(.mint)
                    Text("Welcome to Yoga Epic")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text("Your personal guide to a world of calm and strength.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .transition(.move(edge: .leading))
            } else if step == 1 {
                VStack(spacing: 20) {
                    Text("Your level?")
                        .font(.largeTitle.bold())

                    ForEach(levels, id: \.self) { level in
                        Button {
                            experienceLevel = level
                        } label: {
                            Text(L(level))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(experienceLevel == level ? Color.mint : Color.gray.opacity(0.2))
                                .foregroundStyle(experienceLevel == level ? .black : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                }
                .transition(.move(edge: .trailing))
            } else if step == 2 {
                VStack(spacing: 20) {
                    Text("Main goal?")
                        .font(.largeTitle.bold())

                    ForEach(goals, id: \.self) { goal in
                        Button {
                            mainGoal = goal
                        } label: {
                            Text(L(goal))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(mainGoal == goal ? Color.mint : Color.gray.opacity(0.2))
                                .foregroundStyle(mainGoal == goal ? .black : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                }
                .transition(.move(edge: .trailing))
            } else if step == 3 {
                VStack(spacing: 20) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundStyle(.mint)
                    Text("Your program is ready!")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text(L("Level: %@\nGoal: %@", L(experienceLevel), L(mainGoal)))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .transition(.move(edge: .trailing))
            }

            Spacer()

            Button {
                withAnimation {
                    if step < 3 {
                        step += 1
                    } else {
                        app.completeOnboarding(levelKey: experienceLevel, goalKey: mainGoal)
                    }
                }
            } label: {
                Text(step == 3 ? "Begin" : "Next")
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
}
