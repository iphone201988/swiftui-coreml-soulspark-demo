struct Toast: Equatable {
    var type: ToastViewStyle
    var title: String
    var message: String
    var duration: Double = 3
    var enableDonotShowAgainBtn: Bool = false
}
