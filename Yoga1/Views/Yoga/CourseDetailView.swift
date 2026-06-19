internal import SwiftUI
import SwiftData

struct CourseDetailView: View {
    let course: YogaCourse

    private var sortedDays: [CourseDay] {
        course.days.sorted { $0.dayNumber < $1.dayNumber }
    }

    init(course: YogaCourse) {
        self.course = course
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.desc)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    HStack {
                        Label(L("Level %lld", course.level), systemImage: "chart.bar.fill")
                        Spacer()
                        Label(L("%lld/%lld completed",
                                course.days.filter { $0.isCompleted }.count,
                                course.days.count),
                              systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.mint)
                    }
                    .font(.caption)
                    .padding(.top, 4)
                }
            }

            Section("Days of program") {
                ForEach(sortedDays) { day in
                    let isUnlocked = checkUnlocked(day: day)

                    if isUnlocked {
                        NavigationLink(destination: CourseDayDetailView(day: day)) {
                            DayRowView(day: day, isUnlocked: true)
                        }
                    } else {
                        DayRowView(day: day, isUnlocked: false)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(course.title)
    }

    private func checkUnlocked(day: CourseDay) -> Bool {
        if day.dayNumber == 1 { return true }
        if day.isCompleted { return true }
        if let previousDay = sortedDays.first(where: { $0.dayNumber == day.dayNumber - 1 }) {
            return previousDay.isCompleted
        }
        return false
    }
}

private struct DayRowView: View {
    let day: CourseDay
    let isUnlocked: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(L("Day %lld", day.dayNumber))
                    .font(.headline)
                Text(YogaLibrary.displayName(forKey: day.poseName))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if day.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.mint)
                    .font(.title3)
            } else if !isUnlocked {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .font(.title3)
            } else {
                Text(L("%lld min", day.durationMinutes))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.mint.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }
}
