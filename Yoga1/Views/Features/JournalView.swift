internal import SwiftUI
internal import Charts

struct JournalView: View {
    @Environment(AppState.self) private var app
    @State private var text = ""
    @State private var animateBackground = false
    @FocusState private var isEditorFocused: Bool
    @State private var editorPulse = false
    @State private var timelineNodePulse = false
    @State private var isChartAnimated = false
    
    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    init() {}

    private var entryDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = .current
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground(animate: $animateBackground)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Activity Card (Premium glass card with 3D Parallax Tilt)
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Weekly Activity")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text("Your practice consistency this week")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                Spacer()
                                Image(systemName: "waveform.path.ecg")
                                    .font(.title3)
                                    .foregroundStyle(.mint)
                                    .shadow(color: .mint.opacity(0.3), radius: 5)
                            }
                            
                            Chart(Array(app.weeklyActivity.enumerated()), id: \.offset) { item in
                                BarMark(
                                    x: .value("Day", item.element.label),
                                    y: .value("Minutes", isChartAnimated ? Double(item.element.minutes) : 0.0)
                                )
                                .foregroundStyle(
                                    LinearGradient(colors: [.mint, .teal], startPoint: .bottom, endPoint: .top)
                                )
                                .cornerRadius(6)
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                        .foregroundStyle(Color.white.opacity(0.08))
                                    AxisValueLabel()
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.system(size: 9, weight: .semibold))
                                }
                            }
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisGridLine().foregroundStyle(Color.white.opacity(0.04))
                                    AxisValueLabel()
                                        .foregroundStyle(Color.white.opacity(0.75))
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                }
                            }
                            .frame(height: 160)
                            .padding(.vertical, 4)
                            .onAppear {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.72).delay(0.15)) {
                                    isChartAnimated = true
                                }
                            }

                            HStack(spacing: 12) {
                                StatBadge(title: "Total minutes", value: "\(app.completedMinutes)", icon: "clock.fill", gradientColors: [.mint, .teal])
                                StatBadge(title: "Streak", value: "\(app.streakDays)", icon: "flame.fill", gradientColors: [.orange, .red])
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.18), .white.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                        .card3DTilt(maxTilt: 10.0, cornerRadius: 28.0)

                        // --- POSE MASTERY TRACKER ---
                        let masteredPoses = Set(app.sessions.compactMap { $0.poseKey })
                        let masteredCount = masteredPoses.count
                        let totalPoses = YogaLibrary.poses.count
                        
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(isRussian ? "Мастерство поз" : "Pose Mastery")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text(isRussian ? "Практикуйте позы, чтобы разблокировать их" : "Practice poses to unlock them all")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                Spacer()
                                
                                Text("\(masteredCount) / \(totalPoses)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded).monospacedDigit())
                                    .foregroundStyle(.mint)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.mint.opacity(0.08), in: Capsule())
                            }
                            
                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(height: 6)
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(colors: [.mint, .teal], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .frame(width: max(6, geo.size.width * CGFloat(Double(masteredCount) / Double(totalPoses))), height: 6)
                                        .shadow(color: .mint.opacity(0.4), radius: 4)
                                }
                            }
                            .frame(height: 6)
                            .padding(.bottom, 6)
                            
                            // Grid of poses
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 14) {
                                ForEach(YogaLibrary.poses) { pose in
                                    let isMastered = masteredPoses.contains(pose.key)
                                    
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    isMastered
                                                    ? AnyShapeStyle(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                                                    : AnyShapeStyle(Color.white.opacity(0.03))
                                                )
                                                .frame(width: 46, height: 46)
                                                .shadow(color: isMastered ? pose.gradient.first?.opacity(0.3) ?? .clear : .clear, radius: 4, y: 2)
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(isMastered ? Color.white.opacity(0.15) : Color.white.opacity(0.06), lineWidth: 1)
                                                )
                                            
                                            if isMastered {
                                                Image(systemName: "figure.yoga")
                                                    .font(.system(size: 18))
                                                    .foregroundStyle(.white)
                                                    .shadow(color: .black.opacity(0.2), radius: 2)
                                            } else {
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(.white.opacity(0.15))
                                            }
                                        }
                                        
                                        Text(pose.name)
                                            .font(.system(size: 9, weight: .bold, design: .rounded))
                                            .foregroundStyle(isMastered ? .white : .white.opacity(0.35))
                                            .lineLimit(1)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 4)
                                    .background(isMastered ? Color.white.opacity(0.01) : Color.clear)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.18), .white.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                        .card3DTilt(maxTilt: 6.0, cornerRadius: 28.0)

                        // New entry card (Pulsing border editor)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Reflect on your practice")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            TextEditor(text: $text)
                                .scrollContentBackground(.hidden)
                                .focused($isEditorFocused)
                                .frame(height: 100)
                                .padding(12)
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .strokeBorder(
                                            isEditorFocused
                                            ? AnyShapeStyle(LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            : AnyShapeStyle(Color.white.opacity(0.06)),
                                            lineWidth: 1.2
                                        )
                                        .shadow(
                                            color: .mint.opacity(isEditorFocused ? (editorPulse ? 0.6 : 0.2) : (editorPulse ? 0.15 : 0.05)),
                                            radius: isEditorFocused ? 8 : 3
                                        )
                                )
                                .foregroundStyle(.white)
                                .onChange(of: isEditorFocused) { _, focused in
                                    // Make border pulse regardless, but stronger when focused
                                    resetEditorPulse()
                                }
                                .onAppear {
                                    resetEditorPulse()
                                }

                            HStack {
                                Spacer()
                                Button {
                                    app.addEntry(text)
                                    text = ""
                                    isEditorFocused = false
                                    HapticsManager.shared.playSuccess()
                                } label: {
                                    Text("Save reflections")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white.opacity(0.3) : Color.black)
                                        .padding(.horizontal, 22)
                                        .padding(.vertical, 12)
                                        .background(
                                            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                            ? AnyShapeStyle(Color.white.opacity(0.08))
                                            : AnyShapeStyle(LinearGradient(colors: [.mint, .teal], startPoint: .leading, endPoint: .trailing)),
                                            in: Capsule()
                                        )
                                        .shadow(color: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .clear : .mint.opacity(0.35), radius: 8, y: 3)
                                }
                                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .buttonStyle(.tactile)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.02), in: RoundedRectangle(cornerRadius: 28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.2)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 8)

                        // History Timeline
                        if !app.journalEntries.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Journal History")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.bottom, 4)
                                
                                ForEach(Array(app.journalEntries.enumerated()), id: \.element.id) { index, entry in
                                    JournalEntryRow(
                                        entry: entry,
                                        index: index,
                                        isFirst: index == 0,
                                        isLast: index == app.journalEntries.count - 1,
                                        timelineNodePulse: timelineNodePulse,
                                        entryDateFormatter: entryDateFormatter
                                    )
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .onAppear {
                animateBackground = true
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    timelineNodePulse = true
                }
            }
        }
    }

    private func resetEditorPulse() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            editorPulse = true
        }
    }
}

private struct StatBadge: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String
    let gradientColors: [Color]
    @State private var shineOffset: CGFloat = -100

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(gradientColors.first?.opacity(0.12) ?? .clear)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom))
                    .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 4)
            }
            
            Text(value)
                .font(.system(.title3, design: .rounded).bold().monospacedDigit())
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.02), in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.12), .clear, .white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .overlay(
            GeometryReader { geo in
                Color.white.opacity(0.06)
                    .frame(width: 30, height: 180)
                    .rotationEffect(.degrees(25))
                    .offset(x: shineOffset)
                    .blur(radius: 6)
                    .allowsHitTesting(false)
            }
            .clipped()
            .mask(RoundedRectangle(cornerRadius: 22))
        )
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        .card3DTilt(maxTilt: 12.0, cornerRadius: 22.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: false)) {
                shineOffset = 220
            }
        }
    }
}

private struct JournalEntryRow: View {
    let entry: JournalEntry
    let index: Int
    let isFirst: Bool
    let isLast: Bool
    let timelineNodePulse: Bool
    let entryDateFormatter: DateFormatter
    @State private var animateIn = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Organic Timeline Node
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .stroke(LinearGradient(colors: [.mint, .teal], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        .frame(width: 18, height: 18)
                    
                    Circle()
                        .fill(Color.mint)
                        .frame(width: 8, height: 8)
                        .shadow(color: .mint.opacity(0.8), radius: 4)
                    
                    if isFirst {
                        Circle()
                            .stroke(Color.mint.opacity(0.4), lineWidth: 1)
                            .frame(width: 26, height: 26)
                            .scaleEffect(timelineNodePulse ? 1.35 : 0.95)
                            .opacity(timelineNodePulse ? 0.0 : 1.0)
                    }
                }
                .frame(height: 26)
                
                if !isLast {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(
                            LinearGradient(
                                colors: [.mint.opacity(0.4), .white.opacity(0.06)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(minHeight: 60)
                }
            }
            .padding(.top, 4)
            
            // Frosted Card
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entryDateFormatter.string(from: entry.date))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.mint)
                    Spacer()
                    Image(systemName: "quote.opening")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.2))
                }
                
                Text(entry.text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.12), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
            .card3DTilt(maxTilt: 6.0, cornerRadius: 22.0)
        }
        .offset(y: animateIn ? 0 : 30)
        .opacity(animateIn ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78).delay(Double(index) * 0.06)) {
                animateIn = true
            }
        }
    }
}
