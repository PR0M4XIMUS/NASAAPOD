import SwiftUI

// Centralized theme and styling constants
struct AppTheme {
    // MARK: - Glass Effect Opacity
    static let glassBaseOpacity: CGFloat = 0.08
    static let glassSecondaryOpacity: CGFloat = 0.04
    static let glassAccentOpacity: CGFloat = 0.02
    static let glassBlurOpacity: CGFloat = 0.06

    // MARK: - Glass Effect Blur
    static let glassBlurRadius: CGFloat = 12.0
    static let glassSecondaryBlurRadius: CGFloat = 1.0

    // MARK: - Text Opacity
    static let primaryTextOpacity: CGFloat = 0.9
    static let secondaryTextOpacity: CGFloat = 0.8
    static let tertiaryTextOpacity: CGFloat = 0.7

    // MARK: - Shadows
    static let shadowRadius: CGFloat = 12.0
    static let shadowOpacity: CGFloat = 0.2
    static let highlightShadowOpacity: CGFloat = 0.05

    // MARK: - Padding
    static let standardPadding: CGFloat = 16.0
    static let mediumPadding: CGFloat = 12.0
    static let smallPadding: CGFloat = 8.0

    // MARK: - Corner Radius
    static let largeCornerRadius: CGFloat = 20.0
    static let standardCornerRadius: CGFloat = 14.0
    static let smallCornerRadius: CGFloat = 10.0
    static let tinyCornerRadius: CGFloat = 8.0

    // MARK: - Animation
    static let standardAnimationDuration: Double = 0.3
    static let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7)

    // MARK: - Colors
    static let accentColor = Color.blue
    static let backgroundColor = Color.black
    static let glassColor = Color.white
    static let errorColor = Color.orange
    static let successColor = Color.green

    // MARK: - Network
    static let networkTimeoutInterval: TimeInterval = 15
    static let resourceTimeoutInterval: TimeInterval = 30

    // MARK: - Cache
    static let imageCacheMemoryCapacity: Int = 500_000_000  // 500 MB
    static let imageCacheDiskCapacity: Int = 1_000_000_000   // 1 GB

    // MARK: - Retry
    static let maxRetryAttempts: Int = 3
    static let initialRetryDelay: TimeInterval = 1.0  // 1 second
    static let maxRetryDelay: TimeInterval = 16.0     // 16 seconds
}
