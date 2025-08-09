//
// GuidanceContentSections.swift
// FinanceMate
//
// Section-specific Content Views for Guidance Overlay
// Created: 2025-08-08
// Target: FinanceMate
//

/*
 * Purpose: Section-specific content views for guidance overlay system
 * Issues & Complexity Summary: Specialized section rendering and content organization
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~80
   - Core Algorithm Complexity: Medium
   - Dependencies: SwiftUI, ContextualHelpSystem
   - State Management Complexity: Low (section-specific content)
   - Novelty/Uncertainty Factor: Low (standard SwiftUI patterns)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: 90%
 * Overall Result Score: 90%
 * Key Variances/Learnings: Modular sections improve code organization
 * Last Updated: 2025-08-08
 */

import SwiftUI

/// Section-specific content views for guidance overlay system
struct GuidanceContentSections {
    
    // MARK: - Properties
    
    let helpContent: HelpContent?
    let expandedHelpContent: HelpContent?
    
    // MARK: - Computed Properties
    
    private var showsStepByStepGuidance: Bool { helpContent?.includesStepByStepGuidance ?? false }
    private var showsQuickTips: Bool { helpContent?.includesAdvancedTips ?? false }
    
    // MARK: - Standard Content Views
    
    @ViewBuilder
    func standardContentView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsStepByStepGuidance {
                stepByStepContent()
            } else if showsQuickTips {
                quickTipsContent()
            } else {
                balancedContent()
            }
        }
    }
    
    @ViewBuilder
    func expandedContentView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detailed Help")
                .font(.subheadline)
                .fontWeight(.medium)
                .accessibilityAddTraits(.isHeader)
            
            if let expandedContent = expandedHelpContent {
                Text(expandedContent.description)
                    .font(.body)
            }
            
            if helpContent?.includesAustralianTaxCompliance == true {
                australianTaxComplianceSection()
            }
            
            if helpContent?.includesIndustrySpecificTips == true {
                industrySpecificTipsSection()
            }
        }
    }
    
    // MARK: - Specialized Content Views
    
    @ViewBuilder
    private func stepByStepContent() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step-by-Step Guide")
                .font(.subheadline)
                .fontWeight(.medium)
                .accessibilityAddTraits(.isHeader)
            
            VStack(alignment: .leading, spacing: 4) {
                GuidanceHelperViews().helpStepItem("1. Start with basic information")
                GuidanceHelperViews().helpStepItem("2. Add required details")
                GuidanceHelperViews().helpStepItem("3. Review and confirm")
            }
        }
    }
    
    @ViewBuilder
    private func quickTipsContent() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Tips")
                .font(.subheadline)
                .fontWeight(.medium)
                .accessibilityAddTraits(.isHeader)
            
            VStack(alignment: .leading, spacing: 4) {
                GuidanceHelperViews().helpTipItem("💡 Use keyboard shortcuts for faster navigation")
                GuidanceHelperViews().helpTipItem("⚡ Enable expert mode for advanced features")
                GuidanceHelperViews().helpTipItem("🎯 Customize settings for your workflow")
            }
        }
    }
    
    @ViewBuilder
    private func balancedContent() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Best Practices")
                .font(.subheadline)
                .fontWeight(.medium)
                .accessibilityAddTraits(.isHeader)
            
            VStack(alignment: .leading, spacing: 4) {
                GuidanceHelperViews().helpTipItem("📊 Regular categorization improves accuracy")
                GuidanceHelperViews().helpTipItem("🏷️ Use consistent naming conventions")
                GuidanceHelperViews().helpTipItem("📈 Review reports monthly for insights")
            }
        }
    }
    
    @ViewBuilder
    private func australianTaxComplianceSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Australian Tax Compliance")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .accessibilityAddTraits(.isHeader)
            
            VStack(alignment: .leading, spacing: 4) {
                GuidanceHelperViews().helpTipItem("🇦🇺 Ensure ATO compliance with proper categorization")
                GuidanceHelperViews().helpTipItem("📋 Keep detailed records for deduction claims")
                GuidanceHelperViews().helpTipItem("⏰ Consider quarterly reporting requirements")
            }
        }
    }
    
    @ViewBuilder
    private func industrySpecificTipsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Industry-Specific Tips")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.purple)
                .accessibilityAddTraits(.isHeader)
            
            VStack(alignment: .leading, spacing: 4) {
                GuidanceHelperViews().helpTipItem("🏗️ Track project-specific expenses separately")
                GuidanceHelperViews().helpTipItem("🔧 Materials and labor cost allocation")
                GuidanceHelperViews().helpTipItem("📊 Progress billing and cash flow management")
            }
        }
    }
}