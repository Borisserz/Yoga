internal import SwiftUI
internal import Charts

struct AIDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    
    @State private var ringProgress: Double = 0
    @State private var animateBackground = false
    
    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    private var aiSessions: [SessionRecord] {
        app.sessions.filter { $0.accuracy != nil }
    }

    private var averageScore: Int {
        let scores = aiSessions.compactMap { $0.accuracy }
        guard !scores.isEmpty else { return 0 }
        return Int((scores.reduce(0, +) / Double(scores.count)) * 100)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Neon mint/teal glowing backgrounds
            VStack {
                HStack {
                    Circle()
                        .fill(Color.mint.opacity(0.12))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: -60, y: -80)
                    Spacer()
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // --- HEADER ---
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(isRussian ? "ДЕТАЛИ ИИ" : "AI TRACKING")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(.mint)
                                .tracking(1.5)
                            Text(isRussian ? "Точность Асан" : "Pose Accuracy")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Button {
                            HapticsManager.shared.playLightImpact()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                    
                    // --- HERO ACCURACY DIAL ---
                    VStack(spacing: 12) {
                        ZStack {
                            // Holographic Outer Beveled Ring
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.15), .clear, .white.opacity(0.02)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 170, height: 170)
                            
                            // Recessed 3D Well Base
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 166, height: 166)
                                .shadow(color: .black.opacity(0.6), radius: 8, y: 4)
                            
                            // Background Ring Track
                            Circle()
                                .stroke(Color.white.opacity(0.05), lineWidth: 12)
                                .frame(width: 140, height: 140)
                            
                            // Animated Glowing Progress Ring
                            Circle()
                                .trim(from: 0, to: CGFloat(min(1.0, ringProgress)))
                                .stroke(
                                    LinearGradient(colors: [.mint, .teal, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 140, height: 140)
                                .rotationEffect(.degrees(-90))
                                .shadow(color: .mint.opacity(0.4), radius: 10)
                            
                            VStack(spacing: 2) {
                                if app.lastSessionScore > 0 {
                                    Text("\(Int(ringProgress * 100))%")
                                        .font(.system(size: 38, weight: .bold, design: .rounded).monospacedDigit())
                                        .foregroundStyle(.white)
                                        .shadow(color: .mint.opacity(0.3), radius: 6)
                                    Text(isRussian ? "Мин. точность" : "Last Accuracy")
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.5))
                                } else {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.white.opacity(0.3))
                                    Text(isRussian ? "Нет данных" : "No Data")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }
                        }
                        .frame(width: 180, height: 180)
                        
                        Text(isRussian ? "Качество Асаны с ИИ" : "Pose Accuracy Score")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 8)
                    
                    // --- STATISTICS CARDS ---
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(isRussian ? "ИИ Сессии" : "AI Sessions")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                            Text("\(aiSessions.count)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.06), lineWidth: 1))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(isRussian ? "Средняя Оценка" : "Average Score")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                            Text(averageScore > 0 ? "\(averageScore)%" : "—")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.mint)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.06), lineWidth: 1))
                    }
                    
                    // --- HOW IT WORKS & TIPS ---
                    VStack(alignment: .leading, spacing: 16) {
                        Text(isRussian ? "Инструкция для калибровки" : "Calibration Guide")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            TipRow(icon: "arrow.left.and.right.righttriangle.left.righttriangle.right", color: .mint,
                                   title: isRussian ? "Расстояние 2 метра" : "2 Meters Distance",
                                   desc: isRussian ? "Отойдите на 2 метра от камеры, чтобы ваше тело полностью попадало в кадр от головы до ног." : "Place your device 2 meters away. Your entire body from head to toe must be visible to the camera.")
                            
                            Divider().background(Color.white.opacity(0.06))
                            
                            TipRow(icon: "sun.max.fill", color: .yellow,
                                   title: isRussian ? "Хороший свет" : "Good Lighting",
                                   desc: isRussian ? "Встаньте лицом к источнику света. Избегайте окон непосредственно позади вас." : "Make sure you face the light source. Avoid having bright windows directly behind you.")
                            
                            Divider().background(Color.white.opacity(0.06))
                            
                            TipRow(icon: "tshirt.fill", color: .orange,
                                   title: isRussian ? "Облегающая одежда" : "Form-Fitting Attire",
                                   desc: isRussian ? "Наденьте облегающую форму, чтобы искусственный интеллект точно определял ключевые точки и суставы." : "Wear fitting activewear so that key joints can be accurately tracked by the model.")
                            
                            Divider().background(Color.white.opacity(0.06))
                            
                            TipRow(icon: "person.and.arrow.left.and.right", color: .teal,
                                   title: isRussian ? "Совпадение контуров" : "Silhouette Match",
                                   desc: isRussian ? "Старайтесь точно сопоставлять позы с зеленым контуром йога на экране телефона." : "Align your body positions as closely as possible to the green guide overlays on the screen.")
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.02), in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.2)
                    )
                    
                    // --- RECENT SESSIONS TREND ---
                    if !aiSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(isRussian ? "История точности" : "Accuracy History")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 12) {
                                ForEach(aiSessions.suffix(5).reversed()) { session in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(session.poseKey != nil ? YogaLibrary.displayName(forKey: session.poseKey!) : (isRussian ? "Общая сессия" : "General session"))
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white)
                                            
                                            Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                                .font(.system(size: 10))
                                                .foregroundStyle(.white.opacity(0.4))
                                        }
                                        
                                        Spacer()
                                        
                                        if let accuracy = session.accuracy {
                                            Text("\(Int(accuracy * 100))%")
                                                .font(.system(size: 16, weight: .bold, design: .rounded).monospacedDigit())
                                                .foregroundStyle(accuracy > 0.8 ? .mint : accuracy > 0.6 ? .yellow : .orange)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(
                                                    (accuracy > 0.8 ? Color.mint : accuracy > 0.6 ? Color.yellow : Color.orange).opacity(0.08),
                                                    in: Capsule()
                                                )
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    if session.id != aiSessions.suffix(5).first?.id {
                                        Divider().background(Color.white.opacity(0.05))
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.02), in: RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.2)
                        )
                    }
                }
                .padding()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                ringProgress = Double(app.lastSessionScore) / 100.0
            }
        }
    }
}

private struct TipRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineSpacing(3)
            }
        }
    }
}

#Preview {
    AIDetailView()
        .environment(AppState())
}
