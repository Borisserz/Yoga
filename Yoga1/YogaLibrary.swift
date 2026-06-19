import SwiftUI

public enum YogaLibrary {
    public static let poses: [YogaPose] = [
        YogaPose(key: "warrior_ii",   sanskrit: "Virabhadrasana II",      level: 1, holdSeconds: 20, gradient: [.mint, .teal]),
        YogaPose(key: "tadasana",     sanskrit: "Tadasana",               level: 1, holdSeconds: 30, gradient: [.orange, .pink]),
        YogaPose(key: "bakasana",     sanskrit: "Bakasana",               level: 3, holdSeconds: 15, gradient: [.purple, .blue]),
        YogaPose(key: "balasana",     sanskrit: "Balasana",               level: 1, holdSeconds: 60, gradient: [.indigo, .cyan]),
        YogaPose(key: "utkatasana",   sanskrit: "Utkatasana",             level: 2, holdSeconds: 25, gradient: [.red, .purple]),
        YogaPose(key: "vrksasana",    sanskrit: "Vrksasana",              level: 1, holdSeconds: 30, gradient: [.green, .yellow]),
        YogaPose(key: "downward_dog", sanskrit: "Adho Mukha Svanasana",   level: 1, holdSeconds: 40, gradient: [.blue, .mint])
    ]

    /// Stable keys used to build the introductory "flow" course.
    public static let starterFlow: [String] = ["downward_dog", "warrior_ii", "vrksasana", "balasana"]

    public static let visionIdeaKeys: [String] = ["idea.1", "idea.2", "idea.3", "idea.4"]

    public static let breathPatterns: [BreathPattern] = [
        BreathPattern(titleKey: "breath.box",  inhale: 4, hold: 4, exhale: 4, rounds: 6,  color: .cyan),
        BreathPattern(titleKey: "breath.deep", inhale: 5, hold: 2, exhale: 7, rounds: 5,  color: .mint),
        BreathPattern(titleKey: "breath.fire", inhale: 2, hold: 0, exhale: 2, rounds: 14, color: .orange)
    ]

    public static let quests: [ChallengeQuest] = [
        ChallengeQuest(keyPrefix: "quest.1", duration: 11, icon: "flame.fill", palette: [.orange, .pink]),
        ChallengeQuest(keyPrefix: "quest.2", duration: 10, icon: "wind",       palette: [.mint, .teal]),
        ChallengeQuest(keyPrefix: "quest.3", duration: 20, icon: "bolt.fill",  palette: [.purple, .blue])
    ]

    /// Convenience lookup used to localize a stored pose key for display.
    public static func displayName(forKey key: String) -> String {
        poses.first(where: { $0.key == key })?.name ?? key
    }
}
