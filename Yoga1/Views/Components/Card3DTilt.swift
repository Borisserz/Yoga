internal import SwiftUI

struct Card3DTiltModifier: ViewModifier {
    @State private var dragOffset: CGSize = .zero
    let maxTilt: Double
    let cornerRadius: CGFloat

    init(maxTilt: Double = 12.0, cornerRadius: CGFloat = 24.0) {
        self.maxTilt = maxTilt
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
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
            // Specular gloss reflection overlay shifting with drag translation
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.18), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.plusLighter)
                    .offset(x: dragOffset.width * 1.5, y: dragOffset.height * 1.5)
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius)
                    )
                }
                .allowsHitTesting(false)
            )
            // Touch gesture to track displacement
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let width = value.translation.width
                        let height = value.translation.height
                        dragOffset = CGSize(
                            width: min(max(width, -80), 80),
                            height: min(max(height, -80), 80)
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

extension View {
    func card3DTilt(maxTilt: Double = 12.0, cornerRadius: CGFloat = 24.0) -> some View {
        self.modifier(Card3DTiltModifier(maxTilt: maxTilt, cornerRadius: cornerRadius))
    }
}
