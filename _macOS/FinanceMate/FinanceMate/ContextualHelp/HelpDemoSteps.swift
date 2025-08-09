//
// HelpDemoSteps.swift
// FinanceMate
//
// Modular Demo Step Definitions
// Created: 2025-08-08
// Target: FinanceMate
//

/*
 * Purpose: Modular demo step definitions for help system
 * Issues & Complexity Summary: Step creation patterns
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~120
   - Core Algorithm Complexity: Low
   - Dependencies: Foundation
   - State Management Complexity: None (stateless step definitions)
   - Novelty/Uncertainty Factor: Low (data definition patterns)
 * AI Pre-Task Self-Assessment: 98%
 * Problem Estimate: 98%
 * Initial Code Complexity Estimate: 98%
 * Final Code Complexity: 98%
 * Overall Result Score: 98%
 * Key Variances/Learnings: Modular steps improve maintainability
 * Last Updated: 2025-08-08
 */

import Foundation

/// Modular demo step definitions
struct HelpDemoSteps {
    
    static func splitAllocationSteps() -> [DemoStep] {
        return [
            DemoStep(
                stepNumber: 1,
                title: "Select Transaction",
                instruction: "Choose the transaction you want to split",
                highlightedElement: "transaction_row",
                expectedAction: "transaction_selected"
            ),
            DemoStep(
                stepNumber: 2,
                title: "Enable Split Mode",
                instruction: "Tap the split allocation button",
                highlightedElement: "split_button",
                expectedAction: "split_enabled"
            ),
            DemoStep(
                stepNumber: 3,
                title: "Add Categories",
                instruction: "Add tax categories for splitting",
                highlightedElement: "category_selector",
                expectedAction: "categories_added"
            ),
            DemoStep(
                stepNumber: 4,
                title: "Set Percentages",
                instruction: "Adjust percentage allocations",
                highlightedElement: "percentage_sliders",
                expectedAction: "percentages_set"
            ),
            DemoStep(
                stepNumber: 5,
                title: "Save Split",
                instruction: "Save your split allocation",
                highlightedElement: "save_button",
                expectedAction: "split_saved"
            )
        ]
    }
    
    static func categorizationSteps() -> [DemoStep] {
        return [
            DemoStep(
                stepNumber: 1,
                title: "Open Transaction",
                instruction: "Select a transaction to categorize",
                highlightedElement: "transaction_item",
                expectedAction: "transaction_opened"
            ),
            DemoStep(
                stepNumber: 2,
                title: "Choose Category",
                instruction: "Select appropriate tax category",
                highlightedElement: "category_picker",
                expectedAction: "category_chosen"
            ),
            DemoStep(
                stepNumber: 3,
                title: "Confirm Changes",
                instruction: "Save the categorization",
                highlightedElement: "save_button",
                expectedAction: "changes_saved"
            )
        ]
    }
    
    static func dashboardNavigationSteps() -> [DemoStep] {
        return [
            DemoStep(
                stepNumber: 1,
                title: "Overview Section",
                instruction: "Review your net wealth overview",
                highlightedElement: "overview_card",
                expectedAction: "overview_viewed"
            ),
            DemoStep(
                stepNumber: 2,
                title: "Asset Breakdown",
                instruction: "Explore asset categories",
                highlightedElement: "asset_chart",
                expectedAction: "asset_explored"
            ),
            DemoStep(
                stepNumber: 3,
                title: "Liability Analysis",
                instruction: "Review liability breakdown",
                highlightedElement: "liability_chart",
                expectedAction: "liability_reviewed"
            )
        ]
    }
    
    static func assetManagementSteps() -> [DemoStep] {
        return [
            DemoStep(
                stepNumber: 1,
                title: "Add Asset",
                instruction: "Create new asset entry",
                highlightedElement: "add_asset_button",
                expectedAction: "asset_form_opened"
            ),
            DemoStep(
                stepNumber: 2,
                title: "Asset Details",
                instruction: "Enter asset information",
                highlightedElement: "asset_form",
                expectedAction: "details_entered"
            ),
            DemoStep(
                stepNumber: 3,
                title: "Save Asset",
                instruction: "Confirm asset creation",
                highlightedElement: "save_asset_button",
                expectedAction: "asset_saved"
            )
        ]
    }
    
    static func reportingSteps() -> [DemoStep] {
        return [
            DemoStep(
                stepNumber: 1,
                title: "Select Report Type",
                instruction: "Choose report format",
                highlightedElement: "report_selector",
                expectedAction: "report_selected"
            ),
            DemoStep(
                stepNumber: 2,
                title: "Set Parameters",
                instruction: "Configure report settings",
                highlightedElement: "report_settings",
                expectedAction: "parameters_set"
            ),
            DemoStep(
                stepNumber: 3,
                title: "Generate Report",
                instruction: "Create the report",
                highlightedElement: "generate_button",
                expectedAction: "report_generated"
            )
        ]
    }
}