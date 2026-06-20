internal import SwiftUI
import SwiftData

struct ProgramsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var app
    @Query(sort: \YogaCourse.title) private var courses: [YogaCourse]
    @State private var animateBackground = false

    init() {}

    var body: some View {
        NavigationStack {
            ZStack {
                // Premium background
                Color.black.ignoresSafeArea()
                
                // Soft ambient stardust
                VStack {
                    Circle()
                        .fill(Color.teal.opacity(0.12))
                        .frame(width: 320, height: 320)
                        .blur(radius: 80)
                        .offset(x: -80, y: -100)
                    Spacer()
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .blur(radius: 70)
                        .offset(x: 80, y: 100)
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Section Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Yoga Journeys")
                                .font(.system(.title2, design: .rounded).bold())
                                .foregroundStyle(.white)
                            Text("Structured multi-day programs to build consistency, strength, and calm")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Programs VStack
                        VStack(spacing: 18) {
                            ForEach(courses) { course in
                                NavigationLink(destination: CourseDetailView(course: course)) {
                                    let palette = paletteFor(course)
                                    let completed = course.days.filter { $0.isCompleted }.count
                                    let total = course.days.count
                                    let progress = total > 0 ? Double(completed) / Double(total) : 0.0
                                    
                                    VStack(alignment: .leading, spacing: 16) {
                                        // Header row with Icon, Title, and Difficulty
                                        HStack(alignment: .top, spacing: 14) {
                                            ZStack {
                                                Circle()
                                                    .fill(LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.18))
                                                    .frame(width: 46, height: 46)
                                                Image(systemName: iconFor(course))
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundStyle(LinearGradient(colors: palette, startPoint: .top, endPoint: .bottom))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack(alignment: .firstTextBaseline) {
                                                    Text(course.title)
                                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                                        .foregroundStyle(.white)
                                                    Spacer()
                                                    
                                                    // Level Badge
                                                    Text(difficultyLabel(course.level))
                                                        .font(.system(size: 9, weight: .bold))
                                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                                        .background(difficultyColor(course.level).opacity(0.15), in: Capsule())
                                                        .foregroundStyle(difficultyColor(course.level))
                                                        .overlay(
                                                            Capsule()
                                                                .strokeBorder(difficultyColor(course.level).opacity(0.3), lineWidth: 1)
                                                        )
                                                }
                                                
                                                Text(course.desc)
                                                    .font(.caption)
                                                    .foregroundStyle(.white.opacity(0.6))
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.leading)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                        
                                        // Progress tracking
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(L("Completed: %lld of %lld days", completed, total))
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundStyle(palette.first ?? .mint)
                                                Spacer()
                                                Text(String(format: "%.0f%%", progress * 100))
                                                    .font(.system(size: 11, weight: .bold).monospacedDigit())
                                                    .foregroundStyle(palette.first ?? .mint)
                                            }
                                            
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    Capsule()
                                                        .fill(Color.white.opacity(0.06))
                                                    Capsule()
                                                        .fill(LinearGradient(colors: palette, startPoint: .leading, endPoint: .trailing))
                                                        .frame(width: geo.size.width * CGFloat(progress))
                                                        .shadow(color: palette.first?.opacity(0.4) ?? .clear, radius: 4)
                                                }
                                            }
                                            .frame(height: 6)
                                        }
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(LinearGradient(colors: palette.map { $0.opacity(0.04) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                                    )
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [.white.opacity(0.18), palette.first?.opacity(0.3) ?? .clear, .clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.2
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
                                }
                                .buttonStyle(.tactile)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Programs")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                animateBackground = true
                generateAllDefaultCourses()
            }
        }
    }

    // MARK: - Pre-generation

    private func generateAllDefaultCourses() {
        // Only run pre-generation logic once if the DB is empty or needs populating
        if courses.count < 4 {
            // 1. AI Adaptive Program (matching current onboarding goal/level)
            generateAdaptiveCourse()
            
            // 2. Flexibility Journey (Level 1)
            generatePredefinedCourse(
                title: "Flexibility Journey",
                desc: "A 14-day progressive course designed to open your hips, stretch your hamstrings, and increase spinal mobility.",
                level: 1,
                poses: ["cat_cow", "downward_dog", "cobra", "seated_forward_bend", "seated_twist", "triangle", "pigeon"]
            )
            
            // 3. Core Strength Builder (Level 2)
            generatePredefinedCourse(
                title: "Core Strength Builder",
                desc: "A 14-day sequence focused on building deep core stability, shoulder power, and solid balancing stances.",
                level: 2,
                poses: ["warrior_i", "warrior_ii", "utkatasana", "plank", "boat", "half_moon", "bakasana"]
            )
            
            // 4. Calm & Restoration (Level 1)
            generatePredefinedCourse(
                title: "Calm & Restoration",
                desc: "A 14-day restorative program with slow holds to soothe the nervous system, release stress, and aid deep sleep.",
                level: 1,
                poses: ["balasana", "corpse", "cat_cow", "bridge", "seated_forward_bend"]
            )
        }
    }

    private func generateAdaptiveCourse() {
        // Avoid duplicating adaptive course
        let adaptiveTitle = L(titleKey(for: app.onboardingGoalKey))
        if courses.contains(where: { $0.title == adaptiveTitle }) { return }

        let level = experienceLevel(for: app.onboardingLevelKey)
        let pool = posePool(for: app.onboardingGoalKey, level: level)
        let days = 30

        let course = YogaCourse(
            title: adaptiveTitle,
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

    private func generatePredefinedCourse(title: String, desc: String, level: Int, poses: [String]) {
        if courses.contains(where: { $0.title == title }) { return }
        
        let course = YogaCourse(
            title: title,
            desc: desc,
            level: level
        )
        modelContext.insert(course)
        
        let days = 14
        for i in 1...days {
            let poseKey = poses[(i - 1) % poses.count]
            let day = CourseDay(
                dayNumber: i,
                isCompleted: false,
                poseName: poseKey,
                durationMinutes: 10 + (i / 3)
            )
            modelContext.insert(day)
            course.days.append(day)
        }
        try? modelContext.save()
    }

    // MARK: - Helper Methods

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

    private func posePool(for goalKey: String, level: Int) -> [String] {
        let available = Set(YogaLibrary.poses(forLevel: level).map { $0.key })
        let emphasis: [String]
        switch goalKey {
        case "onb.goal.strength":
            emphasis = ["plank", "boat", "utkatasana", "warrior_i", "warrior_ii", "half_moon", "bakasana"]
        case "onb.goal.calm":
            emphasis = ["balasana", "corpse", "cat_cow", "bridge", "seated_forward_bend", "cobra"]
        default:
            emphasis = ["downward_dog", "seated_forward_bend", "triangle", "pigeon", "cobra", "seated_twist", "camel"]
        }
        let filtered = emphasis.filter { available.contains($0) }
        return filtered.isEmpty ? Array(available) : filtered
    }

    private func paletteFor(_ course: YogaCourse) -> [Color] {
        if course.title.contains("Flexibility") {
            return [.orange, .pink]
        } else if course.title.contains("Strength") {
            return [.red, .purple]
        } else if course.title.contains("Calm") {
            return [.indigo, .cyan]
        } else {
            return [.mint, .teal]
        }
    }

    private func iconFor(_ course: YogaCourse) -> String {
        if course.title.contains("Flexibility") {
            return "figure.stretch"
        } else if course.title.contains("Strength") {
            return "bolt.heart.fill"
        } else if course.title.contains("Calm") {
            return "heart.fill"
        } else {
            return "sparkles"
        }
    }

    private func difficultyLabel(_ level: Int) -> String {
        switch level {
        case 3: return "ADVANCED"
        case 2: return "INTERMEDIATE"
        default: return "BEGINNER"
        }
    }

    private func difficultyColor(_ level: Int) -> Color {
        switch level {
        case 3: return .red
        case 2: return .orange
        default: return .mint
        }
    }
}
