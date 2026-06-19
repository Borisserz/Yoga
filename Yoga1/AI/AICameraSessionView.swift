internal import SwiftUI
import Vision
import AVFoundation

struct AICameraSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var app
    @StateObject private var cameraManager = CameraManager()

    let poseKey: String
    private let displayName: String
    private let algorithm: YogaPoseAlgorithm

    @State private var feedbackText = L("camera.initializing")
    @State private var isCorrect = false
    @State private var correctTime: TimeInterval = 0
    @State private var timer: Timer?

    // Scoring
    @State private var totalFrames = 0
    @State private var correctFrames = 0
    @State private var finished = false
    @State private var recorded = false

    private let targetHoldSeconds = 10.0

    init(poseKey: String) {
        self.poseKey = poseKey
        self.displayName = YogaLibrary.displayName(forKey: poseKey)
        self.algorithm = YogaPoseAnalyzer.getAlgorithm(for: poseKey)
    }

    private var liveScore: Int {
        totalFrames > 0 ? Int(Double(correctFrames) / Double(totalFrames) * 100) : 0
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if cameraManager.isAuthorized {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()

                PoseOverlayView(joints: cameraManager.joints)
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                                .shadow(radius: 4)
                        }
                        Spacer()
                        ScoreBadge(score: liveScore)
                    }
                    .padding()

                    Spacer()

                    if finished {
                        SessionReportCard(
                            poseName: displayName,
                            score: liveScore,
                            holdSeconds: Int(targetHoldSeconds),
                            xpEarned: 10 + Int(Double(liveScore) / 100.0 * 20)
                        ) {
                            dismiss()
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        coachCard
                    }
                }
            } else if cameraManager.authorizationStatus == .denied {
                VStack(spacing: 16) {
                    Text("Camera access denied")
                        .font(.title2)
                        .foregroundStyle(.white)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ProgressView("Starting camera…")
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            cameraManager.checkPermission()
            startAnalysisLoop()
        }
        .onDisappear {
            cameraManager.stopSession()
            timer?.invalidate()
        }
    }

    private var coachCard: some View {
        VStack(spacing: 8) {
            Text(displayName)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))

            Text(feedbackText)
                .font(.title2.bold())
                .foregroundStyle(isCorrect ? .mint : .yellow)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)

            ProgressView(value: min(correctTime / targetHoldSeconds, 1.0))
                .tint(.mint)
                .padding(.horizontal)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
        .padding(.bottom, 20)
    }

    private func startAnalysisLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task { @MainActor in
                guard !finished else { return }
            let result = algorithm.analyze(joints: cameraManager.joints)

            // Only score frames where a body is actually detected.
            if !cameraManager.joints.isEmpty {
                totalFrames += 1
                if result.isCorrect { correctFrames += 1 }
            }

            if result.feedback != feedbackText {
                VoiceCoach.shared.speak(result.feedback)
            } else if result.isCorrect && correctTime == 0.0 {
                VoiceCoach.shared.speak(result.feedback)
            }

            withAnimation {
                feedbackText = result.feedback
                isCorrect = result.isCorrect

                if isCorrect {
                    correctTime += 0.5
                    if correctTime == 0.5 {
                        HapticsManager.shared.playLightImpact()
                    }
                    if correctTime >= targetHoldSeconds {
                        completeSession()
                    }
                } else {
                    correctTime = max(0, correctTime - 0.25)
                }
            }
            }
        }
    }

    private func completeSession() {
        guard !recorded else { return }
        recorded = true
        timer?.invalidate()
        HapticsManager.shared.playSuccess()
        VoiceCoach.shared.speak(L("camera.hold_complete"), force: true)

        let accuracy = totalFrames > 0 ? Double(correctFrames) / Double(totalFrames) : 0
        app.completeSession(minutes: 1, poseKey: poseKey, accuracy: accuracy)

        withAnimation(.spring) { finished = true }
    }
}

// MARK: - Score badge (live)

private struct ScoreBadge: View {
    let score: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "target")
            Text(L("score.percent", score))
                .font(.headline.monospacedDigit())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - Post-session report

private struct SessionReportCard: View {
    let poseName: String
    let score: Int
    let holdSeconds: Int
    let xpEarned: Int
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("Session complete")
                .font(.title2.bold())
            Text(poseName)
                .font(.headline)
                .foregroundStyle(.secondary)

            ScoreRing(score: score)
                .frame(width: 130, height: 130)

            HStack(spacing: 24) {
                ReportStat(title: "Accuracy", value: L("score.percent", score))
                ReportStat(title: "Hold time", value: L("%lld s", holdSeconds))
                ReportStat(title: "XP", value: L("xp.earned", xpEarned))
            }

            Button("Done", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(.mint)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .padding()
        .padding(.bottom, 24)
    }
}

private struct ReportStat: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.mint)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ScoreRing: View {
    let score: Int

    private var tint: Color {
        switch score {
        case 80...: return .mint
        case 50..<80: return .yellow
        default: return .orange
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.15), lineWidth: 12)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100.0)
                .stroke(tint, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
        }
        .animation(.easeOut(duration: 0.6), value: score)
    }
}
