import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var chatbotVM: ChatbotViewModel

    init() {
        // Initialize ChatbotViewModel with Core Data context from environment
        let context = PersistenceController.shared.container.viewContext
        _chatbotVM = StateObject(wrappedValue: ChatbotViewModel(context: context))
    }

    var body: some View {
        Group {
            if !authManager.isAuthenticated {
                LoginView(authManager: authManager)
            } else {
                // BLUEPRINT Line 126: HSplitView prevents chatbot from blocking table content
                HSplitView {
                    // Main content area
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
                    .frame(minWidth: 600)
                    .environmentObject(authManager)

                    // Chatbot sidebar (always rendered - shows collapsed button when hidden)
                    ChatbotDrawer(viewModel: chatbotVM)
                        .frame(
                            minWidth: chatbotVM.isDrawerVisible ? 300 : 60,
                            idealWidth: chatbotVM.isDrawerVisible ? 350 : 60,
                            maxWidth: chatbotVM.isDrawerVisible ? 500 : 60
                        )
                }
                .frame(minWidth: 900, minHeight: 600)
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
