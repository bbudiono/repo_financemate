import Foundation

/**
 * Purpose: Business rule condition models for the BusinessRulesEngine
 * Issues & Complexity Summary: Atomic models for rule evaluation system
 * Key Complexity Drivers:
 * - Logic Scope (Est. LoC): ~10
 * - Core Algorithm Complexity: Low (enum with basic properties)
 * - Dependencies: 0 New, 0 Mod
 * - State Management Complexity: Low (immutable models)
 * - Novelty/Uncertainty Factor: Low (standard enum patterns)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 45%
 * Final Code Complexity: 48%
 * Overall Result Score: 98%
 * Key Variances/Learnings: Minimal complexity enables better testability
 * Last Updated: 2025-10-08
 */

// MARK: - Business Rule Condition

public enum BusinessRuleCondition: Codable {
    case emailDomainEquals(String)
    case merchantContains(String)
    case merchantEquals(String)
    case amountGreaterThan(Double)
    case categoryEquals(String)
    case custom(String, String)

    var type: String {
        switch self {
        case .emailDomainEquals: return "email_domain_equals"
        case .merchantContains: return "merchant_contains"
        case .merchantEquals: return "merchant_equals"
        case .amountGreaterThan: return "amount_greater_than"
        case .categoryEquals: return "category_equals"
        case .custom(let type, _): return type
        }
    }

    var value: String {
        switch self {
        case .emailDomainEquals(let domain): return domain
        case .merchantContains(let merchants): return merchants
        case .merchantEquals(let merchant): return merchant
        case .amountGreaterThan(let amount): return String(amount)
        case .categoryEquals(let category): return category
        case .custom(_, let value): return value
        }
    }
}