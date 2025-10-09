import Foundation
import CoreData
import os.log

/**
 * Purpose: Business rule evaluation service for processing rules against transactions
 * Requirements: Rule evaluation, priority execution, semantic mapping integration
 * Complexity: Optimized for KISS compliance and atomic implementation
 * Last Updated: 2025-10-08
 */

/// Service for evaluating business rules against transaction data
class BusinessRuleEvaluator {

    private static let logger = Logger(subsystem: "FinanceMate", category: "BusinessRuleEvaluator")

    private init() {}

    static let shared = BusinessRuleEvaluator()

    // MARK: - Rule Evaluation

    /// Evaluates a single rule against transaction data
    func evaluateRule(
        _ rule: BusinessRule,
        against transaction: ExtractedTransaction,
        from email: GmailEmail
    ) -> BusinessRuleEvaluationResult {
        guard rule.enabled else {
            return BusinessRuleEvaluationResult(rule: rule, matched: false)
        }

        let matched = evaluateCondition(rule, against: transaction, from: email)

        if matched {
            rule.recordExecution()
            if let action = rule.typedAction {
                let context = ["ruleId": rule.id.uuidString, "executionTime": Date()]
                return BusinessRuleEvaluationResult(
                    rule: rule,
                    matched: true,
                    action: action,
                    executionContext: context
                )
            }
        }

        return BusinessRuleEvaluationResult(rule: rule, matched: false)
    }

    /// Evaluates and applies all applicable rules to a transaction
    func evaluateAndApplyRules(
        to transaction: ExtractedTransaction,
        from email: GmailEmail
    ) -> [BusinessRuleEvaluationResult] {
        let rules = BusinessRulesEngine.shared.loadEnabledRules()
        let sortedRules = rules.sorted { $0.priority > $1.priority }

        var results: [BusinessRuleEvaluationResult] = []

        for rule in sortedRules {
            let result = evaluateRule(rule, against: transaction, from: email)
            if result.matched {
                results.append(result)
            }
        }

        return results
    }

    /// Validates and applies semantic mapping to transaction
    func validateAndApplySemanticMapping(
        to transaction: ExtractedTransaction,
        from email: GmailEmail
    ) -> SemanticValidationResult {
        let results = evaluateAndApplyRules(to: transaction, from: email)

        var correctedMerchant = transaction.merchant
        var finalConfidence = transaction.confidence
        var appliedRules: Set<BusinessRule> = []

        for result in results {
            if case .setMerchant(let merchant) = result.action {
                correctedMerchant = merchant
                finalConfidence += result.rule.confidenceBoost
                appliedRules.insert(.afterpayMerchantCorrection)
            }
        }

        finalConfidence = min(finalConfidence, 1.0)

        return SemanticValidationResult(
            correctedMerchant: correctedMerchant,
            confidence: finalConfidence,
            businessRulesApplied: appliedRules,
            validationReason: "Applied \(results.count) business rule(s)",
            confidenceFactors: Set([.businessRuleApplication, .emailDomainAnalysis]),
            abnValid: nil,
            validatedABN: nil
        )
    }

    // MARK: - Private Helper Methods

    /// Evaluates a condition against transaction and email data
    private func evaluateCondition(
        _ rule: BusinessRule,
        against transaction: ExtractedTransaction,
        from email: GmailEmail
    ) -> Bool {
        guard let condition = rule.typedCondition else { return false }

        switch condition {
        case .emailDomainEquals(let domain):
            return email.sender.lowercased().contains(domain.lowercased())
        case .merchantContains(let merchants):
            return merchants.lowercased().contains(transaction.merchant.lowercased())
        case .merchantEquals(let merchant):
            return transaction.merchant.lowercased() == merchant.lowercased()
        case .amountGreaterThan(let amount):
            return transaction.amount > amount
        case .categoryEquals(let category):
            return transaction.category.lowercased() == category.lowercased()
        case .custom(let type, let value):
            return evaluateCustomCondition(type: type, value: value, transaction: transaction, email: email)
        }
    }

    /// Evaluates custom conditions
    private func evaluateCustomCondition(
        type: String,
        value: String,
        transaction: ExtractedTransaction,
        email: GmailEmail
    ) -> Bool {
        if type == "email_domain_with_content" {
            let parts = value.split(separator: "|").map(String.init)
            guard parts.count == 2 else { return false }

            let domain = parts[0]
            let merchant = parts[1]
            return email.sender.lowercased().contains(domain.lowercased()) &&
                   (email.subject.lowercased().contains(merchant.lowercased()) ||
                    transaction.rawText.lowercased().contains(merchant.lowercased()))
        }
        return false
    }
}