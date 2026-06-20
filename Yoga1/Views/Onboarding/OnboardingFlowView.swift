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

    // New profile initialization states
    @State private var nameInput = ""
    @State private var selectedAvatarIndex = 0
    @State private var generatingProgress = 0.0
    @State private var generatingStatusIndex = 0
    @State private var timer: Timer? = nil

    private let levels = ["onb.level.beginner", "onb.level.intermediate", "onb.level.advanced"]
    private let goals = ["onb.goal.flexibility", "onb.goal.strength", "onb.goal.calm"]
    private let focusOptions = ["onb.focus.back", "onb.focus.hips", "onb.focus.shoulders",
                                "onb.focus.stress", "onb.focus.sleep", "onb.focus.balance"]
    private let times = ["onb.time.morning", "onb.time.afternoon", "onb.time.evening"]
    private let lengths = [5, 10, 15, 20]
    private let targets = [2, 3, 5, 7]

    // 0: Welcome, 1: Level, 2: Goal, 3: Focus, 4: Cadence, 5: Time, 6: Length, 7: Profile, 8: Generating, 9: Summary
    private let lastStep = 9

    @State private var animateBackground = false

    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

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

    private func iconForCadence(_ n: Int) -> String {
        switch n {
        case 2: return "leaf.fill"
        case 3: return "bolt.fill"
        case 5: return "flame.fill"
        default: return "sparkles"
        }
    }

    private func titleForCadence(_ n: Int) -> String {
        switch n {
        case 2: return L("Gentle Start")
        case 3: return L("Consistent Flow")
        case 5: return L("Active Practice")
        default: return L("Daily Devotion")
        }
    }

    private func descriptionForCadence(_ n: Int) -> String {
        switch n {
        case 2: return L("Easy entry to build healthy habits")
        case 3: return L("Optimal balance for habit building")
        case 5: return L("Deepen strength and flexibility")
        default: return L("Deep cosmos of daily practice")
        }
    }

    private func iconForLength(_ mins: Int) -> String {
        switch mins {
        case 5: return "wind"
        case 10: return "figure.yoga"
        case 15: return "sparkles"
        default: return "brain.headset"
        }
    }

    private func titleForLength(_ mins: Int) -> String {
        switch mins {
        case 5: return L("Quick Release")
        case 10: return L("Standard Flow")
        case 15: return L("Deep Stretch")
        default: return L("Complete Arc")
        }
    }

    private func descriptionForLength(_ mins: Int) -> String {
        switch mins {
        case 5: return L("Perfect for busy, demanding days")
        case 10: return L("Your daily focus and body refresh")
        case 15: return L("Excellent muscle relief and calm")
        default: return L("Full session from start to finish")
        }
    }

    private func iconForFocus(_ focus: String) -> String {
        switch focus {
        case "onb.focus.back": return "figure.walk"
        case "onb.focus.hips": return "figure.cooldown"
        case "onb.focus.shoulders": return "figure.arms.open"
        case "onb.focus.stress": return "brain"
        case "onb.focus.sleep": return "moon.stars.fill"
        default: return "scalemass.fill"
        }
    }

    private var generatingStatuses: [String] {
        if isRussian {
            return [
                "Анализируем уровень подготовки...",
                "Настраиваем целевые зоны...",
                "Создаем персональные советы ИИ...",
                "Синхронизируем график тренировок...",
                "Настраиваем ментальные цели...",
                "Завершаем создание плана!"
            ]
        } else {
            return [
                "Analyzing experience level...",
                "Targeting core focus areas...",
                "Building tailored AI techniques...",
                "Integrating daily schedules...",
                "Customizing mindfulness goals...",
                "Finalizing your Space of Flow!"
            ]
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
                        case 7: profileStep
                        case 8: generatingStep
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
                if step != 8 {
                    Button {
                        HapticsManager.shared.playLightImpact()
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            if step == 7 {
                                // Save profile details to state/app before generation
                                let finalName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? (isRussian ? "Йог" : "Yogi") : nameInput
                                app.updateProfile(name: finalName, avatarData: nil, avatarPresetIndex: selectedAvatarIndex)
                                
                                step += 1
                                startPlanGeneration()
                            } else if step < lastStep {
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
                        Text(step == lastStep ? (isRussian ? "Начать" : "Begin") : (isRussian ? "Далее" : "Next"))
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
                } else {
                    // Empty bottom padding during loading animation to keep layout stable
                    Color.clear
                        .frame(height: 78)
                        .padding(.bottom, 30)
                }
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
            
            Text(isRussian ? "Добро пожаловать в Yoga Epic" : "Welcome to Yoga Epic")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.85)
            
            Text(isRussian ? "Создадим практику под ваши цели." : "Let's tailor a practice that fits you.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }

    private var levelStep: some View {
        StepScaffold(title: isRussian ? "Ваш уровень?" : "Your level?", headerIcon: AnyView(LevelIndicatorView())) {
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
        StepScaffold(title: isRussian ? "Главная цель?" : "Main goal?", headerIcon: AnyView(GoalIndicatorView())) {
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
        StepScaffold(title: isRussian ? "Что прорабатываем?" : "What needs love?", subtitle: isRussian ? "Выберите любое или пропустите" : "Pick any — or none.", headerIcon: AnyView(FocusIndicatorView())) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(focusOptions, id: \.self) { focus in
                    SelectChip(title: L(focus), icon: iconForFocus(focus), selected: focusAreas.contains(focus)) {
                        if focusAreas.contains(focus) { focusAreas.remove(focus) }
                        else { focusAreas.insert(focus) }
                    }
                }
            }
        }
    }

    private var cadenceStep: some View {
        StepScaffold(title: isRussian ? "Сколько дней в неделю?" : "How many days a week?", headerIcon: AnyView(CadenceIndicatorView())) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                ForEach(targets, id: \.self) { n in
                    let isActive = (weeklyTarget == n)
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                            weeklyTarget = n
                        }
                        HapticsManager.shared.playLightImpact()
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: iconForCadence(n))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(isActive ? Color.black : Color.mint)
                                Spacer()
                                Text("\(n)")
                                    .font(.system(.title3, design: .rounded).bold().monospacedDigit())
                            }
                            
                            Text(titleForCadence(n))
                                .font(.system(size: 13, weight: .bold))
                                .lineLimit(1)
                            
                            Text(descriptionForCadence(n))
                                .font(.system(size: 10))
                                .foregroundStyle(isActive ? Color.black.opacity(0.7) : Color.white.opacity(0.5))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 104)
                        .background(isActive ? AnyShapeStyle(Color.mint) : AnyShapeStyle(Color.white.opacity(0.06)),
                                    in: RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(isActive ? Color.mint.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: isActive ? .mint.opacity(0.35) : .clear, radius: 8, y: 4)
                        .foregroundStyle(isActive ? .black : .white)
                    }
                    .buttonStyle(.tactile)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var timeStep: some View {
        StepScaffold(title: isRussian ? "Время для практик?" : "When do you practice?", headerIcon: AnyView(TimeIndicatorView())) {
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
        StepScaffold(title: isRussian ? "Длительность сессии?" : "Session length?", headerIcon: AnyView(LengthIndicatorView())) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                ForEach(lengths, id: \.self) { mins in
                    let isActive = (sessionLength == mins)
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                            sessionLength = mins
                        }
                        HapticsManager.shared.playLightImpact()
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: iconForLength(mins))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(isActive ? Color.black : Color.mint)
                                Spacer()
                                Text("\(mins)")
                                    .font(.system(.title3, design: .rounded).bold().monospacedDigit())
                            }
                            
                            Text(titleForLength(mins))
                                .font(.system(size: 13, weight: .bold))
                                .lineLimit(1)
                            
                            Text(descriptionForLength(mins))
                                .font(.system(size: 10))
                                .foregroundStyle(isActive ? Color.black.opacity(0.7) : Color.white.opacity(0.5))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 104)
                        .background(isActive ? AnyShapeStyle(Color.mint) : AnyShapeStyle(Color.white.opacity(0.06)),
                                    in: RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(isActive ? Color.mint.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: isActive ? .mint.opacity(0.35) : .clear, radius: 8, y: 4)
                        .foregroundStyle(isActive ? .black : .white)
                    }
                    .buttonStyle(.tactile)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var profileStep: some View {
        StepScaffold(
            title: isRussian ? "Как вас зовут?" : "What should we call you?",
            subtitle: isRussian ? "Это имя увидят другие йоги" : "This name will represent you in the League",
            headerIcon: AnyView(ProfileIndicatorView(avatarIndex: selectedAvatarIndex))
        ) {
            VStack(spacing: 20) {
                // Name textfield
                TextField(isRussian ? "Имя профиля" : "Your name", text: $nameInput)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1.2)
                    )
                    .tint(.mint)
                
                // Avatar Picker Header
                Text(isRussian ? "Выберите аватар" : "Pick an avatar")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                
                // Horizontal list of avatars
                HStack(spacing: 12) {
                    ForEach(avatarPresets) { preset in
                        let isSelected = (selectedAvatarIndex == preset.id)
                        Button {
                            HapticsManager.shared.playLightImpact()
                            selectedAvatarIndex = preset.id
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: preset.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 42, height: 42)
                                    .shadow(color: isSelected ? preset.gradient.first?.opacity(0.4) ?? .clear : .clear, radius: 6)
                                
                                Image(systemName: preset.iconName)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: isSelected ? 2.5 : 0)
                            )
                            .scaleEffect(isSelected ? 1.15 : 1.0)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var generatingStep: some View {
        StepScaffold(
            title: isRussian ? "Создаем ваш план..." : "Generating your plan...",
            subtitle: isRussian ? "Настраиваем умные рекомендации" : "Tailoring custom recommendations",
            headerIcon: AnyView(GeneratingIndicatorView(progress: generatingProgress))
        ) {
            VStack(spacing: 16) {
                // Progress Bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(colors: [.mint, .teal], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 250 * CGFloat(generatingProgress), height: 8)
                        .shadow(color: .mint.opacity(0.4), radius: 4)
                }
                .frame(width: 250)
                
                // Status Logs
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<generatingStatuses.count, id: \.self) { idx in
                        let isDone = (generatingStatusIndex > idx)
                        let isCurrent = (generatingStatusIndex == idx)
                        
                        HStack(spacing: 10) {
                            if isDone {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.system(size: 13, weight: .bold))
                            } else if isCurrent {
                                ProgressView()
                                    .tint(.mint)
                                    .scaleEffect(0.7)
                                    .frame(width: 13, height: 13)
                            } else {
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                    .frame(width: 13, height: 13)
                            }
                            
                            Text(generatingStatuses[idx])
                                .font(.system(size: 11, weight: isCurrent ? .bold : .medium, design: .rounded))
                                .foregroundStyle(isCurrent ? .white : (isDone ? .white.opacity(0.7) : .white.opacity(0.25)))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
            }
            .frame(height: 200)
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
            
            Text(isRussian ? "План готов!" : "Your plan is ready!")
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

    private func startPlanGeneration() {
        generatingProgress = 0.0
        generatingStatusIndex = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { t in
            withAnimation(.easeInOut(duration: 0.4)) {
                generatingProgress += 0.167
                if generatingStatusIndex < 5 {
                    generatingStatusIndex += 1
                    HapticsManager.shared.playLightImpact()
                } else {
                    t.invalidate()
                    generatingProgress = 1.0
                    HapticsManager.shared.playSuccess()
                    
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                        step += 1
                    }
                }
            }
        }
    }
}

// MARK: - Step Indicators

private struct LevelIndicatorView: View {
    @State private var sweepAngle: Double = -90
    @State private var pulseAxis = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.18), .white.opacity(0.02), .mint.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 4
                )
                .frame(width: 104, height: 104)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
            
            Circle()
                .fill(Color.black.opacity(0.45))
                .frame(width: 96, height: 96)
            
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color.white.opacity(i % 3 == 0 ? 0.35 : 0.15))
                    .frame(width: 2, height: i % 3 == 0 ? 8 : 4)
                    .offset(y: -42)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            
            Rectangle()
                .fill(LinearGradient(colors: [.mint, .teal], startPoint: .top, endPoint: .bottom))
                .frame(width: 3, height: 38)
                .offset(y: -19)
                .rotationEffect(.degrees(sweepAngle))
                .shadow(color: .mint.opacity(0.4), radius: 4)
            
            Circle()
                .fill(Color.mint)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                )
                .scaleEffect(pulseAxis ? 1.2 : 0.9)
                .shadow(color: .mint.opacity(0.6), radius: 6)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                sweepAngle = 90
            }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulseAxis = true
            }
        }
    }
}

private struct GoalIndicatorView: View {
    @State private var rotateOuter = false
    @State private var rotateInner = false
    @State private var pulseWave = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.mint.opacity(0.15), lineWidth: 1.5)
                .frame(width: 110, height: 110)
                .scaleEffect(pulseWave ? 1.25 : 0.8)
                .opacity(pulseWave ? 0 : 0.8)
            
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [6, 12]))
                .foregroundStyle(.mint.opacity(0.35))
                .frame(width: 96, height: 96)
                .rotationEffect(.degrees(rotateOuter ? -360 : 0))
            
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [4, 8]))
                .foregroundStyle(.teal.opacity(0.25))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotateInner ? 360 : 0))
            
            ForEach(0..<4) { i in
                Rectangle()
                    .fill(Color.mint.opacity(0.2))
                    .frame(width: 1.5, height: 8)
                    .offset(y: -44)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
            
            Image(systemName: "target")
                .font(.system(size: 40))
                .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .mint.opacity(0.45), radius: 10)
        }
        .onAppear {
            withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
                rotateOuter = true
            }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotateInner = true
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: false)) {
                pulseWave = true
            }
        }
    }
}

private struct FocusIndicatorView: View {
    @State private var scale = false
    @State private var rotate = false

    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.red.opacity(0.15))
                .scaleEffect(scale ? 1.35 : 0.8)
                .opacity(scale ? 0 : 1)
            
            Circle()
                .stroke(
                    LinearGradient(colors: [.red.opacity(0.3), .clear, .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotate ? 360 : 0))

            Image(systemName: "heart.fill")
                .font(.system(size: 46))
                .foregroundStyle(LinearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottom))
                .scaleEffect(scale ? 1.08 : 0.94)
                .shadow(color: .red.opacity(0.4), radius: 12)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                scale = true
            }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotate = true
            }
        }
    }
}

private struct CadenceIndicatorView: View {
    @State private var float = false
    @State private var shadowScale = false

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [.mint.opacity(0.25), .clear], center: .center, startRadius: 0, endRadius: 40))
                .frame(width: 80, height: 80)
                .scaleEffect(shadowScale ? 1.15 : 0.85)
            
            Image(systemName: "calendar")
                .font(.system(size: 44))
                .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .offset(y: float ? -5 : 5)
                .shadow(color: .mint.opacity(0.4), radius: 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                float = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                shadowScale = true
            }
        }
    }
}

private struct TimeIndicatorView: View {
    @State private var orbitalRotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.1, green: 0.1, blue: 0.25), Color(red: 0.05, green: 0.05, blue: 0.12)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 55
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(colors: [.white.opacity(0.12), .white.opacity(0.02)], startPoint: .top, endPoint: .bottom),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
            
            Circle()
                .stroke(
                    LinearGradient(colors: [.yellow.opacity(0.25), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .frame(width: 72, height: 72)
            
            ZStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .orange.opacity(0.55), radius: 6)
                    .offset(y: -36)
                
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 6)
                    .offset(y: 36)
            }
            .rotationEffect(.degrees(orbitalRotation))
            
            ForEach(0..<24) { i in
                Rectangle()
                    .fill(Color.white.opacity(i % 6 == 0 ? 0.25 : 0.08))
                    .frame(width: 1, height: i % 6 == 0 ? 5 : 2.5)
                    .offset(y: -48)
                    .rotationEffect(.degrees(Double(i) * 15))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                orbitalRotation = 360
            }
        }
    }
}

private struct LengthIndicatorView: View {
    @State private var gearRotation: Double = 0
    @State private var sandPulse = false
    @State private var tiltAngle: Double = -10

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.35))
                .frame(width: 96, height: 96)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 1.2)
                )
            
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [3, 9]))
                    .foregroundStyle(.mint.opacity(0.18))
                    .frame(width: 76, height: 76)
                
                ForEach(0..<8) { i in
                    Rectangle()
                        .fill(Color.mint.opacity(0.12))
                        .frame(width: 6, height: 6)
                        .offset(y: -38)
                        .rotationEffect(.degrees(Double(i) * 45))
                }
            }
            .rotationEffect(.degrees(gearRotation))
            
            VStack(spacing: 0) {
                ZStack {
                    Image(systemName: "hourglass")
                        .font(.system(size: 42))
                        .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: .mint.opacity(0.35), radius: 8)
                    
                    Rectangle()
                        .fill(Color.mint.opacity(0.6))
                        .frame(width: 2, height: 18)
                        .opacity(sandPulse ? 0.3 : 0.9)
                        .shadow(color: .mint.opacity(0.5), radius: 2)
                        .offset(y: 1)
                }
                .rotationEffect(.degrees(tiltAngle))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                gearRotation = 360
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                sandPulse = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                tiltAngle = 10
            }
        }
    }
}

private struct ProfileIndicatorView: View {
    let avatarIndex: Int
    @State private var pulseOuter = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.15), .mint.opacity(0.2)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 2
                )
                .frame(width: 104, height: 104)
                .scaleEffect(pulseOuter ? 1.08 : 0.96)
                .opacity(pulseOuter ? 0.3 : 0.7)
            
            let preset = avatarPresets[safe: avatarIndex] ?? avatarPresets[0]
            Circle()
                .fill(LinearGradient(colors: preset.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 88, height: 88)
                .shadow(color: preset.gradient.first?.opacity(0.4) ?? .clear, radius: 12)
            
            Image(systemName: preset.iconName)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulseOuter = true
            }
        }
    }
}

private struct GeneratingIndicatorView: View {
    let progress: Double
    @State private var rotateCog = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.12), .mint.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
                .frame(width: 104, height: 104)
            
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, dash: [8, 16]))
                .foregroundStyle(.mint)
                .frame(width: 90, height: 90)
                .rotationEffect(.degrees(rotateCog ? 360 : 0))
            
            Text(String(format: "%.0f%%", progress * 100))
                .font(.system(size: 20, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(LinearGradient(colors: [.white, .mint], startPoint: .top, endPoint: .bottom))
                .shadow(color: .mint.opacity(0.35), radius: 6)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotateCog = true
            }
        }
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
    let icon: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.bold())
                    .foregroundStyle(selected ? .black : .mint)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
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
