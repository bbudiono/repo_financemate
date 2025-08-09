import Foundation

/// Financial workflow types and categorization
/// Focused responsibility: Define and categorize available financial workflows for contextual help system
enum FinancialWorkflow: String, CaseIterable {
    case splitAllocationCreation = "split_allocation_creation"
    case transactionCategorization = "transaction_categorization"
    case reportGeneration = "report_generation"
    case analyticsInterpretation = "analytics_interpretation"
    case taxCategorySetup = "tax_category_setup"
    
    /// Workflow categories for organizational purposes
    enum Category {
        case transaction
        case reporting
        case configuration
        case analysis
    }
    
    /// Get the category for this workflow
    var category: Category {
        switch self {
        case .splitAllocationCreation, .transactionCategorization:
            return .transaction
        case .reportGeneration:
            return .reporting
        case .analyticsInterpretation:
            return .analysis
        case .taxCategorySetup:
            return .configuration
        }
    }
    
    /// Display-friendly workflow names
    var displayName: String {
        switch self {
        case .splitAllocationCreation:
            return "Split Allocation Creation"
        case .transactionCategorization:
            return "Transaction Categorization"
        case .reportGeneration:
            return "Report Generation"
        case .analyticsInterpretation:
            return "Analytics Interpretation"
        case .taxCategorySetup:
            return "Tax Category Setup"
        }
    }
}