import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Group {
            if !authManager.isAuthenticated {
                LoginView(authManager: authManager)
            } else {
                ZStack(alignment: .trailing) {
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

                    ChatbotDrawer(viewModel: ChatbotViewModel(context: viewContext))
                        .zIndex(1000)
                }
            }
        }
        .onAppear {
            authManager.checkAuthStatus()
            authManager.checkGoogleAuthStatus()
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
