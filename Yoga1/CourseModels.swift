import Foundation
import SwiftData

@Model
final class YogaCourse {
    var id: UUID
    var title: String
    var desc: String
    var level: Int
    @Relationship(deleteRule: .cascade, inverse: \CourseDay.course)
    var days: [CourseDay]
    
    init(id: UUID = UUID(), title: String, desc: String, level: Int, days: [CourseDay] = []) {
        self.id = id
        self.title = title
        self.desc = desc
        self.level = level
        self.days = days
    }
    
    var isCompleted: Bool {
        guard !days.isEmpty else { return false }
        return days.allSatisfy { $0.isCompleted }
    }
}

@Model
final class CourseDay {
    var id: UUID
    var dayNumber: Int
    var isCompleted: Bool
    var course: YogaCourse?
    
    // We store the pose name or ID so we can look it up in YogaLibrary
    var poseName: String
    var durationMinutes: Int
    
    init(id: UUID = UUID(), dayNumber: Int, isCompleted: Bool = false, poseName: String, durationMinutes: Int) {
        self.id = id
        self.dayNumber = dayNumber
        self.isCompleted = isCompleted
        self.poseName = poseName
        self.durationMinutes = durationMinutes
    }
}
