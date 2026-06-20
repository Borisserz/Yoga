internal import SwiftUI

struct ChallengeArenaView: View {
    @Environment(AppState.self) private var app
    @State private var completed: Set<UUID> = []
    @State private var selectedQuest: ChallengeQuest?

    init() {}

    var body: some View {
        ZStack {
            // Premium background
            Color.black.ignoresSafeArea()
            
            // Soft ambient glow background
            VStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 350, height: 350)
                    .blur(radius: 80)
                    .offset(x: -100, y: -150)
                Spacer()
                Circle()
                    .fill(Color.orange.opacity(0.08))
                    .frame(width: 300, height: 300)
                    .blur(radius: 70)
                    .offset(x: 100, y: 150)
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header text
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Active Quests")
                            .font(.system(.title2, design: .rounded).bold())
                            .foregroundStyle(.white)
                        Text("Embark on challenges to earn badges and boost your practice")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Quest cards stack
                    VStack(spacing: 16) {
                        ForEach(YogaLibrary.quests) { quest in
                            let isDone = completed.contains(quest.id)
                            
                            Button {
                                HapticsManager.shared.playLightImpact()
                                selectedQuest = quest
                            } label: {
                                QuestRow(quest: quest, isDone: isDone)
                            }
                            .buttonStyle(.tactile)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Quest Arena")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedQuest) { quest in
            QuestDetailSheet(quest: quest, completed: $completed)
                .environment(app)
        }
    }
}

// MARK: - Quest Row Card Component

private struct QuestRow: View {
    let quest: ChallengeQuest
    let isDone: Bool

    private var borderStyle: AnyShapeStyle {
        if isDone {
            return AnyShapeStyle(Color.green.opacity(0.3))
        } else {
            return AnyShapeStyle(LinearGradient(
                colors: [.white.opacity(0.15), quest.palette.first?.opacity(0.3) ?? .clear, .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Quest Icon with soft gradient backing
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: quest.palette, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.18))
                    .frame(width: 50, height: 50)
                Image(systemName: quest.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: quest.palette, startPoint: .top, endPoint: .bottom))
                    .shadow(color: quest.palette.first?.opacity(0.4) ?? .clear, radius: 6)
            }
            
            // Quest Title & Details
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(quest.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Label("\(quest.duration) min", systemImage: "clock")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                    
                    Label(quest.reward, systemImage: "gift.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.orange.opacity(0.8))
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Completed state or Chevron
            if isDone {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
                    .shadow(color: .green.opacity(0.4), radius: 6)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: quest.palette.map { $0.opacity(0.06) }, startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    borderStyle,
                    lineWidth: isDone ? 1.5 : 1.2
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 10, y: 6)
    }
}

// MARK: - Quest Detail Sheet

private struct QuestDetailSheet: View {
    let quest: ChallengeQuest
    @Binding var completed: Set<UUID>
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Soft gradient ambient glow matching quest palette
            VStack {
                Circle()
                    .fill(LinearGradient(colors: quest.palette, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(y: -100)
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header with close button
                HStack {
                    Spacer()
                    Button {
                        HapticsManager.shared.playLightImpact()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.top)
                
                // Icon and Title
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: quest.palette, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: quest.icon)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(LinearGradient(colors: quest.palette, startPoint: .top, endPoint: .bottom))
                            .shadow(color: quest.palette.first?.opacity(0.5) ?? .clear, radius: 10)
                    }
                    
                    VStack(spacing: 6) {
                        Text(quest.title)
                            .font(.system(.title2, design: .rounded).bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(quest.subtitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                // Detailed Quest Instructions / Description
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quest Details")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(quest.description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(4)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DURATION")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white.opacity(0.4))
                            Label("\(quest.duration) min", systemImage: "clock")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("REWARD")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white.opacity(0.4))
                            Label(quest.reward, systemImage: "gift.fill")
                                .font(.subheadline.bold())
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                )
                
                Spacer()
                
                // Action Button
                let isDone = completed.contains(quest.id)
                Button {
                    if !isDone {
                        withAnimation {
                            completed.insert(quest.id)
                        }
                        app.completeSession(minutes: quest.duration)
                        HapticsManager.shared.playSuccess()
                        dismiss()
                    }
                } label: {
                    Text(isDone ? "Quest Completed" : "Claim & Complete")
                        .font(.headline.bold())
                        .foregroundStyle(isDone ? .white.opacity(0.6) : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            isDone ?
                            AnyView(Color.white.opacity(0.1)) :
                            AnyView(LinearGradient(colors: quest.palette, startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .clipShape(Capsule())
                        .shadow(color: isDone ? .clear : (quest.palette.first?.opacity(0.4) ?? .clear), radius: 10, y: 4)
                }
                .buttonStyle(.tactile)
                .disabled(isDone)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
