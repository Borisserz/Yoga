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

    init(meditation: Meditation) {
        self.meditation = meditation
        _selectedMinutes = State(initialValue: meditation.guided
                                 ? meditation.guidedMinutes
                                 : (meditation.durationOptions.first ?? 10))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(LinearGradient(colors: meditation.gradient,
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 200)
                    VStack(spacing: 8) {
                        Image(systemName: meditation.category.icon)
                            .font(.system(size: 44))
                        Text(meditation.title)
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(.white)
                }

                Text(meditation.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 8) {
                    InfoPill(icon: meditation.category.icon, text: meditation.category.title)
                    InfoPill(icon: meditation.guided ? "waveform" : "timer",
                             text: meditation.guided ? L("Guided") : L("Timer"))
                    if meditation.guided {
                        InfoPill(icon: "list.bullet", text: L("%lld steps", meditation.segments.count))
                    }
                }

                if !meditation.guided {
                    VStack(spacing: 12) {
                        Text("Choose a length")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            ForEach(meditation.durationOptions, id: \.self) { mins in
                                Button {
                                    selectedMinutes = mins
                                } label: {
                                    Text(L("%lld min", mins))
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedMinutes == mins
                                                    ? AnyShapeStyle(Color.mint)
                                                    : AnyShapeStyle(Color.white.opacity(0.06)),
                                                    in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(selectedMinutes == mins ? Color.mint.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                                        )
                                        .foregroundStyle(selectedMinutes == mins ? .black : .white)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Button {
                    showPlayer = true
                } label: {
                    Label("Begin meditation", systemImage: "play.fill")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mint, in: Capsule())
                        .foregroundStyle(.black)
                        .shadow(color: Color.mint.opacity(0.3), radius: 8, y: 4)
                }
                .buttonStyle(.tactile)
            }
            .padding()
        }
        .navigationTitle(meditation.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showPlayer) {
            MeditationPlayerView(meditation: meditation, minutes: selectedMinutes)
        }
    }
}

private struct InfoPill: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color.white.opacity(0.06), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(.white.opacity(0.8))
    }
}
