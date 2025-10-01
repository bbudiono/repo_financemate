import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)

            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
                .tag(1)

            GmailView()
                .tabItem {
                    Label("Gmail", systemImage: "envelope.fill")
                }
                .tag(2)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
