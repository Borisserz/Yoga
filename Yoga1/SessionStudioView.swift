import SwiftUI

public struct SessionStudioView: View {
    @EnvironmentObject private var state: YogaAppState
    @State private var selectedLevel = 1
    @State private var showAmbient = false

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
                    showAmbient.toggle()
                } label: {
                    Label("Открыть Ambient-сцену", systemImage: "sparkles.tv")
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
    }
}
