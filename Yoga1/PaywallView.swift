import SwiftUI

public struct PaywallView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "crown.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)

            Text("Yoga Epic Premium")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Unlock access to all practices, breathing techniques, and personal programs.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 16) {
                FeatureRow(icon: "figure.yoga", text: "100+ premium classes")
                FeatureRow(icon: "chart.bar.fill", text: "Advanced statistics")
                FeatureRow(icon: "flame.fill", text: "Exclusive quests")
            }
            .padding(.top, 20)

            Spacer()

            Button {
                app.activatePremium()
                dismiss()
                HapticsManager.shared.playSuccess()
            } label: {
                Text("Subscribe")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mint)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
            }

            Button {
                dismiss()
            } label: {
                Text("Later")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.mint)
                .frame(width: 30)
            Text(text)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}
