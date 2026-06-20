internal import SwiftUI
internal import Charts

struct MinutesStatsDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    
    @State private var ringProgress: Double = 0
    @State private var animateBackground = false

    var body: some View {
        ZStack {
            // Dark glassmorphic background
            Color.black.ignoresSafeArea()
            
            // Subtle ambient glows
            VStack {
                Circle()
                    .fill(Color.mint.opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(x: -80, y: -100)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Spacer()
                        Button {
                            HapticsManager.shared.playLightImpact()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .padding(.bottom, 4)

                    // Hero Stat: 3D Metallic Physical Well Ring
                    VStack(spacing: 12) {
                        ZStack {
                            // Outer Beveled Container Border
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
                                .fill(Color.black.opacity(0.55))
                                .frame(width: 166, height: 166)
                                .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
                            
                            // 3D Inner Well Shadow Ring
                            Circle()
                                .stroke(Color.white.opacity(0.03), lineWidth: 16)
                                .frame(width: 150, height: 150)
                            
                            // Background Ring Track
                            Circle()
                                .stroke(Color.white.opacity(0.05), lineWidth: 12)
                                .frame(width: 140, height: 140)
                            
                            // Animated Glowing Progress Ring
                            Circle()
                                .trim(from: 0, to: CGFloat(min(1.0, ringProgress)))
                                .stroke(
                                    LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 140, height: 140)
                                .rotationEffect(.degrees(-90))
                                .shadow(color: .mint.opacity(0.4), radius: 10)
                            
                            // Specular Light Highlight Overlay
                            Circle()
                                .trim(from: 0, to: CGFloat(min(1.0, ringProgress)))
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.45), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                )
                                .frame(width: 142, height: 142)
                                .rotationEffect(.degrees(-90))
                                .blur(radius: 0.5)
                            
                            VStack(spacing: 2) {
                                Text("\(app.completedMinutes)")
                                    .font(.system(size: 42, weight: .bold, design: .rounded).monospacedDigit())
                                    .foregroundStyle(.white)
                                    .shadow(color: .mint.opacity(0.2), radius: 6)
                                Text("Minutes")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.55))
                            }
                        }
                        .frame(width: 180, height: 180)
                        
                        Text("Total Practice Time")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                    
                    // Chart Area (Frosted Card)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Weekly Distribution")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("Minutes spent practicing each day")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            Spacer()
                            Image(systemName: "chart.bar.xaxis")
                                .font(.title3)
                                .foregroundStyle(.mint)
                        }
                        
                        if app.weeklyActivity.isEmpty {
                            Text("No sessions recorded this week yet.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                        } else {
                            Chart(Array(app.weeklyActivity.enumerated()), id: \.offset) { item in
                                BarMark(
                                    x: .value("Day", item.element.label),
                                    y: .value("Minutes", item.element.minutes)
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
                                        .foregroundStyle(Color.white.opacity(0.7))
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                }
                            }
                            .frame(height: 160)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.15), .white.opacity(0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                    
                    // Bento Stats Grid with 3D Tilt Cards
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        MetricCard(
                            title: "Sessions Done",
                            value: "\(app.sessions.count)",
                            subtitle: "Total sessions",
                            systemImage: "figure.yoga",
                            color: .mint
                        )
                        .card3DTilt()
                        
                        MetricCard(
                            title: "Daily Goal",
                            value: "\(app.sessionLengthMinutes) min",
                            subtitle: "Target duration",
                            systemImage: "target",
                            color: .teal
                        )
                        .card3DTilt()
                        
                        MetricCard(
                            title: "Avg Session",
                            value: app.sessions.isEmpty ? "0 min" : "\(app.completedMinutes / app.sessions.count) min",
                            subtitle: "Computed average",
                            systemImage: "chart.bar.fill",
                            color: .blue
                        )
                        .card3DTilt()
                        
                        MetricCard(
                            title: "Target Days",
                            value: "\(app.weeklyTargetDays)",
                            subtitle: "Target days/week",
                            systemImage: "calendar",
                            color: .purple
                        )
                        .card3DTilt()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            animateBackground = true
            withAnimation(.easeOut(duration: 1.5)) {
                ringProgress = Double(app.completedMinutes) / 100.0
            }
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(color)
                        .shadow(color: color.opacity(0.3), radius: 4)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(.system(.title3, design: .rounded).bold().monospacedDigit())
                    .foregroundStyle(.white)
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.12), .white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}
