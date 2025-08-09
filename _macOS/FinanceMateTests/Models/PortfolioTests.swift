//
// PortfolioTests.swift
// FinanceMateTests
//
// Created by AI Agent on 2025-08-09.
// Phase 5 Investment Portfolio Tests: Portfolio Entity Validation
//

/*
 * Purpose: Comprehensive tests for Phase 5 Portfolio entity with Australian tax compliance and multi-asset class support
 * Issues & Complexity Summary: Portfolio entity validation, asset allocation calculations, performance analytics
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~250 (portfolio testing + asset allocation + performance + tax calculations)
   - Core Algorithm Complexity: High (portfolio analytics, asset allocation, rebalancing, performance metrics)
   - Dependencies: Portfolio entity, Investment entity, FinancialEntity, Core Data testing
   - State Management Complexity: High (real-time portfolio valuation, performance tracking, asset allocation)
   - Novelty/Uncertainty Factor: Medium (Australian portfolio optimization, SMSF compliance)
 * AI Pre-Task Self-Assessment: 89%
 * Problem Estimate: 86%
 * Initial Code Complexity Estimate: 87%
 * Final Code Complexity: 90%
 * Overall Result Score: 89%
 * Key Variances/Learnings: Portfolio entity tests require comprehensive investment relationship testing
 * Last Updated: 2025-08-09
 */

import XCTest
import CoreData
@testable import FinanceMate

final class PortfolioTests: XCTestCase {
    
    var testContext: NSManagedObjectContext!
    var testPortfolio: Portfolio!
    
    override func setUp() {
        super.setUp()
        testContext = PersistenceController.testContext
        testPortfolio = createTestPortfolio()
    }
    
    override func tearDown() {
        testContext = nil
        testPortfolio = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createTestPortfolio() -> Portfolio {
        return Portfolio.create(
            in: testContext,
            name: "Test Growth Portfolio",
            type: .personal,
            strategy: .growth
        )
    }
    
    private func createTestInvestment(in portfolio: Portfolio) -> Investment {
        return Investment.create(
            in: testContext,
            symbol: "CBA.AX",
            name: "Commonwealth Bank of Australia",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 85.50,
            currentPrice: 95.25,
            portfolio: portfolio
        )
    }
    
    // MARK: - Factory Method Tests
    
    func testCreatePortfolio() {
        XCTAssertNotNil(testPortfolio)
        XCTAssertNotNil(testPortfolio.id)
        XCTAssertEqual(testPortfolio.name, "Test Growth Portfolio")
        XCTAssertEqual(testPortfolio.portfolioTypeEnum, .personal)
        XCTAssertEqual(testPortfolio.investmentStrategyEnum, .growth)
        XCTAssertEqual(testPortfolio.currency, "AUD")
        XCTAssertTrue(testPortfolio.isActive)
        XCTAssertEqual(testPortfolio.activeInvestmentsCount, 0)
    }
    
    func testCreatePortfolioWithEntity() {
        let financialEntity = FinancialEntity.create(
            in: testContext,
            name: "John Doe",
            type: .individual
        )
        
        let portfolio = Portfolio.create(
            in: testContext,
            name: "John's Investment Portfolio",
            type: .personal,
            entity: financialEntity
        )
        
        XCTAssertNotNil(portfolio.entity)
        XCTAssertEqual(portfolio.entity?.name, "John Doe")
    }
    
    // MARK: - Portfolio Type Tests
    
    func testPortfolioTypeEnum() {
        testPortfolio.portfolioTypeEnum = .smsf
        XCTAssertEqual(testPortfolio.portfolioTypeEnum, .smsf)
        XCTAssertEqual(testPortfolio.portfolioType, Portfolio.PortfolioType.smsf.rawValue)
        
        testPortfolio.portfolioTypeEnum = .crypto
        XCTAssertEqual(testPortfolio.portfolioTypeEnum, .crypto)
        XCTAssertEqual(testPortfolio.portfolioType, Portfolio.PortfolioType.crypto.rawValue)
    }
    
    func testPortfolioTypeDisplayNames() {
        XCTAssertEqual(Portfolio.PortfolioType.personal.displayName, "Personal Portfolio")
        XCTAssertEqual(Portfolio.PortfolioType.superannuation.displayName, "Superannuation")
        XCTAssertEqual(Portfolio.PortfolioType.smsf.displayName, "SMSF")
        XCTAssertEqual(Portfolio.PortfolioType.trust.displayName, "Trust")
        XCTAssertEqual(Portfolio.PortfolioType.company.displayName, "Company")
        XCTAssertEqual(Portfolio.PortfolioType.crypto.displayName, "Cryptocurrency")
    }
    
    func testPortfolioTypeIcons() {
        XCTAssertEqual(Portfolio.PortfolioType.personal.iconName, "person.circle")
        XCTAssertEqual(Portfolio.PortfolioType.smsf.iconName, "building.columns")
        XCTAssertEqual(Portfolio.PortfolioType.crypto.iconName, "bitcoinsign.circle")
        XCTAssertEqual(Portfolio.PortfolioType.family.iconName, "house.fill")
    }
    
    // MARK: - Investment Strategy Tests
    
    func testInvestmentStrategyEnum() {
        testPortfolio.investmentStrategyEnum = .conservative
        XCTAssertEqual(testPortfolio.investmentStrategyEnum, .conservative)
        XCTAssertEqual(testPortfolio.investmentStrategy, Portfolio.InvestmentStrategy.conservative.rawValue)
        
        testPortfolio.investmentStrategyEnum = .aggressive
        XCTAssertEqual(testPortfolio.investmentStrategyEnum, .aggressive)
        XCTAssertEqual(testPortfolio.investmentStrategy, Portfolio.InvestmentStrategy.aggressive.rawValue)
    }
    
    func testInvestmentStrategyDisplayNames() {
        XCTAssertEqual(Portfolio.InvestmentStrategy.conservative.displayName, "Conservative")
        XCTAssertEqual(Portfolio.InvestmentStrategy.balanced.displayName, "Balanced")
        XCTAssertEqual(Portfolio.InvestmentStrategy.growth.displayName, "Growth")
        XCTAssertEqual(Portfolio.InvestmentStrategy.aggressive.displayName, "Aggressive")
        XCTAssertEqual(Portfolio.InvestmentStrategy.income.displayName, "Income Focused")
    }
    
    func testInvestmentStrategyTargetAllocation() {
        let conservativeAllocation = Portfolio.InvestmentStrategy.conservative.targetAllocation
        XCTAssertEqual(conservativeAllocation[.bonds], 60.0)
        XCTAssertEqual(conservativeAllocation[.shares], 30.0)
        XCTAssertEqual(conservativeAllocation[.property], 10.0)
        
        let aggressiveAllocation = Portfolio.InvestmentStrategy.aggressive.targetAllocation
        XCTAssertEqual(aggressiveAllocation[.shares], 80.0)
        XCTAssertEqual(aggressiveAllocation[.cryptocurrency], 10.0)
        XCTAssertEqual(aggressiveAllocation[.property], 10.0)
    }
    
    // MARK: - Portfolio Value Calculations Tests
    
    func testCurrentValueWithNoInvestments() {
        XCTAssertEqual(testPortfolio.currentValue, 0.0, accuracy: 0.01)
        XCTAssertEqual(testPortfolio.totalCostBasis, 0.0, accuracy: 0.01)
        XCTAssertEqual(testPortfolio.unrealizedGainLoss, 0.0, accuracy: 0.01)
    }
    
    func testCurrentValueWithInvestments() {
        let investment1 = createTestInvestment(in: testPortfolio)
        let investment2 = Investment.create(
            in: testContext,
            symbol: "ANZ.AX",
            name: "ANZ Banking Group",
            type: .shares,
            quantity: Decimal(50),
            averageCostBasis: 25.75,
            currentPrice: 27.50,
            portfolio: testPortfolio
        )
        
        let expectedValue = (95.25 * 100) + (27.50 * 50) // 9525 + 1375 = 10900
        XCTAssertEqual(testPortfolio.currentValue, expectedValue, accuracy: 0.01)
    }
    
    func testTotalCostBasis() {
        let investment1 = createTestInvestment(in: testPortfolio)
        let investment2 = Investment.create(
            in: testContext,
            symbol: "WBC.AX",
            name: "Westpac Banking Corporation",
            type: .shares,
            quantity: Decimal(75),
            averageCostBasis: 22.40,
            currentPrice: 24.80,
            portfolio: testPortfolio
        )
        
        let expectedCostBasis = (85.50 * 100) + (22.40 * 75) // 8550 + 1680 = 10230
        XCTAssertEqual(testPortfolio.totalCostBasis, expectedCostBasis, accuracy: 0.01)
    }
    
    func testUnrealizedGainLoss() {
        let investment = createTestInvestment(in: testPortfolio)
        
        let expectedGainLoss = testPortfolio.currentValue - testPortfolio.totalCostBasis // 9525 - 8550 = 975
        XCTAssertEqual(testPortfolio.unrealizedGainLoss, expectedGainLoss, accuracy: 0.01)
    }
    
    func testUnrealizedGainLossPercentage() {
        let investment = createTestInvestment(in: testPortfolio)
        
        let expectedPercentage = (testPortfolio.unrealizedGainLoss / testPortfolio.totalCostBasis) * 100
        XCTAssertEqual(testPortfolio.unrealizedGainLossPercentage, expectedPercentage, accuracy: 0.01)
    }
    
    func testTotalDividends() {
        let investment = createTestInvestment(in: testPortfolio)
        investment.totalDividendsReceived = 250.0
        
        XCTAssertEqual(testPortfolio.totalDividends, 250.0, accuracy: 0.01)
    }
    
    func testDailyChange() {
        let investment = createTestInvestment(in: testPortfolio)
        investment.previousDayPrice = 93.50
        investment.currentPrice = 95.25
        
        let expectedChange = (95.25 - 93.50) * 100 * 1.0 // 175
        XCTAssertEqual(testPortfolio.dailyChange, expectedChange, accuracy: 0.01)
    }
    
    func testDailyChangePercentage() {
        let investment = createTestInvestment(in: testPortfolio)
        investment.previousDayPrice = 93.50
        investment.currentPrice = 95.25
        
        let previousValue = testPortfolio.currentValue - testPortfolio.dailyChange
        let expectedPercentage = (testPortfolio.dailyChange / previousValue) * 100
        XCTAssertEqual(testPortfolio.dailyChangePercentage, expectedPercentage, accuracy: 0.01)
    }
    
    // MARK: - Asset Allocation Tests
    
    func testCalculateAssetAllocationEmpty() {
        let allocation = testPortfolio.calculateAssetAllocation()
        XCTAssertTrue(allocation.isEmpty)
    }
    
    func testCalculateAssetAllocation() {
        // Add investments of different types
        let sharesInvestment = Investment.create(
            in: testContext,
            symbol: "CBA.AX",
            name: "Commonwealth Bank",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 95.0,
            currentPrice: 100.0,
            portfolio: testPortfolio
        )
        
        let propertyInvestment = Investment.create(
            in: testContext,
            symbol: "PROP-1",
            name: "Property Investment",
            type: .property,
            quantity: Decimal(1),
            averageCostBasis: 500000.0,
            currentPrice: 520000.0,
            portfolio: testPortfolio
        )
        
        let bondsInvestment = Investment.create(
            in: testContext,
            symbol: "BOND-1",
            name: "Government Bond",
            type: .bonds,
            quantity: Decimal(1000),
            averageCostBasis: 50.0,
            currentPrice: 52.0,
            portfolio: testPortfolio
        )
        
        let allocation = testPortfolio.calculateAssetAllocation()
        
        let totalValue = testPortfolio.currentValue
        let sharesPercentage = (100.0 * 100.0 / totalValue) * 100.0 // Convert to percentage
        let propertyPercentage = (520000.0 / totalValue) * 100.0
        let bondsPercentage = (1000.0 * 52.0 / totalValue) * 100.0
        
        XCTAssertEqual(allocation[.shares], sharesPercentage, accuracy: 0.1)
        XCTAssertEqual(allocation[.property], propertyPercentage, accuracy: 0.1)
        XCTAssertEqual(allocation[.bonds], bondsPercentage, accuracy: 0.1)
    }
    
    func testCalculateAllocationDeviation() {
        // Set portfolio to growth strategy
        testPortfolio.investmentStrategyEnum = .growth
        
        // Add investments that don't match target allocation
        let _ = Investment.create(
            in: testContext,
            symbol: "CBA.AX",
            name: "Commonwealth Bank",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 100.0,
            currentPrice: 100.0,
            portfolio: testPortfolio
        )
        
        let deviation = testPortfolio.calculateAllocationDeviation()
        
        // Growth strategy targets: 70% shares, 20% property, 10% bonds
        // Current allocation: 100% shares
        // Deviation: shares +30%, property -20%, bonds -10%
        XCTAssertEqual(deviation[.shares], 30.0, accuracy: 1.0)
        XCTAssertEqual(deviation[.property], -20.0, accuracy: 1.0)
        XCTAssertEqual(deviation[.bonds], -10.0, accuracy: 1.0)
    }
    
    func testGetRebalancingRecommendations() {
        // Set portfolio to balanced strategy
        testPortfolio.investmentStrategyEnum = .balanced
        
        // Add only shares (unbalanced portfolio)
        let _ = Investment.create(
            in: testContext,
            symbol: "CBA.AX",
            name: "Commonwealth Bank",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 100.0,
            currentPrice: 100.0,
            portfolio: testPortfolio
        )
        
        let recommendations = testPortfolio.getRebalancingRecommendations()
        
        // Should recommend reducing shares and increasing other assets
        XCTAssertTrue(recommendations.count > 0)
        let sharesRecommendation = recommendations.first { $0.0 == .shares }
        XCTAssertNotNil(sharesRecommendation)
        XCTAssertEqual(sharesRecommendation?.1, "Reduce")
    }
    
    // MARK: - Performance Analytics Tests
    
    func testCalculatePortfolioBeta() {
        // Add investments with different risk profiles
        let _ = Investment.create(
            in: testContext,
            symbol: "CBA.AX",
            name: "Commonwealth Bank",
            type: .shares,
            quantity: Decimal(50),
            averageCostBasis: 100.0,
            currentPrice: 100.0,
            portfolio: testPortfolio
        )
        
        let _ = Investment.create(
            in: testContext,
            symbol: "BOND-1",
            name: "Government Bond",
            type: .bonds,
            quantity: Decimal(500),
            averageCostBasis: 10.0,
            currentPrice: 10.0,
            portfolio: testPortfolio
        )
        
        let beta = testPortfolio.calculatePortfolioBeta()
        
        // Should be between 0 and 1 due to mix of shares (beta=1.0) and bonds (beta=0.2)
        XCTAssertGreaterThan(beta, 0.0)
        XCTAssertLessThan(beta, 1.0)
    }
    
    func testCalculateAnnualizedReturn() {
        // Set creation date to 2 years ago
        let calendar = Calendar.current
        testPortfolio.createdAt = calendar.date(byAdding: .year, value: -2, to: Date())
        
        let investment = createTestInvestment(in: testPortfolio)
        investment.totalDividendsReceived = 500.0
        
        let annualizedReturn = testPortfolio.calculateAnnualizedReturn()
        XCTAssertGreaterThan(annualizedReturn, 0)
        XCTAssertLessThan(annualizedReturn, 50) // Reasonable return range
    }
    
    func testCalculateSharpeRatio() {
        let investment = createTestInvestment(in: testPortfolio)
        investment.totalDividendsReceived = 300.0
        
        let sharpeRatio = testPortfolio.calculateSharpeRatio()
        XCTAssertGreaterThanOrEqual(sharpeRatio, 0.0)
    }
    
    func testCalculatePortfolioVolatility() {
        let investment1 = Investment.create(
            in: testContext,
            symbol: "CBA.AX",
            name: "Commonwealth Bank",
            type: .shares,
            quantity: Decimal(50),
            averageCostBasis: 100.0,
            currentPrice: 100.0,
            portfolio: testPortfolio
        )
        
        let investment2 = Investment.create(
            in: testContext,
            symbol: "BTC",
            name: "Bitcoin",
            type: .cryptocurrency,
            quantity: Decimal(1),
            averageCostBasis: 50000.0,
            currentPrice: 50000.0,
            portfolio: testPortfolio
        )
        
        let volatility = testPortfolio.calculatePortfolioVolatility()
        
        // Should be weighted average of shares (20%) and crypto (45%) volatility
        XCTAssertGreaterThan(volatility, 20.0) // Higher than shares alone
        XCTAssertLessThan(volatility, 45.0)   // Lower than crypto alone
    }
    
    // MARK: - Australian Tax Calculations Tests
    
    func testCalculateCGTImplications() {
        // Set creation date to over 12 months ago for CGT discount eligibility
        let calendar = Calendar.current
        testPortfolio.createdAt = calendar.date(byAdding: .month, value: -15, to: Date())
        
        // Add investments with gains
        let investment1 = Investment.create(
            in: testContext,
            symbol: "CBA.AX",
            name: "Commonwealth Bank",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 80.0,
            currentPrice: 100.0,
            portfolio: testPortfolio
        )
        investment1.createdAt = testPortfolio.createdAt
        
        let investment2 = Investment.create(
            in: testContext,
            symbol: "ANZ.AX",
            name: "ANZ Banking Group",
            type: .shares,
            quantity: Decimal(50),
            averageCostBasis: 20.0,
            currentPrice: 30.0,
            portfolio: testPortfolio
        )
        investment2.createdAt = calendar.date(byAdding: .month, value: -6, to: Date()) // Short-term
        
        let cgtSummary = testPortfolio.calculateCGTImplications()
        
        // Investment 1: Long-term gain (100-80)*100 = 2000, with 50% discount = 1000
        // Investment 2: Short-term gain (30-20)*50 = 500, no discount
        XCTAssertEqual(cgtSummary.longTermGains, 1000.0, accuracy: 0.01) // 50% of 2000
        XCTAssertEqual(cgtSummary.shortTermGains, 500.0, accuracy: 0.01)
        XCTAssertEqual(cgtSummary.totalCGT, 1500.0, accuracy: 0.01)
    }
    
    func testIsSMSFCompliant() {
        testPortfolio.portfolioTypeEnum = .smsf
        
        // Add compliant investments (each under 5% concentration)
        let investment1 = Investment.create(
            in: testContext,
            symbol: "CBA.AX",
            name: "Commonwealth Bank",
            type: .shares,
            quantity: Decimal(10),
            averageCostBasis: 100.0,
            currentPrice: 100.0,
            portfolio: testPortfolio
        )
        
        let investment2 = Investment.create(
            in: testContext,
            symbol: "ANZ.AX",
            name: "ANZ Banking Group",
            type: .shares,
            quantity: Decimal(20),
            averageCostBasis: 50.0,
            currentPrice: 50.0,
            portfolio: testPortfolio
        )
        
        XCTAssertTrue(testPortfolio.isSMSFCompliant)
        
        // Add non-compliant investment (over 5% concentration)
        let largeInvestment = Investment.create(
            in: testContext,
            symbol: "LARGE.AX",
            name: "Large Investment",
            type: .shares,
            quantity: Decimal(1),
            averageCostBasis: 100000.0,
            currentPrice: 100000.0,
            portfolio: testPortfolio
        )
        
        XCTAssertFalse(testPortfolio.isSMSFCompliant)
    }
    
    // MARK: - Investment Management Tests
    
    func testAddInvestment() {
        let investment = createTestInvestment(in: testPortfolio)
        
        testPortfolio.addInvestment(investment)
        
        XCTAssertEqual(investment.portfolio, testPortfolio)
        XCTAssertEqual(testPortfolio.activeInvestmentsCount, 1)
    }
    
    func testRemoveInvestment() {
        let investment = createTestInvestment(in: testPortfolio)
        testPortfolio.addInvestment(investment)
        
        testPortfolio.removeInvestment(investment)
        
        XCTAssertNil(investment.portfolio)
        XCTAssertFalse(investment.isActive)
        XCTAssertEqual(testPortfolio.activeInvestmentsCount, 0)
    }
    
    func testGetTopPerformers() {
        // Add investments with different performance
        let investment1 = Investment.create(
            in: testContext,
            symbol: "HIGH.AX",
            name: "High Performer",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 50.0,
            currentPrice: 100.0, // 100% gain
            portfolio: testPortfolio
        )
        
        let investment2 = Investment.create(
            in: testContext,
            symbol: "MED.AX",
            name: "Medium Performer",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 80.0,
            currentPrice: 100.0, // 25% gain
            portfolio: testPortfolio
        )
        
        let investment3 = Investment.create(
            in: testContext,
            symbol: "LOW.AX",
            name: "Low Performer",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 100.0,
            currentPrice: 90.0, // -10% loss
            portfolio: testPortfolio
        )
        
        let topPerformers = testPortfolio.getTopPerformers(limit: 2)
        
        XCTAssertEqual(topPerformers.count, 2)
        XCTAssertEqual(topPerformers[0].symbol, "HIGH.AX") // Highest return
        XCTAssertEqual(topPerformers[1].symbol, "MED.AX")  // Second highest return
    }
    
    func testGetWorstPerformers() {
        // Add investments with different performance
        let investment1 = Investment.create(
            in: testContext,
            symbol: "HIGH.AX",
            name: "High Performer",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 50.0,
            currentPrice: 100.0, // 100% gain
            portfolio: testPortfolio
        )
        
        let investment2 = Investment.create(
            in: testContext,
            symbol: "LOW.AX",
            name: "Low Performer",
            type: .shares,
            quantity: Decimal(100),
            averageCostBasis: 100.0,
            currentPrice: 70.0, // -30% loss
            portfolio: testPortfolio
        )
        
        let worstPerformers = testPortfolio.getWorstPerformers(limit: 1)
        
        XCTAssertEqual(worstPerformers.count, 1)
        XCTAssertEqual(worstPerformers[0].symbol, "LOW.AX") // Worst return
    }
    
    // MARK: - Validation Tests
    
    func testValidPortfolioCreation() {
        XCTAssertNoThrow(try testPortfolio.validateForInsert())
        XCTAssertNoThrow(try testPortfolio.validateForUpdate())
    }
    
    func testInvalidNameValidation() {
        testPortfolio.name = ""
        XCTAssertThrowsError(try testPortfolio.validateForInsert()) { error in
            XCTAssertEqual(error as? PortfolioValidationError, .invalidName)
        }
    }
    
    func testInvalidCurrencyValidation() {
        testPortfolio.currency = ""
        XCTAssertThrowsError(try testPortfolio.validateForInsert()) { error in
            XCTAssertEqual(error as? PortfolioValidationError, .invalidCurrency)
        }
    }
    
    // MARK: - Relationship Tests
    
    func testPortfolioEntityRelationship() {
        let financialEntity = FinancialEntity.create(in: testContext, name: "Test Entity", type: .individual)
        testPortfolio.entity = financialEntity
        
        XCTAssertEqual(testPortfolio.entity, financialEntity)
        
        // Test bidirectional relationship
        let entityPortfolios = financialEntity.portfolios as? Set<Portfolio> ?? []
        XCTAssertTrue(entityPortfolios.contains(testPortfolio))
    }
    
    func testPortfolioInvestmentsRelationship() {
        let investment1 = createTestInvestment(in: testPortfolio)
        let investment2 = Investment.create(
            in: testContext,
            symbol: "ANZ.AX",
            name: "ANZ Banking Group",
            type: .shares,
            quantity: Decimal(50),
            averageCostBasis: 25.0,
            currentPrice: 27.0,
            portfolio: testPortfolio
        )
        
        let portfolioInvestments = testPortfolio.investments as? Set<Investment> ?? []
        XCTAssertEqual(portfolioInvestments.count, 2)
        XCTAssertTrue(portfolioInvestments.contains(investment1))
        XCTAssertTrue(portfolioInvestments.contains(investment2))
    }
    
    // MARK: - Performance Tests
    
    func testPerformancePortfolioCalculations() {
        // Add 50 investments for performance testing
        for i in 1...50 {
            let _ = Investment.create(
                in: testContext,
                symbol: "TEST\(i).AX",
                name: "Test Investment \(i)",
                type: .shares,
                quantity: Decimal(Double.random(in: 10...100)),
                averageCostBasis: Double.random(in: 20...100),
                currentPrice: Double.random(in: 25...120),
                portfolio: testPortfolio
            )
        }
        
        measure {
            let _ = testPortfolio.currentValue
            let _ = testPortfolio.calculateAssetAllocation()
            let _ = testPortfolio.calculatePortfolioBeta()
            let _ = testPortfolio.calculateSharpeRatio()
        }
    }
}