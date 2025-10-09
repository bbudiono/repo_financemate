import Foundation

/**
 * Purpose: Business rule action models for the BusinessRulesEngine
 * Issues & Complexity Summary: Atomic models for rule execution system
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

// MARK: - Business Rule Action

public enum BusinessRuleAction: Codable {
    case setMerchant(String)
    case setCategory(String)
    case validateABN
    case boostConfidence(Double)
    case setTaxCategory(String)
    case applySplitTemplate(String)
    case custom(String, String?)

    var type: String {
        switch self {
        case .setMerchant: return "set_merchant"
        case .setCategory: return "set_category"
        case .validateABN: return "validate_abn"
        case .boostConfidence: return "boost_confidence"
        case .setTaxCategory: return "set_tax_category"
        case .applySplitTemplate: return "apply_split_template"
        case .custom(let type, _): return type
        }
    }

    var value: String? {
        switch self {
        case .setMerchant(let merchant): return merchant
        case .setCategory(let category): return category
        case .validateABN: return nil
        case .boostConfidence(let boost): return String(boost)
        case .setTaxCategory(let taxCategory): return taxCategory
        case .applySplitTemplate(let template): return template
        case .custom(_, let value): return value
        }
    }
}