import SwiftUI

/// Stub implementation for NavigationSidebar to enable build validation
/// TODO: Implement proper navigation sidebar according to BLUEPRINT.md requirements
struct NavigationSidebar: View {
    @Binding var selectedTab: Int

    var body: some View {
        VStack {
            Text("Navigation")
                .font(.headline)

            // Simple tab selection for build validation
            ForEach(0..<4) { tab in
                Button("Tab \(tab)") {
                    selectedTab = tab
                }
                .padding()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}