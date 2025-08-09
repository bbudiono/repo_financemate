import Foundation

/// Factory for creating interactive demo templates
/// Focused responsibility: Generate demo templates for different help contexts
struct HelpDemoFactory {
    
    /// Create split allocation demo
    static func createSplitAllocationDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Split Allocation Demo",
            description: "Interactive demo showing how to split transactions across tax categories",
            steps: [
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
            ],
            estimatedDuration: 180.0
        )
    }
    
    /// Create transaction entry demo
    static func createTransactionEntryDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Transaction Entry Demo",
            description: "Learn how to add new transactions",
            steps: [
                DemoStep(
                    stepNumber: 1,
                    title: "Open Entry Form",
                    instruction: "Tap the add transaction button",
                    highlightedElement: "add_button",
                    expectedAction: "form_opened"
                ),
                DemoStep(
                    stepNumber: 2,
                    title: "Enter Details",
                    instruction: "Fill in transaction amount and description",
                    highlightedElement: "entry_form",
                    expectedAction: "details_entered"
                ),
                DemoStep(
                    stepNumber: 3,
                    title: "Select Category",
                    instruction: "Choose appropriate tax category",
                    highlightedElement: "category_picker",
                    expectedAction: "category_selected"
                ),
                DemoStep(
                    stepNumber: 4,
                    title: "Save Transaction",
                    instruction: "Save the new transaction",
                    highlightedElement: "save_button",
                    expectedAction: "transaction_saved"
                )
            ],
            estimatedDuration: 120.0
        )
    }
    
    /// Create tax category demo
    static func createTaxCategoryDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Tax Category Selection Demo",
            description: "Understand how to choose the right tax categories",
            steps: [
                DemoStep(
                    stepNumber: 1,
                    title: "View Categories",
                    instruction: "Review available tax categories",
                    highlightedElement: "category_list",
                    expectedAction: "categories_viewed"
                ),
                DemoStep(
                    stepNumber: 2,
                    title: "Understand Types",
                    instruction: "Learn about different category types",
                    highlightedElement: "category_info",
                    expectedAction: "types_understood"
                ),
                DemoStep(
                    stepNumber: 3,
                    title: "Make Selection",
                    instruction: "Choose the most appropriate category",
                    highlightedElement: "selection_button",
                    expectedAction: "selection_made"
                )
            ],
            estimatedDuration: 90.0
        )
    }
    
    /// Create reporting demo
    static func createReportingDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Financial Reporting Demo",
            description: "Generate and understand financial reports",
            steps: [
                DemoStep(
                    stepNumber: 1,
                    title: "Access Reports",
                    instruction: "Navigate to the reports section",
                    highlightedElement: "reports_tab",
                    expectedAction: "reports_accessed"
                ),
                DemoStep(
                    stepNumber: 2,
                    title: "Select Report Type",
                    instruction: "Choose your desired report",
                    highlightedElement: "report_selector",
                    expectedAction: "report_selected"
                ),
                DemoStep(
                    stepNumber: 3,
                    title: "Set Parameters",
                    instruction: "Configure date range and filters",
                    highlightedElement: "parameter_controls",
                    expectedAction: "parameters_set"
                ),
                DemoStep(
                    stepNumber: 4,
                    title: "Generate Report",
                    instruction: "Create and review your report",
                    highlightedElement: "generate_button",
                    expectedAction: "report_generated"
                )
            ],
            estimatedDuration: 150.0
        )
    }
    
    /// Create analytics demo
    static func createAnalyticsDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Analytics Dashboard Demo",
            description: "Navigate and interpret your financial analytics",
            steps: [
                DemoStep(
                    stepNumber: 1,
                    title: "Open Analytics",
                    instruction: "Access the analytics dashboard",
                    highlightedElement: "analytics_tab",
                    expectedAction: "analytics_opened"
                ),
                DemoStep(
                    stepNumber: 2,
                    title: "Review Charts",
                    instruction: "Examine income and expense trends",
                    highlightedElement: "chart_area",
                    expectedAction: "charts_reviewed"
                ),
                DemoStep(
                    stepNumber: 3,
                    title: "Interpret Insights",
                    instruction: "Understand key financial insights",
                    highlightedElement: "insights_panel",
                    expectedAction: "insights_interpreted"
                )
            ],
            estimatedDuration: 120.0
        )
    }
    
    /// Create dashboard demo
    static func createDashboardDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Dashboard Navigation Demo",
            description: "Learn to navigate your financial dashboard",
            steps: [
                DemoStep(
                    stepNumber: 1,
                    title: "Overview Cards",
                    instruction: "Review balance and summary cards",
                    highlightedElement: "overview_cards",
                    expectedAction: "overview_reviewed"
                ),
                DemoStep(
                    stepNumber: 2,
                    title: "Recent Transactions",
                    instruction: "Browse recent transaction history",
                    highlightedElement: "transaction_list",
                    expectedAction: "transactions_browsed"
                ),
                DemoStep(
                    stepNumber: 3,
                    title: "Quick Actions",
                    instruction: "Use quick action buttons",
                    highlightedElement: "action_buttons",
                    expectedAction: "actions_used"
                )
            ],
            estimatedDuration: 90.0
        )
    }
    
    /// Create settings demo
    static func createSettingsDemo() -> InteractiveDemo {
        return InteractiveDemo(
            title: "Settings Configuration Demo",
            description: "Configure your app preferences and settings",
            steps: [
                DemoStep(
                    stepNumber: 1,
                    title: "Access Settings",
                    instruction: "Navigate to the settings screen",
                    highlightedElement: "settings_tab",
                    expectedAction: "settings_accessed"
                ),
                DemoStep(
                    stepNumber: 2,
                    title: "Adjust Preferences",
                    instruction: "Modify your user preferences",
                    highlightedElement: "preference_controls",
                    expectedAction: "preferences_adjusted"
                ),
                DemoStep(
                    stepNumber: 3,
                    title: "Save Changes",
                    instruction: "Save your configuration changes",
                    highlightedElement: "save_button",
                    expectedAction: "changes_saved"
                )
            ],
            estimatedDuration: 60.0
        )
    }
}