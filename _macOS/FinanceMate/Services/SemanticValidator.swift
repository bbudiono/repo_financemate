//
// SemanticValidator.swift
// FinanceMate
//
// Purpose: Core validation logic for semantic merchant mapping
// Complexity: Focused validation engine with KISS principles
// Last Updated: 2025-10-08
//

import Foundation

/// Core validator for semantic merchant mapping
class SemanticValidator {
    let transaction: ExtractedTransaction
    let email: GmailEmail
    let corrections: [String: SemanticCorrection]

    init(transaction: ExtractedTransaction, email: GmailEmail, corrections: [String: SemanticCorrection]) {
        self.transaction = transaction
        self.email = email
        self.corrections = corrections
    }

    func validate() -> SemanticValidationResult {
        let correctedMerchant = findCorrectedMerchant()
        let confidence = calculateConfidence(correctedMerchant: correctedMerchant)
        let appliedRules = determineAppliedRules(correctedMerchant: correctedMerchant)
        let validationReason = generateValidationReason(correctedMerchant: correctedMerchant)
        let confidenceFactors = determineConfidenceFactors()

        return SemanticValidationResult(
            correctedMerchant: correctedMerchant,
            confidence: confidence,
            businessRulesApplied: appliedRules,
            validationReason: validationReason,
            confidenceFactors: confidenceFactors,
            abnValid: validateABN(),
            validatedABN: normalizeABN()
        )
    }

    private func findCorrectedMerchant() -> String {
        let emailDomain = EmailDomainExtractor.extract(from: email.sender)

        // RULE 1: Business rule mappings (e.g., afterpay.com → Officeworks)
        if let mapping = BusinessRuleEngine.mapping(for: emailDomain) {
            if ContentMatcher.matches(content: email.subject + transaction.rawText, merchant: mapping.correctedMerchant) {
                NSLog("[SEMANTIC-VALIDATION] Business rule applied: \(emailDomain) → \(mapping.correctedMerchant)")
                return mapping.correctedMerchant
            }
        }

        // RULE 2: User feedback learning (historical corrections)
        let learningKey = "\(emailDomain)-\(transaction.merchant)"
        if let correction = corrections[learningKey] {
            NSLog("[SEMANTIC-VALIDATION] User correction applied: \(transaction.merchant) → \(correction.correctedMerchant)")
            return correction.correctedMerchant
        }

        // RULE 3: Preserve original merchant (do NOT override with naive matching)
        // ContentExtractor was deleted due to naive .contains() bugs
        // The extraction pipeline (Tier 1/2/3) already did proper merchant extraction
        NSLog("[SEMANTIC-VALIDATION] No validation rules applied - preserving original: \(transaction.merchant)")
        return transaction.merchant
    }

    private func calculateConfidence(correctedMerchant: String) -> Double {
        var confidence = transaction.confidence
        let emailDomain = EmailDomainExtractor.extract(from: email.sender)

        confidence += ConfidenceCalculator.businessRuleBoost(domain: emailDomain, merchant: correctedMerchant)
        confidence += ConfidenceCalculator.learningBoost(domain: emailDomain, originalMerchant: transaction.merchant, correctedMerchant: correctedMerchant, corrections: corrections)
        confidence += ConfidenceCalculator.contentBoost(subject: email.subject, rawText: transaction.rawText, merchant: correctedMerchant)

        return min(confidence, 1.0)
    }

    private func determineAppliedRules(correctedMerchant: String) -> Set<BusinessRule> {
        var appliedRules: Set<BusinessRule> = []
        let emailDomain = EmailDomainExtractor.extract(from: email.sender)

        if let mapping = BusinessRuleEngine.mapping(for: emailDomain), correctedMerchant == mapping.correctedMerchant {
            appliedRules.insert(mapping.businessRule)
        }

        let learningKey = "\(emailDomain)-\(transaction.merchant)"
        if corrections[learningKey] != nil {
            appliedRules.insert(.userFeedbackLearning)
        }

        appliedRules.insert(.semanticPatternMatching)
        return appliedRules
    }

    private func generateValidationReason(correctedMerchant: String) -> String {
        let emailDomain = EmailDomainExtractor.extract(from: email.sender)

        if let mapping = BusinessRuleEngine.mapping(for: emailDomain), correctedMerchant == mapping.correctedMerchant {
            return "Email domain \(emailDomain) with \(correctedMerchant) content indicates semantic merchant mapping"
        }

        let learningKey = "\(emailDomain)-\(transaction.merchant)"
        if corrections[learningKey] != nil {
            return "Applied user feedback learning for \(emailDomain) domain"
        }

        return "Content-based semantic analysis for merchant identification"
    }

    private func determineConfidenceFactors() -> Set<ConfidenceFactor> {
        var factors: Set<ConfidenceFactor> = [.subjectMerchantMatch, .emailDomainAnalysis, .contentSemanticAnalysis, .businessRuleApplication]

        let emailDomain = EmailDomainExtractor.extract(from: email.sender)
        let learningKey = "\(emailDomain)-\(transaction.merchant)"
        if corrections[learningKey] != nil {
            factors.insert(.historicalUserCorrections)
        }

        return factors
    }

    private func validateABN() -> Bool? {
        guard let abn = transaction.abn else { return nil }
        let cleanABN = abn.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return cleanABN.count == 11
    }

    private func normalizeABN() -> String? {
        guard let abn = transaction.abn else { return nil }
        return abn.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}