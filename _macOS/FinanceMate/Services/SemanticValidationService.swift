//
// SemanticValidationService.swift
// FinanceMate
//
// Purpose: GREEN PHASE - Semantic validation for email-to-merchant mappings
// BLUEPRINT.md Requirements: Semantic Validation Service with confidence scoring and business rule application
// Features: Domain pattern recognition, confidence scoring, Afterpay→Officeworks business rules, user feedback learning
// Complexity: Optimized for KISS compliance and atomic implementation
// Last Updated: 2025-10-08
//

import Foundation

/// Service for performing semantic validation of email-to-merchant mappings
class SemanticValidationService {

    static let shared = SemanticValidationService()

    private var semanticCorrections: [String: SemanticCorrection] = [:]

    private init() {}

    // MARK: - Public Interface

    func validateSemanticMapping(for transaction: ExtractedTransaction, from email: GmailEmail) -> SemanticValidationResult {
        let validator = SemanticValidator(
            transaction: transaction,
            email: email,
            corrections: semanticCorrections
        )
        return validator.validate()
    }

    func updateLearningData(_ corrections: [SemanticCorrection]) {
        for correction in corrections {
            let key = "\(correction.emailDomain)-\(correction.originalMerchant)"
            semanticCorrections[key] = correction
        }
    }

    func validateAndApplySemanticMapping(to transaction: inout ExtractedTransaction, from email: GmailEmail) -> Bool {
        let result = validateSemanticMapping(for: transaction, from: email)
        transaction.merchant = result.correctedMerchant
        transaction.confidence = result.confidence
        return result.confidence > 0.8
    }
}