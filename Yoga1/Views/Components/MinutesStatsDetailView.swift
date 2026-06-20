internal import SwiftUI
internal import Charts

struct MinutesStatsDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Dark glassmorphic background
            Color.black.ignoresSafeArea()
            
            // Subtle ambient glows
            VStack {
                Circle()
                    .fill(Color.mint.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
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
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    .padding(.bottom, 8)

                    // Hero Stat: Large Glowing Minutes Ring
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.08), lineWidth: 12)
                                .frame(width: 140, height: 140)
                            
                            // Glowing Ring progress
                            Circle()
                                .trim(from: 0, to: CGFloat(min(1.0, Double(app.completedMinutes) / 100.0))) // relative to 100 min milestone
                                .stroke(
                                    LinearGradient(colors: [.mint, .teal], startPoint: .top, endPoint: .bottom),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 140, height: 140)
                                .rotationEffect(.degrees(-90))
                                .shadow(color: .mint.opacity(0.4), radius: 12)
                            
                            VStack(spacing: 2) {
                                Text("\(app.completedMinutes)")
                                    .font(.system(size: 38, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("Minutes")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        
                        Text("Total Practice Time")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.top, 8)
                    }
                    
                    // Chart Area
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weekly Distribution")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        if app.weeklyActivity.isEmpty {
                            Text("No sessions recorded this week yet.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                        } else {
                            Chart(Array(app.weeklyActivity.enumerated()), id: \.offset) { item in
                                BarMark(
                                    x: .value("Day", item.element.label),
                                    y: .value("Minutes", item.element.minutes)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.mint, .teal],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .cornerRadius(6)
                            }
                            .frame(height: 160)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                    )
                    
                    // Bento Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        MetricCard(
                            title: "Sessions Done",
                            value: "\(app.sessions.count)",
                            subtitle: "Total sessions",
                            systemImage: "figure.yoga",
                            color: .mint
                        )
                        
                        MetricCard(
                            title: "Daily Goal",
                            value: "\(app.sessionLengthMinutes) min",
                            subtitle: "Target duration",
                            systemImage: "target",
                            color: .teal
                        )
                        
                        MetricCard(
                            title: "Avg Session",
                            value: app.sessions.isEmpty ? "0 min" : "\(app.completedMinutes / app.sessions.count) min",
                            subtitle: "Computed average",
                            systemImage: "chart.bar.fill",
                            color: .blue
                        )
                        
                        MetricCard(
                            title: "Target Days",
                            value: "\(app.weeklyTargetDays)",
                            subtitle: "Target days/week",
                            systemImage: "calendar",
                            color: .purple
                        )
                    }
                }
                .padding()
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
                        .frame(width: 32, height: 32)
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(color)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(.white)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
    }
}

#Preview {
    MinutesStatsDetailView()
        .environment(AppState())
}
