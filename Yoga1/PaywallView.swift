import SwiftUI

public struct PaywallView: View {
    @Environment(AppStateManager.self) private var appState
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
            
            Text("Открой доступ ко всем практикам, дыхательным техникам и персональным программам.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                FeatureRow(icon: "figure.yoga", text: "100+ премиум-классов")
                FeatureRow(icon: "chart.bar.fill", text: "Продвинутая статистика")
                FeatureRow(icon: "flame.fill", text: "Эксклюзивные квесты")
            }
            .padding(.top, 20)
            
            Spacer()
            
            Button {
                appState.activatePremium()
                dismiss()
                HapticsManager.shared.playSuccess()
            } label: {
                Text("Оформить подписку")
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
                Text("Позже")
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
    let text: String
    
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
