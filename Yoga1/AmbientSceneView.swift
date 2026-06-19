import SwiftUI

public struct AmbientSceneView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var drift = false

    public init() {}

    public var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .indigo, .purple], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ForEach(0..<40, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: CGFloat((i % 8) + 4) * 6)
                    .offset(x: drift ? CGFloat((i * 23) % 300 - 150) : CGFloat((i * 13) % 280 - 140),
                            y: drift ? CGFloat((i * 17) % 620 - 320) : CGFloat((i * 31) % 620 - 320))
                    .blur(radius: 1.5)
                    .animation(.easeInOut(duration: Double((i % 7) + 6)).repeatForever(autoreverses: true), value: drift)
            }

            VStack(spacing: 18) {
                Text("Ambient Yoga Realm")
                    .font(.largeTitle.bold())
                Text("Visual meditation: breathe to the rhythm of light")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                Button("Close") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .onAppear { drift = true }
    }
}
