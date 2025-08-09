//
// HelpDemoFactoryCore.swift
// FinanceMate
//
// Core Demo Factory Logic
// Created: 2025-08-08
// Target: FinanceMate
//

/*
 * Purpose: Core demo factory logic with modular architecture
 * Issues & Complexity Summary: Core demo creation patterns
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~60
   - Core Algorithm Complexity: Low
   - Dependencies: Foundation
   - State Management Complexity: None (stateless factory)
   - Novelty/Uncertainty Factor: Low (standard factory patterns)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 95%
 * Initial Code Complexity Estimate: 95%
 * Final Code Complexity: 95%
 * Overall Result Score: 95%
 * Key Variances/Learnings: Modular factory improves extensibility
 * Last Updated: 2025-08-08
 */

import Foundation

/// Core demo factory with modular architecture
struct HelpDemoFactoryCore {
    
    /// Create split allocation demo
    static func createSplitAllocationDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Split Allocation Demo",
            description: "Interactive demo showing how to split transactions across tax categories",
            steps: HelpDemoSteps.splitAllocationSteps(),
            estimatedDuration: 180.0
        )
    }
    
    /// Create transaction categorization demo
    static func createTransactionCategorizationDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Transaction Categorization",
            description: "Learn to categorize transactions for tax compliance",
            steps: HelpDemoSteps.categorizationSteps(),
            estimatedDuration: 120.0
        )
    }
    
    /// Create net wealth dashboard demo
    static func createNetWealthDashboardDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Net Wealth Dashboard",
            description: "Navigate the comprehensive net wealth visualization",
            steps: HelpDemoSteps.dashboardNavigationSteps(),
            estimatedDuration: 150.0
        )
    }
    
    /// Create asset management demo
    static func createAssetManagementDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Asset Management",
            description: "Manage your assets and liabilities",
            steps: HelpDemoSteps.assetManagementSteps(),
            estimatedDuration: 200.0
        )
    }
    
    /// Create reporting demo
    static func createReportingDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Financial Reporting",
            description: "Generate comprehensive financial reports",
            steps: HelpDemoSteps.reportingSteps(),
            estimatedDuration: 160.0
        )
    }
}