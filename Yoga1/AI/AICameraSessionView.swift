import SwiftUI
import Vision

public struct AICameraSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()

    let poseKey: String
    private let displayName: String
    private let algorithm: YogaPoseAlgorithm

    @State private var feedbackText = L("camera.initializing")
    @State private var isCorrect = false
    @State private var correctTime: TimeInterval = 0
    @State private var timer: Timer?

    private let targetHoldSeconds = 10.0

    public init(poseKey: String) {
        self.poseKey = poseKey
        self.displayName = YogaLibrary.displayName(forKey: poseKey)
        self.algorithm = YogaPoseAnalyzer.getAlgorithm(for: poseKey)
    }

    public var body: some View {
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
                    }
                    .padding()

                    Spacer()

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

                        if correctTime >= targetHoldSeconds {
                            Button("Continue") {
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.mint)
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding()
                    .padding(.bottom, 20)
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

    private func startAnalysisLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let result = algorithm.analyze(joints: cameraManager.joints)

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
                        HapticsManager.shared.playSuccess()
                        timer?.invalidate()
                        let done = L("camera.hold_complete")
                        feedbackText = done
                        VoiceCoach.shared.speak(done, force: true)
                    }
                } else {
                    correctTime = max(0, correctTime - 0.25)
                }
            }
        }
    }
}
