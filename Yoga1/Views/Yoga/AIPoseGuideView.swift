internal import SwiftUI

struct AIPoseGuideView: View {
    @Environment(\.dismiss) private var dismiss
    let pose: YogaPose
    var onStartCamera: (() -> Void)? = nil
    var onStartPractice: (() -> Void)? = nil
    
    @State private var scanAnimation = false
    @State private var rotateScanner = false
    @State private var appearAnimation = false
    
    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }
    
    private var aiData: AIPoseAnalysisData {
        YogaPoseAIContent.getAnalysis(for: pose.key)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Neon accent blobs - positioned cleanly without layout stretching
            ZStack {
                Circle()
                    .fill(pose.gradient.first?.opacity(0.18) ?? .mint.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: -80, y: -50)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                Circle()
                    .fill(pose.gradient.last?.opacity(0.18) ?? .indigo.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: 80, y: -20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                
                // --- HEADER SECTION ---
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(isRussian ? "ИНСТРУКЦИЯ ИИ" : "AI ANALYSIS")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: pose.gradient, startPoint: .leading, endPoint: .trailing))
                            .tracking(2.0)
                        
                        Text(pose.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.8)
                        
                        Text(pose.sanskrit)
                            .font(.system(size: 13, weight: .medium, design: .serif).italic())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    // Close button
                    Button {
                        HapticsManager.shared.playLightImpact()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(9)
                            .background(Color.white.opacity(0.08), in: Circle())
                            .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 16)
                
                // --- INTERACTIVE AI HOLOGRAM RADAR ---
                VStack(spacing: 12) {
                    ZStack {
                        // Background radar rings
                        Circle()
                            .stroke(Color.white.opacity(0.03), lineWidth: 1)
                            .frame(width: 120, height: 120)
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 1.5)
                            .frame(width: 95, height: 95)
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 2)
                            .frame(width: 70, height: 70)
                        
                        // Rotating dashed outer scan ring
                        Circle()
                            .trim(from: 0, to: 0.6)
                            .stroke(
                                LinearGradient(colors: pose.gradient, startPoint: .top, endPoint: .bottom),
                                style: StrokeStyle(lineWidth: 2.0, lineCap: .round, dash: [6, 10])
                            )
                            .frame(width: 108, height: 108)
                            .rotationEffect(.degrees(rotateScanner ? 360 : 0))
                        
                        // Animated scanner sweeping line (radar wave)
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [pose.gradient.first?.opacity(0.22) ?? .mint.opacity(0.22), .clear]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 54
                                )
                            )
                            .frame(width: 108, height: 108)
                            .scaleEffect(scanAnimation ? 1.05 : 0.9)
                        
                        // Holographic Laser scan line
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, pose.gradient.first?.opacity(0.4) ?? .mint, .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 2)
                            .offset(y: scanAnimation ? 48 : -48)
                            .blur(radius: 0.8)
                        
                        // Central Icon representing pose
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: pose.gradient.map { $0.opacity(0.2) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(colors: pose.gradient.map { $0.opacity(0.6) }, startPoint: .topLeading, endPoint: .bottomTrailing),
                                            lineWidth: 1.2
                                        )
                                )
                                .shadow(color: pose.gradient.first?.opacity(0.4) ?? .clear, radius: 10)
                            
                            AnimatedPoseView(pose: pose, size: 56)
                        }
                    }
                    .frame(height: 120)
                    
                    // AI active badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 5, height: 5)
                            .scaleEffect(scanAnimation ? 1.3 : 0.9)
                        Text(isRussian ? "ИИ АКТИВЕН" : "AI SCANNER ACTIVE")
                            .font(.system(size: 7, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.08), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.green.opacity(0.2), lineWidth: 1))
                }
                
                // --- TARGET MUSCLES ---
                VStack(alignment: .leading, spacing: 8) {
                    Text(isRussian ? "Целевые зоны" : "Targeted Muscles")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 4)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(aiData.targetedMuscles, id: \.self) { muscle in
                                Text(muscle)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.white.opacity(0.06), in: Capsule())
                                    .overlay(
                                        Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // --- LAUNCH AI COACH BUTTONS (LIFTED UP!) ---
                VStack(spacing: 10) {
                    if let onStartCamera {
                        Button {
                            HapticsManager.shared.playSuccess()
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onStartCamera()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 16, weight: .bold))
                                Text(isRussian ? "Начать с ИИ-тренером" : "Practice with AI Coach")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: pose.gradient, startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                            .shadow(color: pose.gradient.first?.opacity(0.4) ?? .clear, radius: 10, y: 4)
                        }
                        .buttonStyle(.tactile)
                    }
                    
                    if let onStartPractice {
                        Button {
                            HapticsManager.shared.playLightImpact()
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onStartPractice()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14))
                                Text(isRussian ? "Стандартная практика" : "Start Standard Practice")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().strokeBorder(Color.white.opacity(0.15), lineWidth: 1.2)
                            )
                        }
                        .buttonStyle(.tactile)
                    }
                }
                .padding(.top, 4)
                
                // --- POSE INSTRUCTIONS (STEPS) ---
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "list.number")
                            .font(.system(size: 14))
                            .foregroundStyle(pose.gradient.first ?? .mint)
                        Text(isRussian ? "Инструкция к позе" : "Practice Steps")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(pose.instructions.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(pose.gradient.first ?? .mint)
                                    .frame(width: 18, height: 18)
                                    .background(pose.gradient.first?.opacity(0.12) ?? .clear, in: Circle())
                                
                                Text(step)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.02))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                
                // --- AI INSIGHTS CAROUSEL ---
                let categoryData = YogaPoseAIContent.getCategoryAnalysis(for: pose.category)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles.dialogues")
                            .font(.system(size: 14))
                            .foregroundStyle(pose.gradient.first ?? .mint)
                        Text(isRussian ? "Анализ и советы ИИ" : "AI Insights & Tips")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 4)
                    
                    TabView {
                        // 1. Technique
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(pose.gradient.first ?? .mint)
                                Text(isRussian ? "Техника ИИ" : "AI Technique")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            
                            Text(aiData.technique)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineSpacing(3)
                                .lineLimit(5)
                            Spacer()
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(Color.white.opacity(0.02))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                        )
                        .padding(.horizontal, 4)
                        
                        // 2. Pro-Tip
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.yellow)
                                Text(isRussian ? "ИИ-Совет" : "AI Pro-Tip")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            
                            Text(aiData.aiTip)
                                .font(.system(size: 11, weight: .medium).italic())
                                .foregroundStyle(.yellow.opacity(0.85))
                                .lineSpacing(3)
                                .lineLimit(5)
                            Spacer()
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(Color.yellow.opacity(0.02))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.yellow.opacity(0.12), lineWidth: 1)
                        )
                        .padding(.horizontal, 4)
                        
                        // 3. Benefits & Risks
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.mint)
                                Text(isRussian ? "Плюсы и Риски" : "Benefits & Risks")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                // Pros
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(aiData.pros.prefix(2), id: \.self) { item in
                                        HStack(alignment: .top, spacing: 4) {
                                            Text("•")
                                                .foregroundStyle(.mint)
                                            Text(item)
                                                .font(.system(size: 9, weight: .medium))
                                                .foregroundStyle(.white.opacity(0.75))
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Cons
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(aiData.cons.prefix(2), id: \.self) { item in
                                        HStack(alignment: .top, spacing: 4) {
                                            Text("•")
                                                .foregroundStyle(.orange)
                                            Text(item)
                                                .font(.system(size: 9, weight: .medium))
                                                .foregroundStyle(.white.opacity(0.75))
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(Color.white.opacity(0.02))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                        )
                        .padding(.horizontal, 4)
                        
                        // 4. Category Style description
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(pose.category.tint)
                                Text(isRussian ? "Направление: \(pose.category.title)" : "Style: \(pose.category.title)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            
                            Text(categoryData.description)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineSpacing(3)
                                .lineLimit(5)
                            Spacer()
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(pose.category.tint.opacity(0.02))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(pose.category.tint.opacity(0.12), lineWidth: 1)
                        )
                        .padding(.horizontal, 4)
                    }
                    .frame(height: 165)
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal)
        }
        }
        .opacity(appearAnimation ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) {
                appearAnimation = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scanAnimation = true
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotateScanner = true
            }
        }
    }
}

#Preview {
    AIPoseGuideView(
        pose: YogaLibrary.poses[0],
        onStartCamera: {},
        onStartPractice: {}
    )
}
