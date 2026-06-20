internal import SwiftUI
import Foundation

// MARK: - Pose Category

/// A coarse grouping used to filter poses on the Practice screen. `rawValue` is
/// a stable, language-independent key; the user-facing label is localized.
enum PoseCategory: String, CaseIterable, Identifiable, Hashable {
    case strength
    case flexibility
    case balance
    case restorative

    var id: String { rawValue }

    /// Localized display name, e.g. "Strength" / "Сила".
    var title: String { L("category.\(rawValue)") }

    /// SF Symbol shown on the filter chip.
    var icon: String {
        switch self {
        case .strength:    return "bolt.fill"
        case .flexibility: return "figure.cooldown"
        case .balance:     return "scalemass.fill"
        case .restorative: return "moon.stars.fill"
        }
    }

    /// Accent color for the filter chip.
    var tint: Color {
        switch self {
        case .strength:    return .orange
        case .flexibility: return .mint
        case .balance:     return .purple
        case .restorative: return .indigo
        }
    }
}

// MARK: - Yoga Pose

/// A yoga pose. `key` is a stable, language-independent identifier used both by
/// the AI analyzer factory (`YogaPoseAnalyzer.getAlgorithm(for:)`) and to look
/// up localized content. User-facing text is resolved from the String Catalog.
struct YogaPose: Identifiable, Hashable {
    let id = UUID()
    let key: String
    let sanskrit: String          // Latin transliteration — same in every language
    let level: Int
    let holdSeconds: Int
    let gradient: [Color]
    let stepCount: Int
    let category: PoseCategory

    init(key: String, sanskrit: String, level: Int, holdSeconds: Int,
                gradient: [Color], category: PoseCategory = .flexibility, stepCount: Int = 5) {
        self.key = key
        self.sanskrit = sanskrit
        self.level = level
        self.holdSeconds = holdSeconds
        self.gradient = gradient
        self.category = category
        self.stepCount = stepCount
    }

    var name: String { L("pose.\(key).name") }
    var focus: String { L("pose.\(key).focus") }
    var mantra: String { L("pose.\(key).mantra") }
    var instructions: [String] { (1...stepCount).map { L("pose.\(key).step\($0)") } }
}

// MARK: - Breathing Pattern

struct BreathPattern: Identifiable, Hashable {
    let id = UUID()
    let titleKey: String
    let inhale: Double
    let hold: Double
    let exhale: Double
    let rounds: Int
    let color: Color

    init(titleKey: String, inhale: Double, hold: Double, exhale: Double, rounds: Int, color: Color) {
        self.titleKey = titleKey
        self.inhale = inhale
        self.hold = hold
        self.exhale = exhale
        self.rounds = rounds
        self.color = color
    }

    var title: String { L(titleKey) }
}

// MARK: - Challenge Quest

struct ChallengeQuest: Identifiable, Hashable {
    let id = UUID()
    let keyPrefix: String
    let duration: Int
    let icon: String
    let palette: [Color]

    init(keyPrefix: String, duration: Int, icon: String, palette: [Color]) {
        self.keyPrefix = keyPrefix
        self.duration = duration
        self.icon = icon
        self.palette = palette
    }

    var title: String { L("\(keyPrefix).title") }
    var subtitle: String { L("\(keyPrefix).subtitle") }
    var reward: String { L("\(keyPrefix).reward") }
    var description: String { L("\(keyPrefix).description") }
}

// MARK: - Session Record (persisted history)

struct SessionRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var durationMinutes: Int
    var poseKey: String?
    /// AI accuracy for the session, 0...1, when the camera coach was used.
    var accuracy: Double?

    init(id: UUID = UUID(), date: Date = Date(), durationMinutes: Int,
                poseKey: String? = nil, accuracy: Double? = nil) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.poseKey = poseKey
        self.accuracy = accuracy
    }
}

// MARK: - Journal Entry (persisted)

struct JournalEntry: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var text: String

    init(id: UUID = UUID(), date: Date = Date(), text: String) {
        self.id = id
        self.date = date
        self.text = text
    }
}
