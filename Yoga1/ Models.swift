import SwiftUI
import Combine // Добавили явный импорт библиотеки для @Published
import Foundation

public struct YogaPose: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let sanskrit: String
    public let level: Int
    public let holdSeconds: Int
    public let focus: String
    public let mantra: String
    public let gradient: [Color]
    public let instructions: [String]
}

public struct BreathPattern: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let inhale: Double
    public let hold: Double
    public let exhale: Double
    public let rounds: Int
    public let color: Color
}

public struct ChallengeQuest: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let duration: Int
    public let reward: String
    public let icon: String
    public let palette: [Color]
}

public final class YogaAppState: ObservableObject {
    @Published public var selectedTab: Int = 0
    @Published public var activePose: YogaPose?
    @Published public var completedMinutes: Int = 0
    @Published public var streakDays: Int = 1
    @Published public var mood: String = "Спокойно"
    @Published public var journalEntries: [String] = []
    @Published public var pulseAnimation = false

    public init() {}

    public func completeSession(minutes: Int) {
        completedMinutes += minutes
        streakDays += 1
        pulseAnimation.toggle()
    }

    public func addEntry(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        journalEntries.insert(text, at: 0)
    }
}
