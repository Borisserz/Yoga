internal import SwiftUI

/// Browse the meditation library: a daily featured pick, category filters and
/// a card for every meditation.
struct MeditationLibraryView: View {
    @State private var category: MeditationCategory?
    @State private var animateBackground = false

    init() {}

    private var items: [Meditation] {
        MeditationLibrary.meditations(in: category)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground(animate: $animateBackground)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Find your calm")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                        
                        NavigationLink {
                            MeditationDetailView(meditation: MeditationLibrary.featured)
                        } label: {
                            FeaturedMeditationCard(meditation: MeditationLibrary.featured)
                        }
                        .buttonStyle(.tactile)

                        MeditationCategoryRow(selection: $category)

                        LazyVStack(spacing: 12) {
                            ForEach(items) { meditation in
                                NavigationLink {
                                    MeditationDetailView(meditation: meditation)
                                } label: {
                                    MeditationRowCard(meditation: meditation)
                                }
                                .buttonStyle(.tactile)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Meditation")
            .onAppear { animateBackground = true }
        }
    }
}

// MARK: - Category chips

private struct MeditationCategoryRow: View {
    @Binding var selection: MeditationCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(L("med.cat.all"), "square.grid.2x2", .mint, selection == nil) { selection = nil }
                ForEach(MeditationCategory.allCases) { cat in
                    chip(cat.title, cat.icon, cat.tint, selection == cat) {
                        selection = (selection == cat) ? nil : cat
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func chip(_ title: String, _ icon: String, _ tint: Color,
                      _ active: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.weight(.bold))
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(active ? AnyShapeStyle(tint.opacity(0.85)) : AnyShapeStyle(Color.white.opacity(0.06)),
                        in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(active ? tint.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(active ? .white : .white.opacity(0.6))
        }
        .buttonStyle(.tactile)
    }
}

// MARK: - Cards

private struct FeaturedMeditationCard: View {
    let meditation: Meditation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(L("Today's pick"), systemImage: "sparkles")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.mint)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.mint.opacity(0.12), in: Capsule())
            
            Text(meditation.title)
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            Text(meditation.subtitle)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.65))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 12) {
                Label(L("%lld min", meditation.displayMinutes), systemImage: "clock")
                Label(meditation.guided ? L("Guided") : L("Timer"),
                      systemImage: meditation.guided ? "waveform" : "timer")
            }
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white.opacity(0.85))
            .padding(.top, 2)
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .bottomLeading)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThinMaterial)
        )
        .background(
            LinearGradient(colors: meditation.gradient.map { $0.opacity(0.25) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 26))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct MeditationRowCard: View {
    let meditation: Meditation

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: meditation.gradient,
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: meditation.category.icon)
                            .foregroundStyle(.white.opacity(0.9))
                    )
                    .shadow(color: meditation.gradient.first?.opacity(0.3) ?? .clear, radius: 4)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(meditation.title)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                Text(meditation.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(L("%lld min", meditation.displayMinutes))
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(.mint)
                Image(systemName: meditation.guided ? "waveform" : "timer")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Detail / launcher

struct MeditationDetailView: View {
    let meditation: Meditation
    @State private var selectedMinutes: Int
    @State private var showPlayer = false
    @State private var pulseOrb = false

    init(meditation: Meditation) {
        self.meditation = meditation
        _selectedMinutes = State(initialValue: meditation.guided
                                 ? meditation.guidedMinutes
                                 : (meditation.durationOptions.first ?? 10))
    }

    var body: some View {
        ZStack {
            // Dark premium background
            Color.black.ignoresSafeArea()

            // Soft ambient glow matching meditation category gradient
            VStack {
                Circle()
                    .fill(LinearGradient(colors: meditation.gradient, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(y: -100)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer()

                    // Pulsing Meditating Orb
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: meditation.gradient, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.08))
                            .frame(width: 200, height: 200)
                            .scaleEffect(pulseOrb ? 1.15 : 0.95)
                            .blur(radius: 5)
                        
                        Circle()
                            .stroke(LinearGradient(colors: meditation.gradient, startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.2), lineWidth: 1.5)
                            .frame(width: 170, height: 170)
                            .scaleEffect(pulseOrb ? 1.10 : 0.98)
                        
                        Image(systemName: meditation.category.icon)
                            .font(.system(size: 70))
                            .foregroundStyle(LinearGradient(colors: meditation.gradient, startPoint: .top, endPoint: .bottom))
                            .shadow(color: meditation.gradient.first?.opacity(0.4) ?? .clear, radius: 10)
                            .scaleEffect(pulseOrb ? 1.03 : 0.98)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                            pulseOrb = true
                        }
                    }

                    // Title & Description
                    VStack(spacing: 8) {
                        Text(meditation.title)
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text(meditation.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .lineSpacing(4)
                    }

                    // Details Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("MEDITATION STYLE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                Label(meditation.guided ? "Guided Flow" : "Silent Timer", systemImage: meditation.guided ? "waveform" : "timer")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("CATEGORY")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                                Label(meditation.category.title, systemImage: meditation.category.icon)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(meditation.gradient.first ?? .mint)
                            }
                        }

                        if meditation.guided {
                            Divider()
                                .background(Color.white.opacity(0.08))

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("STAGES")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.4))
                                    Text("\(meditation.segments.count) Steps")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("XP REWARD")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.4))
                                    Text("+\(meditation.displayMinutes * 15) XP")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                    )
                    .padding(.horizontal, 24)

                    // Choose length (for timer meditations)
                    if !meditation.guided {
                        VStack(spacing: 14) {
                            Text("Choose session duration")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            HStack(spacing: 10) {
                                ForEach(meditation.durationOptions, id: \.self) { mins in
                                    let isActive = (selectedMinutes == mins)
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            selectedMinutes = mins
                                        }
                                        HapticsManager.shared.playLightImpact()
                                    } label: {
                                        Text(L("%lld min", mins))
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(
                                                isActive ?
                                                AnyShapeStyle(LinearGradient(colors: meditation.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)) :
                                                AnyShapeStyle(Color.white.opacity(0.04))
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .strokeBorder(
                                                        isActive ? Color.white.opacity(0.2) : Color.white.opacity(0.08),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .foregroundStyle(isActive ? .black : .white)
                                            .shadow(color: isActive ? (meditation.gradient.first?.opacity(0.3) ?? .clear) : .clear, radius: 8, y: 3)
                                    }
                                    .buttonStyle(.tactile)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    Spacer()

                    // Launch button
                    Button {
                        showPlayer = true
                    } label: {
                        Label("Begin Meditation", systemImage: "play.fill")
                            .font(.headline.bold())
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: meditation.gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: Capsule()
                            )
                            .shadow(color: meditation.gradient.first?.opacity(0.4) ?? .clear, radius: 10, y: 4)
                    }
                    .buttonStyle(.tactile)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Session Info")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showPlayer) {
            MeditationPlayerView(meditation: meditation, minutes: selectedMinutes)
        }
    }
}
