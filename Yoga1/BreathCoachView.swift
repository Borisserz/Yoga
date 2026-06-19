internal import SwiftUI

struct BreathCoachView: View {
    @State private var selected: BreathPattern = YogaLibrary.breathPatterns.first
        ?? BreathPattern(titleKey: "breath.box", inhale: 4, hold: 4, exhale: 4, rounds: 6, color: .cyan)
    @State private var phase = L("phase.ready")
    @State private var scale: CGFloat = 0.6
    @State private var running = false
    @State private var breathingTask: Task<Void, Never>?

    init() {}

    var body: some View {
        VStack(spacing: 20) {
            Text("Breathing coach")
                .font(.largeTitle.bold())
            Picker("Pattern", selection: $selected) {
                ForEach(YogaLibrary.breathPatterns) { pattern in
                    Text(pattern.title).tag(pattern)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .onChange(of: selected) { _, _ in
                reset()
            }

            Circle()
                .fill(selected.color.gradient)
                .frame(width: 220 * scale, height: 220 * scale)
                .overlay {
                    Text(phase)
                        .font(.title2.bold())
                }
                .shadow(color: selected.color.opacity(0.6), radius: 24)

            Text("\(Int(selected.inhale)) - \(Int(selected.hold)) - \(Int(selected.exhale))")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.75))

            HStack(spacing: 20) {
                Button(running ? "Reset" : "Start breathing") {
                    running ? reset() : runPattern()
                }
                .buttonStyle(.borderedProminent)

                Button {
                    let isPlaying = AudioManager.shared.toggleAmbientSound()
                    if isPlaying {
                        HapticsManager.shared.playLightImpact()
                    }
                } label: {
                    Image(systemName: "speaker.wave.3.fill")
                        .padding(12)
                        .background(.white.opacity(0.2), in: Circle())
                }
            }
        }
        .padding()
        .navigationTitle("Breathing")
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
                await MainActor.run {
                    phase = L("phase.hold")
                }
                try? await Task.sleep(nanoseconds: UInt64(selected.hold * 1_000_000_000))

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
