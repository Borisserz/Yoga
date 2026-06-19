import SwiftUI
import Charts

public struct ActivityData: Identifiable {
    public let id = UUID()
    public let day: String
    public let minutes: Int
}

public struct JournalView: View {
    @EnvironmentObject private var state: YogaAppState
    @State private var text = ""
    
    // Mock data for the chart
    let weeklyData: [ActivityData] = [
        ActivityData(day: "Пн", minutes: 15),
        ActivityData(day: "Вт", minutes: 30),
        ActivityData(day: "Ср", minutes: 0),
        ActivityData(day: "Чт", minutes: 45),
        ActivityData(day: "Пт", minutes: 20),
        ActivityData(day: "Сб", minutes: 60),
        ActivityData(day: "Вс", minutes: 25)
    ]

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Активность за неделю") {
                    Chart(weeklyData) { data in
                        BarMark(
                            x: .value("День", data.day),
                            y: .value("Минуты", data.minutes)
                        )
                        .foregroundStyle(Color.mint.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 180)
                    .padding(.vertical)
                }
                
                Section("Новая запись") {
                    VStack(alignment: .trailing) {
                        TextEditor(text: $text)
                            .frame(height: 100)
                            .padding(4)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                        
                        Button("Сохранить") {
                            state.addEntry(text)
                            text = ""
                            HapticsManager.shared.playSuccess()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.mint)
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
                if !state.journalEntries.isEmpty {
                    Section("История") {
                        ForEach(Array(state.journalEntries.enumerated()), id: \.offset) { idx, entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Запись #\(state.journalEntries.count - idx)")
                                    .font(.caption)
                                    .foregroundStyle(.mint)
                                Text(entry)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Дневник роста")
        }
    }
}
