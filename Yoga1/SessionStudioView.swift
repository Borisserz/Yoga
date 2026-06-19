import SwiftUI

public struct SessionStudioView: View {
    @Environment(AppState.self) private var app

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
                Picker("Level", selection: $selectedLevel) {
                    Text("Easy").tag(1)
                    Text("Medium").tag(2)
                    Text("Advanced").tag(3)
                }
                .pickerStyle(.segmented)

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
                                Text(L("%lld sec • %@", pose.holdSeconds, pose.focus))
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
            .navigationTitle("Studio")
        }
        .sheet(isPresented: $showAmbient) {
            AmbientSceneView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
