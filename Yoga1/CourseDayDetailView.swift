import SwiftUI
import SwiftData

public struct CourseDayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var day: CourseDay
    
    public init(day: CourseDay) {
        self.day = day
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "figure.yoga")
                .font(.system(size: 100))
                .foregroundStyle(.mint)
            
            Text("День \(day.dayNumber)")
                .font(.largeTitle.bold())
            
            Text("Фокус: \(day.poseName)")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("Длительность: \(day.durationMinutes) минут")
                .font(.headline)
            
            Spacer()
            
            if day.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("День пройден")
                }
                .font(.headline)
                .foregroundStyle(.mint)
                .padding()
            } else {
                Button {
                    completeDay()
                } label: {
                    Text("Завершить тренировку")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .navigationTitle("Тренировка")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func completeDay() {
        withAnimation {
            day.isCompleted = true
            try? modelContext.save()
        }
        
        // Haptics Feedback
        HapticsManager.shared.playSuccess()
        
        // Save to HealthKit (Async task)
        Task {
            let startDate = Date().addingTimeInterval(Double(-day.durationMinutes * 60))
            await HealthKitManager.shared.saveYogaWorkout(
                durationMinutes: day.durationMinutes,
                calories: Double(day.durationMinutes * 5), // Rough estimate: 5 kcal/min
                startDate: startDate,
                endDate: Date()
            )
        }
        
        // In a real app we would call FirebaseManager here too, e.g.
        // FirebaseManager.shared.saveUserStats(userId: AuthManager.shared.currentUserId, ...)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
