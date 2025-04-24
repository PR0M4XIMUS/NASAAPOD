import SwiftUI

// Main app entry point
@main
struct NASAAPODApp: App {
    // Create a shared motion manager for the app
    @StateObject private var motionManager = MotionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // Using dark mode for glass effect
                .environmentObject(motionManager) // Provide motion manager to all views
        }
    }
}
// version 1.1.0
