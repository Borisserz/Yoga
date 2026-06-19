import SwiftUI

public struct BreathCoachView: View {
    @State private var selected = YogaLibrary.breathPatterns.first!
    @State private var phase = "Готов?"
    @State private var scale: CGFloat = 0.6
    @State private var running = false
    @State private var breathingTask: Task<Void, Never>?

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Text("Дыхательный коуч")
                .font(.largeTitle.bold())
            Picker("Паттерн", selection: $selected) {
                ForEach(YogaLibrary.breathPatterns) { pattern in
                    Text(pattern.title).tag(pattern)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .onChange(of: selected) { _ in
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
                Button(running ? "Сброс" : "Старт дыхания") {
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
                    phase = "Вдох"
                    HapticsManager.shared.playLightImpact()
                    withAnimation(.easeInOut(duration: selected.inhale)) { scale = 1.0 }
                }
                try? await Task.sleep(nanoseconds: UInt64(selected.inhale * 1_000_000_000))

                if Task.isCancelled { break }
                await MainActor.run {
                    phase = "Пауза"
                }
                try? await Task.sleep(nanoseconds: UInt64(selected.hold * 1_000_000_000))

                if Task.isCancelled { break }
                await MainActor.run {
                    phase = "Выдох"
                    HapticsManager.shared.playMediumImpact()
                    withAnimation(.easeInOut(duration: selected.exhale)) { scale = 0.6 }
                }
                try? await Task.sleep(nanoseconds: UInt64(selected.exhale * 1_000_000_000))
            }
            if !Task.isCancelled {
                await MainActor.run {
                    phase = "Готово"
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
            phase = "Готов?"
            scale = 0.6
        }
    }
}
