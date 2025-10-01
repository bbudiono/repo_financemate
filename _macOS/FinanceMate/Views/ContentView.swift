import SwiftUI

/// Main content view with tab navigation
/// BLUEPRINT: Simple, working TabView (not the broken 1,149 line monster)
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)

            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            GmailView()
                .tabItem {
                    Label("Gmail Receipts", systemImage: "envelope.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
