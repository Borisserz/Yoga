import SwiftUI
import SwiftData

public struct ProgramsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \YogaCourse.title) private var courses: [YogaCourse]

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if courses.isEmpty {
                    ContentUnavailableView {
                        Label("No programs", systemImage: "tray")
                    } description: {
                        Text("Generate your first program.")
                    } actions: {
                        Button("Generate") {
                            generateStarterCourse()
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
                    generateStarterCourse()
                }
            }
        }
    }

    private func generateStarterCourse() {
        let course = YogaCourse(
            title: L("course.starter.title"),
            desc: L("course.starter.desc"),
            level: 1
        )
        modelContext.insert(course)

        let flow = YogaLibrary.starterFlow

        for i in 1...30 {
            let poseKey = flow[i % flow.count]
            let day = CourseDay(
                dayNumber: i,
                isCompleted: false,
                poseName: poseKey,
                durationMinutes: 10 + (i / 5)
            )
            modelContext.insert(day)
            course.days.append(day)
        }

        try? modelContext.save()
    }
}
