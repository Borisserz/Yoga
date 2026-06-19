internal import SwiftUI

enum YogaLibrary {
    static let poses: [YogaPose] = [
        YogaPose(key: "balasana", sanskrit: "Balasana", level: 1, holdSeconds: 60, gradient: [.indigo, .cyan], category: .restorative),
        YogaPose(key: "bridge", sanskrit: "Setu Bandhasana", level: 1, holdSeconds: 30, gradient: [.indigo, .purple], category: .strength),
        YogaPose(key: "cat_cow", sanskrit: "Marjaryasana-Bitilasana", level: 1, holdSeconds: 30, gradient: [.mint, .green], category: .flexibility),
        YogaPose(key: "cobra", sanskrit: "Bhujangasana", level: 1, holdSeconds: 20, gradient: [.red, .orange], category: .flexibility),
        YogaPose(key: "corpse", sanskrit: "Savasana", level: 1, holdSeconds: 90, gradient: [.indigo, .cyan], category: .restorative),
        YogaPose(key: "downward_dog", sanskrit: "Adho Mukha Svanasana", level: 1, holdSeconds: 40, gradient: [.blue, .mint], category: .flexibility),
        YogaPose(key: "tadasana", sanskrit: "Tadasana", level: 1, holdSeconds: 30, gradient: [.orange, .pink], category: .balance),
        YogaPose(key: "vrksasana", sanskrit: "Vrksasana", level: 1, holdSeconds: 30, gradient: [.green, .yellow], category: .balance),
        YogaPose(key: "warrior_i", sanskrit: "Virabhadrasana I", level: 1, holdSeconds: 25, gradient: [.teal, .blue], category: .strength),
        YogaPose(key: "warrior_ii", sanskrit: "Virabhadrasana II", level: 1, holdSeconds: 20, gradient: [.mint, .teal], category: .strength),
        YogaPose(key: "boat", sanskrit: "Navasana", level: 2, holdSeconds: 20, gradient: [.orange, .yellow], category: .strength),
        YogaPose(key: "plank", sanskrit: "Phalakasana", level: 2, holdSeconds: 30, gradient: [.orange, .red], category: .strength),
        YogaPose(key: "seated_forward_bend", sanskrit: "Paschimottanasana", level: 2, holdSeconds: 40, gradient: [.cyan, .blue], category: .flexibility),
        YogaPose(key: "seated_twist", sanskrit: "Ardha Matsyendrasana", level: 2, holdSeconds: 30, gradient: [.green, .teal], category: .flexibility),
        YogaPose(key: "triangle", sanskrit: "Trikonasana", level: 2, holdSeconds: 30, gradient: [.pink, .orange], category: .flexibility),
        YogaPose(key: "utkatasana", sanskrit: "Utkatasana", level: 2, holdSeconds: 25, gradient: [.red, .purple], category: .strength),
        YogaPose(key: "bakasana", sanskrit: "Bakasana", level: 3, holdSeconds: 15, gradient: [.purple, .blue], category: .balance),
        YogaPose(key: "camel", sanskrit: "Ustrasana", level: 3, holdSeconds: 25, gradient: [.red, .purple], category: .flexibility),
        YogaPose(key: "half_moon", sanskrit: "Ardha Chandrasana", level: 3, holdSeconds: 20, gradient: [.yellow, .orange], category: .balance),
        YogaPose(key: "pigeon", sanskrit: "Eka Pada Rajakapotasana", level: 3, holdSeconds: 40, gradient: [.purple, .pink], category: .flexibility),
    ]

    /// Stable keys used to build the introductory "flow" course.
    static let starterFlow: [String] = ["downward_dog", "warrior_ii", "vrksasana", "balasana"]

    static let visionIdeaKeys: [String] = ["idea.1", "idea.2", "idea.3", "idea.4"]

    static let breathPatterns: [BreathPattern] = [
        BreathPattern(titleKey: "breath.box",  inhale: 4, hold: 4, exhale: 4, rounds: 6,  color: .cyan),
        BreathPattern(titleKey: "breath.deep", inhale: 5, hold: 2, exhale: 7, rounds: 5,  color: .mint),
        BreathPattern(titleKey: "breath.fire", inhale: 2, hold: 0, exhale: 2, rounds: 14, color: .orange)
    ]

    static let quests: [ChallengeQuest] = [
        ChallengeQuest(keyPrefix: "quest.1", duration: 11, icon: "flame.fill", palette: [.orange, .pink]),
        ChallengeQuest(keyPrefix: "quest.2", duration: 10, icon: "wind",       palette: [.mint, .teal]),
        ChallengeQuest(keyPrefix: "quest.3", duration: 20, icon: "bolt.fill",  palette: [.purple, .blue])
    ]

    /// Poses suitable for a given onboarding experience level (1...3).
    static func poses(forLevel level: Int) -> [YogaPose] {
        poses.filter { $0.level <= max(1, level) }
    }

    /// Convenience lookup used to localize a stored pose key for display.
    static func displayName(forKey key: String) -> String {
        poses.first(where: { $0.key == key })?.name ?? key
    }
}
