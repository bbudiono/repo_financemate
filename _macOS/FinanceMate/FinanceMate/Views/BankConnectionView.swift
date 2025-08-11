import SwiftUI
import CoreData

/**
 * Purpose: UI interface for connecting to ANZ and NAB banks using real BankAPIIntegrationService
 * Issues & Complexity Summary: OAuth flow management, secure credential handling, real bank API integration
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300+ (OAuth UI flows, bank selection, error handling)
 *   - Core Algorithm Complexity: Medium (UI coordination, API integration, OAuth flows)
 *   - Dependencies: 2 New (BankAPIIntegrationService, existing glassmorphism components)
 *   - State Management Complexity: High (async bank connections, OAuth states, error management)
 *   - Novelty/Uncertainty Factor: Low (established SwiftUI patterns, existing service integration)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 88%
 * Target Coverage: ≥95%
 * Australian Compliance: CDR compliance, OAuth2 + PKCE security standards
 * Last Updated: 2025-08-11
 */

/// SwiftUI interface for managing ANZ and NAB bank connections using production BankAPIIntegrationService
struct BankConnectionView: View {
    
    // MARK: - Properties
    
    @StateObject private var bankService = BankAPIIntegrationService()
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedBank: BankType? = nil
    @State private var showingCredentialSetup = false
    @State private var showingConnectionHelp = false
    @State private var isProcessingConnection = false
    @State private var connectionMessage: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Bank Selection Section
                    bankSelectionSection
                    
                    // Connection Status Section
                    connectionStatusSection
                    
                    // Connected Accounts Section
                    if !bankService.availableAccounts.isEmpty {
                        connectedAccountsSection
                    }
                    
                    // Connection Management
                    connectionManagementSection
                }
                .padding()
            }
            .navigationTitle("Bank Connections")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Help") {
                        showingConnectionHelp = true
                    }
                }
            }
            .sheet(isPresented: $showingCredentialSetup) {
                BankCredentialSetupView(selectedBank: $selectedBank)
            }
            .sheet(isPresented: $showingConnectionHelp) {
                BankConnectionHelpView()
            }
            .onAppear {
                Task {
                    await loadInitialConnectionStatus()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Bank Account Connections")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("Securely connect your ANZ and NAB accounts for automatic transaction importing")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var bankSelectionSection: some View {
        VStack(spacing: 16) {
            Text("Select Bank to Connect")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                // ANZ Bank Button
                BankSelectionCard(
                    bankType: .anz,
                    isSelected: selectedBank == .anz,
                    isConnected: hasANZConnection
                ) {
                    selectedBank = .anz
                }
                
                // NAB Bank Button
                BankSelectionCard(
                    bankType: .nab,
                    isSelected: selectedBank == .nab,
                    isConnected: hasNABConnection
                ) {
                    selectedBank = .nab
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var connectionStatusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: connectionStatusIcon)
                    .foregroundColor(connectionStatusColor)
                    .font(.title2)
                
                Text(bankService.connectionStatus)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(connectionStatusColor)
                
                Spacer()
            }
            
            if let lastSync = bankService.lastSyncDate {
                HStack {
                    Text("Last sync: \(lastSync, style: .relative) ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var connectedAccountsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Connected Accounts")
                    .font(.headline)
                Spacer()
                Text("\(bankService.availableAccounts.count) account\(bankService.availableAccounts.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(bankService.availableAccounts, id: \.id) { account in
                    BankAccountRow(account: account)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var connectionManagementSection: some View {
        VStack(spacing: 16) {
            // Connect Button
            if selectedBank != nil && !isSelectedBankConnected {
                Button(action: initiateConnection) {
                    HStack {
                        if isProcessingConnection {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "link")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        Text(isProcessingConnection ? "Connecting..." : "Connect \(selectedBank?.displayName ?? "Bank")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.white)
                    .background(selectedBank == .anz ? Color.blue : Color.green)
                    .cornerRadius(8)
                    .opacity(isProcessingConnection ? 0.6 : 1.0)
                }
                .disabled(isProcessingConnection)
                .accessibilityLabel("Connect to \(selectedBank?.displayName ?? "selected bank")")
            }
            
            // Sync All Button
            if !bankService.availableAccounts.isEmpty {
                Button(action: syncAllBankData) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Sync All Accounts")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.blue)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                .accessibilityLabel("Sync all connected bank accounts")
            }
            
            // Credential Setup Button
            Button(action: {
                showingCredentialSetup = true
            }) {
                HStack {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Configure API Credentials")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundColor(.secondary)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            .accessibilityLabel("Configure bank API credentials")
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasANZConnection: Bool {
        bankService.availableAccounts.contains { $0.bankType == .anz }
    }
    
    private var hasNABConnection: Bool {
        bankService.availableAccounts.contains { $0.bankType == .nab }
    }
    
    private var isSelectedBankConnected: Bool {
        guard let selected = selectedBank else { return false }
        return bankService.availableAccounts.contains { $0.bankType == selected }
    }
    
    private var connectionStatusIcon: String {
        if bankService.isConnected {
            return "checkmark.circle.fill"
        } else if isProcessingConnection {
            return "clock.circle.fill"
        } else {
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var connectionStatusColor: Color {
        if bankService.isConnected {
            return .green
        } else if isProcessingConnection {
            return .orange
        } else {
            return .secondary
        }
    }
    
    // MARK: - Actions
    
    private func loadInitialConnectionStatus() async {
        // Trigger connection status validation
        // The bankService will automatically check credential status on init
    }
    
    private func initiateConnection() {
        guard let selectedBank = selectedBank else { return }
        
        isProcessingConnection = true
        connectionMessage = ""
        
        Task {
            do {
                switch selectedBank {
                case .anz:
                    try await bankService.connectANZBank()
                case .nab:
                    try await bankService.connectNABBank()
                }
                
                await MainActor.run {
                    connectionMessage = "Successfully connected to \(selectedBank.displayName)"
                    isProcessingConnection = false
                }
                
            } catch {
                await MainActor.run {
                    connectionMessage = "Connection failed: \(error.localizedDescription)"
                    isProcessingConnection = false
                }
            }
        }
    }
    
    private func syncAllBankData() {
        Task {
            do {
                try await bankService.syncAllBankData()
            } catch {
                connectionMessage = "Sync failed: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Supporting Views

private struct BankSelectionCard: View {
    let bankType: BankType
    let isSelected: Bool
    let isConnected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: bankIcon)
                    .font(.system(size: 40))
                    .foregroundColor(bankColor)
                
                Text(bankType.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if isConnected {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Connected")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else {
                    Text("Not Connected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? bankColor.opacity(0.1) : Color.secondary.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? bankColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var bankIcon: String {
        switch bankType {
        case .anz:
            return "building.columns.fill"
        case .nab:
            return "building.2.fill"
        }
    }
    
    private var bankColor: Color {
        switch bankType {
        case .anz:
            return .blue
        case .nab:
            return .green
        }
    }
}

private struct BankAccountRow: View {
    let account: BankAccount
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.accountName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(account.accountType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("AUD \(String(format: "%.2f", account.currentBalance))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(account.bankType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Supporting Views (Placeholder implementations)

private struct BankCredentialSetupView: View {
    @Binding var selectedBank: BankType?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("API Credential Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("To connect to your bank, you'll need to configure API credentials. This requires:")
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. Register with your bank's developer portal")
                    Text("2. Obtain OAuth 2.0 client credentials")
                    Text("3. Configure redirect URIs")
                    Text("4. Store credentials securely in Keychain")
                }
                .font(.body)
                
                Spacer()
                
                Text("This feature requires production API credentials which are configured separately for security.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Setup")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct BankConnectionHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Bank Connection Guide")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Security & Privacy")
                        .font(.headline)
                    
                    Text("FinanceMate uses bank-grade security to protect your financial data:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• OAuth 2.0 with PKCE authentication")
                        Text("• Encrypted credential storage in macOS Keychain")
                        Text("• Consumer Data Right (CDR) compliance")
                        Text("• No storage of banking passwords")
                        Text("• Read-only access to account data")
                    }
                    .font(.body)
                    
                    Text("Supported Banks")
                        .font(.headline)
                    
                    Text("Currently supported Australian banks:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• ANZ (Australia and New Zealand Banking Group)")
                        Text("• NAB (National Australia Bank)")
                    }
                    .font(.body)
                    
                    Text("Connection Process")
                        .font(.headline)
                    
                    Text("Connecting your bank account involves:")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Select your bank")
                        Text("2. Configure API credentials (one-time setup)")
                        Text("3. Authenticate through your bank's secure portal")
                        Text("4. Grant permission for account access")
                        Text("5. Start automatic transaction syncing")
                    }
                    .font(.body)
                }
                .padding()
            }
            .navigationTitle("Help")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BankConnectionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}