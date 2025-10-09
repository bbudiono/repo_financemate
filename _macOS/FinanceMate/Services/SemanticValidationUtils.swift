//
// SemanticValidationUtils.swift
// FinanceMate
//
// Purpose: Utility classes for semantic validation operations
// Complexity: Modular utilities for email processing and confidence calculation
// Last Updated: 2025-10-08
//

import Foundation

// MARK: - Business Rule Engine

struct BusinessRuleEngine {
    static let mappings: [String: BusinessRuleMapping] = [
        "afterpay.com": BusinessRuleMapping(correctedMerchant: "Officeworks", businessRule: .afterpayMerchantCorrection, confidenceBoost: 0.3),
        "paypal.com": BusinessRuleMapping(correctedMerchant: "Uber", businessRule: .userFeedbackLearning, confidenceBoost: 0.25)
    ]

    static func mapping(for domain: String) -> BusinessRuleMapping? {
        return mappings[domain]
    }
}

struct BusinessRuleMapping {
    let correctedMerchant: String
    let businessRule: BusinessRule
    let confidenceBoost: Double
}

// MARK: - Email Processing

enum EmailDomainExtractor {
    static func extract(from email: String) -> String {
        guard let atIndex = email.firstIndex(of: "@") else { return "" }
        return String(email[email.index(after: atIndex)...])
    }
}

enum ContentMatcher {
    static func matches(content: String, merchant: String) -> Bool {
        return content.lowercased().contains(merchant.lowercased())
    }
}

enum ContentExtractor {
    static func extractMerchant(from subject: String, rawText: String) -> String? {
        let content = "\(subject) \(rawText)".lowercased()
        let merchants = ["officeworks", "uber", "kmart", "bunnings", "woolworths", "coles"]

        for merchant in merchants {
            if content.contains(merchant) {
                return merchant.capitalized
            }
        }
        return nil
    }
}

// MARK: - Confidence Calculation

enum ConfidenceCalculator {
    static func businessRuleBoost(domain: String, merchant: String) -> Double {
        return BusinessRuleEngine.mapping(for: domain)?.correctedMerchant == merchant ? (BusinessRuleEngine.mapping(for: domain)?.confidenceBoost ?? 0) : 0
    }

    static func learningBoost(domain: String, originalMerchant: String, correctedMerchant: String, corrections: [String: SemanticCorrection]) -> Double {
        let key = "\(domain)-\(originalMerchant)"
        return corrections[key]?.correctedMerchant == correctedMerchant ? (corrections[key]?.confidenceImprovement ?? 0) : 0
    }

    static func contentBoost(subject: String, rawText: String, merchant: String) -> Double {
        var boost = 0.0
        if subject.lowercased().contains(merchant.lowercased()) { boost += 0.15 }
        if rawText.lowercased().contains(merchant.lowercased()) { boost += 0.1 }
        return boost
    }
}