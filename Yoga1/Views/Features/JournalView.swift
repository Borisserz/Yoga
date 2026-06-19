internal import SwiftUI
import Charts

struct JournalView: View {
    @Environment(AppState.self) private var app
    @State private var text = ""

    init() {}

    private var entryDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = .current
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Weekly activity") {
                    Chart(Array(app.weeklyActivity.enumerated()), id: \.offset) { item in
                        BarMark(
                            x: .value("Day", item.element.label),
                            y: .value("Minutes", item.element.minutes)
                        )
                        .foregroundStyle(Color.mint.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 180)
                    .padding(.vertical)

                    HStack {
                        StatBadge(title: "Total minutes", value: "\(app.completedMinutes)")
                        StatBadge(title: "Streak", value: "\(app.streakDays)")
                    }
                }

                Section("New entry") {
                    VStack(alignment: .trailing) {
                        TextEditor(text: $text)
                            .frame(height: 100)
                            .padding(4)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))

                        Button("Save") {
                            app.addEntry(text)
                            text = ""
                            HapticsManager.shared.playSuccess()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.mint)
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }

                if !app.journalEntries.isEmpty {
                    Section("History") {
                        ForEach(app.journalEntries) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entryDateFormatter.string(from: entry.date))
                                    .font(.caption)
                                    .foregroundStyle(.mint)
                                Text(entry.text)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Progress")
        }
    }
}

private struct StatBadge: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.mint)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
}
