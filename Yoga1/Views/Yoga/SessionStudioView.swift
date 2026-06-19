internal import SwiftUI

struct SessionStudioView: View {
    @Environment(AppState.self) private var app

    @State private var selectedLevel = 1
    @State private var selectedCategory: PoseCategory? = nil
    @State private var searchText = ""
    @State private var showAmbient = false
    @State private var showPaywall = false

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
            VStack(spacing: 14) {
                Picker("Level", selection: $selectedLevel) {
                    Text("Easy").tag(1)
                    Text("Medium").tag(2)
                    Text("Advanced").tag(3)
                }
                .pickerStyle(.segmented)

                CategoryFilterRow(selection: $selectedCategory)

                Button {
                    if app.isPremiumActivated {
                        showAmbient.toggle()
                    } else {
                        showPaywall.toggle()
                        HapticsManager.shared.playWarning()
                    }
                } label: {
                    HStack {
                        Label("Open Ambient scene", systemImage: "sparkles.tv")
                        if !app.isPremiumActivated {
                            Spacer()
                            Image(systemName: "crown.fill").foregroundStyle(.yellow)
                        }
                    }
                    .font(.headline)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(.mint.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
                }

                if filteredPoses.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                        .frame(maxHeight: .infinity)
                } else {
                    List(filteredPoses) { pose in
                        NavigationLink {
                            PoseDetailView(pose: pose)
                        } label: {
                            PoseRow(pose: pose)
                        }
                        .listRowBackground(Color.white.opacity(0.04))
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Studio")
            .searchable(text: $searchText, prompt: Text("Search poses"))
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
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(pose.name)
                    .font(.headline)
                Text(L("%lld sec • %@", pose.holdSeconds, pose.focus))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: pose.category.icon)
                .font(.caption)
                .foregroundStyle(pose.category.tint)
                .padding(6)
                .background(pose.category.tint.opacity(0.18), in: Circle())
        }
    }
}
