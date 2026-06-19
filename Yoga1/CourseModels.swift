import Foundation
import SwiftData

@Model
public final class YogaCourse {
    public var id: UUID
    public var title: String
    public var desc: String
    public var level: Int
    @Relationship(deleteRule: .cascade, inverse: \CourseDay.course)
    public var days: [CourseDay]
    
    public init(id: UUID = UUID(), title: String, desc: String, level: Int, days: [CourseDay] = []) {
        self.id = id
        self.title = title
        self.desc = desc
        self.level = level
        self.days = days
    }
    
    public var isCompleted: Bool {
        guard !days.isEmpty else { return false }
        return days.allSatisfy { $0.isCompleted }
    }
}

@Model
public final class CourseDay {
    public var id: UUID
    public var dayNumber: Int
    public var isCompleted: Bool
    public var course: YogaCourse?
    
    // We store the pose name or ID so we can look it up in YogaLibrary
    public var poseName: String
    public var durationMinutes: Int
    
    public init(id: UUID = UUID(), dayNumber: Int, isCompleted: Bool = false, poseName: String, durationMinutes: Int) {
        self.id = id
        self.dayNumber = dayNumber
        self.isCompleted = isCompleted
        self.poseName = poseName
        self.durationMinutes = durationMinutes
    }
}
