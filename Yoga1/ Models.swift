import SwiftUI
import Foundation

// MARK: - Yoga Pose

/// A yoga pose. `key` is a stable, language-independent identifier used both by
/// the AI analyzer factory (`YogaPoseAnalyzer.getAlgorithm(for:)`) and to look
/// up localized content. User-facing text is resolved from the String Catalog.
public struct YogaPose: Identifiable, Hashable {
    public let id = UUID()
    public let key: String
    public let sanskrit: String          // Latin transliteration — same in every language
    public let level: Int
    public let holdSeconds: Int
    public let gradient: [Color]
    public let stepCount: Int

    public init(key: String, sanskrit: String, level: Int, holdSeconds: Int,
                gradient: [Color], stepCount: Int = 5) {
        self.key = key
        self.sanskrit = sanskrit
        self.level = level
        self.holdSeconds = holdSeconds
        self.gradient = gradient
        self.stepCount = stepCount
    }

    public var name: String { L("pose.\(key).name") }
    public var focus: String { L("pose.\(key).focus") }
    public var mantra: String { L("pose.\(key).mantra") }
    public var instructions: [String] { (1...stepCount).map { L("pose.\(key).step\($0)") } }
}

// MARK: - Breathing Pattern

public struct BreathPattern: Identifiable, Hashable {
    public let id = UUID()
    public let titleKey: String
    public let inhale: Double
    public let hold: Double
    public let exhale: Double
    public let rounds: Int
    public let color: Color

    public init(titleKey: String, inhale: Double, hold: Double, exhale: Double, rounds: Int, color: Color) {
        self.titleKey = titleKey
        self.inhale = inhale
        self.hold = hold
        self.exhale = exhale
        self.rounds = rounds
        self.color = color
    }

    public var title: String { L(titleKey) }
}

// MARK: - Challenge Quest

public struct ChallengeQuest: Identifiable, Hashable {
    public let id = UUID()
    public let keyPrefix: String
    public let duration: Int
    public let icon: String
    public let palette: [Color]

    public init(keyPrefix: String, duration: Int, icon: String, palette: [Color]) {
        self.keyPrefix = keyPrefix
        self.duration = duration
        self.icon = icon
        self.palette = palette
    }

    public var title: String { L("\(keyPrefix).title") }
    public var subtitle: String { L("\(keyPrefix).subtitle") }
    public var reward: String { L("\(keyPrefix).reward") }
}

// MARK: - Session Record (persisted history)

public struct SessionRecord: Identifiable, Codable, Hashable {
    public var id: UUID
    public var date: Date
    public var durationMinutes: Int
    public var poseKey: String?
    /// AI accuracy for the session, 0...1, when the camera coach was used.
    public var accuracy: Double?

    public init(id: UUID = UUID(), date: Date = Date(), durationMinutes: Int,
                poseKey: String? = nil, accuracy: Double? = nil) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.poseKey = poseKey
        self.accuracy = accuracy
    }
}

// MARK: - Journal Entry (persisted)

public struct JournalEntry: Identifiable, Codable, Hashable {
    public var id: UUID
    public var date: Date
    public var text: String

    public init(id: UUID = UUID(), date: Date = Date(), text: String) {
        self.id = id
        self.date = date
        self.text = text
    }
}
