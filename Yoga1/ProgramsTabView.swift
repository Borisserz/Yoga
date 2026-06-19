internal import SwiftUI
import SwiftData

struct ProgramsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var app
    @Query(sort: \YogaCourse.title) private var courses: [YogaCourse]

    init() {}

    var body: some View {
        NavigationStack {
            Group {
                if courses.isEmpty {
                    ContentUnavailableView {
                        Label("No programs", systemImage: "tray")
                    } description: {
                        Text("Generate your first program.")
                    } actions: {
                        Button("Generate") {
                            generateAdaptiveCourse()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.mint)
                    }
                } else {
                    List(courses) { course in
                        NavigationLink(destination: CourseDetailView(course: course)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(course.title)
                                    .font(.headline)
                                Text(course.desc)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                let completed = course.days.filter { $0.isCompleted }.count
                                let total = course.days.count
                                let progress = total > 0 ? Double(completed) / Double(total) : 0.0

                                ProgressView(value: progress)
                                    .tint(.mint)

                                Text(L("Completed: %lld of %lld days", completed, total))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color.white.opacity(0.04))
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Programs")
            .onAppear {
                if courses.isEmpty {
                    generateAdaptiveCourse()
                }
            }
        }
    }

    /// Builds a 30-day plan tailored to the goal and level chosen during onboarding.
    private func generateAdaptiveCourse() {
        let level = experienceLevel(for: app.onboardingLevelKey)
        let pool = posePool(for: app.onboardingGoalKey, level: level)
        let days = 30

        let course = YogaCourse(
            title: L(titleKey(for: app.onboardingGoalKey)),
            desc: L("course.adaptive.desc", days),
            level: level
        )
        modelContext.insert(course)

        for i in 1...days {
            let poseKey = pool[(i - 1) % pool.count]
            let day = CourseDay(
                dayNumber: i,
                isCompleted: false,
                poseName: poseKey,
                durationMinutes: 8 + (i / 4)
            )
            modelContext.insert(day)
            course.days.append(day)
        }

        try? modelContext.save()
    }

    private func experienceLevel(for key: String) -> Int {
        switch key {
        case "onb.level.advanced": return 3
        case "onb.level.intermediate": return 2
        default: return 1
        }
    }

    private func titleKey(for goalKey: String) -> String {
        switch goalKey {
        case "onb.goal.strength": return "course.adaptive.title.strength"
        case "onb.goal.calm": return "course.adaptive.title.calm"
        default: return "course.adaptive.title.flexibility"
        }
    }

    /// Goal-weighted pose selection, always constrained to the user's level.
    private func posePool(for goalKey: String, level: Int) -> [String] {
        let available = Set(YogaLibrary.poses(forLevel: level).map { $0.key })
        let emphasis: [String]
        switch goalKey {
        case "onb.goal.strength":
            emphasis = ["plank", "boat", "utkatasana", "warrior_i", "warrior_ii", "half_moon", "bakasana"]
        case "onb.goal.calm":
            emphasis = ["balasana", "corpse", "cat_cow", "bridge", "seated_forward_bend", "cobra"]
        default: // flexibility
            emphasis = ["downward_dog", "seated_forward_bend", "triangle", "pigeon", "cobra", "seated_twist", "camel"]
        }
        let filtered = emphasis.filter { available.contains($0) }
        return filtered.isEmpty ? Array(available) : filtered
    }
}
