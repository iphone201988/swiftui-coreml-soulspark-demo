import SwiftUI

@main
struct SoulSparkApp: App {
    
    // Singleton instance of the Core Data stack
    // Used to manage and access Core Data throughout the app
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            // Initial screen when the app launches
            LoadInitialView()
            // Injects Core Data's managedObjectContext into the SwiftUI environment
            // Required for any view that interacts with Core Data
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
