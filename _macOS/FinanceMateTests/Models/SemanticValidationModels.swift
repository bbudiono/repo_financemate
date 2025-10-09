//
// SemanticValidationModels.swift
// FinanceMateTests
//
// Purpose: Test data models for SemanticValidationService
// These models will be implemented in the actual service during GREEN phase
// Last Updated: 2025-10-08
//

import Foundation

// MARK: - Semantic Validation Result Model

struct SemanticValidationResult {
    let correctedMerchant: String
    let confidence: Double
    let businessRulesApplied: Set<BusinessRule>
    let validationReason: String
    let confidenceFactors: Set<ConfidenceFactor>?
    let abnValid: Bool?
    let validatedABN: String?
}

// MARK: - Business Rules Enum

enum BusinessRule: String, CaseIterable {
    case afterpayMerchantCorrection = "afterpay_merchant_correction"
    case australianABNValidation = "australian_abn_validation"
    case userFeedbackLearning = "user_feedback_learning"
    case semanticPatternMatching = "semantic_pattern_matching"
}

// MARK: - Confidence Factors Enum

enum ConfidenceFactor: String, CaseIterable {
    case subjectMerchantMatch = "subject_merchant_match"
    case emailDomainAnalysis = "email_domain_analysis"
    case contentSemanticAnalysis = "content_semantic_analysis"
    case historicalUserCorrections = "historical_user_corrections"
    case businessRuleApplication = "business_rule_application"
}

// MARK: - Semantic Correction Model

struct SemanticCorrection {
    let originalMerchant: String
    let correctedMerchant: String
    let emailDomain: String
    let userCorrectionCount: Int
    let confidenceImprovement: Double
}