internal import SwiftUI

struct MoodCheckInView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    struct MoodOption: Identifiable {
        let id = UUID()
        let key: String
        let emoji: String
        let color: Color
    }

    private let moodOptions = [
        MoodOption(key: "mood.calm", emoji: "🧘", color: .mint),
        MoodOption(key: "mood.energized", emoji: "⚡️", color: .orange),
        MoodOption(key: "mood.focused", emoji: "🎯", color: .purple),
        MoodOption(key: "mood.relaxed", emoji: "🍃", color: .teal),
        MoodOption(key: "mood.tired", emoji: "💤", color: .indigo),
        MoodOption(key: "mood.happy", emoji: "☀️", color: .pink)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Soft pink/purple ambient glow
            VStack {
                Circle()
                    .fill(Color.pink.opacity(0.12))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: -60, y: -100)
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
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
                .padding(.horizontal)

                VStack(spacing: 8) {
                    Text("How do you feel?")
                        .font(.system(.title, design: .rounded).bold())
                        .foregroundStyle(.white)
                    Text("Select your current state to tune your practice")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                // Grid of Moods
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(moodOptions) { option in
                        let isSelected = (app.moodKey == option.key)
                        
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                app.updateMoodKey(option.key)
                            }
                            HapticsManager.shared.playSuccess()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss()
                            }
                        } label: {
                            VStack(spacing: 12) {
                                Text(option.emoji)
                                    .font(.system(size: 36))
                                
                                Text(L(option.key))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(isSelected ? option.color : .white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                isSelected ?
                                option.color.opacity(0.15) :
                                Color.white.opacity(0.04)
                            )
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(
                                        isSelected ?
                                        option.color.opacity(0.8) :
                                        Color.white.opacity(0.08),
                                        lineWidth: isSelected ? 2 : 1.2
                                    )
                            )
                            .shadow(color: isSelected ? option.color.opacity(0.2) : Color.clear, radius: 10, y: 5)
                            .scaleEffect(isSelected ? 1.03 : 1.0)
                        }
                        .buttonStyle(.tactile)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

#Preview {
    MoodCheckInView()
        .environment(AppState())
}
