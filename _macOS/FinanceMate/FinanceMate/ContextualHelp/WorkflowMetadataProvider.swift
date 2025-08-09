import Foundation

/// Workflow metadata provider for contextual help system
/// Focused responsibility: Provide workflow titles, descriptions, and display metadata
final class WorkflowMetadataProvider {
    
    /// Get the display title for a specific workflow
    static func getTitle(for workflow: FinancialWorkflow) -> String {
        switch workflow {
        case .splitAllocationCreation:
            return "Create Split Allocation"
        case .transactionCategorization:
            return "Categorize Transactions"
        case .reportGeneration:
            return "Generate Financial Reports"
        case .analyticsInterpretation:
            return "Understand Your Analytics"
        case .taxCategorySetup:
            return "Set Up Tax Categories"
        }
    }
    
    /// Get the detailed description for a specific workflow
    static func getDescription(for workflow: FinancialWorkflow) -> String {
        switch workflow {
        case .splitAllocationCreation:
            return "Learn how to split transactions across multiple tax categories for better financial tracking."
        case .transactionCategorization:
            return "Discover how to properly categorize your transactions for accurate reporting."
        case .reportGeneration:
            return "Generate comprehensive financial reports for your business or personal use."
        case .analyticsInterpretation:
            return "Understand and interpret your financial analytics and insights."
        case .taxCategorySetup:
            return "Set up and manage tax categories that align with Australian tax requirements."
        }
    }
    
    /// Get estimated duration for a workflow (in seconds)
    static func getEstimatedDuration(for workflow: FinancialWorkflow, stepCount: Int) -> TimeInterval {
        let baseTimePerStep: TimeInterval = 60 // 1 minute per step
        let workflowMultiplier: Double
        
        switch workflow {
        case .splitAllocationCreation:
            workflowMultiplier = 1.2 // More complex workflow
        case .transactionCategorization:
            workflowMultiplier = 0.8 // Simpler workflow
        case .reportGeneration:
            workflowMultiplier = 1.0 // Standard workflow
        case .analyticsInterpretation:
            workflowMultiplier = 1.5 // Requires more thought
        case .taxCategorySetup:
            workflowMultiplier = 1.3 // Setup workflows take longer
        }
        
        return TimeInterval(Double(stepCount) * baseTimePerStep * workflowMultiplier)
    }
    
    /// Get the appropriate expertise level for a workflow
    static func getRecommendedUserLevel(for workflow: FinancialWorkflow) -> ExpertiseLevel {
        switch workflow {
        case .transactionCategorization:
            return .beginner
        case .splitAllocationCreation, .taxCategorySetup:
            return .intermediate
        case .reportGeneration, .analyticsInterpretation:
            return .advanced
        }
    }
}