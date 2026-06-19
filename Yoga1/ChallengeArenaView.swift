import SwiftUI

public struct ChallengeArenaView: View {
    @EnvironmentObject private var state: YogaAppState
    @State private var completed: Set<UUID> = []

    public init() {}

    public var body: some View {
        NavigationStack {
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
                                Text("\(quest.duration) мин")
                                Spacer()
                                Text("Награда: \(quest.reward)")
                            }
                            .font(.caption.bold())

                            Button(completed.contains(quest.id) ? "Выполнено" : "Завершить") {
                                completed.insert(quest.id)
                                state.completeSession(minutes: quest.duration)
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
            .navigationTitle("Арена квестов")
        }
    }
}
