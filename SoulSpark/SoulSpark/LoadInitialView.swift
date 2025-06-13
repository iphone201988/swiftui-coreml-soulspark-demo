import SwiftUI

// This is the initial view that loads when the app starts.
struct LoadInitialView: View {
    var body: some View {
        NavigationStack {
            // Loads the first screen inside a navigation controller
            AddNewJournalView()
            // Suggestion: You can add .navigationTitle() here if needed
                .ignoresSafeArea()
        }
        // Optional improvement: Add navigationViewStyle for iPad optimization
        // .navigationViewStyle(StackNavigationViewStyle())
    }
}
