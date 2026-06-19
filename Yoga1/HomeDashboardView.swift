import SwiftUI

public struct HomeDashboardView: View {
    @Environment(AppState.self) private var app
    @State private var animateBackground = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground(animate: $animateBackground)
                ScrollView {
                    VStack(spacing: 20) {
                        HeroCard()
                        LevelBanner()
                        StatsCard(minutes: app.completedMinutes, streak: app.streakDays, mood: app.mood)
                        QuickActionsRow()
                        IdeaCarouselView(ideaKeys: YogaLibrary.visionIdeaKeys)
                        QuickPoseGrid(poses: Array(YogaLibrary.poses.prefix(4)))
                    }
                    .padding()
                }
            }
            .navigationTitle("Yoga Epic")
        }
        .onAppear { animateBackground = true }
    }
}

struct HeroCard: View {
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's impulse")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
            Text("Dive into the flow where movement becomes a story")
                .font(.title2.bold())
            Button {
                app.selectedTab = 2
            } label: {
                Label("Start practice", systemImage: "play.fill")
                    .font(.headline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2), in: Capsule())
            }
            .foregroundStyle(.white)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.purple, .blue, .mint], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 30)
        )
        .overlay(alignment: .topTrailing) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .padding()
                .rotationEffect(.degrees(app.pulseAnimation ? 20 : -20))
                .animation(.easeInOut(duration: 1.6).repeatForever(), value: app.pulseAnimation)
        }
    }
}

struct StatsCard: View {
    let minutes: Int
    let streak: Int
    let mood: String

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                StatPill(title: "Minutes", value: "\(minutes)", color: .mint)
                StatPill(title: "Streak", value: "\(streak)", color: .orange)
                StatPill(title: "Mood", value: mood, color: .pink)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
}

struct StatPill: View {
    let title: LocalizedStringKey
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.18), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct QuickActionsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            NavigationLink {
                MeditationLibraryView()
            } label: {
                QuickActionCard(title: "Meditate", systemImage: "moon.stars.fill", color: .indigo)
            }
            NavigationLink {
                BreathCoachView()
            } label: {
                QuickActionCard(title: "Breathing", systemImage: "wind", color: .teal)
            }
            NavigationLink {
                ChallengeArenaView()
            } label: {
                QuickActionCard(title: "Quests", systemImage: "flame.fill", color: .orange)
            }
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionCard: View {
    let title: LocalizedStringKey
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3)
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct IdeaCarouselView: View {
    let ideaKeys: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inspiring ideas")
                .font(.title3.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(ideaKeys.enumerated()), id: \.offset) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("Idea #%lld", item.offset + 1))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                            Text(L(item.element))
                                .font(.headline)
                                .lineLimit(4)
                        }
                        .padding()
                        .frame(width: 240, height: 160, alignment: .topLeading)
                        .background(
                            LinearGradient(
                                colors: [Color(hue: Double(item.offset % 10) / 10.0, saturation: 0.7, brightness: 0.9), .black.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                    }
                }
            }
        }
    }
}

struct QuickPoseGrid: View {
    let poses: [YogaPose]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick start")
                .font(.title3.bold())
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(poses) { pose in
                    NavigationLink {
                        PoseDetailView(pose: pose)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(pose.name)
                                .font(.headline)
                            Text(pose.sanskrit)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            Spacer()
                            Text(L("%lld sec", pose.holdSeconds))
                                .font(.caption.bold())
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 130)
                        .background(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

struct LevelBanner: View {
    @Environment(AppState.self) private var app

    var body: some View {
        HStack(spacing: 16) {
            LevelRing(level: app.level, progress: app.levelProgress)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(L("Level %lld", app.level))
                    .font(.headline)
                ProgressView(value: app.levelProgress)
                    .tint(.mint)
                Text(L("%lld / %lld XP", app.xpIntoLevel, app.xpForNextLevel))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct LevelRing: View {
    let level: Int
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.15), lineWidth: 7)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(Color.mint, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(level)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.mint)
        }
        .animation(.easeOut(duration: 0.5), value: progress)
    }
}

struct AnimatedGradientBackground: View {
    @Binding var animate: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Circle()
                .fill(Color.purple.opacity(0.7))
                .frame(width: 300)
                .blur(radius: 120)
                .offset(x: animate ? 100 : -100, y: animate ? -200 : 0)

            Circle()
                .fill(Color.blue.opacity(0.6))
                .frame(width: 300)
                .blur(radius: 120)
                .offset(x: animate ? -100 : 100, y: animate ? 200 : 0)

            Circle()
                .fill(Color.mint.opacity(0.5))
                .frame(width: 250)
                .blur(radius: 100)
                .offset(x: animate ? 50 : -50, y: animate ? 0 : 200)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
    }
}
