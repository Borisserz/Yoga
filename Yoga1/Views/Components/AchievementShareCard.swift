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
            achievementTitle: AchievementDefinition.resolvedTitle(forKey: achievementKey),
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

struct AchievementDefinition: Identifiable, Hashable, Sendable {
    let id: String
    let titleEN: String
    let titleRU: String
    let descEN: String
    let descRU: String
    let icon: String
    let gradient: [Color]
    
    var title: String {
        let isRussian = Locale.current.language.languageCode?.identifier == "ru"
        return isRussian ? titleRU : titleEN
    }
    
    var description: String {
        let isRussian = Locale.current.language.languageCode?.identifier == "ru"
        return isRussian ? descRU : descEN
    }
    
    static func resolvedTitle(forKey key: String) -> String {
        allAchievements.first(where: { $0.id == key })?.title ?? key
    }
    
    static func resolvedDesc(forKey key: String) -> String {
        allAchievements.first(where: { $0.id == key })?.description ?? ""
    }
    
    static let allAchievements: [AchievementDefinition] = [
        AchievementDefinition(
            id: "achievement.first_step",
            titleEN: "First Step",
            titleRU: "Первый шаг",
            descEN: "Complete your first pose practice",
            descRU: "Выполните вашу первую практику позы",
            icon: "figure.yoga",
            gradient: [.indigo, .cyan]
        ),
        AchievementDefinition(
            id: "achievement.streak_7",
            titleEN: "7-Day Streak",
            titleRU: "Серия 7 дней",
            descEN: "Practice for 7 consecutive days",
            descRU: "Занимайтесь 7 дней подряд",
            icon: "flame.fill",
            gradient: [.orange, .pink]
        ),
        AchievementDefinition(
            id: "achievement.streak_30",
            titleEN: "30-Day Streak",
            titleRU: "Серия 30 дней",
            descEN: "Practice for 30 consecutive days",
            descRU: "Занимайтесь 30 дней подряд",
            icon: "bolt.fill",
            gradient: [.purple, .indigo]
        ),
        AchievementDefinition(
            id: "achievement.zen",
            titleEN: "Inner Peace",
            titleRU: "Внутренний покой",
            descEN: "Complete your first meditation session",
            descRU: "Завершите ваш первый сеанс медитации",
            icon: "heart.fill",
            gradient: [.mint, .green]
        ),
        AchievementDefinition(
            id: "achievement.vip",
            titleEN: "VIP Yogi",
            titleRU: "VIP Йог",
            descEN: "Unlock premium yoga access",
            descRU: "Разблокируйте премиум-доступ",
            icon: "crown.fill",
            gradient: [.yellow, .orange]
        ),
        AchievementDefinition(
            id: "achievement.mastery_5",
            titleEN: "Pose Master",
            titleRU: "Мастер Поз",
            descEN: "Practice 5 different yoga poses",
            descRU: "Выполните 5 различных асан",
            icon: "checkmark.seal.fill",
            gradient: [.teal, .blue]
        ),
        AchievementDefinition(
            id: "achievement.breath_guru",
            titleEN: "Pranayama Guru",
            titleRU: "Гуру Дыхания",
            descEN: "Complete a breathing exercise",
            descRU: "Завершите дыхательную практику",
            icon: "wind",
            gradient: [.cyan, .blue]
        ),
        AchievementDefinition(
            id: "achievement.early_yogi",
            titleEN: "Sunrise Yogi",
            titleRU: "Рассветный Йог",
            descEN: "Complete a practice before 9:00 AM",
            descRU: "Завершите практику до 9:00 утра",
            icon: "sunrise.fill",
            gradient: [.orange, .yellow]
        ),
        AchievementDefinition(
            id: "achievement.journal_entry",
            titleEN: "Reflective Mind",
            titleRU: "Осознанность",
            descEN: "Write your first journal entry",
            descRU: "Сделайте первую запись в дневнике",
            icon: "doc.plaintext.fill",
            gradient: [.pink, .purple]
        )
    ]
}
