//
// SemanticValidationServiceTests.swift
// FinanceMateTests
//
// Purpose: RED PHASE - Failing tests for SemanticValidationService
// Requirements: Email-to-merchant semantic mappings, confidence scoring, business rules
// Complexity: Optimized for KISS compliance and atomic testing
// Last Updated: 2025-10-08
//

import XCTest
import CoreData
@testable import FinanceMate

final class SemanticValidationServiceTests: XCTestCase {

    var semanticValidationService: SemanticValidationService!

    override func setUp() {
        super.setUp()
        semanticValidationService = SemanticValidationService.shared
    }

    override func tearDown() {
        semanticValidationService = nil
        super.tearDown()
    }

    // MARK: - Afterpay→Officeworks Semantic Mapping Test

    func testAfterpayToOfficeworksMapping() {
        let email = GmailEmail(
            id: "test-001",
            subject: "Your Officeworks purchase",
            sender: "notifications@afterpay.com",
            date: Date(),
            snippet: "Officeworks receipt"
        )

        let transaction = ExtractedTransaction(
            id: "test-001",
            merchant: "Afterpay",
            amount: 156.99,
            date: Date(),
            category: "Retail",
            items: [],
            confidence: 0.7,
            rawText: "Afterpay payment for Officeworks",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let result = semanticValidationService.validateSemanticMapping(for: transaction, from: email)

        XCTAssertEqual(result.correctedMerchant, "Officeworks")
        XCTAssertGreaterThanOrEqual(result.confidence, 0.85)
        XCTAssertTrue(result.businessRulesApplied.contains(.afterpayMerchantCorrection))
    }

    // MARK: - Confidence Scoring Test

    func testConfidenceScoring() {
        let email = GmailEmail(
            id: "test-002",
            subject: "Payment to Uber",
            sender: "paypal@paypal.com",
            date: Date(),
            snippet: "Uber trip payment"
        )

        let transaction = ExtractedTransaction(
            id: "test-002",
            merchant: "PayPal",
            amount: 45.50,
            date: Date(),
            category: "Transport",
            items: [],
            confidence: 0.6,
            rawText: "Uber ride",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let result = semanticValidationService.validateSemanticMapping(for: transaction, from: email)

        XCTAssertGreaterThan(result.confidence, 0.6)
        XCTAssertLessThanOrEqual(result.confidence, 1.0)
        XCTAssertNotNil(result.confidenceFactors)
    }

    // MARK: - User Feedback Learning Test

    func testUserFeedbackLearning() {
        let email = GmailEmail(
            id: "test-003",
            subject: "Uber payment",
            sender: "paypal@paypal.com",
            date: Date(),
            snippet: "Uber payment confirmation"
        )

        let transaction = ExtractedTransaction(
            id: "test-003",
            merchant: "PayPal",
            amount: 25.00,
            date: Date(),
            category: "Transport",
            items: [],
            confidence: 0.7,
            rawText: "Uber trip",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let corrections = [SemanticCorrection(
            originalMerchant: "PayPal",
            correctedMerchant: "Uber",
            emailDomain: "paypal.com",
            userCorrectionCount: 5,
            confidenceImprovement: 0.3
        )]

        semanticValidationService.updateLearningData(corrections)
        let result = semanticValidationService.validateSemanticMapping(for: transaction, from: email)

        XCTAssertEqual(result.correctedMerchant, "Uber")
        XCTAssertGreaterThanOrEqual(result.confidence, 0.85)
    }
}