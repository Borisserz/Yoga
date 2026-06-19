internal import SwiftUI
import SwiftData

struct CourseDayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var day: CourseDay

    init(day: CourseDay) {
        self.day = day
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "figure.yoga")
                .font(.system(size: 100))
                .foregroundStyle(.mint)

            Text(L("Day %lld", day.dayNumber))
                .font(.largeTitle.bold())

            Text(L("Focus: %@", YogaLibrary.displayName(forKey: day.poseName)))
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(L("Duration: %lld minutes", day.durationMinutes))
                .font(.headline)

            Spacer()

            if day.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Day completed")
                }
                .font(.headline)
                .foregroundStyle(.mint)
                .padding()
            } else {
                Button {
                    completeDay()
                } label: {
                    Text("Complete workout")
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
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func completeDay() {
        withAnimation {
            day.isCompleted = true
            try? modelContext.save()
        }

        HapticsManager.shared.playSuccess()

        Task {
            let startDate = Date().addingTimeInterval(Double(-day.durationMinutes * 60))
            await HealthKitManager.shared.saveYogaWorkout(
                durationMinutes: day.durationMinutes,
                calories: Double(day.durationMinutes * 5),
                startDate: startDate,
                endDate: Date()
            )
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
