import SwiftUI

struct ToastViewModifier: ViewModifier {
    @Binding var toast: Toast?
    @StateObject private var keyboard = KeyboardObserver()  // 👈 Keyboard state
    @State private var workItem: DispatchWorkItem?

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Group {
                    if let toast = toast {
                        VStack {
                            Spacer()
                            ToastView(type: toast.type, title: toast.title, message: toast.message)
                                .padding(.bottom, keyboard.keyboardHeight + 20) // 👈 Push above keyboard
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: toast)
                    }
                }
            )
            .onChange(of: toast) { _, _ in
                showToast()
            }
    }

    private func showToast() {
        guard let toast = toast else { return }
        if toast.duration > 0 {
            workItem?.cancel()
            let task = DispatchWorkItem { dismissToast() }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }

    private func dismissToast() {
        withAnimation { toast = nil }
        workItem?.cancel()
        workItem = nil
    }
}
