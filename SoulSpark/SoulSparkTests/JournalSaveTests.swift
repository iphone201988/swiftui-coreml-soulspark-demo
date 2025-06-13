import XCTest
import CoreData
@testable import SoulSpark

/// Unit tests related to journal entry saving and encryption-decryption logic.
final class JournalSaveTests: XCTestCase {

    var context: NSManagedObjectContext!

    /// Setup in-memory Core Data stack for testing.
    override func setUp() {
        super.setUp()

        // Initialize in-memory store to isolate test data
        let container = NSPersistentContainer(name: "SoulSpark")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // Avoids writing to disk
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load in-memory store: \(error!.localizedDescription)")
        }
        context = container.viewContext
    }

    /// Tests encryption, saving, fetching, and decryption of a journal entry.
    func testJournalEntrySaveAndDecrypt() {
        let originalText = "Today was a sunny day!"

        // Encrypt journal content using helper
        guard let encrypted = EncryptionHelper.encrypt(originalText) else {
            XCTFail("Encryption failed")
            return
        }

        // Create and populate JournalEntry
        let entry = JournalEntry(context: context)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.mood = "happy"
        entry.journalContent = encrypted

        // Attempt to save entry to Core Data
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save JournalEntry: \(error)")
        }

        // Fetch the saved entry
        let fetchRequest: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        guard let fetched = try? context.fetch(fetchRequest).first else {
            XCTFail("Failed to fetch JournalEntry")
            return
        }

        // Decrypt and compare content
        let decrypted = EncryptionHelper.decrypt(fetched.journalContent ?? Data())
        XCTAssertEqual(decrypted, originalText, "Decrypted text does not match original")
    }
}
