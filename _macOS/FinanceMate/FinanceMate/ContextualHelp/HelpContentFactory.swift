import Foundation

/// Factory for creating help content templates
/// Focused responsibility: Generate base help content templates for different contexts
struct HelpContentFactory {
    
    /// Generate base content template for a specific context
    static func createBaseContent(for context: HelpContext) -> HelpContent {
        switch context {
        case .transactionEntry:
            return HelpContent(
                context: context,
                title: "Transaction Entry Help",
                description: "Get help with creating and managing financial transactions.",
                includesStepByStepGuidance: true,
                includesBasicConcepts: true,
                hasMultimediaContent: true,
                isOfflineCapable: true
            )
            
        case .splitAllocation:
            return HelpContent(
                context: context,
                title: "Split Allocation Guide", 
                description: "Learn how to split transactions across tax categories efficiently.",
                includesOptimizationTips: true,
                includesBestPractices: true,
                includesAustralianTaxCompliance: true,
                hasMultimediaContent: true,
                isOfflineCapable: true
            )
            
        case .taxCategorySelection:
            return HelpContent(
                context: context,
                title: "Tax Category Selection",
                description: "Choose the right tax categories for your transactions.",
                includesAustralianTaxCompliance: true,
                includesDeductionGuidance: true,
                includesBestPractices: true,
                isOfflineCapable: true
            )
            
        case .reporting:
            return HelpContent(
                context: context,
                title: "Financial Reporting",
                description: "Generate comprehensive financial reports.",
                includesAdvancedTips: true,
                includesBestPractices: true,
                hasMultimediaContent: true
            )
            
        case .analytics:
            return HelpContent(
                context: context,
                title: "Analytics Dashboard",
                description: "Understand your financial analytics and insights.",
                includesAdvancedTips: true,
                includesOptimizationTips: true,
                hasMultimediaContent: true
            )
            
        case .dashboard:
            return HelpContent(
                context: context,
                title: "Dashboard Overview",
                description: "Navigate your financial dashboard effectively.",
                includesBasicConcepts: true,
                includesKeyboardShortcuts: true,
                isOfflineCapable: true
            )
            
        case .settings:
            return HelpContent(
                context: context,
                title: "Settings Configuration",
                description: "Configure your preferences and settings.",
                includesStepByStepGuidance: true,
                includesBasicConcepts: true,
                isOfflineCapable: true
            )
        }
    }
    
    /// Get adapted complexity for user level
    static func getComplexityForUserLevel(_ userLevel: ExpertiseLevel) -> HelpComplexity {
        switch userLevel {
        case .beginner:
            return .simplified
        case .intermediate:
            return .balanced
        case .advanced:
            return .advanced
        }
    }
}