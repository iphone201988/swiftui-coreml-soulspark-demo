import CoreHaptics

/// Manages haptic feedback using Core Haptics.
/// Singleton pattern used for global access across the app.
class HapticsManager {
    
    /// Shared singleton instance of the HapticsManager.
    static let shared = HapticsManager()
    
    /// The haptic engine responsible for generating feedback.
    private var engine: CHHapticEngine?

    /// Private initializer to ensure singleton usage and initialize engine.
    private init() {
        prepare()
    }

    /// Prepares and starts the haptic engine if supported by the device.
    func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            SharedMethods.shared.debugLog("Haptic Engine failed: \(error)")
        }
    }

    /// Triggers a specific haptic feedback pattern based on `FeedbackType`.
    /// - Parameter type: The desired haptic feedback to play (e.g., `.moodChange`, `.saveSuccess`).
    func trigger(_ type: FeedbackType) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        // Configure event parameters
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: type.intensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: type.sharpness)
        
        // Create a transient (short burst) haptic event
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0) // Play immediately
        } catch {
            SharedMethods.shared.debugLog("Failed to play haptic: \(error)")
        }
    }
}

/// Defines different types of feedback with associated haptic characteristics.
enum FeedbackType {
    case moodChange
    case saveSuccess

    /// Intensity of the haptic effect (0.0 to 1.0).
    var intensity: Float {
        switch self {
        case .moodChange: return 0.3
        case .saveSuccess: return 0.7
        }
    }

    /// Sharpness of the haptic effect (0.0 = soft, 1.0 = sharp tap).
    var sharpness: Float {
        switch self {
        case .moodChange: return 0.2
        case .saveSuccess: return 0.8
        }
    }
}
