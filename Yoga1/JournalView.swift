import SwiftUI

public struct JournalView: View {
    @EnvironmentObject private var state: YogaAppState
    @State private var text = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextEditor(text: $text)
                    .frame(height: 140)
                    .padding(8)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                Button("Добавить инсайт") {
                    state.addEntry(text)
                    text = ""
                }
                .buttonStyle(.borderedProminent)

                List {
                    ForEach(Array(state.journalEntries.enumerated()), id: \.offset) { idx, entry in
                        VStack(alignment: .leading) {
                            Text("Запись #\(state.journalEntries.count - idx)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(entry)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .padding()
            .navigationTitle("Дневник роста")
        }
    }
}
