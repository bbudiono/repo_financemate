import Foundation

/// Walkthrough step generator for interactive financial workflows
/// Focused responsibility: Generate context-aware walkthrough steps for all financial workflows
final class WalkthroughStepGenerator {
    
    /// Generate walkthrough steps for a specific financial workflow
    static func generateSteps(for workflow: FinancialWorkflow) -> [WalkthroughStep] {
        switch workflow {
        case .splitAllocationCreation:
            return generateSplitAllocationSteps()
        case .transactionCategorization:
            return generateTransactionCategorizationSteps()
        case .reportGeneration:
            return generateReportGenerationSteps()
        case .analyticsInterpretation:
            return generateAnalyticsInterpretationSteps()
        case .taxCategorySetup:
            return generateTaxCategorySetupSteps()
        }
    }
    
    // MARK: - Split Allocation Creation Steps
    
    private static func generateSplitAllocationSteps() -> [WalkthroughStep] {
        return [
            WalkthroughStep(
                stepNumber: 1,
                title: "Create Transaction",
                instruction: "Start by creating a new transaction",
                context: .transactionEntry,
                requiredAction: "create_transaction",
                validationCriteria: "transaction_created"
            ),
            WalkthroughStep(
                stepNumber: 2,
                title: "Enable Split Allocation",
                instruction: "Turn on split allocation for this transaction",
                context: .splitAllocation,
                requiredAction: "enable_split",
                validationCriteria: "split_enabled"
            ),
            WalkthroughStep(
                stepNumber: 3,
                title: "Add Tax Categories",
                instruction: "Select tax categories for allocation",
                context: .taxCategorySelection,
                requiredAction: "add_categories",
                validationCriteria: "categories_added"
            ),
            WalkthroughStep(
                stepNumber: 4,
                title: "Set Percentages",
                instruction: "Allocate percentages across categories",
                context: .splitAllocation,
                requiredAction: "set_percentages",
                validationCriteria: "percentages_total_100"
            ),
            WalkthroughStep(
                stepNumber: 5,
                title: "Save Split Allocation",
                instruction: "Save your split allocation configuration",
                context: .splitAllocation,
                requiredAction: "save_split",
                validationCriteria: "split_saved"
            )
        ]
    }
    
    // MARK: - Transaction Categorization Steps
    
    private static func generateTransactionCategorizationSteps() -> [WalkthroughStep] {
        return [
            WalkthroughStep(
                stepNumber: 1,
                title: "Select Transaction",
                instruction: "Choose a transaction to categorize",
                context: .transactionEntry,
                requiredAction: "select_transaction",
                validationCriteria: "transaction_selected"
            ),
            WalkthroughStep(
                stepNumber: 2,
                title: "Choose Category",
                instruction: "Select the appropriate tax category",
                context: .taxCategorySelection,
                requiredAction: "choose_category",
                validationCriteria: "category_selected"
            ),
            WalkthroughStep(
                stepNumber: 3,
                title: "Save Changes",
                instruction: "Save the transaction categorization",
                context: .transactionEntry,
                requiredAction: "save_transaction",
                validationCriteria: "transaction_saved"
            )
        ]
    }
    
    // MARK: - Report Generation Steps
    
    private static func generateReportGenerationSteps() -> [WalkthroughStep] {
        return [
            WalkthroughStep(
                stepNumber: 1,
                title: "Access Reports",
                instruction: "Navigate to the reports section",
                context: .reporting,
                requiredAction: "access_reports",
                validationCriteria: "reports_accessed"
            ),
            WalkthroughStep(
                stepNumber: 2,
                title: "Select Report Type",
                instruction: "Choose the type of report to generate",
                context: .reporting,
                requiredAction: "select_report_type",
                validationCriteria: "report_type_selected"
            ),
            WalkthroughStep(
                stepNumber: 3,
                title: "Configure Parameters",
                instruction: "Set date range and other parameters",
                context: .reporting,
                requiredAction: "configure_parameters",
                validationCriteria: "parameters_configured"
            ),
            WalkthroughStep(
                stepNumber: 4,
                title: "Generate Report",
                instruction: "Generate and review your report",
                context: .reporting,
                requiredAction: "generate_report",
                validationCriteria: "report_generated"
            )
        ]
    }
    
    // MARK: - Analytics Interpretation Steps
    
    private static func generateAnalyticsInterpretationSteps() -> [WalkthroughStep] {
        return [
            WalkthroughStep(
                stepNumber: 1,
                title: "Open Analytics",
                instruction: "Navigate to the analytics dashboard",
                context: .analytics,
                requiredAction: "open_analytics",
                validationCriteria: "analytics_opened"
            ),
            WalkthroughStep(
                stepNumber: 2,
                title: "Review Key Metrics",
                instruction: "Examine your key financial metrics",
                context: .analytics,
                requiredAction: "review_metrics",
                validationCriteria: "metrics_reviewed"
            ),
            WalkthroughStep(
                stepNumber: 3,
                title: "Analyze Trends",
                instruction: "Look at trends and patterns in your data",
                context: .analytics,
                requiredAction: "analyze_trends",
                validationCriteria: "trends_analyzed"
            )
        ]
    }
    
    // MARK: - Tax Category Setup Steps
    
    private static func generateTaxCategorySetupSteps() -> [WalkthroughStep] {
        return [
            WalkthroughStep(
                stepNumber: 1,
                title: "Access Settings",
                instruction: "Navigate to tax category settings",
                context: .settings,
                requiredAction: "access_settings",
                validationCriteria: "settings_accessed"
            ),
            WalkthroughStep(
                stepNumber: 2,
                title: "Create Category",
                instruction: "Create a new tax category",
                context: .taxCategorySelection,
                requiredAction: "create_category",
                validationCriteria: "category_created"
            ),
            WalkthroughStep(
                stepNumber: 3,
                title: "Configure Rules",
                instruction: "Set up category rules and defaults",
                context: .taxCategorySelection,
                requiredAction: "configure_rules",
                validationCriteria: "rules_configured"
            )
        ]
    }
}