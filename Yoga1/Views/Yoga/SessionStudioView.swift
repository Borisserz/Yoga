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
                    VStack(spacing: 24) {
                        // Cosmic Yoga 3D Hero Banner with Parallax Tilt
                        VStack(alignment: .leading, spacing: 14) {
                            Text("PRACTICE STUDIO")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(.mint)
                                .tracking(2.0)
                            
                            Text("Enter the Space of Flow")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                            
                            Text("Engage with daily guided poses and visual breath-work.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.75))
                                .lineLimit(2)
                                .padding(.bottom, 8)
                            
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
                                HStack {
                                    Label("Ambient Yoga Realm", systemImage: "sparkles.tv")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                    Spacer()
                                    if !app.isPremiumActivated {
                                        Image(systemName: "crown.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.yellow)
                                            .padding(6)
                                            .background(.white.opacity(0.15), in: Circle())
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.black.opacity(0.6))
                                            .padding(6)
                                            .background(.black.opacity(0.08), in: Circle())
                                    }
                                }
                                .foregroundStyle(.black)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(Color.white, in: Capsule())
                                .shadow(color: .white.opacity(0.25), radius: 10, y: 4)
                            }
                            .buttonStyle(.tactile)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            ZStack {
                                Image("studio_hero")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 230)
                                    .clipped()
                                
                                LinearGradient(
                                    colors: [.black.opacity(0.85), .black.opacity(0.3), .black.opacity(0.75)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.28), .clear, .white.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .shadow(color: .black.opacity(0.35), radius: 18, y: 10)
                        .card3DTilt(maxTilt: 10.0, cornerRadius: 32.0)
                        .padding(.top, 8)

                        // Premium Sliding Segmented Control
                        CustomSegmentedPicker(selection: $selectedLevel)

                        // Category Filter row using custom 3D illustration assets
                        CategoryFilterRow(selection: $selectedCategory)
                        
                        if let category = selectedCategory {
                            AICategoryInsightCard(category: category)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                    removal: .opacity
                                ))
                        }

                        if filteredPoses.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                                .padding(.top, 40)
                                .transition(.opacity)
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredPoses) { pose in
                                    NavigationLink {
                                        PoseDetailView(pose: pose)
                                    } label: {
                                        PoseRow(pose: pose) {
                                            selectedAIPose = pose
                                        }
                                    }
                                    .buttonStyle(.plain)
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
            AIPoseGuideView(pose: pose) {
                activeCameraPose = pose
            }
        }
        .fullScreenCover(item: $activeCameraPose) { pose in
            AICameraSessionView(poseKey: pose.key)
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
    var onAIClick: (() -> Void)? = nil

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
            
            if let onAIClick {
                Button {
                    onAIClick()
                } label: {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(9)
                        .background(
                            LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: Circle()
                        )
                        .shadow(color: pose.gradient.first?.opacity(0.4) ?? .clear, radius: 4)
                }
                .buttonStyle(.plain)
                .highPriorityGesture(TapGesture().onEnded {
                    onAIClick()
                })
            }
            
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

private struct AICategoryInsightCard: View {
    let category: PoseCategory
    
    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }
    
    private var categoryData: AICategoryAnalysisData {
        YogaPoseAIContent.getCategoryAnalysis(for: category)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Header
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(category.tint)
                
                Text(isRussian ? "ИИ-АНАЛИЗ КАТЕГОРИИ: \(category.title.uppercased())" : "AI CATEGORY ANALYSIS: \(category.title.uppercased())")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(1.5)
                
                Spacer()
                
                // Glowing radar scanner dot
                HStack(spacing: 4) {
                    Circle()
                        .fill(category.tint)
                        .frame(width: 5, height: 5)
                    Text(isRussian ? "АКТИВЕН" : "ACTIVE")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(category.tint)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(category.tint.opacity(0.08), in: Capsule())
                .overlay(Capsule().strokeBorder(category.tint.opacity(0.2), lineWidth: 1))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                // Description Section
                VStack(alignment: .leading, spacing: 4) {
                    Text(isRussian ? "Описание направления" : "Category Overview")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                    
                    Text(categoryData.description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(3)
                }
                
                Divider()
                    .background(Color.white.opacity(0.06))
                    .padding(.vertical, 2)
                
                // Technique Section
                VStack(alignment: .leading, spacing: 4) {
                    Text(isRussian ? "Техника ИИ" : "AI Technique Guide")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                    
                    Text(categoryData.technique)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(category.tint.opacity(0.9))
                        .lineSpacing(3)
                }
                
                Divider()
                    .background(Color.white.opacity(0.06))
                    .padding(.vertical, 2)
                
                // Poses Summary Section
                VStack(alignment: .leading, spacing: 4) {
                    Text(isRussian ? "Состав комплекса поз" : "Target Poses Overview")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                    
                    Text(categoryData.posesOverview)
                        .font(.system(size: 12, weight: .medium).italic())
                        .foregroundStyle(.white.opacity(0.7))
                        .lineSpacing(3)
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [category.tint.opacity(0.04), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(Color.white.opacity(0.02))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        colors: [category.tint.opacity(0.25), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}
