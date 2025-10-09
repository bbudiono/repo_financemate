import Foundation

/**
 * Purpose: Extensions for BusinessRule to support typed conditions and actions
 * Requirements: Type-safe conversion between string and enum representations
 * Complexity: Minimal extension for clean type conversion
 * Last Updated: 2025-10-08
 */

// MARK: - BusinessRule Extensions

extension BusinessRule {

    /// Gets the rule condition as a typed object
    public var typedCondition: BusinessRuleCondition? {
        switch conditionType {
        case "email_domain_equals": return .emailDomainEquals(conditionValue)
        case "merchant_contains": return .merchantContains(conditionValue)
        case "merchant_equals": return .merchantEquals(conditionValue)
        case "amount_greater_than": return .amountGreaterThan(Double(conditionValue) ?? 0.0)
        case "category_equals": return .categoryEquals(conditionValue)
        default: return .custom(conditionType, conditionValue)
        }
    }

    /// Gets the rule action as a typed object
    public var typedAction: BusinessRuleAction? {
        switch actionType {
        case "set_merchant": return .setMerchant(actionValue ?? "")
        case "set_category": return .setCategory(actionValue ?? "")
        case "validate_abn": return .validateABN
        default: return .custom(actionType, actionValue)
        }
    }
}

// MARK: - BusinessRuleCondition Extensions

extension BusinessRuleCondition {

    static func from(type: String, value: String) -> BusinessRuleCondition? {
        switch type {
        case "email_domain_equals": return .emailDomainEquals(value)
        case "merchant_contains": return .merchantContains(value)
        case "merchant_equals": return .merchantEquals(value)
        case "amount_greater_than": return .amountGreaterThan(Double(value) ?? 0.0)
        case "category_equals": return .categoryEquals(value)
        default: return .custom(type, value)
        }
    }
}

// MARK: - BusinessRuleAction Extensions

extension BusinessRuleAction {

    static func from(type: String, value: String?) -> BusinessRuleAction? {
        switch type {
        case "set_merchant": return .setMerchant(value ?? "")
        case "set_category": return .setCategory(value ?? "")
        case "validate_abn": return .validateABN
        default: return .custom(type, value)
        }
    }
}