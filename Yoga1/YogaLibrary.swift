import SwiftUI

public enum YogaLibrary {
    public static let poses: [YogaPose] = [
        YogaPose(name: "Поза Потока 1", sanskrit: "Vinyasa Variation 1", level: 1, holdSeconds: 20, focus: "Гибкость", mantra: "Я держу ритм", gradient: [.mint, .teal], instructions: ["Встань устойчиво", "Дыши ровно"]),
        YogaPose(name: "Сила Гор 2", sanskrit: "Tadasana", level: 2, holdSeconds: 30, focus: "Сила", mantra: "Я как гора", gradient: [.orange, .pink], instructions: ["Активируй корпус", "Расслабь плечи"]),
        YogaPose(name: "Полет Дракона 3", sanskrit: "Bakasana", level: 3, holdSeconds: 45, focus: "Баланс", mantra: "Я лечу", gradient: [.purple, .blue], instructions: ["Найди точку фокуса", "Тянись макушкой вверх"]),
        YogaPose(name: "Тихий океан 4", sanskrit: "Balasana", level: 1, holdSeconds: 60, focus: "Восстановление", mantra: "Я спокоен", gradient: [.indigo, .cyan], instructions: ["Опусти таз на пятки", "Лоб на коврик"]),
        YogaPose(name: "Огненный шар 5", sanskrit: "Utkatasana", level: 2, holdSeconds: 25, focus: "Мобильность", mantra: "Энергия во мне", gradient: [.red, .purple], instructions: ["Присядь назад", "Руки вверх"])
    ]

    public static let visionIdeas: [String] = [
        "Создай мини-историю «Пробуждение города» из 5 поз.",
        "Создай мини-историю «Тихий океан внутри».",
        "Создай мини-историю «Сила рассвета».",
        "Создай мини-историю «Космический шторм»."
    ]

    public static let breathPatterns: [BreathPattern] = [
        BreathPattern(title: "Квадрат 4-4-4", inhale: 4, hold: 4, exhale: 4, rounds: 6, color: .cyan),
        BreathPattern(title: "Глубокое 5-2-7", inhale: 5, hold: 2, exhale: 7, rounds: 5, color: .mint),
        BreathPattern(title: "Огонь 2-0-2", inhale: 2, hold: 0, exhale: 2, rounds: 14, color: .orange)
    ]

    public static let quests: [ChallengeQuest] = [
        ChallengeQuest(title: "Квест 1: Пик энергии", subtitle: "Собери связку из 4 поз", duration: 11, reward: "Бейдж #1", icon: "flame.fill", palette: [.orange, .pink]),
        ChallengeQuest(title: "Квест 2: Дзен", subtitle: "10 минут чистого дыхания", duration: 10, reward: "Бейдж Воздуха", icon: "wind", palette: [.mint, .teal]),
        ChallengeQuest(title: "Квест 3: Испытание огнем", subtitle: "Сложные позы на 20 минут", duration: 20, reward: "Бейдж Пламени", icon: "bolt.fill", palette: [.purple, .blue])
    ]
}
