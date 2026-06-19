import SwiftUI

public struct BreathCoachView: View {
    @State private var selected = YogaLibrary.breathPatterns.first!
    @State private var phase = "Готов?"
    @State private var scale: CGFloat = 0.6
    @State private var running = false

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

            Button(running ? "Сброс" : "Старт дыхания") {
                running ? reset() : runPattern()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func runPattern() {
        running = true
        Task {
            for _ in 0..<selected.rounds {
                await MainActor.run {
                    phase = "Вдох"
                    withAnimation(.easeInOut(duration: selected.inhale)) { scale = 1.0 }
                }
                try? await Task.sleep(nanoseconds: UInt64(selected.inhale * 1_000_000_000))

                await MainActor.run {
                    phase = "Пауза"
                }
                try? await Task.sleep(nanoseconds: UInt64(selected.hold * 1_000_000_000))

                await MainActor.run {
                    phase = "Выдох"
                    withAnimation(.easeInOut(duration: selected.exhale)) { scale = 0.6 }
                }
                try? await Task.sleep(nanoseconds: UInt64(selected.exhale * 1_000_000_000))
            }
            await MainActor.run {
                phase = "Готово"
                running = false
            }
        }
    }

    private func reset() {
        running = false
        phase = "Готов?"
        scale = 0.6
    }
}
