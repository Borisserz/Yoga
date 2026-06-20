internal import SwiftUI

struct PoseDetailView: View {
    @Environment(AppState.self) private var app
    let pose: YogaPose
    @State private var progress: Double = 0
    @State private var isPlaying = false
    @State private var timer: Timer?
    @State private var showAICamera = false
    @State private var pulseOrb = false
    @State private var animateBackground = false
    @State private var showAIGuide = false

    init(pose: YogaPose) {
        self.pose = pose
    }

    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    var body: some View {
        ZStack {
            // Dark night background
            Color.black.ignoresSafeArea()

            // Dynamic ambient background glow matching pose gradient
            VStack {
                Circle()
                    .fill(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(y: -100)
                Spacer()
            }
            .ignoresSafeArea()

            AnimatedGradientBackground(animate: $animateBackground)

            ScrollView {
                VStack(spacing: 26) {
                    Spacer()

                    // Pulsing 3D-like progress dial
                    ZStack {
                        // Recessed track
                        Circle()
                            .stroke(Color.white.opacity(0.04), lineWidth: 12)
                            .frame(width: 220, height: 220)
                        
                        // Ambient inner glow
                        Circle()
                            .fill(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.08))
                            .frame(width: 210, height: 210)
                            .scaleEffect(pulseOrb ? 1.06 : 0.96)
                            .blur(radius: 4)

                        // Progress ring
                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(
                                LinearGradient(colors: pose.gradient, startPoint: .top, endPoint: .bottom),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 220, height: 220)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: pose.gradient.first?.opacity(0.4) ?? .clear, radius: 10)
                            .scaleEffect(pulseOrb ? 1.02 : 0.98)
                        
                        // Specular glass highlight ring
                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 224, height: 224)
                            .rotationEffect(.degrees(-90))
                            .blur(radius: 0.5)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "figure.yoga")
                                .font(.system(size: 40))
                                .foregroundStyle(LinearGradient(colors: pose.gradient, startPoint: .top, endPoint: .bottom))
                                .shadow(color: pose.gradient.first?.opacity(0.35) ?? .clear, radius: 6)
                            
                            Text(L("%lld / %lld sec", Int(progress * Double(pose.holdSeconds)), pose.holdSeconds))
                                .font(.system(size: 20, weight: .bold, design: .rounded).monospacedDigit())
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(height: 250)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                            pulseOrb = true
                        }
                    }

                    // Mantra Section
                    HStack(spacing: 14) {
                        Image(systemName: "quote.opening")
                            .font(.title3)
                            .foregroundStyle(pose.gradient.first ?? .mint)
                        Text(L("Mantra: %@", pose.mantra))
                            .font(.system(size: 14, weight: .semibold, design: .serif).italic())
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(LinearGradient(colors: pose.gradient.map { $0.opacity(0.04) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.2)
                    )
                    .padding(.horizontal)

                    // Step Instructions List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Practice Steps")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(pose.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(spacing: 14) {
                                    // Step Number Pin
                                    ZStack {
                                        Circle()
                                            .fill(pose.gradient.first?.opacity(0.15) ?? Color.white.opacity(0.04))
                                            .frame(width: 28, height: 28)
                                        Text("\(index + 1)")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundStyle(pose.gradient.first ?? .mint)
                                    }
                                    
                                    Text(step)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.8))
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer()
                                }
                                .padding(14)
                                .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.0)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // AI Technique & Benefits button
                    Button {
                        HapticsManager.shared.playLightImpact()
                        showAIGuide = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(pose.gradient.first ?? .mint)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isRussian ? "Инструкция ИИ и Плюсы/Минусы" : "AI Technique & Benefits")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(isRussian ? "Подробный разбор выполнения от тренера" : "Detailed breakdown and precautions")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    LinearGradient(colors: pose.gradient.map { $0.opacity(0.3) }, startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1.2
                                )
                        )
                    }
                    .buttonStyle(.tactile)
                    .padding(.horizontal)

                    // Control Buttons
                    HStack(spacing: 16) {
                        Button {
                            isPlaying ? stop() : start()
                        } label: {
                            Label(isPlaying ? "Pause Flow" : "Start Pose", systemImage: isPlaying ? "pause.fill" : "play.fill")
                                .font(.headline.bold())
                                .foregroundStyle(isPlaying ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    isPlaying ?
                                    AnyView(Color.white.opacity(0.08)) :
                                    AnyView(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(isPlaying ? Color.white.opacity(0.12) : Color.clear, lineWidth: 1)
                                )
                                .shadow(color: isPlaying ? .clear : (pose.gradient.first?.opacity(0.3) ?? .clear), radius: 8, y: 3)
                        }
                        .buttonStyle(.tactile)
                        
                        Button {
                            showAICamera = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.indigo.opacity(0.15))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.indigo)
                                    .shadow(color: .indigo.opacity(0.3), radius: 4)
                            }
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.indigo.opacity(0.4), lineWidth: 1.2)
                            )
                        }
                        .buttonStyle(.tactile)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(pose.name)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showAICamera) {
            AICameraSessionView(poseKey: pose.key)
        }
        .sheet(isPresented: $showAIGuide) {
            AIPoseGuideView(pose: pose, onStartCamera: {
                showAICamera = true
            })
        }
        .onAppear {
            animateBackground = true
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
