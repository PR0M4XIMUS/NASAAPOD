import SwiftUI

// ViewModifier for creating glass-like backgrounds that respond to motion
struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 16
    
    // Make motion manager optional to support previews
    @EnvironmentObject var motionManager: MotionManager
    
    // Provide fallback values when motion manager is not available
    private var roll: Double {
        return (try? motionManager.roll) ?? 0.0
    }
    
    private var pitch: Double {
        return (try? motionManager.pitch) ?? 0.0
    }
    
    func body(content: Content) -> some View {
        content
            // Semi-transparent white background
            .background(
                Color.white.opacity(0.12)
            )
            // Blur effect layer
            .background(
                Color.black.opacity(0.05)
                    .blur(radius: 10)
            )
            // Gradient border for glass effect - shifts with motion
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.6 + min(0.2, max(-0.2, roll * 0.2))),
                                Color.white.opacity(0.2 + min(0.1, max(-0.1, pitch * 0.1))),
                                Color.clear,
                                Color.white.opacity(0.2 + min(0.1, max(-0.1, -roll * 0.1)))
                            ]),
                            startPoint: computeStartPoint(),
                            endPoint: computeEndPoint()
                        ),
                        lineWidth: 1.5
                    )
            )
            // Dynamic shadow based on motion
            .shadow(
                color: Color.white.opacity(0.1 + min(0.05, max(-0.05, pitch * 0.1))),
                radius: 8,
                x: CGFloat(roll * 2),
                y: CGFloat(pitch * 2)
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
    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}

// Preview-friendly version of the glass background
struct PreviewFriendlyGlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .background(Color.white.opacity(0.12))
            .background(Color.black.opacity(0.05).blur(radius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.white.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// Provide a preview-friendly version that doesn't need the environment object
extension View {
    func previewGlassBackground(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(PreviewFriendlyGlassBackground(cornerRadius: cornerRadius))
    }
}
