import SwiftUI

/**
 * ProviderHelpSheet.swift
 * 
 * Purpose: PHASE 3.3 - Modular provider help sheet component (extracted from ProviderSelectionView)
 * Issues & Complexity Summary: Email provider help content with setup instructions and guidance
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~100 (focused help content display responsibility)
 *   - Core Algorithm Complexity: Low (content display and provider information formatting)
 *   - Dependencies: 2 (SwiftUI, SupportedEmailProvider enum)
 *   - State Management Complexity: Low (sheet presentation and provider iteration)
 *   - Novelty/Uncertainty Factor: Low (established help content patterns)
 * AI Pre-Task Self-Assessment: 97%
 * Problem Estimate: 82%
 * Initial Code Complexity Estimate: 75%
 * Target Coverage: Provider help content validation testing
 * Australian Compliance: Provider security information and setup guidance
 * Last Updated: 2025-08-08
 */

/// Modular email provider help sheet component
/// Extracted from ProviderSelectionView to maintain <200 line rule
struct ProviderHelpSheet: View {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(SupportedEmailProvider.allCases, id: \.self) { provider in
                        providerHelpSection(provider)
                    }
                }
                .padding()
            }
            .navigationTitle("Email Provider Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    // MARK: - Provider Help Section
    
    private func providerHelpSection(_ provider: SupportedEmailProvider) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: provider.iconName)
                    .font(.title2)
                    .foregroundColor(provider.brandColor)
                
                Text(provider.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(provider.helpText)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            if !provider.setupInstructions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Setup Instructions:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    ForEach(provider.setupInstructions, id: \.self) { instruction in
                        Text("• \(instruction)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Security information
            securityInfoSection(provider)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Security Info Section
    
    private func securityInfoSection(_ provider: SupportedEmailProvider) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Security Information:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.green)
            
            HStack(spacing: 4) {
                Image(systemName: "shield.checkered")
                    .font(.caption2)
                    .foregroundColor(.green)
                
                Text("Authentication: \(provider.securityLevel)")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            
            Text("• All credentials stored securely in macOS Keychain")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text("• No credentials transmitted to FinanceMate servers")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text("• OAuth tokens automatically refreshed when needed")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }
}

// MARK: - Preview

#Preview {
    ProviderHelpSheet(
        isPresented: .constant(true)
    )
}