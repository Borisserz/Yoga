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
                        Label("Нет программ", systemImage: "tray")
                    } description: {
                        Text("Сгенерируйте первую программу.")
                    } actions: {
                        Button("Сгенерировать") {
                            generateMockCourse()
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
                                
                                Text("Пройдено: \(completed) из \(total) дней")
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
            .navigationTitle("Курсы")
            .onAppear {
                if courses.isEmpty {
                    generateMockCourse()
                }
            }
        }
    }
    
    private func generateMockCourse() {
        let course = YogaCourse(
            title: "30 дней гибкости",
            desc: "Программа для развития гибкости всего тела шаг за шагом.",
            level: 1
        )
        modelContext.insert(course)
        
        let poses = ["Собака мордой вниз", "Поза воина I", "Поза дерева", "Поза лотоса"]
        
        for i in 1...30 {
            let poseName = poses[i % poses.count]
            let day = CourseDay(
                dayNumber: i,
                isCompleted: false,
                poseName: poseName,
                durationMinutes: 10 + (i / 5) // Duration increases slightly over time
            )
            modelContext.insert(day)
            course.days.append(day)
        }
        
        try? modelContext.save()
    }
}
