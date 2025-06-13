import SwiftUI

struct ToastView: View {
    
    var type: ToastViewStyle
    var title: String
    var message: String
    
    @State private var isHideToast: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: type.iconFileName)
                    .foregroundColor(type.themeColor)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.65))
                }
                
                Spacer(minLength: 10)
            }
            .padding()
        }
        .background(
            Color.black // Base black background
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("2D4450").opacity(0.9), .black.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Rectangle()
                .fill(type.themeColor)
                .frame(width: 6)
                .clipped()
            , alignment: .leading
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}
