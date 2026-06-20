internal import SwiftUI

/// Full-screen meditation player. Guided meditations walk through timed prompts;
/// open-timer meditations run a calm countdown with interval bells. Both show a
/// slowly breathing orb and log the session on completion.
struct MeditationPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var app

    let meditation: Meditation
    let minutes: Int

    @State private var elapsed: Double = 0
    @State private var isRunning = true
    @State private var pulse = false
    @State private var soundOn = false
    @State private var finished = false
    @State private var logged = false
    @State private var lastSegmentIndex = -1
    @State private var lastBellMinute = 0
    @State private var timer: Timer?

    init(meditation: Meditation, minutes: Int) {
        self.meditation = meditation
        self.minutes = minutes
    }

    private var total: Double {
        meditation.guided ? meditation.scriptSeconds : Double(minutes * 60)
    }

    private var remaining: Double { max(0, total - elapsed) }

    private func segmentIndex(at t: Double) -> Int {
        var acc = 0.0
        for (i, seg) in meditation.segments.enumerated() {
            acc += seg.seconds
            if t < acc { return i }
        }
        return max(0, meditation.segments.count - 1)
    }

    private var currentText: String {
        if meditation.guided, !meditation.segments.isEmpty {
            return meditation.segments[segmentIndex(at: elapsed)].text
        }
        return L("med.timer.prompt")
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: meditation.gradient.map { $0.opacity(0.55) },
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Color.black.opacity(0.45).ignoresSafeArea()

            if finished {
                completionCard.transition(.scale.combined(with: .opacity))
            } else {
                playerContent
            }
        }
        .onAppear {
            pulse = true
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            AudioManager.shared.stop()
        }
    }

    // MARK: - Player

    private var playerContent: some View {
        VStack(spacing: 24) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Text(meditation.title)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                Button {
                    soundOn = AudioManager.shared.toggleAmbientSound()
                    HapticsManager.shared.playLightImpact()
                } label: {
                    Image(systemName: soundOn ? "speaker.wave.3.fill" : "speaker.slash.fill")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }

            Spacer()

            // Glowing breathing orb
            ZStack {
                // Outer glow shadow circle
                Circle()
                    .fill(
                        RadialGradient(colors: meditation.gradient, center: .center,
                                       startRadius: 10, endRadius: 130)
                    )
                    .frame(width: 250, height: 250)
                    .blur(radius: 20)
                    .opacity(pulse ? 0.5 : 0.25)
                    .scaleEffect(pulse ? 1.15 : 0.85)
                    .animation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true), value: pulse)
                
                // Main breathing orb
                Circle()
                    .fill(
                        LinearGradient(colors: meditation.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 230, height: 230)
                    .scaleEffect(pulse ? 1.0 : 0.8)
                    .shadow(color: meditation.gradient.first?.opacity(0.4) ?? .clear, radius: 25)
                    .animation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true), value: pulse)
                
                // Ring tracking the progress
                Circle()
                    .trim(from: 0, to: CGFloat(min(1, elapsed / max(1, total))))
                    .stroke(
                        LinearGradient(colors: [.white, .white.opacity(0.5)], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 260, height: 260)
                    .shadow(color: .white.opacity(0.15), radius: 4)
                
                Text(timeString(remaining))
                    .font(.system(size: 38, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.15), radius: 3)
            }

            Text(currentText)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 28)
                .frame(minHeight: 90)
                .id(currentText)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.6), value: currentText)

            Spacer()

            Button {
                isRunning.toggle()
                HapticsManager.shared.playLightImpact()
            } label: {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundStyle(.black)
                    .frame(width: 72, height: 72)
                    .background(Color.white.opacity(0.95), in: Circle())
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
            }
            .buttonStyle(.tactile)
            .padding(.bottom, 30)
        }
        .padding()
    }

    // MARK: - Completion

    private var completionCard: some View {
        VStack(spacing: 18) {
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(.white)
            Text("Take a moment")
                .font(.title.bold())
                .foregroundStyle(.white)
            Text(L("You meditated for %lld min", max(1, Int((total / 60).rounded()))))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
            if app.streakDays > 0 {
                Text(L("%lld-day streak 🔥", app.streakDays))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
            }
            Button("Done") { dismiss() }
                .font(.headline)
                .padding(.horizontal, 44).padding(.vertical, 14)
                .background(.white.opacity(0.9), in: Capsule())
                .foregroundStyle(.black)
                .padding(.top, 8)
        }
        .padding(32)
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard isRunning, !finished else { return }
            elapsed += 0.1

            if meditation.guided {
                let idx = segmentIndex(at: elapsed)
                if idx != lastSegmentIndex {
                    lastSegmentIndex = idx
                    HapticsManager.shared.playLightImpact()
                }
            } else {
                let minute = Int(elapsed) / 60
                if minute > lastBellMinute {
                    lastBellMinute = minute
                    HapticsManager.shared.playLightImpact()
                }
            }

            if elapsed >= total { finish() }
        }
    }

    private func finish() {
        timer?.invalidate()
        guard !logged else { return }
        logged = true
        HapticsManager.shared.playSuccess()
        let mins = max(1, Int((total / 60).rounded()))
        app.completeSession(minutes: mins)
        if !app.earnedAchievements.contains("achievement.zen") {
            app.unlockAchievement("achievement.zen")
        }
        withAnimation(.spring) { finished = true }
    }

    private func timeString(_ seconds: Double) -> String {
        let s = Int(seconds.rounded())
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}
