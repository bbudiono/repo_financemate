import SwiftUI

/**
 * TermsAndConditionsSheet.swift
 * 
 * Purpose: PHASE 3.3 - Modular terms and conditions sheet component (extracted from PrivacyConsentView)
 * Issues & Complexity Summary: Terms and conditions content display with usage agreement details
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~70 (focused terms content display responsibility)
 *   - Core Algorithm Complexity: Low (content display and navigation handling)
 *   - Dependencies: 1 (SwiftUI)
 *   - State Management Complexity: Low (sheet presentation and dismissal)
 *   - Novelty/Uncertainty Factor: Low (established content display patterns)
 * AI Pre-Task Self-Assessment: 98%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 73%
 * Target Coverage: Terms content validation testing
 * Australian Compliance: Consumer protection and agreement disclosure requirements
 * Last Updated: 2025-08-08
 */

/// Modular terms and conditions sheet component
/// Extracted from PrivacyConsentView to maintain <200 line rule
struct TermsAndConditionsSheet: View {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    termsContent
                }
                .padding()
            }
            .navigationTitle("Terms & Conditions")
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
    
    // MARK: - Terms Content
    
    private var termsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FinanceMate Terms & Conditions")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("By using FinanceMate's email receipt processing feature, you agree to these terms.")
                .font(.body)
            
            termsSection(
                title: "Email Access",
                content: "FinanceMate requires permission to access your email to process receipts. This access is used only for extracting transaction information and creating financial records."
            )
            
            termsSection(
                title: "Local Processing",
                content: "All email processing occurs locally on your device. FinanceMate does not send your emails or personal information to external servers or third parties."
            )
            
            termsSection(
                title: "Consent Withdrawal",
                content: "You may withdraw consent for email processing at any time through the application settings. This will disable email receipt processing but will not affect your existing financial data."
            )
            
            termsSection(
                title: "Accuracy of Information",
                content: "While FinanceMate uses advanced OCR technology to extract receipt information, you are responsible for reviewing and verifying all extracted transaction data before making financial decisions."
            )
            
            termsSection(
                title: "Software Updates",
                content: "FinanceMate may receive updates that modify or improve email processing capabilities. Continued use of the application constitutes acceptance of updated terms."
            )
            
            termsSection(
                title: "Limitation of Liability",
                content: "FinanceMate is provided 'as is' for personal financial management. We are not liable for any decisions made based on processed receipt information."
            )
        }
    }
    
    private func termsSection(title: String, content: String) -> some View {
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
    TermsAndConditionsSheet(
        isPresented: .constant(true)
    )
}