import Foundation
import Combine
import CoreHaptics
import CoreData
import CoreML

/// ViewModel responsible for managing journal entry text, user mood, toast messages, and mood simulation logic.
class JournalViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The current text entered by the user in the journal.
    @Published var journalText: String = ""
    
    /// The user's current mood. Updates every 2–5 seconds via simulation.
    @Published var mood: MoodType = .neutral
    
    /// Optional toast to show feedback (e.g. success/failure).
    @Published var toast: Toast?
    
    // 📘 Stores the list of saved journal entries fetched from Core Data.
    // 🧠 This will be observed by SwiftUI views to show a list of entries (mood + timestamp).
    @Published var savedEntries: [JournalEntry] = []
    
    // MARK: - Private Properties
    
    /// Timer used for simulating mood changes periodically.
    private var timer: Timer?
    
    /// Optionally stores the last mood to prevent redundant UI updates.
    private var lastMood: MoodType?
    
    // MARK: - Private Properties
    
    /// Engine for Core Haptics/
    private var hapticEngine: CHHapticEngine?
    
    // MARK: - Initialization
    
    init() {
        ///  Prepare haptics when ViewModel initializes
        //prepareHaptics()
        startMoodSimulation()
    }
    
    // MARK: - Deinitialization
    
    /// Cleanly invalidate the timer when the ViewModel is deallocated.
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Mood Simulation Logic
    
    /// Starts the mood simulation with a random interval.
    /// Repeats indefinitely with randomized timing between 2–5 seconds.
    func startMoodSimulation() {
        restartTimer() // Begin loop
    }
    
    /// Restarts the simulation timer with a new 2–5 second delay.
    private func restartTimer() {
        // Invalidate any existing timer before creating a new one
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(
            withTimeInterval: Double.random(in: 10...11), //Double.random(in: 2...5),
            repeats: false
        ) { [weak self] _ in
            self?.simulateMoodChange()
            self?.restartTimer() // Recurse to simulate continuous mood change
        }
    }
    
    /// Simulates CoreML mood detection based on journal text keywords
    /// Only updates if mood has actually changed (prevents unnecessary redraws).
    func simulateMoodChange() {
        let text = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty
        else {
            mood = .neutral // Default fallback for empty input
            return
        }
        
        do {
            let config = MLModelConfiguration()
            let classifier = try JournalMoodClassifier(configuration: config)
            let prediction = try classifier.prediction(text: text)
            var newMood: MoodType = .neutral
            newMood = MoodType(rawValue: prediction.label) ?? .neutral
            // Avoid duplicate updates (improves SwiftUI rendering performance)
            if newMood != mood {
                mood = newMood
                HapticsManager.shared.trigger(.moodChange)
            }
            
        } catch {
            SharedMethods.shared.debugLog("⚠️ Mood prediction failed: \(error.localizedDescription)")
            mood = .neutral
        }
    }
    
    // MARK: - Journal Saving Logic
    
    /// Saves the current journal entry and shows a confirmation toast.
    func saveEntry() {
        // 💾 Ensure journal text is not empty
        guard !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            SharedMethods.shared.debugLog("⚠️ Journal text is empty, not saving.")
            toast = Toast(
                type: .warning,
                title: "Journal Entry",
                message: "Journal text is empty, not saving."
            )
            return
        }
        
        // 🔐 Encrypt the journal text using AES-256
        guard let encryptedContent = EncryptionHelper.encrypt(journalText) else {
            SharedMethods.shared.debugLog("❌ Failed to encrypt journal text.")
            return
        }
        
        // 🧠 Create a new Core Data object
        //let entry = JournalEntry(context: CoreDataStack.shared.context)
        let entry = JournalEntry(context: PersistenceController.shared.container.viewContext)
        entry.id = UUID()
        entry.journalContent = encryptedContent
        entry.timestamp = Date()
        entry.mood = mood.rawValue
        
        // 💽 Save context
        let context = PersistenceController.shared.container.viewContext
        
        do {
            try context.save()
            SharedMethods.shared.debugLog("✅ Saved with PersistenceController.")
        } catch {
            SharedMethods.shared.debugLog("❌ Failed to save: \(error.localizedDescription)")
        }
        
        //  CoreDataStack.shared.save()
        
        // ✅ Add to local array if needed (optional)
        savedEntries.insert(entry, at: 0)
        
        // ✅ Update UI model
        // loadLatestEntry()
        
        // 📳 Trigger haptic feedback
        triggerHaptic()
        
        // 🧹 Optional: Clear input
        journalText = ""
        mood = .neutral
        HapticsManager.shared.trigger(.saveSuccess)
    }
    
    /// Loads all saved journal entries from Core Data and updates the `savedEntries` array.
    /// Useful when opening the view again or restoring last state.
    func loadLatestEntry() {
        
        // Create a fetch request for JournalEntry entities
        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        
        // Sort entries by timestamp in descending order (newest first)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntry.timestamp, ascending: false)]
        
        do {
            // Fetch results and assign to the published array
            //savedEntries = try CoreDataStack.shared.context.fetch(request)
            savedEntries = try PersistenceController.shared.container.viewContext.fetch(request)
        } catch {
            // Log any error that occurs during the fetch
            SharedMethods.shared.debugLog("❌ Failed to fetch entries: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Haptic Setup
    
    /// Prepare CoreHaptics engine
//    private func prepareHaptics() {
//        do {
//            hapticEngine = try CHHapticEngine()
//            try hapticEngine?.start()
//        } catch {
//            SharedMethods.shared.debugLog("⚠️ Haptic engine failed to start: \(error)")
//        }
//    }
    
    /// Trigger a subtle haptic feedback
    private func triggerHaptic() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        let event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [intensity, sharpness],
                                  relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            SharedMethods.shared.debugLog("⚠️ Haptic failed: \(error)")
        }
    }
}
