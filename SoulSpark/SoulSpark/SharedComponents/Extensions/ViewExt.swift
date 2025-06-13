import Foundation
import SwiftUI

// MARK: View Extension -
extension View {
    
    // MARK: View Builder -
    /// Hide or show the view based on a boolean value.
    /// - Parameters:
    /// - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    /// - remove:  Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden { if !remove { self.hidden() } }
        else { self }
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) }
        else { self }
    }
    
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastViewModifier(toast: toast))
    }
    
    func backgroundView() -> some View {
        self.modifier(BackgroundView())
    }
    
    func keyboardResponsive() -> some View {
        self.modifier(KeyboardResponsive())
    }
}
