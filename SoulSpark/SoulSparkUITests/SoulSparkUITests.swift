import XCTest

/// UI Tests for SoulSpark app.
/// This test suite ensures key user interface elements and actions behave as expected.
final class SoulSparkUITests: XCTestCase {

    var app: XCUIApplication!

    /// Called before each test. Sets up app state and disables failure continuation.
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    /// Called after each test. You can clean up state here if needed.
    override func tearDownWithError() throws {
        app = nil
    }

    /// Verifies that the Save button exists and is tappable.
    @MainActor
    func testSaveButtonExistsAndTappable() throws {
        // Ensure you're on the correct screen (e.g., New Entry View)
        let saveButton = app.buttons["SaveButton"]

        // Assert button exists
        XCTAssertTrue(saveButton.exists, "❌ Save button should exist on the screen.")

        // Tap the button if it exists
        if saveButton.isHittable {
            saveButton.tap()
        } else {
            XCTFail("❌ Save button exists but is not hittable.")
        }
    }

    /// Measures how long it takes to launch the app.
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
