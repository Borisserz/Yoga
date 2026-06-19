import SwiftUI

public struct ChallengeArenaView: View {
    @Environment(AppState.self) private var app
    @State private var completed: Set<UUID> = []

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(YogaLibrary.quests) { quest in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: quest.icon)
                            Text(quest.title)
                                .font(.title3.bold())
                            Spacer()
                            if completed.contains(quest.id) {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                            }
                        }
                        Text(quest.subtitle)
                            .foregroundStyle(.white.opacity(0.8))
                        HStack {
                            Text(L("%lld min", quest.duration))
                            Spacer()
                            Text(L("Reward: %@", quest.reward))
                        }
                        .font(.caption.bold())

                        Button(completed.contains(quest.id) ? "Completed" : "Complete") {
                            completed.insert(quest.id)
                            app.completeSession(minutes: quest.duration)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(completed.contains(quest.id))
                    }
                    .padding()
                    .background(
                        LinearGradient(colors: quest.palette, startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Quest Arena")
    }
}
