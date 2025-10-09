import Foundation

/**
 * Purpose: Business rule result models for evaluation and application tracking
 * Requirements: Result tracking, execution context, application status
 * Complexity: Optimized for KISS compliance and atomic implementation
 * Last Updated: 2025-10-08
 */

// MARK: - Rule Evaluation Result

public struct BusinessRuleEvaluationResult {
    let rule: BusinessRule
    let matched: Bool
    let action: BusinessRuleAction?
    let executionContext: [String: Any]?
    let executionTime: Date

    init(rule: BusinessRule, matched: Bool, action: BusinessRuleAction? = nil, executionContext: [String: Any]? = nil) {
        self.rule = rule
        self.matched = matched
        self.action = action
        self.executionContext = executionContext
        self.executionTime = Date()
    }
}

// MARK: - Rule Application Result

public struct BusinessRuleApplicationResult {
    let rule: BusinessRule
    let action: BusinessRuleAction
    let previousValue: String?
    let newValue: String?
    let success: Bool
    let errorMessage: String?

    init(rule: BusinessRule, action: BusinessRuleAction, previousValue: String? = nil, newValue: String? = nil, success: Bool = true, errorMessage: String? = nil) {
        self.rule = rule
        self.action = action
        self.previousValue = previousValue
        self.newValue = newValue
        self.success = success
        self.errorMessage = errorMessage
    }
}