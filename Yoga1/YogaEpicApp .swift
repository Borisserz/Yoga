


import SwiftUI

@main
public struct YogaEpicApp: App {
    @StateObject private var state = YogaAppState()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .preferredColorScheme(.dark)
        }
    }
}
