internal import SwiftUI

/// A sheet that renders a shareable achievement card to an image and offers a
/// native `ShareLink` so the user can post it to social apps, Messages, etc.
struct AchievementShareSheet: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    let achievementKey: String
    @State private var rendered: Image?

    init(achievementKey: String) {
        self.achievementKey = achievementKey
    }

    private var card: AchievementCard {
        AchievementCard(
            achievementTitle: L(achievementKey),
            userName: app.displayName,
            level: app.level,
            streak: app.streakDays,
            minutes: app.completedMinutes
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                card
                    .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
                    .padding(.top, 12)

                if let rendered {
                    ShareLink(item: rendered,
                              preview: SharePreview(L("My yoga achievement"), image: rendered)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.mint, in: RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                } else {
                    ProgressView()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Share achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear(perform: renderCard)
        }
    }

    @MainActor
    private func renderCard() {
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            rendered = Image(uiImage: uiImage)
        }
    }
}

// MARK: - The card

struct AchievementCard: View {
    let achievementTitle: String
    let userName: String
    let level: Int
    let streak: Int
    let minutes: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "figure.yoga")
                Text("Yoga Epic")
                    .font(.headline.bold())
                Spacer()
            }
            .foregroundStyle(.white.opacity(0.9))

            Image(systemName: "medal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                .padding(.top, 4)

            VStack(spacing: 6) {
                Text("Achievement unlocked")
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.7))
                Text(achievementTitle)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                Text(userName)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.85))
            }

            HStack(spacing: 14) {
                CardStat(value: "\(level)", label: "Level")
                CardStat(value: "\(streak)", label: "Streak")
                CardStat(value: "\(minutes)", label: "Minutes")
            }
            .padding(.top, 4)

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: 340, height: 420)
        .background(
            LinearGradient(colors: [.purple, .blue, .mint],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

private struct CardStat: View {
    let value: String
    let label: LocalizedStringKey

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
    }
}
