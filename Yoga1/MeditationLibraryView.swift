import SwiftUI

/// Browse the meditation library: a daily featured pick, category filters and
/// a card for every meditation.
public struct MeditationLibraryView: View {
    @State private var category: MeditationCategory?

    public init() {}

    private var items: [Meditation] {
        MeditationLibrary.meditations(in: category)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Find your calm")
                        .font(.title3.bold())
                    NavigationLink {
                        MeditationDetailView(meditation: MeditationLibrary.featured)
                    } label: {
                        FeaturedMeditationCard(meditation: MeditationLibrary.featured)
                    }
                    .buttonStyle(.plain)

                    MeditationCategoryRow(selection: $category)

                    LazyVStack(spacing: 12) {
                        ForEach(items) { meditation in
                            NavigationLink {
                                MeditationDetailView(meditation: meditation)
                            } label: {
                                MeditationRowCard(meditation: meditation)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Meditation")
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
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(active ? AnyShapeStyle(tint.opacity(0.85)) : AnyShapeStyle(Color.white.opacity(0.08)),
                        in: Capsule())
            .foregroundStyle(active ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Cards

private struct FeaturedMeditationCard: View {
    let meditation: Meditation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(L("Today's pick"), systemImage: "sparkles")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text(meditation.title)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(meditation.subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(2)
            HStack(spacing: 12) {
                Label(L("%lld min", meditation.displayMinutes), systemImage: "clock")
                Label(meditation.guided ? L("Guided") : L("Timer"),
                      systemImage: meditation.guided ? "waveform" : "timer")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .bottomLeading)
        .background(
            LinearGradient(colors: meditation.gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 26)
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
                    .frame(width: 56, height: 56)
                Image(systemName: meditation.category.icon)
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(meditation.title).font(.headline)
                Text(meditation.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(L("%lld min", meditation.displayMinutes))
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(.mint)
                Image(systemName: meditation.guided ? "waveform" : "timer")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Detail / launcher

public struct MeditationDetailView: View {
    let meditation: Meditation
    @State private var selectedMinutes: Int
    @State private var showPlayer = false

    public init(meditation: Meditation) {
        self.meditation = meditation
        _selectedMinutes = State(initialValue: meditation.guided
                                 ? meditation.guidedMinutes
                                 : (meditation.durationOptions.first ?? 10))
    }

    public var body: some View {
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

                HStack(spacing: 10) {
                    InfoPill(icon: meditation.category.icon, text: meditation.category.title)
                    InfoPill(icon: meditation.guided ? "waveform" : "timer",
                             text: meditation.guided ? L("Guided") : L("Timer"))
                    if meditation.guided {
                        InfoPill(icon: "list.bullet", text: L("%lld steps", meditation.segments.count))
                    }
                }

                if !meditation.guided {
                    VStack(spacing: 10) {
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
                                                    : AnyShapeStyle(Color.white.opacity(0.08)),
                                                    in: RoundedRectangle(cornerRadius: 12))
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
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.mint, in: Capsule())
                        .foregroundStyle(.black)
                }
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
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(.white.opacity(0.08), in: Capsule())
    }
}
