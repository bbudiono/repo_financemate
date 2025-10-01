import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if !authManager.isAuthenticated {
                LoginView(authManager: authManager)
            } else {
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

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(3)
                }
                .frame(minWidth: 800, minHeight: 600)
                .environmentObject(authManager)
            }
        }
        .onAppear {
            authManager.checkAuthStatus()
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
