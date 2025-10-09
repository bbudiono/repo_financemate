//
// BusinessRulesEngineTests.swift
// FinanceMateTests
//
// Purpose: RED PHASE - Failing tests for BusinessRulesEngine
// Requirements: Business rule creation, evaluation, priority system, semantic mappings, categorization logic, UserAutomationMemory integration
// Complexity: Optimized for KISS compliance and atomic testing
// Last Updated: 2025-10-08
//

import XCTest
import CoreData
@testable import FinanceMate

final class BusinessRulesEngineTests: XCTestCase {

    var businessRulesEngine: BusinessRulesEngine!
    var testContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        businessRulesEngine = BusinessRulesEngine.shared
        testContext = PersistenceController.preview.container.viewContext
    }

    override func tearDown() {
        businessRulesEngine = nil
        testContext = nil
        super.tearDown()
    }

    // MARK: - Business Rule Creation Tests

    func testCreateBusinessRule() {
        let rule = businessRulesEngine.createRule(
            name: "Afterpay to Officeworks",
            condition: BusinessRuleCondition.emailDomainEquals("afterpay.com"),
            action: BusinessRuleAction.setMerchant("Officeworks"),
            priority: 100,
            enabled: true
        )

        XCTAssertNotNil(rule)
        XCTAssertEqual(rule.name, "Afterpay to Officeworks")
        XCTAssertEqual(rule.priority, 100)
        XCTAssertTrue(rule.enabled)
        XCTAssertEqual(rule.condition.type, .emailDomainEquals)
        XCTAssertEqual(rule.action.type, .setMerchant)
    }

    func testCreateRuleWithPriority() {
        let highPriorityRule = businessRulesEngine.createRule(
            name: "High Priority ABN Validation",
            condition: BusinessRuleCondition.merchantContains("Officeworks"),
            action: BusinessRuleAction.validateABN(),
            priority: 200,
            enabled: true
        )

        let lowPriorityRule = businessRulesEngine.createRule(
            name: "Low Priority Category Mapping",
            condition: BusinessRuleCondition.amountGreaterThan(100.0),
            action: BusinessRuleAction.setCategory("Business Expenses"),
            priority: 50,
            enabled: true
        )

        XCTAssertNotNil(highPriorityRule)
        XCTAssertNotNil(lowPriorityRule)
        XCTAssertGreaterThan(highPriorityRule.priority, lowPriorityRule.priority)
    }

    // MARK: - Rule Evaluation Tests

    func testEvaluateRuleWithMatchingCondition() {
        let rule = businessRulesEngine.createRule(
            name: "PayPal to Uber Mapping",
            condition: BusinessRuleCondition.emailDomainEquals("paypal.com"),
            action: BusinessRuleAction.setMerchant("Uber"),
            priority: 100,
            enabled: true
        )

        let email = GmailEmail(
            id: "test-001",
            subject: "Uber ride payment",
            sender: "payment@paypal.com",
            date: Date(),
            snippet: "Uber payment"
        )

        let transaction = ExtractedTransaction(
            id: "test-001",
            merchant: "PayPal",
            amount: 45.50,
            date: Date(),
            category: "Transport",
            items: [],
            confidence: 0.7,
            rawText: "Uber ride payment",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let result = BusinessRuleEvaluator.shared.evaluateRule(rule, against: transaction, from: email)

        XCTAssertTrue(result.matched)
        XCTAssertEqual(result.action?.type, .setMerchant)
        XCTAssertEqual(result.action?.value, "Uber")
        XCTAssertNotNil(result.executionContext)
    }

    func testEvaluateRuleWithNonMatchingCondition() {
        let rule = businessRulesEngine.createRule(
            name: "Afterpay to Officeworks",
            condition: BusinessRuleCondition.emailDomainEquals("afterpay.com"),
            action: BusinessRuleAction.setMerchant("Officeworks"),
            priority: 100,
            enabled: true
        )

        let email = GmailEmail(
            id: "test-002",
            subject: "Payment from different source",
            sender: "payment@stripe.com",
            date: Date(),
            snippet: "Payment confirmation"
        )

        let transaction = ExtractedTransaction(
            id: "test-002",
            merchant: "Stripe",
            amount: 25.00,
            date: Date(),
            category: "Other",
            items: [],
            confidence: 0.8,
            rawText: "Payment processed",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let result = BusinessRuleEvaluator.shared.evaluateRule(rule, against: transaction, from: email)

        XCTAssertFalse(result.matched)
        XCTAssertNil(result.action)
        XCTAssertNil(result.executionContext)
    }

    // MARK: - Priority-Based Rule Execution Tests

    func testExecuteRulesInPriorityOrder() {
        let lowPriorityRule = businessRulesEngine.createRule(
            name: "Low Priority Rule",
            condition: BusinessRuleCondition.emailDomainEquals("paypal.com"),
            action: BusinessRuleAction.setMerchant("Generic Payment"),
            priority: 50,
            enabled: true
        )

        let highPriorityRule = businessRulesEngine.createRule(
            name: "High Priority Rule",
            condition: BusinessRuleCondition.emailDomainEquals("paypal.com"),
            action: BusinessRuleAction.setMerchant("Uber"),
            priority: 150,
            enabled: true
        )

        let email = GmailEmail(
            id: "test-003",
            subject: "Uber payment",
            sender: "payment@paypal.com",
            date: Date(),
            snippet: "Uber ride"
        )

        let transaction = ExtractedTransaction(
            id: "test-003",
            merchant: "PayPal",
            amount: 30.00,
            date: Date(),
            category: "Transport",
            items: [],
            confidence: 0.7,
            rawText: "Uber ride",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let results = BusinessRuleEvaluator.shared.evaluateAndApplyRules(to: transaction, from: email)

        XCTAssertGreaterThan(results.count, 0)

        // High priority rule should be applied first
        let highPriorityResult = results.first { $0.rule.priority == 150 }
        let lowPriorityResult = results.first { $0.rule.priority == 50 }

        XCTAssertNotNil(highPriorityResult)
        XCTAssertNotNil(lowPriorityResult)
        XCTAssertEqual(highPriorityResult?.action?.value, "Uber")
        XCTAssertEqual(lowPriorityResult?.action?.value, "Generic Payment")
    }

    // MARK: - Semantic Mapping Rules Tests

    func testSemanticMappingRuleCreation() {
        let semanticRule = businessRulesEngine.createSemanticMappingRule(
            emailDomain: "afterpay.com",
            targetMerchant: "Officeworks",
            confidenceBoost: 0.3,
            priority: 100
        )

        XCTAssertNotNil(semanticRule)
        XCTAssertEqual(semanticRule.name, "Afterpay to Officeworks Mapping")
        XCTAssertEqual(semanticRule.condition.type, .emailDomainEquals)
        XCTAssertEqual(semanticRule.action.type, .setMerchant)
        XCTAssertEqual(semanticRule.action.value, "Officeworks")
        XCTAssertEqual(semanticRule.confidenceBoost, 0.3)
    }

    func testSemanticMappingWithContentMatching() {
        let semanticRule = businessRulesEngine.createSemanticMappingRule(
            emailDomain: "paypal.com",
            targetMerchant: "Uber",
            confidenceBoost: 0.25,
            priority: 100,
            requireContentMatch: true
        )

        let email = GmailEmail(
            id: "test-004",
            subject: "Uber ride payment",
            sender: "payment@paypal.com",
            date: Date(),
            snippet: "Uber payment confirmation"
        )

        let transaction = ExtractedTransaction(
            id: "test-004",
            merchant: "PayPal",
            amount: 22.50,
            date: Date(),
            category: "Transport",
            items: [],
            confidence: 0.6,
            rawText: "Uber ride from downtown to airport",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let result = businessRulesEngine.evaluateRule(semanticRule, against: transaction, from: email)

        XCTAssertTrue(result.matched)
        XCTAssertEqual(result.action?.value, "Uber")
    }

    // MARK: - Categorization Logic Tests

    func testCategorizationRuleCreation() {
        let categorizationRule = businessRulesEngine.createCategorizationRule(
            name: "Transport Expenses",
            condition: BusinessRuleCondition.merchantContains(["Uber", "Lyft", "Taxi"]),
            action: BusinessRuleAction.setCategory("Transport"),
            priority: 80
        )

        XCTAssertNotNil(categorizationRule)
        XCTAssertEqual(categorizationRule.condition.type, .merchantContains)
        XCTAssertEqual(categorizationRule.action.type, .setCategory)
        XCTAssertEqual(categorizationRule.action.value, "Transport")
    }

    func testCategorizationRuleEvaluation() {
        let categorizationRule = businessRulesEngine.createCategorizationRule(
            name: "Office Supplies",
            condition: BusinessRuleCondition.merchantContains(["Officeworks", "Staples", "Bunnings"]),
            action: BusinessRuleAction.setCategory("Office Supplies"),
            priority: 80
        )

        let email = GmailEmail(
            id: "test-005",
            subject: "Officeworks purchase",
            sender: "receipts@officeworks.com.au",
            date: Date(),
            snippet: "Office supplies receipt"
        )

        let transaction = ExtractedTransaction(
            id: "test-005",
            merchant: "Officeworks",
            amount: 156.99,
            date: Date(),
            category: "Uncategorized",
            items: [],
            confidence: 0.9,
            rawText: "Office supplies and stationery",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let result = businessRulesEngine.evaluateRule(categorizationRule, against: transaction, from: email)

        XCTAssertTrue(result.matched)
        XCTAssertEqual(result.action?.value, "Office Supplies")
    }

    // MARK: - UserAutomationMemory Integration Tests

    func testCreateRuleFromAutomationMemory() {
        let automationMemory = UserAutomationMemory(context: testContext)
        automationMemory.id = UUID()
        automationMemory.merchantPatterns = "Uber,Ulta,Taxi"
        automationMemory.userCategory = "Transport"
        automationMemory.confidence = 0.85
        automationMemory.usageCount = 5
        automationMemory.lastUsed = Date()
        automationMemory.createdAt = Date()
        automationMemory.updatedAt = Date()

        let rule = businessRulesEngine.createRuleFromAutomationMemory(automationMemory)

        XCTAssertNotNil(rule)
        XCTAssertEqual(rule.name, "Auto: Transport Pattern")
        XCTAssertEqual(rule.condition.type, .merchantPatternMatch)
        XCTAssertEqual(rule.action.type, .setCategory)
        XCTAssertEqual(rule.action.value, "Transport")
        XCTAssertEqual(rule.confidenceThreshold, 0.8)
    }

    func testIntegrateWithSemanticValidationService() {
        let businessRule = businessRulesEngine.createRule(
            name: "Afterpay to Officeworks",
            condition: BusinessRuleCondition.emailDomainEquals("afterpay.com"),
            action: BusinessRuleAction.setMerchant("Officeworks"),
            priority: 100,
            enabled: true
        )

        let email = GmailEmail(
            id: "test-006",
            subject: "Your Officeworks purchase",
            sender: "notifications@afterpay.com",
            date: Date(),
            snippet: "Officeworks receipt"
        )

        let transaction = ExtractedTransaction(
            id: "test-006",
            merchant: "Afterpay",
            amount: 89.99,
            date: Date(),
            category: "Retail",
            items: [],
            confidence: 0.7,
            rawText: "Afterpay payment for Officeworks",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let semanticResult = BusinessRuleEvaluator.shared.validateAndApplySemanticMapping(
            to: transaction,
            from: email
        )

        XCTAssertEqual(semanticResult.correctedMerchant, "Officeworks")
        XCTAssertGreaterThanOrEqual(semanticResult.confidence, 0.85)
        XCTAssertTrue(semanticResult.businessRulesApplied.contains(.afterpayMerchantCorrection))
    }

    // MARK: - Rule Persistence Tests

    func testSaveAndLoadRules() {
        let rule = businessRulesEngine.createRule(
            name: "Test Persistence Rule",
            condition: BusinessRuleCondition.emailDomainEquals("test.com"),
            action: BusinessRuleAction.setMerchant("Test Merchant"),
            priority: 100,
            enabled: true
        )

        // Save rule
        XCTAssertNoThrow(try businessRulesEngine.saveRule(rule, in: testContext))

        // Load rules
        let loadedRules = businessRulesEngine.loadRules(from: testContext)
        XCTAssertGreaterThan(loadedRules.count, 0)

        let savedRule = loadedRules.first { $0.name == "Test Persistence Rule" }
        XCTAssertNotNil(savedRule)
        XCTAssertEqual(savedRule?.name, rule.name)
        XCTAssertEqual(savedRule?.priority, rule.priority)
        XCTAssertEqual(savedRule?.enabled, rule.enabled)
    }

    // MARK: - Rule Conflict Resolution Tests

    func testResolveConflictingRules() {
        let rule1 = businessRulesEngine.createRule(
            name: "Rule 1 - Set to Uber",
            condition: BusinessRuleCondition.emailDomainEquals("paypal.com"),
            action: BusinessRuleAction.setMerchant("Uber"),
            priority: 100,
            enabled: true
        )

        let rule2 = businessRulesEngine.createRule(
            name: "Rule 2 - Set to Lyft",
            condition: BusinessRuleCondition.emailDomainEquals("paypal.com"),
            action: BusinessRuleAction.setMerchant("Lyft"),
            priority: 150,
            enabled: true
        )

        let email = GmailEmail(
            id: "test-007",
            subject: "Ride payment",
            sender: "payment@paypal.com",
            date: Date(),
            snippet: "Ride payment"
        )

        let transaction = ExtractedTransaction(
            id: "test-007",
            merchant: "PayPal",
            amount: 35.00,
            date: Date(),
            category: "Transport",
            items: [],
            confidence: 0.7,
            rawText: "Ride payment",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        let results = BusinessRuleEvaluator.shared.evaluateAndApplyRules(to: transaction, from: email)
        let appliedActions = results.compactMap { $0.action }

        // Should apply both actions, but higher priority rule should be last
        XCTAssertEqual(appliedActions.count, 2)
        XCTAssertEqual(appliedActions.last?.value, "Lyft") // Higher priority rule
    }

    // MARK: - Performance Tests

    func testRuleEvaluationPerformance() {
        // Create multiple rules
        for i in 0..<50 {
            _ = businessRulesEngine.createRule(
                name: "Performance Test Rule \(i)",
                condition: BusinessRuleCondition.emailDomainEquals("test\(i).com"),
                action: BusinessRuleAction.setMerchant("Test Merchant \(i)"),
                priority: Int.random(in: 1...100),
                enabled: true
            )
        }

        let email = GmailEmail(
            id: "test-perf",
            subject: "Test email",
            sender: "test@test.com",
            date: Date(),
            snippet: "Test performance"
        )

        let transaction = ExtractedTransaction(
            id: "test-perf",
            merchant: "Test Merchant",
            amount: 100.0,
            date: Date(),
            category: "Test",
            items: [],
            confidence: 0.8,
            rawText: "Test performance evaluation",
            emailSubject: email.subject,
            emailSender: email.sender
        )

        measure {
            _ = BusinessRuleEvaluator.shared.evaluateAndApplyRules(to: transaction, from: email)
        }
    }
}