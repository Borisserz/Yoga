internal import SwiftUI

struct PoseDetailView: View {
    @Environment(AppState.self) private var app
    let pose: YogaPose
    @State private var progress: Double = 0
    @State private var isPlaying = false
    @State private var timer: Timer?
    @State private var showAICamera = false

    init(pose: YogaPose) {
        self.pose = pose
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 260)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(.white.opacity(0.8), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 160, height: 160)
                    VStack {
                        Text(pose.name)
                            .font(.title.bold())
                        Text(L("%lld / %lld sec", Int(progress * Double(pose.holdSeconds)), pose.holdSeconds))
                            .font(.headline)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Steps")
                        .font(.title3.bold())
                    ForEach(Array(pose.instructions.enumerated()), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                    }
                }

                Text(L("Mantra: %@", pose.mantra))
                    .font(.headline)
                    .padding()
                    .background(.pink.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))

                HStack(spacing: 16) {
                    Button(isPlaying ? "Stop" : "Start") {
                        isPlaying ? stop() : start()
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        showAICamera = true
                    } label: {
                        Label("AI Camera", systemImage: "camera.viewfinder")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
            }
            .padding()
        }
        .navigationTitle(pose.name)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showAICamera) {
            AICameraSessionView(poseKey: pose.key)
        }
        .onDisappear { stop() }
    }

    private func start() {
        isPlaying = true
        progress = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            let step = 0.1 / Double(pose.holdSeconds)
            progress += step
            if progress >= 1 {
                progress = 1
                t.invalidate()
                isPlaying = false
                app.completeSession(minutes: max(1, pose.holdSeconds / 60), poseKey: pose.key)
            }
        }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }
}
