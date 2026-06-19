internal import SwiftUI

// MARK: - Category

/// Coarse grouping for the meditation library. `rawValue` is a stable,
/// language-independent key; labels are localized.
enum MeditationCategory: String, CaseIterable, Identifiable, Hashable {
    case morning
    case focus
    case sleep
    case stress
    case anxiety
    case gratitude

    var id: String { rawValue }
    var title: String { L("med.cat.\(rawValue)") }

    var icon: String {
        switch self {
        case .morning:   return "sunrise.fill"
        case .focus:     return "scope"
        case .sleep:     return "moon.zzz.fill"
        case .stress:    return "leaf.fill"
        case .anxiety:   return "heart.fill"
        case .gratitude: return "hands.and.sparkles.fill"
        }
    }

    var tint: Color {
        switch self {
        case .morning:   return .orange
        case .focus:     return .blue
        case .sleep:     return .indigo
        case .stress:    return .mint
        case .anxiety:   return .pink
        case .gratitude: return .purple
        }
    }
}

// MARK: - Segment

/// A timed step in a guided meditation: a localized prompt held for `seconds`.
struct MeditationSegment: Identifiable, Hashable {
    let id = UUID()
    let textKey: String
    let seconds: Double

    init(_ textKey: String, _ seconds: Double) {
        self.textKey = textKey
        self.seconds = seconds
    }

    var text: String { L(textKey) }
}

// MARK: - Meditation

/// A meditation. Guided meditations play through `segments`; open-timer ones
/// let the user pick a length and run a calm timer with interval bells.
struct Meditation: Identifiable, Hashable {
    let id = UUID()
    let key: String
    let category: MeditationCategory
    let gradient: [Color]
    let guided: Bool
    let segments: [MeditationSegment]
    let durationOptions: [Int]   // minutes — used by open-timer meditations

    init(key: String,
                category: MeditationCategory,
                gradient: [Color],
                guided: Bool,
                segments: [MeditationSegment] = [],
                durationOptions: [Int] = [5, 10, 15]) {
        self.key = key
        self.category = category
        self.gradient = gradient
        self.guided = guided
        self.segments = segments
        self.durationOptions = durationOptions
    }

    var title: String { L("med.\(key).title") }
    var subtitle: String { L("med.\(key).subtitle") }

    /// Total length of a guided script, in seconds.
    var scriptSeconds: Double { segments.reduce(0) { $0 + $1.seconds } }

    /// Rounded minutes for a guided meditation (≥1).
    var guidedMinutes: Int { max(1, Int((scriptSeconds / 60).rounded())) }

    /// Default minutes shown on cards.
    var displayMinutes: Int { guided ? guidedMinutes : (durationOptions.first ?? 10) }
}
