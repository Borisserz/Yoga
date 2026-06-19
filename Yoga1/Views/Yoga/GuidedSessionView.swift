internal import SwiftUI

/// Runs an adaptive `DailyPlan` as a guided, auto-advancing flow with a hold
/// timer per pose, optional AI camera per pose, and a completion summary that
/// logs the whole session at once.
struct GuidedSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var app

    let plan: DailyPlan

    @State private var index = 0
    @State private var progress: Double = 0
    @State private var isPlaying = true
    @State private var timer: Timer?
    @State private var showAICamera = false
    @State private var finished = false
    @State private var logged = false

    init(plan: DailyPlan) {
        self.plan = plan
    }

    private var current: YogaPose? {
        plan.poses.indices.contains(index) ? plan.poses[index] : nil
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: (current?.gradient ?? plan.gradient).map { $0.opacity(0.35) },
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Color.black.opacity(0.5).ignoresSafeArea()

            if finished {
                completionCard
                    .transition(.scale.combined(with: .opacity))
            } else if let pose = current {
                practiceContent(for: pose)
            }
        }
        .onAppear(perform: startTimer)
        .onDisappear { timer?.invalidate() }
        .fullScreenCover(isPresented: $showAICamera) {
            if let pose = current {
                AICameraSessionView(poseKey: pose.key)
            }
        }
    }

    // MARK: - Practice UI

    private func practiceContent(for pose: YogaPose) -> some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Text(L("Pose %lld of %lld", index + 1, plan.poses.count))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }

            // Step progress dots.
            HStack(spacing: 6) {
                ForEach(plan.poses.indices, id: \.self) { i in
                    Capsule()
                        .fill(i <= index ? Color.mint : Color.white.opacity(0.25))
                        .frame(height: 4)
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.18), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.mint, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 6) {
                    Text(pose.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text(L("%lld / %lld sec",
                           Int(progress * Double(pose.holdSeconds)), pose.holdSeconds))
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding()
            }
            .frame(width: 240, height: 240)
            .foregroundStyle(.white)

            if let first = pose.instructions.first {
                Text(first)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal)
            }

            Spacer()

            controls
        }
        .padding()
    }

    private var controls: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                Button { isPlaying.toggle() } label: {
                    Label(isPlaying ? "Pause" : "Resume",
                          systemImage: isPlaying ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                }
                Button { showAICamera = true } label: {
                    Label("AI Camera", systemImage: "camera.viewfinder")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.indigo.opacity(0.8), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .font(.headline)
            .foregroundStyle(.white)

            Button {
                advance(counting: true)
            } label: {
                Text(index == plan.poses.count - 1 ? "Finish" : "Next pose")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.mint, in: Capsule())
                    .foregroundStyle(.black)
            }
        }
    }

    // MARK: - Completion

    private var completionCard: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 70))
                .foregroundStyle(.mint)
            Text("Practice complete")
                .font(.title.bold())
                .foregroundStyle(.white)
            Text(L("%lld poses • %lld min", plan.poses.count, plan.totalMinutes))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))
            if app.streakDays > 0 {
                Text(L("%lld-day streak 🔥", app.streakDays))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
            }
            Button("Done") { dismiss() }
                .font(.headline)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(.mint, in: Capsule())
                .foregroundStyle(.black)
                .padding(.top, 8)
        }
        .padding(32)
    }

    // MARK: - Timer / flow

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard isPlaying, !finished, let pose = current else { return }
            withAnimation(.linear(duration: 0.1)) {
                progress += 0.1 / Double(max(1, pose.holdSeconds))
            }
            if progress >= 1 {
                advance(counting: true)
            }
        }
    }

    private func advance(counting: Bool) {
        HapticsManager.shared.playLightImpact()
        if index < plan.poses.count - 1 {
            index += 1
            progress = 0
        } else {
            finish()
        }
    }

    private func finish() {
        timer?.invalidate()
        guard !logged else { return }
        logged = true
        HapticsManager.shared.playSuccess()
        app.completeSession(minutes: plan.totalMinutes, poseKey: plan.poses.first?.key)
        withAnimation(.spring) { finished = true }
    }
}
