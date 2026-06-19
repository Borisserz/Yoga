import SwiftUI

public enum YogaLibrary {
    public static let poses: [YogaPose] = [
        YogaPose(key: "balasana", sanskrit: "Balasana", level: 1, holdSeconds: 60, gradient: [.indigo, .cyan]),
        YogaPose(key: "bridge", sanskrit: "Setu Bandhasana", level: 1, holdSeconds: 30, gradient: [.indigo, .purple]),
        YogaPose(key: "cat_cow", sanskrit: "Marjaryasana-Bitilasana", level: 1, holdSeconds: 30, gradient: [.mint, .green]),
        YogaPose(key: "cobra", sanskrit: "Bhujangasana", level: 1, holdSeconds: 20, gradient: [.red, .orange]),
        YogaPose(key: "corpse", sanskrit: "Savasana", level: 1, holdSeconds: 90, gradient: [.indigo, .cyan]),
        YogaPose(key: "downward_dog", sanskrit: "Adho Mukha Svanasana", level: 1, holdSeconds: 40, gradient: [.blue, .mint]),
        YogaPose(key: "tadasana", sanskrit: "Tadasana", level: 1, holdSeconds: 30, gradient: [.orange, .pink]),
        YogaPose(key: "vrksasana", sanskrit: "Vrksasana", level: 1, holdSeconds: 30, gradient: [.green, .yellow]),
        YogaPose(key: "warrior_i", sanskrit: "Virabhadrasana I", level: 1, holdSeconds: 25, gradient: [.teal, .blue]),
        YogaPose(key: "warrior_ii", sanskrit: "Virabhadrasana II", level: 1, holdSeconds: 20, gradient: [.mint, .teal]),
        YogaPose(key: "boat", sanskrit: "Navasana", level: 2, holdSeconds: 20, gradient: [.orange, .yellow]),
        YogaPose(key: "plank", sanskrit: "Phalakasana", level: 2, holdSeconds: 30, gradient: [.orange, .red]),
        YogaPose(key: "seated_forward_bend", sanskrit: "Paschimottanasana", level: 2, holdSeconds: 40, gradient: [.cyan, .blue]),
        YogaPose(key: "seated_twist", sanskrit: "Ardha Matsyendrasana", level: 2, holdSeconds: 30, gradient: [.green, .teal]),
        YogaPose(key: "triangle", sanskrit: "Trikonasana", level: 2, holdSeconds: 30, gradient: [.pink, .orange]),
        YogaPose(key: "utkatasana", sanskrit: "Utkatasana", level: 2, holdSeconds: 25, gradient: [.red, .purple]),
        YogaPose(key: "bakasana", sanskrit: "Bakasana", level: 3, holdSeconds: 15, gradient: [.purple, .blue]),
        YogaPose(key: "camel", sanskrit: "Ustrasana", level: 3, holdSeconds: 25, gradient: [.red, .purple]),
        YogaPose(key: "half_moon", sanskrit: "Ardha Chandrasana", level: 3, holdSeconds: 20, gradient: [.yellow, .orange]),
        YogaPose(key: "pigeon", sanskrit: "Eka Pada Rajakapotasana", level: 3, holdSeconds: 40, gradient: [.purple, .pink]),
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

    /// Poses suitable for a given onboarding experience level (1...3).
    public static func poses(forLevel level: Int) -> [YogaPose] {
        poses.filter { $0.level <= max(1, level) }
    }

    /// Convenience lookup used to localize a stored pose key for display.
    public static func displayName(forKey key: String) -> String {
        poses.first(where: { $0.key == key })?.name ?? key
    }
}
