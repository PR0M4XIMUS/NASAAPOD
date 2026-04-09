import SwiftUI

// ViewModifier for creating glass-like backgrounds that respond to motion
struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 16
    var intensity: CGFloat = 1.0 // Controls strength of glass effect (0-1)

    // Make motion manager optional to support previews
    @EnvironmentObject var motionManager: MotionManager

    // Access motion values (they're always available as @Published)
    private var roll: Double {
        return motionManager.roll
    }

    private var pitch: Double {
        return motionManager.pitch
    }

    func body(content: Content) -> some View {
        content
            // Multi-layer glass background for depth
            .background(
                ZStack {
                    // Base frosted glass layer with gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.08 * intensity),
                            Color.white.opacity(0.04 * intensity)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Subtle noise/texture effect (simulated with blur)
                    Color.white
                        .opacity(0.02 * intensity)
                        .blur(radius: 1)

                    // Secondary color layer for depth
                    Color.blue
                        .opacity(0.02 * intensity)
                }
                .blur(radius: 12 * intensity) // Primary blur for glass effect
            )
            // Gradient border for glass effect - shifts with motion
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.5 + min(0.25, max(-0.25, roll * 0.25)) * intensity),
                                Color.white.opacity(0.15 + min(0.15, max(-0.15, pitch * 0.15)) * intensity),
                                Color.clear,
                                Color.white.opacity(0.15 + min(0.15, max(-0.15, -roll * 0.15)) * intensity),
                                Color.blue.opacity(0.1 * intensity)
                            ]),
                            startPoint: computeStartPoint(),
                            endPoint: computeEndPoint()
                        ),
                        lineWidth: 0.8
                    )
            )
            // Dynamic lighting effect based on motion
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1 * intensity),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .offset(y: -0.5)
            )
            // Dynamic shadow based on motion
            .shadow(
                color: Color.black.opacity(0.2 + min(0.1, max(-0.1, pitch * 0.15))),
                radius: 12,
                x: CGFloat(roll * 3),
                y: CGFloat(pitch * 3 + 2)
            )
            // Soften edges with a secondary subtle shadow
            .shadow(
                color: Color.white.opacity(0.05 * intensity),
                radius: 4,
                x: CGFloat(-roll * 1),
                y: CGFloat(-pitch * 1 - 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    // Compute gradient start point based on device motion
    private func computeStartPoint() -> UnitPoint {
        let rollInfluence = min(0.2, max(-0.2, roll * 0.3))
        let pitchInfluence = min(0.2, max(-0.2, pitch * 0.3))
        
        return UnitPoint(
            x: 0.0 + rollInfluence,
            y: 0.0 + pitchInfluence
        )
    }
    
    // Compute gradient end point based on device motion
    private func computeEndPoint() -> UnitPoint {
        let rollInfluence = min(0.2, max(-0.2, roll * 0.3))
        let pitchInfluence = min(0.2, max(-0.2, pitch * 0.3))
        
        return UnitPoint(
            x: 1.0 - rollInfluence,
            y: 1.0 - pitchInfluence
        )
    }
}

// Extension for easy application of glass effect
extension View {
    func glassBackground(cornerRadius: CGFloat = 16, intensity: CGFloat = 1.0) -> some View {
        self.modifier(GlassBackground(cornerRadius: cornerRadius, intensity: intensity))
    }
}

// Preview-friendly version of the glass background
struct PreviewFriendlyGlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 16
    var intensity: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.08 * intensity),
                            Color.white.opacity(0.04 * intensity)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Color.white.opacity(0.02 * intensity).blur(radius: 1)
                    Color.blue.opacity(0.02 * intensity)
                }
                .blur(radius: 12 * intensity)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.5 * intensity),
                                Color.white.opacity(0.15 * intensity),
                                Color.clear,
                                Color.white.opacity(0.15 * intensity),
                                Color.blue.opacity(0.1 * intensity)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1 * intensity),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .offset(y: -0.5)
            )
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 2)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// Provide a preview-friendly version that doesn't need the environment object
extension View {
    func previewGlassBackground(cornerRadius: CGFloat = 16, intensity: CGFloat = 1.0) -> some View {
        self.modifier(PreviewFriendlyGlassBackground(cornerRadius: cornerRadius, intensity: intensity))
    }
}
