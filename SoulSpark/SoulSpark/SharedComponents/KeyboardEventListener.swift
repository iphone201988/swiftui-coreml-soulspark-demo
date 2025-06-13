import Foundation
import UIKit

/// An observable object that monitors the keyboard's visibility and height.
/// Useful for adjusting UI when the keyboard appears or disappears.
final class KeyboardObserver: ObservableObject {

    /// Published height of the keyboard; updates when keyboard shows/hides.
    @Published var keyboardHeight: CGFloat = 0.0

    /// Initializes the observer by subscribing to keyboard show/hide notifications.
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// Called when the keyboard is about to show.
    /// - Parameter notification: Notification containing the keyboard's final frame.
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = frame.height
        }
    }

    /// Called when the keyboard is about to hide.
    @objc private func keyboardWillHide() {
        keyboardHeight = 0
    }

    /// Removes the observer when the instance is deallocated.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
