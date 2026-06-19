import SwiftUI

public struct OnboardingFlowView: View {
    @Environment(AppStateManager.self) private var appState
    @State private var step = 0
    @State private var experienceLevel = "Новичок"
    @State private var mainGoal = "Гибкость"
    
    public init() {}
    
    public var body: some View {
        VStack {
            Spacer()
            
            if step == 0 {
                VStack(spacing: 20) {
                    Image(systemName: "figure.yoga")
                        .font(.system(size: 80))
                        .foregroundStyle(.mint)
                    Text("Добро пожаловать в Yoga Epic")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text("Твой личный проводник в мир спокойствия и силы.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .transition(.move(edge: .leading))
            } else if step == 1 {
                VStack(spacing: 20) {
                    Text("Твой уровень?")
                        .font(.largeTitle.bold())
                    
                    ForEach(["Новичок", "Средний", "Продвинутый"], id: \.self) { level in
                        Button(action: { experienceLevel = level }) {
                            Text(level)
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
                    Text("Главная цель?")
                        .font(.largeTitle.bold())
                    
                    ForEach(["Гибкость", "Сила", "Спокойствие"], id: \.self) { goal in
                        Button(action: { mainGoal = goal }) {
                            Text(goal)
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
                    Text("Твоя программа готова!")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text("Уровень: \(experienceLevel)\nЦель: \(mainGoal)")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .transition(.move(edge: .trailing))
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    if step < 3 {
                        step += 1
                    } else {
                        appState.completeOnboarding()
                    }
                }
            }) {
                Text(step == 3 ? "Начать" : "Далее")
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
