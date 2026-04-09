import SwiftUI

// ViewModifier for creating glass-like backgrounds that respond to motion
struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.standardCornerRadius
    var intensity: CGFloat = 1.0  // Controls strength of glass effect (0-1)
    var useMotion: Bool = true

    @EnvironmentObject var motionManager: MotionManager

    private var roll: Double {
        useMotion ? motionManager.roll : 0.0
    }

    private var pitch: Double {
        useMotion ? motionManager.pitch : 0.0
    }

    func body(content: Content) -> some View {
        content
            .background(createGlassBackground())
            .overlay(createGlassBorder())
            .overlay(createLightingEffect())
            .shadow(
                color: Color.black.opacity(AppTheme.shadowOpacity + min(0.1, max(-0.1, pitch * 0.15))),
                radius: AppTheme.shadowRadius,
                x: CGFloat(roll * 3),
                y: CGFloat(pitch * 3 + 2)
            )
            .shadow(
                color: Color.white.opacity(AppTheme.highlightShadowOpacity * intensity),
                radius: 4,
                x: CGFloat(-roll * 1),
                y: CGFloat(-pitch * 1 - 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    // MARK: - Private Helper Methods

    private func createGlassBackground() -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(AppTheme.glassBaseOpacity * intensity),
                    Color.white.opacity(AppTheme.glassSecondaryOpacity * intensity)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Color.white
                .opacity(AppTheme.glassAccentOpacity * intensity)
                .blur(radius: AppTheme.glassSecondaryBlurRadius)

            Color.blue.opacity(AppTheme.glassAccentOpacity * intensity)
        }
        .blur(radius: AppTheme.glassBlurRadius * intensity)
    }

    private func createGlassBorder() -> some View {
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
    }

    private func createLightingEffect() -> some View {
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
    }

    private func computeStartPoint() -> UnitPoint {
        let rollInfluence = min(0.2, max(-0.2, roll * 0.3))
        let pitchInfluence = min(0.2, max(-0.2, pitch * 0.3))

        return UnitPoint(x: 0.0 + rollInfluence, y: 0.0 + pitchInfluence)
    }

    private func computeEndPoint() -> UnitPoint {
        let rollInfluence = min(0.2, max(-0.2, roll * 0.3))
        let pitchInfluence = min(0.2, max(-0.2, pitch * 0.3))

        return UnitPoint(x: 1.0 - rollInfluence, y: 1.0 - pitchInfluence)
    }
}

// Extension for easy application of glass effect
extension View {
    func glassBackground(
        cornerRadius: CGFloat = AppTheme.standardCornerRadius,
        intensity: CGFloat = 1.0,
        useMotion: Bool = true
    ) -> some View {
        self.modifier(GlassBackground(cornerRadius: cornerRadius, intensity: intensity, useMotion: useMotion))
    }
}

// Preview-friendly version of the glass background (no motion)
extension View {
    func previewGlassBackground(
        cornerRadius: CGFloat = AppTheme.standardCornerRadius,
        intensity: CGFloat = 1.0
    ) -> some View {
        self.modifier(GlassBackground(cornerRadius: cornerRadius, intensity: intensity, useMotion: false))
    }
}
