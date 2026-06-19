import SwiftUI

public struct SessionStudioView: View {
    @EnvironmentObject private var state: YogaAppState
    @Environment(AppStateManager.self) private var appState
    
    @State private var selectedLevel = 1
    @State private var showAmbient = false
    @State private var showPaywall = false

    public init() {}

    var filteredPoses: [YogaPose] {
        YogaLibrary.poses.filter { $0.level <= selectedLevel }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Picker("Уровень", selection: $selectedLevel) {
                    Text("Легко").tag(1)
                    Text("Средне").tag(2)
                    Text("Продвинуто").tag(3)
                }
                .pickerStyle(.segmented)

                Button {
                    if appState.isPremiumActivated {
                        showAmbient.toggle()
                    } else {
                        showPaywall.toggle()
                        HapticsManager.shared.playWarning()
                    }
                } label: {
                    HStack {
                        Label("Открыть Ambient-сцену", systemImage: "sparkles.tv")
                        if !appState.isPremiumActivated {
                            Spacer()
                            Image(systemName: "crown.fill").foregroundStyle(.yellow)
                        }
                    }
                    .font(.headline)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(.mint.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
                }

                List(filteredPoses) { pose in
                    NavigationLink {
                        PoseDetailView(pose: pose)
                    } label: {
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: pose.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 44, height: 44)
                            VStack(alignment: .leading) {
                                Text(pose.name)
                                    .font(.headline)
                                Text("\(pose.holdSeconds) сек • \(pose.focus)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .padding()
            .navigationTitle("Студия")
        }
        .sheet(isPresented: $showAmbient) {
            AmbientSceneView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
