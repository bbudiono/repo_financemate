import SwiftUI

/**
 * PrivacyPolicySheet.swift
 * 
 * Purpose: PHASE 3.3 - Modular privacy policy sheet component (extracted from PrivacyConsentView)
 * Issues & Complexity Summary: Privacy policy content display with Australian compliance details
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~80 (focused privacy policy display responsibility)
 *   - Core Algorithm Complexity: Low (content display and navigation handling)
 *   - Dependencies: 1 (SwiftUI)
 *   - State Management Complexity: Low (sheet presentation and dismissal)
 *   - Novelty/Uncertainty Factor: Low (established content display patterns)
 * AI Pre-Task Self-Assessment: 98%
 * Problem Estimate: 82%
 * Initial Code Complexity Estimate: 75%
 * Target Coverage: Privacy policy content validation testing
 * Australian Compliance: Privacy Act 1988 (Cth) policy content requirements
 * Last Updated: 2025-08-08
 */

/// Modular privacy policy sheet component
/// Extracted from PrivacyConsentView to maintain <200 line rule
struct PrivacyPolicySheet: View {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @Binding var hasReadPrivacyPolicy: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    privacyPolicyContent
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        hasReadPrivacyPolicy = true
                        isPresented = false
                    }
                }
            }
        }
    }
    
    // MARK: - Privacy Policy Content
    
    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FinanceMate Privacy Policy")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Last updated: August 2025")
                .font(.caption)
                .foregroundColor(.secondary)
            
            privacySection(
                title: "Information We Collect",
                content: "FinanceMate processes email receipts locally on your device. We do not transmit, store, or share your email content with external servers. All processing occurs within the application on your Mac."
            )
            
            privacySection(
                title: "How We Use Information",
                content: "Receipt information is used solely to create financial transactions within your local FinanceMate database. No personal information leaves your device unless you explicitly choose to export or share it."
            )
            
            privacySection(
                title: "Australian Privacy Principles Compliance",
                content: "FinanceMate complies with the Privacy Act 1988 (Cth) and follows all 13 Australian Privacy Principles. You have the right to access, correct, and control your personal information at all times."
            )
            
            privacySection(
                title: "Data Security",
                content: "All data is stored locally using Apple's Core Data framework with encryption. Your financial information is protected by your Mac's security systems and never transmitted to external servers."
            )
            
            privacySection(
                title: "Your Privacy Rights",
                content: "Under the Australian Privacy Act 1988, you have the right to: access your personal information, request corrections to inaccurate information, withdraw consent at any time, and understand how your information is being used."
            )
            
            privacySection(
                title: "Contact Information",
                content: "For privacy-related inquiries or to exercise your privacy rights, please contact us through the FinanceMate application settings or support documentation."
            )
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview {
    PrivacyPolicySheet(
        isPresented: .constant(true),
        hasReadPrivacyPolicy: .constant(false)
    )
}