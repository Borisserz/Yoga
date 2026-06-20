internal import SwiftUI

struct BreathCoachView: View {
    @Environment(AppState.self) private var app
    @State private var selected: BreathPattern = YogaLibrary.breathPatterns.first
        ?? BreathPattern(titleKey: "breath.box", inhale: 4, hold: 4, exhale: 4, rounds: 6, color: .cyan)
    @State private var phase = L("phase.ready")
    @State private var scale: CGFloat = 0.6
    @State private var running = false
    @State private var breathingTask: Task<Void, Never>?
    @State private var animateBackground = false

    init() {}

    var body: some View {
        ZStack {
            // Dark premium background
            Color.black.ignoresSafeArea()

            // Dynamic ambient background glow matching chosen pattern color
            VStack {
                Circle()
                    .fill(selected.color.opacity(0.15))
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .offset(y: -80)
                Spacer()
            }
            .ignoresSafeArea()

            AnimatedGradientBackground(animate: $animateBackground)

            ScrollView {
                VStack(spacing: 26) {
                    // Title and Header
                    VStack(spacing: 6) {
                        Text("Breathing Coach")
                            .font(.system(.title2, design: .rounded).bold())
                            .foregroundStyle(.white)
                        Text("Tune your breath to align your energy and relax")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 12)

                    // Pattern Selector Cards
                    HStack(spacing: 12) {
                        ForEach(YogaLibrary.breathPatterns) { pattern in
                            let isActive = (selected == pattern)
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    selected = pattern
                                }
                                HapticsManager.shared.playLightImpact()
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "wind")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(isActive ? .black : pattern.color)
                                    Text(pattern.title)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(isActive ? .black : .white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    Text("\(Int(pattern.inhale))-\(Int(pattern.hold))-\(Int(pattern.exhale))")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(isActive ? .black.opacity(0.6) : .white.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    isActive ?
                                    AnyShapeStyle(pattern.color) :
                                    AnyShapeStyle(Color.white.opacity(0.04))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(
                                            isActive ? Color.white.opacity(0.2) : Color.white.opacity(0.08),
                                            lineWidth: 1.0
                                        )
                                )
                                .shadow(color: isActive ? pattern.color.opacity(0.3) : .clear, radius: 8, y: 3)
                            }
                            .buttonStyle(.tactile)
                            .disabled(running)
                        }
                    }
                    .padding(.horizontal)

                    // Interactive Breathing Sphere
                    ZStack {
                        // Ambient outer glow
                        Circle()
                            .fill(selected.color.opacity(0.06))
                            .frame(width: 250 * scale, height: 250 * scale)
                            .blur(radius: 8)
                        
                        // Thin glowing stroke orbit
                        Circle()
                            .stroke(
                                LinearGradient(colors: [selected.color, selected.color.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                            .frame(width: 210 * scale, height: 210 * scale)
                        
                        // Main sphere body
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [selected.color.opacity(0.25), selected.color.opacity(0.04)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200 * scale, height: 200 * scale)
                            .overlay(
                                Text(phase)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 4)
                            )
                            .shadow(color: selected.color.opacity(0.35), radius: 18)
                    }
                    .frame(height: 280)

                    // Summary statistics info card
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("INHALE / HOLD / EXHALE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                Text("\(Int(selected.inhale))s / \(Int(selected.hold))s / \(Int(selected.exhale))s")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("TOTAL CYCLES")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                Text("\(selected.rounds) Rounds")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(selected.color)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.2)
                    )
                    .padding(.horizontal)

                    // Bottom Action Row
                    HStack(spacing: 16) {
                        Button {
                            running ? reset() : runPattern()
                        } label: {
                            Label(running ? "Reset Session" : "Start Breathing", systemImage: running ? "arrow.counterclockwise" : "play.fill")
                                .font(.headline.bold())
                                .foregroundStyle(running ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    running ?
                                    AnyView(Color.white.opacity(0.08)) :
                                    AnyView(LinearGradient(colors: [selected.color, selected.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(running ? Color.white.opacity(0.12) : Color.clear, lineWidth: 1)
                                )
                                .shadow(color: running ? .clear : selected.color.opacity(0.3), radius: 8, y: 3)
                        }
                        .buttonStyle(.tactile)
                        
                        Button {
                            let isPlaying = AudioManager.shared.toggleAmbientSound()
                            if isPlaying {
                                HapticsManager.shared.playLightImpact()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "speaker.wave.3.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.tactile)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Breathing")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateBackground = true
        }
        .onDisappear {
            reset()
            AudioManager.shared.stop()
        }
    }

    private func runPattern() {
        breathingTask?.cancel()
        running = true
        breathingTask = Task {
            for _ in 0..<selected.rounds {
                if Task.isCancelled { break }
                await MainActor.run {
                    phase = L("phase.inhale")
                    HapticsManager.shared.playLightImpact()
                    withAnimation(.easeInOut(duration: selected.inhale)) { scale = 1.0 }
                }
                try? await Task.sleep(nanoseconds: UInt64(selected.inhale * 1_000_000_000))

                if Task.isCancelled { break }
                if selected.hold > 0 {
                    await MainActor.run {
                        phase = L("phase.hold")
                    }
                    try? await Task.sleep(nanoseconds: UInt64(selected.hold * 1_000_000_000))
                }

                if Task.isCancelled { break }
                await MainActor.run {
                    phase = L("phase.exhale")
                    HapticsManager.shared.playMediumImpact()
                    withAnimation(.easeInOut(duration: selected.exhale)) { scale = 0.6 }
                }
                try? await Task.sleep(nanoseconds: UInt64(selected.exhale * 1_000_000_000))
            }
            if !Task.isCancelled {
                await MainActor.run {
                    phase = L("phase.done")
                    HapticsManager.shared.playSuccess()
                    app.unlockAchievement("achievement.breath_guru")
                    running = false
                }
            }
        }
    }

    private func reset() {
        breathingTask?.cancel()
        breathingTask = nil
        running = false
        withAnimation(.easeOut(duration: 0.5)) {
            phase = L("phase.ready")
            scale = 0.6
        }
    }
}
