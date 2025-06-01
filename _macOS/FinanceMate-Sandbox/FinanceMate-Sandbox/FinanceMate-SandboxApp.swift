// SANDBOX FILE: For testing/development. See .cursorrules.
import SwiftUI

/**
 * Sandbox main application entry point
 * 
 * Purpose: Testing environment for FinanceMate with SANDBOX watermark
 * 
 * Key Features:
 * - Identical functionality to Production version
 * - Visible SANDBOX watermark for environment identification
 * - Isolated testing environment for new features
 */

@main
struct FinanceMateSandboxApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                // Prominent SANDBOX watermark
                HStack {
                    Spacer()
                    Text("🧪 SANDBOX ENVIRONMENT")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                }
                .padding()
                
                // Main content - simplified for testing
                ContentView()
                    .environmentObject(ChatStateManager.shared)
            }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)
    }
}

// Simple content view for sandbox testing
struct ContentView: View {
    @EnvironmentObject var chatStateManager: ChatStateManager
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                
                Text("FinanceMate Sandbox")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Development & Testing Environment")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("This is the sandbox environment for testing new features before they go to production.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("FinanceMate Sandbox")
    }
}

#Preview {
    ContentView()
        .environmentObject(ChatStateManager.shared)
}