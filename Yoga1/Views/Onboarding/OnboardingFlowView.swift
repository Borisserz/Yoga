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
    @State private var sweepAngle: Double = -90
    @State private var pulseAxis = false

    var body: some View {
        ZStack {
            // Metallic Outer Ring
            Circle()
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.18), .white.opacity(0.02), .mint.opacity(0.15), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 4
                )
                .frame(width: 104, height: 104)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
            
            // Matte Chronograph Dial Face
            Circle()
                .fill(Color.black.opacity(0.45))
                .frame(width: 96, height: 96)
            
            // Tick Marks
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color.white.opacity(i % 3 == 0 ? 0.35 : 0.15))
                    .frame(width: 2, height: i % 3 == 0 ? 8 : 4)
                    .offset(y: -42)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            
            // Sweep Needle
            Rectangle()
                .fill(LinearGradient(colors: [.mint, .teal], startPoint: .top, endPoint: .bottom))
                .frame(width: 3, height: 38)
                .offset(y: -19)
                .rotationEffect(.degrees(sweepAngle))
                .shadow(color: .mint.opacity(0.4), radius: 4)
            
            // Glowing Center Pivot / Axis
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
            // Concentric Expanding Radar Waves
            Circle()
                .stroke(Color.mint.opacity(0.15), lineWidth: 1.5)
                .frame(width: 110, height: 110)
                .scaleEffect(pulseWave ? 1.25 : 0.8)
                .opacity(pulseWave ? 0 : 0.8)
            
            // Outer Counter-Clockwise Dash Circle
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [6, 12]))
                .foregroundStyle(.mint.opacity(0.35))
                .frame(width: 96, height: 96)
                .rotationEffect(.degrees(rotateOuter ? -360 : 0))
            
            // Inner Clockwise Dash Circle
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [4, 8]))
                .foregroundStyle(.teal.opacity(0.25))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotateInner ? 360 : 0))
            
            // Radar Crosshairs
            ForEach(0..<4) { i in
                Rectangle()
                    .fill(Color.mint.opacity(0.2))
                    .frame(width: 1.5, height: 8)
                    .offset(y: -44)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
            
            // Center Glowing Target Icon
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
            // Expanding neon pulse ring
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.red.opacity(0.15))
                .scaleEffect(scale ? 1.35 : 0.8)
                .opacity(scale ? 0 : 1)
            
            // Glowing border orbit
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
            // Glowing soft back-shadow
            Circle()
                .fill(RadialGradient(colors: [.mint.opacity(0.25), .clear], center: .center, startRadius: 0, endRadius: 40))
                .frame(width: 80, height: 80)
                .scaleEffect(shadowScale ? 1.15 : 0.85)
            
            // Floating calendar icon
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
            // Starry Sky Plate
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
            
            // Orbit Track Ring (Golden)
            Circle()
                .stroke(
                    LinearGradient(colors: [.yellow.opacity(0.25), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .frame(width: 72, height: 72)
            
            // Celestial Bodies Group (rotating together)
            ZStack {
                // Sun
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .orange.opacity(0.55), radius: 6)
                    .offset(y: -36)
                
                // Moon
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 6)
                    .offset(y: 36)
            }
            .rotationEffect(.degrees(orbitalRotation))
            
            // Astrolabe Scale Markings
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
            // Background Recess
            Circle()
                .fill(Color.black.opacity(0.35))
                .frame(width: 96, height: 96)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 1.2)
                )
            
            // Mechanical Gear Cog (Rotating behind the hourglass)
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
            
            // Flowing Sand Stream Indicator (Vertical pulsing line)
            VStack(spacing: 0) {
                // Hourglass Glass Vessel and Sand
                ZStack {
                    Image(systemName: "hourglass")
                        .font(.system(size: 42))
                        .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: .mint.opacity(0.35), radius: 8)
                    
                    // Streaming Sand Particles (Micro-pulse)
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
