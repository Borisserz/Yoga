internal import SwiftUI

struct SessionStudioView: View {
    @Environment(AppState.self) private var app

    @State private var selectedLevel = 1
    @State private var selectedCategory: PoseCategory? = nil
    @State private var searchText = ""
    @State private var showAmbient = false
    @State private var showPaywall = false
    @State private var animateBackground = false
    @State private var selectedAIPose: YogaPose? = nil
    @State private var activeCameraPose: YogaPose? = nil
    @State private var navigatingPose: YogaPose? = nil

    init() {}

    var filteredPoses: [YogaPose] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return YogaLibrary.poses.filter { pose in
            guard pose.level <= selectedLevel else { return false }
            if let category = selectedCategory, pose.category != category { return false }
            guard !query.isEmpty else { return true }
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
                    VStack(spacing: 16) {
                        // Compact Cosmic Yoga 3D Hero Banner with Parallax Tilt
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("PRACTICE STUDIO")
                                    .font(.system(size: 10, weight: .black, design: .rounded))
                                    .foregroundStyle(.mint)
                                    .tracking(2.0)
                                
                                Text("Space of Flow")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                            }
                            
                            Spacer()
                            
                            // Ambient realm entry button inside hero
                            Button {
                                if app.isPremiumActivated {
                                    showAmbient.toggle()
                                    HapticsManager.shared.playLightImpact()
                                } else {
                                    showPaywall.toggle()
                                    HapticsManager.shared.playWarning()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles.tv")
                                        .font(.system(size: 12, weight: .bold))
                                    Text(app.isPremiumActivated ? "Ambient" : "Unlock")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                    if !app.isPremiumActivated {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.yellow)
                                    }
                                }
                                .foregroundStyle(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.white, in: Capsule())
                                .shadow(color: .white.opacity(0.15), radius: 6, y: 2)
                            }
                            .buttonStyle(.tactile)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                Image("studio_hero")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 75)
                                    .clipped()
                                
                                LinearGradient(
                                    colors: [.black.opacity(0.75), .black.opacity(0.45)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.2), .clear, .white.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 4)
                        .card3DTilt(maxTilt: 6.0, cornerRadius: 24.0)
                        .padding(.top, 8)

                        // Premium Sliding Segmented Control
                        CustomSegmentedPicker(selection: $selectedLevel)

                        // Category Filter row using custom 3D illustration assets
                        CategoryFilterRow(selection: $selectedCategory)

                        if filteredPoses.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                                .padding(.top, 40)
                                .transition(.opacity)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredPoses) { pose in
                                    PoseRow(pose: pose)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            HapticsManager.shared.playLightImpact()
                                            selectedAIPose = pose
                                        }
                                }
                            }
                            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: filteredPoses)
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
        .sheet(item: $selectedAIPose) { pose in
            AIPoseGuideView(pose: pose, onStartCamera: {
                activeCameraPose = pose
            }, onStartPractice: {
                navigatingPose = pose
            })
        }
        .fullScreenCover(item: $activeCameraPose) { pose in
            AICameraSessionView(poseKey: pose.key)
        }
        .navigationDestination(item: $navigatingPose) { pose in
            PoseDetailView(pose: pose)
        }
    }
}

// MARK: - Premium sliding Segmented Picker

private struct CustomSegmentedPicker: View {
    @Binding var selection: Int
    private let options = [(1, "Beginner"), (2, "Intermediate"), (3, "Advanced")]
    @Namespace private var activeSegmentNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.0) { val, text in
                let isActive = (selection == val)
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selection = val
                    }
                    HapticsManager.shared.playLightImpact()
                } label: {
                    Text(text)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(isActive ? .black : .white.opacity(0.65))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                if isActive {
                                    Capsule()
                                        .fill(Color.mint)
                                        .matchedGeometryEffect(id: "active_segment_indicator", in: activeSegmentNamespace)
                                        .shadow(color: .mint.opacity(0.35), radius: 8)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.03), in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4)
    }
}

// MARK: - Category filter chips

private struct CategoryFilterRow: View {
    @Binding var selection: PoseCategory?
    
    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(title: isRussian ? "Все" : "All",
                           category: nil,
                           tint: .mint,
                           isSelected: selection == nil) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        selection = nil
                    }
                }
                
                // Beautiful separator line
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 1.5, height: 22)
                    .padding(.horizontal, 4)
                
                ForEach(PoseCategory.allCases) { category in
                    FilterChip(title: category.title,
                               category: category,
                               tint: category.tint,
                               isSelected: selection == category) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            selection = (selection == category) ? nil : category
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
}

private struct FilterChip: View {
    let title: String
    let category: PoseCategory?
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let category {
                    Image("category_\(category.rawValue)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .shadow(color: tint.opacity(0.4), radius: 4)
                } else {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isSelected ? .black : tint)
                }
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ? AnyShapeStyle(tint.opacity(0.9)) : AnyShapeStyle(Color.white.opacity(0.04)),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.08),
                        lineWidth: 1.0
                    )
            )
            .foregroundStyle(isSelected ? .black : .white.opacity(0.8))
            .shadow(color: isSelected ? tint.opacity(0.3) : .clear, radius: 8, y: 3)
            .scaleEffect(isSelected ? 1.04 : 1.0)
        }
        .buttonStyle(.tactile)
    }
}

// MARK: - Pose row

private struct PoseRow: View {
    let pose: YogaPose

    var body: some View {
        HStack(spacing: 16) {
            // Left: Glowing 3D card for Category Icon
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 58, height: 58)
                    .shadow(color: pose.gradient.first?.opacity(0.45) ?? .clear, radius: 8, y: 4)
                
                Image("category_\(pose.category.rawValue)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 38, height: 38)
                    .shadow(color: .black.opacity(0.3), radius: 4)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(pose.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                HStack(spacing: 6) {
                    Text(pose.sanskrit)
                        .font(.system(size: 11, weight: .medium, design: .serif).italic())
                        .foregroundStyle(.white.opacity(0.55))
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.2))
                    Text(L("%lld sec", pose.holdSeconds))
                        .font(.system(size: 11, weight: .bold).monospacedDigit())
                        .foregroundStyle(.mint)
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.2))
                    Text(pose.focus)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .padding(10)
                .background(Color.white.opacity(0.04), in: Circle())
                .overlay(
                    Circle().strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.12), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
        .card3DTilt(maxTilt: 8.0, cornerRadius: 24.0)
    }
}


