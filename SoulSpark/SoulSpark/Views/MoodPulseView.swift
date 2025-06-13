import SwiftUI

/// A heartbeat-style mood pulse animation that reflects the current emotional state.
///
/// - Visualizes mood through color and pulse rhythm (scale/tempo).
/// - Heartbeat animation tempo adjusts dynamically per `mood.speed`.
/// - Uses async loop for smooth and precise timing without relying on `Timer`.
/// - Triggers subtle haptic feedback when mood changes.
struct MoodPulseView: View {
    /// Represents the current mood type with associated color and speed.
    var mood: MoodType
    
    /// Internal state used to control the size of the pulsating circle.
    @State private var scale: CGFloat = 1.0
    
    /// A reference to the async heartbeat animation loop task.
    @State private var beatTask: Task<Void, Never>? = nil
    
    var body: some View {
        ZStack {
            // Outer blurred pulse for atmospheric glow effect
            Circle()
                .fill(mood.color)
                .blur(radius: 40)
                .scaleEffect(scale)
                .opacity(0.2)
            
            // Inner radial pulse for visual clarity and rhythm
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [mood.color.opacity(0.8), mood.color.opacity(0.2)]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .shadow(color: mood.color.opacity(0.5), radius: 10)
        }
        .onAppear {
            // Start pulsing when the view appears
            startHeartBeat()
        }
        .onChange(of: mood) { _, _ in
            // Restart pulse animation and trigger haptic when mood changes
            HapticsManager.shared.trigger(.moodChange)
            restartHeartBeat()
        }
        .onDisappear {
            // Cancel the task when view is removed
            beatTask?.cancel()
        }
    }
    
    // MARK: - Heartbeat Animation Loop
    
    /// Starts an asynchronous repeating heartbeat animation based on mood speed.
    private func startHeartBeat() {
        beatTask = Task {
            while !Task.isCancelled {
                await performBeat() // One complete beat cycle
                try? await Task.sleep(nanoseconds: UInt64((mood.speed + 0.2) * 1_000_000_000)) // Gap between beats
            }
        }
    }
    
    /// Cancels the current heartbeat task and restarts with updated speed/mood.
    private func restartHeartBeat() {
        beatTask?.cancel()
        startHeartBeat()
    }
    
    /// Performs one full heartbeat-style animation:
    /// - First large pulse
    /// - Brief contract
    /// - Second smaller pulse
    /// - Return to idle
    private func performBeat() async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: mood.speed * 0.4)) {
                scale = 1.3 // Big beat
            }
        }
        try? await Task.sleep(nanoseconds: UInt64(mood.speed * 0.4 * 1_000_000_000))
        
        await MainActor.run {
            withAnimation(.easeOut(duration: mood.speed * 0.2)) {
                scale = 1.1 // Quick recoil
            }
        }
        try? await Task.sleep(nanoseconds: UInt64(mood.speed * 0.2 * 1_000_000_000))
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: mood.speed * 0.3)) {
                scale = 1.25 // Second lighter pulse
            }
        }
        try? await Task.sleep(nanoseconds: UInt64(mood.speed * 0.3 * 1_000_000_000))
        
        await MainActor.run {
            withAnimation(.easeOut(duration: mood.speed * 0.1)) {
                scale = 1.0 // Reset to idle
            }
        }
    }
}
