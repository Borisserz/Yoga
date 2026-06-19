import SwiftUI

public enum MeditationLibrary {

    public static let all: [Meditation] = [
        // MARK: Guided

        Meditation(
            key: "morning_intention",
            category: .morning,
            gradient: [.orange, .pink],
            guided: true,
            segments: [
                MeditationSegment("med.morning_intention.s1", 40),
                MeditationSegment("med.morning_intention.s2", 60),
                MeditationSegment("med.morning_intention.s3", 60),
                MeditationSegment("med.morning_intention.s4", 50),
                MeditationSegment("med.morning_intention.s5", 40)
            ]
        ),
        Meditation(
            key: "breath_awareness",
            category: .focus,
            gradient: [.blue, .teal],
            guided: true,
            segments: [
                MeditationSegment("med.breath_awareness.s1", 45),
                MeditationSegment("med.breath_awareness.s2", 60),
                MeditationSegment("med.breath_awareness.s3", 60),
                MeditationSegment("med.breath_awareness.s4", 60),
                MeditationSegment("med.breath_awareness.s5", 45)
            ]
        ),
        Meditation(
            key: "body_scan",
            category: .sleep,
            gradient: [.indigo, .purple],
            guided: true,
            segments: [
                MeditationSegment("med.body_scan.s1", 50),
                MeditationSegment("med.body_scan.s2", 60),
                MeditationSegment("med.body_scan.s3", 60),
                MeditationSegment("med.body_scan.s4", 60),
                MeditationSegment("med.body_scan.s5", 60),
                MeditationSegment("med.body_scan.s6", 50)
            ]
        ),
        Meditation(
            key: "loving_kindness",
            category: .gratitude,
            gradient: [.purple, .pink],
            guided: true,
            segments: [
                MeditationSegment("med.loving_kindness.s1", 45),
                MeditationSegment("med.loving_kindness.s2", 55),
                MeditationSegment("med.loving_kindness.s3", 55),
                MeditationSegment("med.loving_kindness.s4", 55),
                MeditationSegment("med.loving_kindness.s5", 40)
            ]
        ),
        Meditation(
            key: "anxiety_grounding",
            category: .anxiety,
            gradient: [.pink, .orange],
            guided: true,
            segments: [
                MeditationSegment("med.anxiety_grounding.s1", 40),
                MeditationSegment("med.anxiety_grounding.s2", 55),
                MeditationSegment("med.anxiety_grounding.s3", 55),
                MeditationSegment("med.anxiety_grounding.s4", 55),
                MeditationSegment("med.anxiety_grounding.s5", 45)
            ]
        ),
        Meditation(
            key: "stress_release",
            category: .stress,
            gradient: [.mint, .teal],
            guided: true,
            segments: [
                MeditationSegment("med.stress_release.s1", 45),
                MeditationSegment("med.stress_release.s2", 60),
                MeditationSegment("med.stress_release.s3", 60),
                MeditationSegment("med.stress_release.s4", 50),
                MeditationSegment("med.stress_release.s5", 40)
            ]
        ),

        // MARK: Open timer

        Meditation(
            key: "silent_sit",
            category: .focus,
            gradient: [.blue, .indigo],
            guided: false,
            durationOptions: [3, 5, 10, 15]
        ),
        Meditation(
            key: "sleep_winddown",
            category: .sleep,
            gradient: [.indigo, .black],
            guided: false,
            durationOptions: [10, 15, 20, 30]
        ),
        Meditation(
            key: "deep_calm",
            category: .stress,
            gradient: [.mint, .blue],
            guided: false,
            durationOptions: [5, 10, 15]
        )
    ]

    public static func meditations(in category: MeditationCategory?) -> [Meditation] {
        guard let category else { return all }
        return all.filter { $0.category == category }
    }

    /// A simple daily pick that rotates through the library.
    public static var featured: Meditation {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[day % all.count]
    }
}
