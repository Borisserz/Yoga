internal import SwiftUI

struct AnimatedPoseView: View {
    let pose: YogaPose
    let size: CGFloat
    
    @State private var currentFrame = 1
    @State private var timer: Timer? = nil
    
    // Check if the animated transition frames exist in Assets
    private var hasAnimationFrames: Bool {
        UIImage(named: "\(pose.key)_1") != nil && UIImage(named: "\(pose.key)_2") != nil
    }
    
    var body: some View {
        ZStack {
            if hasAnimationFrames {
                // If animation frames exist, cycle through them with opacity transitions
                Group {
                    if currentFrame == 1 {
                        poseImage(named: "\(pose.key)_1")
                            .transition(.opacity)
                    } else if currentFrame == 2 {
                        poseImage(named: "\(pose.key)_2")
                            .transition(.opacity)
                    } else {
                        poseImage(named: pose.key)
                            .transition(.opacity)
                    }
                }
                // Use a unique ID based on pose and frame so SwiftUI tracks and transitions them correctly
                .id("\(pose.key)_frame_\(currentFrame)")
            } else if UIImage(named: pose.key) != nil {
                // Fallback: static custom pose image
                poseImage(named: pose.key)
            } else {
                // Fallback: standard SF Symbol
                Image(systemName: "figure.yoga")
                    .font(.system(size: size * 0.6))
                    .foregroundStyle(LinearGradient(colors: pose.gradient, startPoint: .top, endPoint: .bottom))
                    .shadow(color: pose.gradient.first?.opacity(0.35) ?? .clear, radius: 6)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    @ViewBuilder
    private func poseImage(named name: String) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .shadow(color: pose.gradient.first?.opacity(0.25) ?? .clear, radius: 4)
    }
    
    private func startAnimation() {
        guard hasAnimationFrames else { return }
        var tickIndex = 0
        currentFrame = 1
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            tickIndex = (tickIndex + 1) % 5
            
            withAnimation(.easeInOut(duration: 0.35)) {
                if tickIndex == 0 {
                    currentFrame = 1 // Prep (0.6s)
                } else if tickIndex == 1 {
                    currentFrame = 2 // Transition (0.6s)
                } else {
                    currentFrame = 3 // Hold pose (1.8s total across ticks 2, 3, and 4)
                }
            }
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}
