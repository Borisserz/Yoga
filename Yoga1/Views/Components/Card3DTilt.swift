internal import SwiftUI

internal struct Card3DTiltModifier: ViewModifier {
    @State private var dragOffset: CGSize = .zero
    internal let maxTilt: Double
    internal let cornerRadius: CGFloat

    internal init(maxTilt: Double = 12.0, cornerRadius: CGFloat = 24.0) {
        self.maxTilt = maxTilt
        self.cornerRadius = cornerRadius
    }

    internal func body(content: Content) -> some View {
        content
            // 3D rotation based on drag offset
            .rotation3DEffect(
                .degrees(Double(dragOffset.width / maxTilt)),
                axis: (x: 0.0, y: 1.0, z: 0.0),
                anchor: .center,
                perspective: 0.5
            )
            .rotation3DEffect(
                .degrees(Double(-dragOffset.height / maxTilt)),
                axis: (x: 1.0, y: 0.0, z: 0.0),
                anchor: .center,
                perspective: 0.5
            )
            // Touch gesture to track displacement without blocking scrolling
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        let width = value.translation.width
                        let height = value.translation.height
                        dragOffset = CGSize(
                            width: min(max(width, -60), 60),
                            height: min(max(height, -60), 60)
                        )
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                            dragOffset = .zero
                        }
                    }
            )
    }
}

internal extension View {
    func card3DTilt(maxTilt: Double = 12.0, cornerRadius: CGFloat = 24.0) -> some View {
        self.modifier(Card3DTiltModifier(maxTilt: maxTilt, cornerRadius: cornerRadius))
    }
}
