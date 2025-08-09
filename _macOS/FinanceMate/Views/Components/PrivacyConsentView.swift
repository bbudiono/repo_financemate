import SwiftUI

/**
 * PrivacyConsentView.swift
 * 
 * Purpose: PHASE 3.3 - Modular privacy consent orchestration (now using PrivacyPolicySheet and TermsAndConditionsSheet)
 * Issues & Complexity Summary: Privacy consent orchestration using extracted sheet components
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~120 (orchestration only, sheets handle detailed content)
 *   - Core Algorithm Complexity: Low (consent validation and component coordination)
 *   - Dependencies: 4 (SwiftUI, 2 sheet components, Australian privacy law compliance)
 *   - State Management Complexity: Medium (consent state, privacy preferences, sheet presentation)
 *   - Novelty/Uncertainty Factor: Low (modular orchestration patterns)
 * AI Pre-Task Self-Assessment: 96% (simplified through component extraction)
 * Problem Estimate: 84% (reduced complexity through modular architecture)
 * Initial Code Complexity Estimate: 78% (orchestration benefits)
 * Target Coverage: Privacy compliance testing with component integration
 * Australian Compliance: Privacy Act 1988 (Cth), email access consent, GDPR equivalent
 * Last Updated: 2025-08-08
 */

/// Modular privacy consent orchestration view for email receipt processing
/// Uses PrivacyPolicySheet and TermsAndConditionsSheet components to maintain <200 line rule
struct PrivacyConsentView: View {
    
    // MARK: - Properties
    
    @Binding var privacyConsentGiven: Bool
    @Binding var privacyOptionalConsents: Set<String>
    let onConsentUpdate: () -> Void
    
    @State private var showingPrivacyDetails = false
    @State private var showingTerms = false
    @State private var hasReadPrivacyPolicy = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Privacy header
            privacyHeader
            
            // Main consent section
            mainConsentSection
            
            // Optional consents
            optionalConsentsSection
            
            // Privacy details and links
            privacyLinksSection
        }
        .modifier(GlassmorphismModifier(.secondary))
        .sheet(isPresented: $showingPrivacyDetails) {
            PrivacyPolicySheet(
                isPresented: $showingPrivacyDetails,
                hasReadPrivacyPolicy: $hasReadPrivacyPolicy
            )
        }
        .sheet(isPresented: $showingTerms) {
            TermsAndConditionsSheet(
                isPresented: $showingTerms
            )
        }
    }
    
    // MARK: - Privacy Header
    
    private var privacyHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "shield.checkerboard")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Privacy & Consent")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("Australian Privacy Act 1988 Compliance")
                .font(.caption)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Main Consent Section
    
    private var mainConsentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Toggle("", isOn: $privacyConsentGiven)
                    .toggleStyle(.checkbox)
                    .onChange(of: privacyConsentGiven) { _ in
                        onConsentUpdate()
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("I consent to email access and processing")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Required: Allow FinanceMate to access and process your emails to extract receipt information. All processing occurs locally on your device.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            if !privacyConsentGiven {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("Consent required to process email receipts")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
                .padding(.leading, 32)
            }
        }
    }
    
    // MARK: - Optional Consents Section
    
    private var optionalConsentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Optional Consents")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                optionalConsentToggle(
                    key: "analytics",
                    title: "Anonymous usage analytics",
                    description: "Help improve receipt processing accuracy by sharing anonymous usage patterns"
                )
                
                optionalConsentToggle(
                    key: "improvements",
                    title: "Product improvement feedback",
                    description: "Participate in product improvements and feature testing (optional surveys)"
                )
                
                optionalConsentToggle(
                    key: "notifications",
                    title: "Processing notifications",
                    description: "Receive notifications about receipt processing status and results"
                )
            }
        }
    }
    
    private func optionalConsentToggle(key: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Toggle("", isOn: Binding(
                get: { privacyOptionalConsents.contains(key) },
                set: { isOn in
                    if isOn {
                        privacyOptionalConsents.insert(key)
                    } else {
                        privacyOptionalConsents.remove(key)
                    }
                    onConsentUpdate()
                }
            ))
            .toggleStyle(.checkbox)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Privacy Links Section
    
    private var privacyLinksSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Privacy Policy") {
                    showingPrivacyDetails = true
                }
                .buttonStyle(.borderless)
                .foregroundColor(.blue)
                .font(.caption)
                
                Text("•")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Button("Terms & Conditions") {
                    showingTerms = true
                }
                .buttonStyle(.borderless)
                .foregroundColor(.blue)
                .font(.caption)
                
                Spacer()
            }
            
            // Compliance summary
            PrivacyComplianceSummary()
        }
    }
    
    
}

// MARK: - Preview

#Preview {
    PrivacyConsentView(
        privacyConsentGiven: .constant(false),
        privacyOptionalConsents: .constant(Set<String>())
    ) {
        print("Consent updated")
    }
}