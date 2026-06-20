internal import SwiftUI

/// Runs an adaptive `DailyPlan` as a guided, auto-advancing flow with a hold
/// timer per pose, optional AI camera per pose, and a completion summary that
/// logs the whole session at once.
struct GuidedSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var app

    let plan: DailyPlan

    @State private var index = 0
    @State private var progress: Double = 0
    @State private var isPlaying = true
    @State private var timer: Timer?
    @State private var showAICamera = false
    @State private var finished = false
    @State private var logged = false
    @State private var pulseOrb = false
    @State private var flareRotation: Double = 0
    @State private var pulseStreak = false

    init(plan: DailyPlan) {
        self.plan = plan
    }

    private var current: YogaPose? {
        plan.poses.indices.contains(index) ? plan.poses[index] : nil
    }

    var body: some View {
        ZStack {
            // Dark base background
            Color.black.ignoresSafeArea()

            // Dynamic ambient background glow matching pose gradient
            let currentColors = current?.gradient ?? plan.gradient
            VStack {
                Circle()
                    .fill(LinearGradient(colors: currentColors, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.15))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(y: -80)
                Spacer()
            }
            .ignoresSafeArea()

            if finished {
                completionCard
                    .transition(.scale.combined(with: .opacity))
            } else if let pose = current {
                practiceContent(for: pose)
            }
        }
        .onAppear {
            startTimer()
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseOrb = true
            }
        }
        .onDisappear { timer?.invalidate() }
        .fullScreenCover(isPresented: $showAICamera) {
            if let pose = current {
                AICameraSessionView(poseKey: pose.key)
            }
        }
    }

    // MARK: - Practice UI

    private func practiceContent(for pose: YogaPose) -> some View {
        VStack(spacing: 24) {
            // Header actions
            HStack {
                Button {
                    HapticsManager.shared.playLightImpact()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Text(L("Pose %lld of %lld", index + 1, plan.poses.count))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }

            // Glowing Indicator Line
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                    Capsule()
                        .fill(LinearGradient(colors: pose.gradient, startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(index + 1) / CGFloat(plan.poses.count))
                        .shadow(color: pose.gradient.first?.opacity(0.4) ?? .clear, radius: 4)
                }
            }
            .frame(height: 6)
            .padding(.top, 4)

            Spacer()

            // Concentric Progress Timer Dial
            ZStack {
                // Background outer ring well
                Circle()
                    .stroke(Color.white.opacity(0.04), lineWidth: 12)
                    .frame(width: 230, height: 230)
                
                // Pulsing ambient background glow
                Circle()
                    .fill(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.08))
                    .frame(width: 220, height: 220)
                    .scaleEffect(pulseOrb ? 1.05 : 0.96)
                    .blur(radius: 5)

                // 3D progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        LinearGradient(colors: pose.gradient, startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 230, height: 230)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: pose.gradient.first?.opacity(0.4) ?? .clear, radius: 8)
                
                // Specular glass highlight ring
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(Color.white.opacity(0.35), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 233, height: 233)
                    .rotationEffect(.degrees(-90))
                    .blur(radius: 0.5)
                
                VStack(spacing: 8) {
                    Text(pose.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Text(L("%lld / %lld sec", Int(progress * Double(pose.holdSeconds)), pose.holdSeconds))
                        .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .frame(width: 250, height: 250)

            // Instruction Card
            if let first = pose.instructions.first {
                Text(first)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(3)
                    .padding(18)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.0)
                    )
            }

            Spacer()

            controls
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private var controls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Pause / Resume Button
                Button {
                    isPlaying.toggle()
                    HapticsManager.shared.playLightImpact()
                } label: {
                    Label(isPlaying ? "Pause" : "Resume", systemImage: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.08), in: Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1.0)
                        )
                }
                .buttonStyle(.tactile)
                
                // AI Camera Button
                Button {
                    showAICamera = true
                    HapticsManager.shared.playLightImpact()
                } label: {
                    Label("AI Camera", systemImage: "camera.viewfinder")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.indigo)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.indigo.opacity(0.15), in: Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.indigo.opacity(0.35), lineWidth: 1.0)
                        )
                }
                .buttonStyle(.tactile)
            }

            // Next / Finish Button
            Button {
                advance(counting: true)
            } label: {
                let currentColors = current?.gradient ?? plan.gradient
                Text(index == plan.poses.count - 1 ? "Finish Session" : "Next Pose")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: currentColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Capsule()
                    )
                    .shadow(color: currentColors.first?.opacity(0.4) ?? .clear, radius: 10, y: 4)
            }
            .buttonStyle(.tactile)
        }
    }

    // MARK: - Completion

    private var completionCard: some View {
        ZStack {
            // Rotating ambient sunburst flare
            Image(systemName: "sun.max.fill")
                .font(.system(size: 140))
                .foregroundStyle(plan.gradient.first?.opacity(0.08) ?? Color.mint.opacity(0.08))
                .rotationEffect(.degrees(flareRotation))
                .blur(radius: 4)
                .onAppear {
                    withAnimation(.linear(duration: 15.0).repeatForever(autoreverses: false)) {
                        flareRotation = 360
                    }
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        pulseStreak = true
                    }
                }

            VStack(spacing: 28) {
                // Header badge
                ZStack {
                    Circle()
                        .fill(plan.gradient.first?.opacity(0.15) ?? Color.mint.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: plan.gradient, startPoint: .top, endPoint: .bottom))
                        .shadow(color: plan.gradient.first?.opacity(0.4) ?? .clear, radius: 10)
                }

                VStack(spacing: 6) {
                    Text("Practice Complete")
                        .font(.system(.title, design: .rounded).bold())
                        .foregroundStyle(.white)
                    
                    Text("You've completed your flow. Well done!")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                // Statistics horizontal row
                HStack(spacing: 12) {
                    StatBox(title: "Poses Completed", value: "\(plan.poses.count)", icon: "figure.yoga", tint: plan.gradient.first ?? .mint)
                    StatBox(title: "Time Spent", value: "\(plan.totalMinutes) min", icon: "clock.fill", tint: plan.gradient.last ?? .teal)
                }

                // Streak milestone badge
                if app.streakDays > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text(L("%lld-Day Streak", app.streakDays))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.15), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.orange.opacity(0.35), lineWidth: 1.2))
                    .scaleEffect(pulseStreak ? 1.04 : 0.98)
                }

                // Done Button
                Button {
                    HapticsManager.shared.playLightImpact()
                    dismiss()
                } label: {
                    Text("Complete Flow")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: plan.gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: Capsule()
                        )
                        .shadow(color: plan.gradient.first?.opacity(0.3) ?? .clear, radius: 10, y: 4)
                }
                .buttonStyle(.tactile)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
            )
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Timer / flow

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard isPlaying, !finished, let pose = current else { return }
            withAnimation(.linear(duration: 0.1)) {
                progress += 0.1 / Double(max(1, pose.holdSeconds))
            }
            if progress >= 1 {
                advance(counting: true)
            }
        }
    }

    private func advance(counting: Bool) {
        HapticsManager.shared.playLightImpact()
        if index < plan.poses.count - 1 {
            index += 1
            progress = 0
        } else {
            finish()
        }
    }

    private func finish() {
        timer?.invalidate()
        guard !logged else { return }
        logged = true
        HapticsManager.shared.playSuccess()
        app.completeSession(minutes: plan.totalMinutes, poseKey: plan.poses.first?.key)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) { finished = true }
    }
}

// MARK: - Helper Stat Badge Box

private struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(tint)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.0)
        )
    }
}
