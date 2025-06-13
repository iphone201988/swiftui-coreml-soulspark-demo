import SwiftUI

struct AddNewJournalView: View {
    // ViewModel holds journal text, mood, and logic
    @StateObject private var viewModel = JournalViewModel()
    @State private var presentJournalListView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Header's Section
                HStack(spacing: 10) {
                    Image("appLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    Text("SoulSpark")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 50) // Moves the whole HStack down
                .frame(maxWidth: .infinity, alignment: .leading) // Aligns content to the left
                
                // MARK: - Mood Animation
                // Displays a pulsing animation whose color/rhythm reflects the mood
                MoodPulseView(mood: viewModel.mood)
                
                // MARK: - Journal Text Editor
                ZStack {
                    BlurView(style: .systemMaterial)
                        .cornerRadius(12)
                        .opacity(0.8)
                    
                    CustomTextEditor(text: $viewModel.journalText) {
                        viewModel.simulateMoodChange()
                    }
                    .frame(height: 120)
                    //.padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                //.padding(.horizontal)
                
                // MARK: - Save Button
                Button(action: {
                    viewModel.saveEntry() // Trigger save (and haptics)
                }) {
                    Label("Save Mood into Journal", systemImage: "square.and.arrow.down.fill")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("2D4450"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .accessibilityIdentifier("SaveButton") // ← Add this line
                
                // MARK: - View Saved Entries Button
                NavigationLink(destination: JournalListView()) {
                    Label("View Saved Entries", systemImage: "book.fill")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("2D4450"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer() // Pushes content up
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .onAppear {
                // Optional: load previous saved journal on view appear
                viewModel.loadLatestEntry()
            }
        }
        .keyboardResponsive()
        .backgroundView() // View's custom background
        /// `Showing Toast either for Success or Failure`
        .toastView(toast: $viewModel.toast)
    }
}
