internal import SwiftUI

struct SessionStudioView: View {
    @Environment(AppState.self) private var app

    @State private var selectedLevel = 1
    @State private var selectedCategory: PoseCategory? = nil
    @State private var searchText = ""
    @State private var showAmbient = false
    @State private var showPaywall = false
    @State private var animateBackground = false

    init() {}

    /// Poses after applying level, category and search-text filters.
    var filteredPoses: [YogaPose] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return YogaLibrary.poses.filter { pose in
            guard pose.level <= selectedLevel else { return false }
            if let category = selectedCategory, pose.category != category { return false }
            guard !query.isEmpty else { return true }
            // Match against the localized name, focus and the language-neutral sanskrit.
            return pose.name.lowercased().contains(query)
                || pose.sanskrit.lowercased().contains(query)
                || pose.focus.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground(animate: $animateBackground)
                
                ScrollView {
                    VStack(spacing: 18) {
                        Picker("Level", selection: $selectedLevel) {
                            Text("Easy").tag(1)
                            Text("Medium").tag(2)
                            Text("Advanced").tag(3)
                        }
                        .pickerStyle(.segmented)
                        .padding(4)
                        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))

                        CategoryFilterRow(selection: $selectedCategory)

                        Button {
                            if app.isPremiumActivated {
                                showAmbient.toggle()
                            } else {
                                showPaywall.toggle()
                                HapticsManager.shared.playWarning()
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "sparkles.tv")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Ambient Yoga Realm")
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                    Text("Breathe to the rhythm of ambient light")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                                Spacer()
                                if !app.isPremiumActivated {
                                    Image(systemName: "crown.fill")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.yellow)
                                        .padding(6)
                                        .background(.white.opacity(0.12), in: Circle())
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                            .padding(16)
                            .background(
                                LinearGradient(colors: [.indigo, .purple, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 20)
                            )
                            .shadow(color: .indigo.opacity(0.35), radius: 10, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.tactile)

                        if filteredPoses.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                                .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredPoses) { pose in
                                    NavigationLink {
                                        PoseDetailView(pose: pose)
                                    } label: {
                                        PoseRow(pose: pose)
                                    }
                                    .buttonStyle(.tactile)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Studio")
            .searchable(text: $searchText, prompt: Text("Search poses"))
            .onAppear { animateBackground = true }
        }
        .sheet(isPresented: $showAmbient) {
            AmbientSceneView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Category filter chips

private struct CategoryFilterRow: View {
    @Binding var selection: PoseCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: L("category.all"),
                           systemImage: "square.grid.2x2",
                           tint: .mint,
                           isSelected: selection == nil) {
                    selection = nil
                }
                ForEach(PoseCategory.allCases) { category in
                    FilterChip(title: category.title,
                               systemImage: category.icon,
                               tint: category.tint,
                               isSelected: selection == category) {
                        selection = (selection == category) ? nil : category
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct FilterChip: View {
    let title: String
    let systemImage: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ? AnyShapeStyle(tint.opacity(0.85)) : AnyShapeStyle(Color.white.opacity(0.08)),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pose row

private struct PoseRow: View {
    let pose: YogaPose

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "figure.yoga")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                )
                .shadow(color: pose.gradient.first?.opacity(0.3) ?? .clear, radius: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pose.name)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                
                HStack(spacing: 6) {
                    Text(pose.sanskrit)
                        .font(.caption2.italic())
                        .foregroundStyle(.white.opacity(0.55))
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.3))
                    Text(L("%lld sec", pose.holdSeconds))
                        .font(.caption2.weight(.bold).monospacedDigit())
                        .foregroundStyle(.mint)
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.3))
                    Text(pose.focus)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            Spacer()
            Image(systemName: pose.category.icon)
                .font(.caption)
                .foregroundStyle(pose.category.tint)
                .padding(8)
                .background(pose.category.tint.opacity(0.12), in: Circle())
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
