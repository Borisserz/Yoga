internal import SwiftUI
import Foundation

// MARK: - Intensity

/// How demanding today's session should feel. Chosen automatically from the
/// user's habits, but overridable on the Today screen.
enum PracticeIntensity: String, CaseIterable, Identifiable, Hashable {
    case restore
    case balanced
    case energize

    var id: String { rawValue }
    var title: String { L("intensity.\(rawValue)") }

    var icon: String {
        switch self {
        case .restore:  return "moon.stars.fill"
        case .balanced: return "circle.lefthalf.filled"
        case .energize: return "bolt.fill"
        }
    }
}

// MARK: - Daily plan

/// A ready-to-practice session tailored to the user for a given day.
struct DailyPlan {
    let title: String
    let focusLabel: String
    let poses: [YogaPose]
    let breath: BreathPattern?
    let totalMinutes: Int
    let rationaleChips: [String]
    let isEaseBack: Bool
    let intensity: PracticeIntensity
    let gradient: [Color]
}

// MARK: - Engine

/// Builds the adaptive "Today" plan. Pure, deterministic for a given day so the
/// recommendation is stable within the day but rotates for variety day to day.
enum AdaptivePlanEngine {

    /// Maps a focus area / pain point to poses that address it.
    static let focusMap: [String: [String]] = [
        "onb.focus.back":      ["cat_cow", "cobra", "bridge", "seated_twist"],
        "onb.focus.hips":      ["pigeon", "half_moon", "vrksasana"],
        "onb.focus.shoulders": ["downward_dog", "camel", "cobra"],
        "onb.focus.stress":    ["balasana", "corpse", "seated_forward_bend"],
        "onb.focus.sleep":     ["balasana", "corpse", "seated_forward_bend", "bridge"],
        "onb.focus.balance":   ["vrksasana", "half_moon", "tadasana"]
    ]

    // MARK: Public entry point

    static func plan(for app: AppState,
                            intensity override: PracticeIntensity? = nil,
                            date: Date = Date()) -> DailyPlan {
        let baseLevel = level(for: app.onboardingLevelKey)
        let intensity = override ?? recommendedIntensity(for: app)
        let isEaseBack = intensity == .restore && (app.daysSinceLastSession ?? 99) >= 2

        // Restore tones the level down; energize keeps it but favours stronger poses.
        let effectiveLevel = intensity == .restore ? min(baseLevel, 2) : baseLevel
        let available = YogaLibrary.poses(forLevel: effectiveLevel)
        let byKey = Dictionary(uniqueKeysWithValues: available.map { ($0.key, $0) })

        let count = max(3, min(8, Int((Double(app.sessionLengthMinutes) / 3.0).rounded())))

        // 1) Personalized focus-area poses come first.
        var orderedKeys: [String] = []
        for focus in app.focusAreaKeys {
            for key in focusMap[focus] ?? [] where byKey[key] != nil {
                if !orderedKeys.contains(key) { orderedKeys.append(key) }
            }
        }

        // 2) Goal / intensity emphasis.
        for key in emphasisKeys(goal: app.onboardingGoalKey, intensity: intensity) where byKey[key] != nil {
            if !orderedKeys.contains(key) { orderedKeys.append(key) }
        }

        // 3) Fill the remainder from the rest of the pool, rotated by day for variety.
        var seed = SeededGenerator(seed: daySeed(date: date, salt: app.onboardingGoalKey))
        var remainder = available.map { $0.key }.filter { !orderedKeys.contains($0) }
        remainder.shuffle(using: &seed)
        orderedKeys.append(contentsOf: remainder)

        var chosen = Array(orderedKeys.prefix(count)).compactMap { byKey[$0] }

        // 4) Shape the arc: a calming pose closes the session.
        chosen = arrange(chosen)

        let total = max(app.sessionLengthMinutes, count * 2)
        let breath = breathPattern(for: intensity, goal: app.onboardingGoalKey)

        return DailyPlan(
            title: title(isEaseBack: isEaseBack, intensity: intensity, goal: app.onboardingGoalKey),
            focusLabel: focusLabel(for: app),
            poses: chosen,
            breath: breath,
            totalMinutes: total,
            rationaleChips: rationale(for: app, intensity: intensity, minutes: total),
            isEaseBack: isEaseBack,
            intensity: intensity,
            gradient: chosen.first?.gradient ?? [.mint, .teal]
        )
    }

    // MARK: Adaptive intensity

    /// Picks intensity from recent behaviour: ease back after a gap, push when
    /// recent AI form scores are strong, otherwise stay balanced.
    static func recommendedIntensity(for app: AppState) -> PracticeIntensity {
        if let gap = app.daysSinceLastSession, gap >= 2, !app.sessions.isEmpty {
            return .restore
        }
        let recent = app.sessions.suffix(3).compactMap { $0.accuracy }
        if !recent.isEmpty {
            let avg = recent.reduce(0, +) / Double(recent.count)
            if avg >= 0.8 { return .energize }
        }
        return .balanced
    }

    // MARK: Helpers

    static func level(for key: String) -> Int {
        switch key {
        case "onb.level.advanced": return 3
        case "onb.level.intermediate": return 2
        default: return 1
        }
    }

    private static func emphasisKeys(goal: String, intensity: PracticeIntensity) -> [String] {
        switch intensity {
        case .restore:
            return ["balasana", "corpse", "cat_cow", "seated_forward_bend", "bridge", "cobra"]
        case .energize:
            return ["plank", "boat", "utkatasana", "warrior_i", "warrior_ii", "half_moon", "bakasana"]
        case .balanced:
            switch goal {
            case "onb.goal.strength":
                return ["plank", "boat", "utkatasana", "warrior_i", "warrior_ii", "half_moon"]
            case "onb.goal.calm":
                return ["balasana", "corpse", "cat_cow", "bridge", "seated_forward_bend", "cobra"]
            default: // flexibility
                return ["downward_dog", "seated_forward_bend", "triangle", "pigeon", "cobra", "seated_twist", "camel"]
            }
        }
    }

    /// Restorative poses used to close a session on a calm note.
    static let restorativeKeys: Set<String> = ["balasana", "corpse"]

    /// Moves restorative poses to the end so the session winds down.
    private static func arrange(_ poses: [YogaPose]) -> [YogaPose] {
        let active = poses.filter { !restorativeKeys.contains($0.key) }
        let calm = poses.filter { restorativeKeys.contains($0.key) }
        return active + calm
    }

    private static func breathPattern(for intensity: PracticeIntensity, goal: String) -> BreathPattern? {
        let key: String
        switch intensity {
        case .restore:  key = "breath.deep"
        case .energize: key = "breath.fire"
        case .balanced: key = goal == "onb.goal.calm" ? "breath.deep" : "breath.box"
        }
        return YogaLibrary.breathPatterns.first { $0.titleKey == key }
    }

    private static func title(isEaseBack: Bool, intensity: PracticeIntensity, goal: String) -> String {
        if isEaseBack { return L("today.title.easeback") }
        switch intensity {
        case .restore:  return L("today.title.calm")
        case .energize: return L("today.title.energize")
        case .balanced: return L("today.title.flow")
        }
    }

    private static func focusLabel(for app: AppState) -> String {
        if let first = app.focusAreaKeys.first { return L(first) }
        return L(app.onboardingGoalKey)
    }

    private static func rationale(for app: AppState,
                                  intensity: PracticeIntensity,
                                  minutes: Int) -> [String] {
        var chips: [String] = [L(app.onboardingGoalKey)]
        for focus in app.focusAreaKeys.prefix(2) { chips.append(L(focus)) }
        chips.append(intensity.title)
        chips.append(L("%lld min", minutes))
        return chips
    }

    /// A stable per-day seed (varies daily, deterministic within the day and
    /// across launches — uses a fixed string fold, not the randomized hashValue).
    private static func daySeed(date: Date, salt: String) -> UInt64 {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let year = Calendar.current.component(.year, from: date)
        var h: UInt64 = 1469598103934665603 // FNV-1a offset basis
        for scalar in salt.unicodeScalars {
            h = (h ^ UInt64(scalar.value)) &* 1099511628211
        }
        return UInt64(year * 1000 + day) &+ h
    }
}

// MARK: - Deterministic RNG

/// Tiny SplitMix64 generator so daily plan rotation is reproducible.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0x9E3779B97F4A7C15 : seed }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
