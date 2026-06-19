import SwiftUI
import SwiftData

public struct CourseDetailView: View {
    let course: YogaCourse
    
    // Sort days by day number
    private var sortedDays: [CourseDay] {
        course.days.sorted { $0.dayNumber < $1.dayNumber }
    }
    
    public init(course: YogaCourse) {
        self.course = course
    }
    
    public var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.desc)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Label("Уровень \(course.level)", systemImage: "chart.bar.fill")
                        Spacer()
                        Label("\(course.days.filter { $0.isCompleted }.count)/\(course.days.count) пройдено", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.mint)
                    }
                    .font(.caption)
                    .padding(.top, 4)
                }
            }
            
            Section("Дни программы") {
                ForEach(sortedDays) { day in
                    // Unlock Day 1 or any day if the previous day is completed
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
        // Find previous day
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
                Text("День \(day.dayNumber)")
                    .font(.headline)
                Text(day.poseName)
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
                Text("\(day.durationMinutes) мин")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.mint.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }
}
