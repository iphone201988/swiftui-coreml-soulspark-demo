import SwiftUI

/// ✅ JournalListView displays saved journal entries from Core Data,
/// showing mood, timestamp, and decrypted journal text in a beautiful, gradient-backed layout.
struct JournalListView: View {
    
    @Environment(\.dismiss) private var dismiss // For manually dismissing this view
    @StateObject private var viewModel = JournalViewModel() // 🧠 Holds the saved journal entries
    
    var body: some View {
        ZStack {
            // 🌈 Gradient background filling the full screen, ignoring safe areas
            LinearGradient(colors: [Color("2D4450"), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                // 📋 List of saved entries from Core Data
                List(viewModel.savedEntries, id: \.self) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        
                        // 🔖 Mood + Timestamp header
                        HStack {
                            // 🌈 Mood label (e.g., "calm", "stressed", etc.)
                            Text(entry.mood ?? "Unknown")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // 🕒 Formatted date of the entry
                            Text(entry.timestamp ?? Date(), formatter: DateUtil.shared.dateFormatter)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // 🔐 Journal text (decrypted)
                        Text(EncryptionHelper.decrypt(entry.journalContent ?? Data()) ?? "N/A")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 6) // Spacing between list entries
                }
                .scrollContentBackground(.hidden) // Hides default list background
                .background(Color.clear)          // Transparent to show gradient below
            }
        }
        
        // 🧭 Custom navigation toolbar (replaces default NavBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    // 🔙 Manual back button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    
                    // 📝 Title next to back button
                    Text("Journal History")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .navigationBarBackButtonHidden() // Hides the default iOS back button
        .onAppear {
            viewModel.loadLatestEntry() // ⬇️ Load saved entries when view appears
        }
    }
}
