internal import SwiftUI

struct HealthSettingsView: View {
    @Environment(AppState.self) private var app
    @State private var animateBackground = false
    @State private var isSyncing = false
    
    // We observe HealthKitManager.shared's properties
    private var healthManager: HealthKitManager {
        HealthKitManager.shared
    }

    init() {}

    var body: some View {
        ZStack {
            AnimatedGradientBackground(animate: $animateBackground)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.pink)
                            .shadow(color: .pink.opacity(0.35), radius: 10)
                        
                        Text("Apple Health")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        
                        Text("Sync your mindfulness sessions and yoga workouts directly with the Apple Health app.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 10)

                    // Status Indicator Card
                    HStack(spacing: 16) {
                        Image(systemName: healthManager.isAuthorized ? "checkmark.shield.fill" : "lock.shield.fill")
                            .font(.title)
                            .foregroundStyle(healthManager.isAuthorized ? .green : .orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(healthManager.isAuthorized ? "Synchronization Active" : "Access Required")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text(healthManager.isAuthorized ? "Your sessions are syncing smoothly." : "Enable permissions to sync your progress.")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer()
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(healthManager.isAuthorized ? Color.green.opacity(0.2) : Color.white.opacity(0.08), lineWidth: 1)
                    )

                    // Sync Categories
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sync details")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white.opacity(0.7))
                        
                        SyncRow(icon: "figure.yoga", title: "Yoga Workouts", desc: "Saves exercise times to your fitness ring.")
                        Divider().background(Color.white.opacity(0.08))
                        SyncRow(icon: "flame.fill", title: "Active Energy", desc: "Logs estimated active calories burnt.")
                        Divider().background(Color.white.opacity(0.08))
                        SyncRow(icon: "brain.headset", title: "Mindful Minutes", desc: "Adds meditation minutes to your mental health stats.")
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )

                    Spacer()

                    // Action Button
                    if !healthManager.isAuthorized {
                        Button {
                            requestAccess()
                        } label: {
                            HStack {
                                if isSyncing {
                                    ProgressView()
                                        .tint(.black)
                                        .padding(.trailing, 8)
                                }
                                Text(isSyncing ? "Requesting..." : "Connect Apple Health")
                                    .font(.headline.bold())
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.mint, in: Capsule())
                            .shadow(color: Color.mint.opacity(0.3), radius: 8, y: 4)
                        }
                        .buttonStyle(.tactile)
                        .disabled(isSyncing)
                    } else {
                        Button {
                            triggerManualSync()
                        } label: {
                            Label("Sync now", systemImage: "arrow.triangle.2.circlepath")
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.08), in: Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.tactile)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Apple Health")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateBackground = true
        }
    }

    private func requestAccess() {
        isSyncing = true
        HapticsManager.shared.playLightImpact()
        Task {
            await healthManager.requestAuthorization()
            await MainActor.run {
                isSyncing = false
                HapticsManager.shared.playSuccess()
            }
        }
    }
    
    private func triggerManualSync() {
        HapticsManager.shared.playSuccess()
        // Mock sync visual loop
        isSyncing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isSyncing = false
        }
    }
}

private struct SyncRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.mint)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(desc)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
        }
    }
}
