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
            // Dark base background
            Color.black.ignoresSafeArea()
            
            // Neon accent blobs
            VStack {
                HStack {
                    Circle()
                        .fill(pose.gradient.first?.opacity(0.18) ?? .mint.opacity(0.15))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .offset(x: -80, y: -50)
                    Spacer()
                    Circle()
                        .fill(pose.gradient.last?.opacity(0.18) ?? .indigo.opacity(0.15))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .offset(x: 80, y: -20)
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // --- HEADER SECTION ---
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(isRussian ? "ИНСТРУКЦИЯ ИИ" : "AI ANALYSIS")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(LinearGradient(colors: pose.gradient, startPoint: .leading, endPoint: .trailing))
                                .tracking(2.0)
                            
                            Text(pose.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text(pose.sanskrit)
                                .font(.system(size: 15, weight: .medium, design: .serif).italic())
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        // Close button
                        Button {
                            HapticsManager.shared.playLightImpact()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(10)
                                .background(Color.white.opacity(0.08), in: Circle())
                                .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 16)
                    
                    // --- INTERACTIVE AI HOLOGRAM RADAR ---
                    ZStack {
                        // Background radar rings
                        Circle()
                            .stroke(Color.white.opacity(0.03), lineWidth: 1)
                            .frame(width: 170, height: 170)
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 1.5)
                            .frame(width: 130, height: 130)
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 2)
                            .frame(width: 90, height: 90)
                        
                        // Rotating dashed outer scan ring
                        Circle()
                            .trim(from: 0, to: 0.6)
                            .stroke(
                                LinearGradient(colors: pose.gradient, startPoint: .top, endPoint: .bottom),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [8, 12])
                            )
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(rotateScanner ? 360 : 0))
                        
                        // Animated scanner sweeping line (radar wave)
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [pose.gradient.first?.opacity(0.25) ?? .mint.opacity(0.25), .clear]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 75
                                )
                            )
                            .frame(width: 150, height: 150)
                            .scaleEffect(scanAnimation ? 1.05 : 0.9)
                        
                        // Holographic Laser scan line
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, pose.gradient.first?.opacity(0.5) ?? .mint, .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 3)
                            .offset(y: scanAnimation ? 65 : -65)
                            .blur(radius: 1)
                        
                        // Central Icon representing pose
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: pose.gradient.map { $0.opacity(0.2) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 76, height: 76)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(colors: pose.gradient.map { $0.opacity(0.6) }, startPoint: .topLeading, endPoint: .bottomTrailing),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: pose.gradient.first?.opacity(0.4) ?? .clear, radius: 15)
                            
                            Image(systemName: "figure.yoga")
                                .font(.system(size: 38))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.3), radius: 4)
                        }
                        
                        // AI active badge
                        VStack {
                            Spacer()
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 6, height: 6)
                                    .scaleEffect(scanAnimation ? 1.3 : 0.9)
                                Text(isRussian ? "ИИ АКТИВЕН" : "AI SCANNER ACTIVE")
                                    .font(.system(size: 8, weight: .bold, design: .rounded))
                                    .foregroundStyle(.green)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.green.opacity(0.08), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.green.opacity(0.2), lineWidth: 1))
                            .offset(y: 85)
                        }
                    }
                    .frame(height: 180)
                    
                    // --- TARGET MUSCLES ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text(isRussian ? "Целевые зоны" : "Targeted Muscles")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 4)
                        
                        HStack(spacing: 8) {
                            ForEach(aiData.targetedMuscles, id: \.self) { muscle in
                                Text(muscle)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(Color.white.opacity(0.06), in: Capsule())
                                    .overlay(
                                        Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // --- POSE INSTRUCTIONS (STEPS) ---
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "list.number")
                                .font(.system(size: 16))
                                .foregroundStyle(pose.gradient.first ?? .mint)
                            Text(isRussian ? "Инструкция к позе" : "Practice Steps")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(pose.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(pose.gradient.first ?? .mint)
                                        .frame(width: 20, height: 20)
                                        .background(pose.gradient.first?.opacity(0.12) ?? .clear, in: Circle())
                                    
                                    Text(step)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.8))
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    
                    // --- CATEGORY ANALYSIS CARD ---
                    let categoryData = YogaPoseAIContent.getCategoryAnalysis(for: pose.category)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(pose.category.tint)
                            
                            Text(isRussian 
                                 ? "ИИ-АНАЛИЗ КАТЕГОРИИ: \(pose.category.title.uppercased())" 
                                 : "AI CATEGORY ANALYSIS: \(pose.category.title.uppercased())")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                                .tracking(1.5)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(pose.category.tint)
                                    .frame(width: 5, height: 5)
                                Text(isRussian ? "АКТИВЕН" : "ACTIVE")
                                    .font(.system(size: 8, weight: .bold, design: .rounded))
                                    .foregroundStyle(pose.category.tint)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(pose.category.tint.opacity(0.08), in: Capsule())
                            .overlay(Capsule().strokeBorder(pose.category.tint.opacity(0.2), lineWidth: 1))
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // Category Overview
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isRussian ? "Описание направления" : "Category Overview")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.55))
                                
                                Text(categoryData.description)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.85))
                                    .lineSpacing(3)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.06))
                            
                            // AI Technique Guide
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isRussian ? "Техника ИИ" : "AI Technique Guide")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.55))
                                
                                Text(categoryData.technique)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(pose.category.tint.opacity(0.9))
                                    .lineSpacing(3)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.06))
                            
                            // Target Poses Overview
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isRussian ? "Состав комплекса поз" : "Target Poses Overview")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.55))
                                
                                Text(categoryData.posesOverview)
                                    .font(.system(size: 12, weight: .medium).italic())
                                    .foregroundStyle(.white.opacity(0.7))
                                    .lineSpacing(3)
                            }
                        }
                    }
                    .padding(18)
                    .background(
                        LinearGradient(
                            colors: [pose.category.tint.opacity(0.04), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(Color.white.opacity(0.02))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [pose.category.tint.opacity(0.25), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    
                    // --- AI TECHNIQUE REVIEW ---
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16))
                                .foregroundStyle(pose.gradient.first ?? .mint)
                            Text(isRussian ? "Анализ техники от ИИ" : "AI Technique Analysis")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        Text(aiData.technique)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(5)
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                    )
                    
                    // --- PROS & CONS (DOCK COLUMN GRID) ---
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                        
                        // Pros (Benefits)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.mint)
                                Text(isRussian ? "Плюсы" : "Benefits")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(aiData.pros, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .font(.body)
                                            .foregroundStyle(.mint)
                                        Text(item)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.75))
                                            .lineLimit(3)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(
                            LinearGradient(
                                colors: [Color.mint.opacity(0.05), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.mint.opacity(0.18), lineWidth: 1)
                        )
                        
                        // Cons (Precautions)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.orange)
                                Text(isRussian ? "Минусы" : "Risks")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(aiData.cons, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .font(.body)
                                            .foregroundStyle(.orange)
                                        Text(item)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.75))
                                            .lineLimit(3)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.04), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.orange.opacity(0.18), lineWidth: 1)
                        )
                    }
                    
                    // --- GOLDEN AI PRO TIP ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.yellow)
                            Text(isRussian ? "ИИ-Совет" : "AI Pro-Tip")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        Text(aiData.aiTip)
                            .font(.system(size: 13, weight: .medium).italic())
                            .foregroundStyle(.yellow.opacity(0.9))
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.04), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.yellow.opacity(0.25), lineWidth: 1.2)
                    )
                    
                    // --- LAUNCH AI COACH BUTTON ---
                    VStack(spacing: 12) {
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
                    .padding(.top, 8)
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
