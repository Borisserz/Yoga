import SwiftUI

public struct HomeDashboardView: View {
    @EnvironmentObject private var state: YogaAppState
    @State private var animateBackground = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground(animate: $animateBackground)
                ScrollView {
                    VStack(spacing: 20) {
                        HeroCard()
                        StatsCard(minutes: state.completedMinutes, streak: state.streakDays, mood: state.mood)
                        IdeaCarouselView(ideas: YogaLibrary.visionIdeas)
                        QuickPoseGrid(poses: Array(YogaLibrary.poses.prefix(4))) // Показываем 4 позы
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
    @EnvironmentObject private var state: YogaAppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сегодняшний импульс")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))
            Text("Погрузись в поток, где движение превращается в историю")
                .font(.title2.bold())
            Button {
                state.selectedTab = 1
            } label: {
                Label("Запустить практику", systemImage: "play.fill")
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
                .rotationEffect(.degrees(state.pulseAnimation ? 20 : -20))
                .animation(.easeInOut(duration: 1.6).repeatForever(), value: state.pulseAnimation)
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
                StatPill(title: "Минут", value: "\(minutes)", color: .mint)
                StatPill(title: "Серия", value: "\(streak)", color: .orange)
                StatPill(title: "Настрой", value: mood, color: .pink)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
}

struct StatPill: View {
    let title: String
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

struct IdeaCarouselView: View {
    let ideas: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Цепляющие идеи")
                .font(.title3.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(ideas.enumerated()), id: \.offset) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Идея #\(item.offset + 1)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                            Text(item.element)
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
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Быстрый старт")
                .font(.title3.bold())
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(poses) { pose in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(pose.name)
                            .font(.headline)
                        Text(pose.sanskrit)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        Text("\(pose.holdSeconds) сек")
                            .font(.caption.bold())
                    }
                    .padding()
                    .frame(height: 130)
                    .background(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 18))
                }
            }
        }
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
