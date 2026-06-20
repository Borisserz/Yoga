internal import SwiftUI

struct PaywallView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var pulseCrown = false

    init() {}

    var body: some View {
        ZStack {
            // Dark premium background
            Color.black.ignoresSafeArea()

            // Subtle gold ambient glow
            VStack {
                Circle()
                    .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .offset(y: -150)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Close button at top-right
                    HStack {
                        Spacer()
                        Button {
                            HapticsManager.shared.playLightImpact()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .padding(.top)

                    // Hero pulsing gold crown
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.yellow.opacity(0.15), .orange.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 140, height: 140)
                            .scaleEffect(pulseCrown ? 1.08 : 0.96)
                            .blur(radius: 4)
                        
                        Circle()
                            .stroke(
                                LinearGradient(colors: [.yellow.opacity(0.5), .orange.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1.5
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseCrown ? 1.04 : 0.98)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                            .shadow(color: .orange.opacity(0.5), radius: 10)
                            .scaleEffect(pulseCrown ? 1.03 : 0.98)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                            pulseCrown = true
                        }
                    }

                    // Title
                    VStack(spacing: 8) {
                        Text("Yoga Epic Premium")
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text("Join Premium to expand your practice, track deep insights, and build solid habits.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Feature Cards
                    VStack(spacing: 12) {
                        FeatureCard(
                            icon: "figure.yoga",
                            title: "Unlimited Practices",
                            description: "Access a cosmos of adaptive, custom, and professional yoga flows tailored to your goals.",
                            color: .mint
                        )

                        FeatureCard(
                            icon: "chart.bar.fill",
                            title: "Bento Stats Insights",
                            description: "Unlock advanced charts, streak calendar, mindful minutes distribution, and AI score tracking.",
                            color: .teal
                        )

                        FeatureCard(
                            icon: "flame.fill",
                            title: "Quest & Challenge Arena",
                            description: "Participate in weekly quests, collect special achievements, and climb the Leaderboards.",
                            color: .orange
                        )
                    }
                    .padding(.top, 8)

                    // Plan Info Box
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("ANNUAL ACCESS")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.yellow)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.yellow.opacity(0.15), in: Capsule())
                            Spacer()
                            Text("7 DAYS FREE")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.mint, in: Capsule())
                        }
                        
                        HStack(alignment: .lastTextBaseline) {
                            Text("$49.99")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("/ year")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.55))
                            Spacer()
                        }
                        
                        Text("Cancel anytime. Only $4.16/month billed annually. Free trial included.")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                            .lineSpacing(2)
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                    )

                    Spacer()

                    // Subscribe & Decline buttons
                    VStack(spacing: 14) {
                        Button {
                            app.activatePremium()
                            dismiss()
                            HapticsManager.shared.playSuccess()
                        } label: {
                            Text("Unlock Premium Access")
                                .font(.headline.bold())
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: Capsule()
                                )
                                .shadow(color: .orange.opacity(0.35), radius: 10, y: 4)
                        }
                        .buttonStyle(.tactile)

                        Button {
                            HapticsManager.shared.playLightImpact()
                            dismiss()
                        } label: {
                            Text("Maybe Later")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.tactile)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Premium Feature Row Component

private struct FeatureCard: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .shadow(color: color.opacity(0.3), radius: 4)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.0)
        )
    }
}

#Preview {
    PaywallView()
        .environment(AppState())
}
