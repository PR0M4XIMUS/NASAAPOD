import CoreMotion
import SwiftUI

// Class to handle device motion tracking
class MotionManager: ObservableObject {
    // Published properties to track device orientation
    @Published var roll: Double = 0.0
    @Published var pitch: Double = 0.0
    
    // Core Motion manager
    private let motionManager = CMMotionManager()
    
    init() {
        // Only setup if motion is available and not in preview
        if motionManager.isDeviceMotionAvailable {
            // Start tracking device motion
            motionManager.deviceMotionUpdateInterval = 1/60
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
                guard let data = data, error == nil else { return }
                
                // Update roll and pitch values
                self?.roll = data.attitude.roll
                self?.pitch = data.attitude.pitch
            }
        }
    }
    
    deinit {
        // Clean up when no longer needed
        motionManager.stopDeviceMotionUpdates()
    }
}
