internal import SwiftUI
import Combine

struct AmbientSceneView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var breatheIn = false
    @State private var phaseText = L("phase.inhale")
    @State private var drift = false

    // Timer to update the guiding text phase every 4 seconds
    private let timer = Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()

    init() {}

    var body: some View {
        ZStack {
            // Dark night sky base
            Color.black.ignoresSafeArea()

            // Dynamic pulsing ambient background glow
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.indigo, .purple, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 420, height: 420)
                    .blur(radius: 90)
                    .scaleEffect(breatheIn ? 1.35 : 0.8)
                    .opacity(breatheIn ? 0.35 : 0.15)
                
                Circle()
                    .fill(RadialGradient(colors: [.white.opacity(0.12), .clear], center: .center, startRadius: 0, endRadius: 150))
                    .frame(width: 280, height: 280)
                    .scaleEffect(breatheIn ? 1.25 : 0.75)
                    .blur(radius: 12)
            }
            .ignoresSafeArea()

            // Drifting ambient cosmic dust
            ForEach(0..<25, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: CGFloat((i % 5) + 3) * 3)
                    .offset(
                        x: drift ? CGFloat((i * 27) % 320 - 160) : CGFloat((i * 13) % 320 - 160),
                        y: drift ? CGFloat((i * 19) % 640 - 320) : CGFloat((i * 31) % 640 - 320)
                    )
                    .blur(radius: 1.0)
                    .animation(
                        .easeInOut(duration: Double((i % 5) + 8))
                        .repeatForever(autoreverses: true),
                        value: drift
                    )
            }

            // Concentric golden guide ring
            Circle()
                .stroke(
                    LinearGradient(colors: [.yellow.opacity(0.35), .clear, .mint.opacity(0.2)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1.5
                )
                .frame(width: 210)
                .scaleEffect(breatheIn ? 1.12 : 0.88)
                .rotationEffect(.degrees(breatheIn ? 90 : -90))

            VStack(spacing: 40) {
                // Header details
                VStack(spacing: 8) {
                    Text("Ambient Yoga Realm")
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .foregroundStyle(.white)
                    
                    Text("Follow the light to guide your breath")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                Spacer()

                // Centered dynamic instruction
                VStack(spacing: 6) {
                    Text(phaseText)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .id(phaseText)
                    
                    Text(phaseText == L("phase.inhale") ? "Inhale as the light expands" : "Exhale as the light contracts")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                }

                Spacer()

                // Close Button
                Button {
                    HapticsManager.shared.playLightImpact()
                    dismiss()
                } label: {
                    Text("Close Realm")
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 16)
                        .background(Color.white, in: Capsule())
                        .shadow(color: .white.opacity(0.3), radius: 10, y: 4)
                }
                .buttonStyle(.tactile)
                .padding(.bottom, 40)
            }
            .padding()
        }
        .onAppear {
            drift = true
            // Match standard 4s inhale, 4s exhale cycle
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                breatheIn = true
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                if phaseText == L("phase.inhale") {
                    phaseText = L("phase.exhale")
                } else {
                    phaseText = L("phase.inhale")
                }
            }
        }
    }
}

#Preview {
    AmbientSceneView()
}
