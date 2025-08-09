import SwiftUI

/**
 * PrivacyComplianceSummary.swift
 * 
 * Purpose: PHASE 3.3 - Modular privacy compliance summary component (extracted from PrivacyConsentView)
 * Issues & Complexity Summary: Privacy rights summary display with Australian compliance details
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~60 (focused compliance summary responsibility)
 *   - Core Algorithm Complexity: Low (static content display and formatting)
 *   - Dependencies: 1 (SwiftUI)
 *   - State Management Complexity: None (static content display)
 *   - Novelty/Uncertainty Factor: Low (established compliance display patterns)
 * AI Pre-Task Self-Assessment: 99%
 * Problem Estimate: 78%
 * Initial Code Complexity Estimate: 70%
 * Target Coverage: Compliance content validation testing
 * Australian Compliance: Privacy Act 1988 (Cth) rights summary display
 * Last Updated: 2025-08-08
 */

/// Modular privacy compliance summary component
/// Extracted from PrivacyConsentView to maintain <200 line rule
struct PrivacyComplianceSummary: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("Your Privacy Rights (Australian Privacy Principles)")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                privacyRightItem("Right to access your personal information")
                privacyRightItem("Right to correct inaccurate information")
                privacyRightItem("Right to withdraw consent at any time")
                privacyRightItem("Local processing - no data leaves your device")
                privacyRightItem("Right to understand how your information is used")
                privacyRightItem("Right to complain to the Privacy Commissioner")
            }
        }
        .padding(12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func privacyRightItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Circle()
                .fill(Color.green)
                .frame(width: 4, height: 4)
                .padding(.top, 4)
            
            Text(text)
                .font(.caption2)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview {
    PrivacyComplianceSummary()
}