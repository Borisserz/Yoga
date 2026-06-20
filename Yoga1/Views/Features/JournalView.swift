internal import SwiftUI
internal import Charts

struct JournalView: View {
    @Environment(AppState.self) private var app
    @State private var text = ""
    @State private var animateBackground = false

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
            ZStack {
                AnimatedGradientBackground(animate: $animateBackground)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Activity Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Weekly Activity")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                            
                            Chart(Array(app.weeklyActivity.enumerated()), id: \.offset) { item in
                                BarMark(
                                    x: .value("Day", item.element.label),
                                    y: .value("Minutes", item.element.minutes)
                                )
                                .foregroundStyle(LinearGradient(colors: [.mint, .teal], startPoint: .bottom, endPoint: .top))
                                .cornerRadius(6)
                            }
                            .frame(height: 160)
                            .padding(.vertical, 4)

                            HStack(spacing: 12) {
                                StatBadge(title: "Total minutes", value: "\(app.completedMinutes)")
                                StatBadge(title: "Streak", value: "\(app.streakDays)")
                            }
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // New entry card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reflect on your practice")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                            
                            TextEditor(text: $text)
                                .scrollContentBackground(.hidden)
                                .frame(height: 100)
                                .padding(10)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                )
                                .foregroundStyle(.white)

                            HStack {
                                Spacer()
                                Button("Save reflections") {
                                    app.addEntry(text)
                                    text = ""
                                    HapticsManager.shared.playSuccess()
                                }
                                .font(.subheadline.bold())
                                .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white.opacity(0.3) : Color.black)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 12)
                                .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white.opacity(0.08) : Color.mint, in: Capsule())
                                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .buttonStyle(.tactile)
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // History Timeline
                        if !app.journalEntries.isEmpty {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Journal History")
                                    .font(.headline.bold())
                                    .foregroundStyle(.white)
                                    .padding(.bottom, 4)
                                
                                ForEach(app.journalEntries) { entry in
                                    HStack(alignment: .top, spacing: 16) {
                                        VStack(spacing: 0) {
                                            Circle()
                                                .fill(Color.mint)
                                                .frame(width: 10, height: 10)
                                            Rectangle()
                                                .fill(Color.white.opacity(0.12))
                                                .frame(width: 2)
                                        }
                                        .padding(.top, 6)
                                        
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(entryDateFormatter.string(from: entry.date))
                                                .font(.caption2.weight(.bold))
                                                .foregroundStyle(.mint)
                                            Text(entry.text)
                                                .font(.body)
                                                .foregroundStyle(.white.opacity(0.9))
                                                .fixedSize(horizontal: false, vertical: true)
                                                .multilineTextAlignment(.leading)
                                        }
                                        .padding(14)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.04))
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .onAppear { animateBackground = true }
        }
    }
}

private struct StatBadge: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(.title2, design: .rounded).bold().monospacedDigit())
                .foregroundStyle(.mint)
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
