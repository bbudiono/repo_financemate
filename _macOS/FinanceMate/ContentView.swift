import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var selectedTab = 0
    @State private var showingAddTransaction = false
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
                VStack(spacing: 0) {
                    // BLUEPRINT Line 298: Offline banner when network unavailable
                    if !networkMonitor.isConnected {
                        OfflineBanner()
                            .environmentObject(networkMonitor)
                    }

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
                    .accessibleFocus() // WCAG 2.1 AA: Focus visible indicator

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
                .environmentObject(networkMonitor)
            }
        }
        .onAppear {
            authManager.checkAuthStatus()
            authManager.checkGoogleAuthStatus()
        }
        // WCAG 2.1 AA: Listen for keyboard shortcuts (BLUEPRINT Line 266)
        .onReceive(NotificationCenter.default.publisher(for: .newTransactionShortcut)) { _ in
            if authManager.isAuthenticated && selectedTab == 1 {
                showingAddTransaction = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .selectTab)) { notification in
            if authManager.isAuthenticated, let tabIndex = notification.object as? Int {
                selectedTab = tabIndex
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionForm(isPresented: $showingAddTransaction)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
