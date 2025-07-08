//
// PortfolioManagerTests.swift
// FinanceMateTests
//
// Created by AI Agent on 2025-07-08.
// UR-105: Investment Portfolio Tracking - TDD Implementation
//

/*
 * Purpose: Test suite for PortfolioManager investment tracking capabilities
 * Issues & Complexity Summary: TDD-driven portfolio management validation with Australian tax compliance
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~700 (comprehensive investment tracking testing)
   - Core Algorithm Complexity: Very High (financial calculations + Australian tax)
   - Dependencies: Market data APIs, Core Data, tax calculation engine
   - State Management Complexity: High (real-time portfolio updates)
   - Novelty/Uncertainty Factor: High (complex financial calculations and compliance)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 96%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD approach for complex financial portfolio management
 * Last Updated: 2025-07-08
 */

import XCTest
import CoreData
@testable import FinanceMate

final class PortfolioManagerTests: XCTestCase {
    
    // MARK: - Test Properties
    private var portfolioManager: PortfolioManager!
    private var testContext: NSManagedObjectContext!
    private var testEntity: FinancialEntity!
    
    // MARK: - Test Setup
    override func setUpWithError() throws {
        try super.setUpWithError()
        testContext = PersistenceController.preview.container.viewContext
        portfolioManager = PortfolioManager(context: testContext)
        
        // Create test financial entity
        testEntity = FinancialEntity(context: testContext)
        testEntity.id = UUID()
        testEntity.name = "Test Portfolio Entity"
        testEntity.type = "Personal"
        testEntity.isActive = true
        
        try testContext.save()
    }
    
    override func tearDownWithError() throws {
        portfolioManager = nil
        testContext = nil
        testEntity = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Portfolio Creation Tests
    
    func testPortfolioManagerInitialization() {
        // Given: Fresh PortfolioManager instance
        let manager = PortfolioManager(context: testContext)
        
        // Then: Should be properly initialized
        XCTAssertNotNil(manager, "PortfolioManager should initialize successfully")
    }
    
    func testCreatePortfolioWithValidData() async throws {
        // Given: Valid portfolio data
        let portfolioData = PortfolioData(
            name: "Test Investment Portfolio",
            entityId: testEntity.id!,
            description: "Testing portfolio creation",
            strategy: .balanced,
            riskProfile: .moderate
        )
        
        // When: Creating portfolio
        let portfolio = try await portfolioManager.createPortfolio(portfolioData)
        
        // Then: Should create portfolio successfully
        XCTAssertNotNil(portfolio, "Should create portfolio successfully")
        XCTAssertEqual(portfolio.name, "Test Investment Portfolio", "Should set correct portfolio name")
        XCTAssertEqual(portfolio.entityId, testEntity.id!, "Should associate with correct entity")
        XCTAssertEqual(portfolio.strategy, "balanced", "Should set correct investment strategy")
        XCTAssertEqual(portfolio.totalValue, 0.0, "New portfolio should have zero initial value")
    }
    
    func testCreatePortfolioWithInvalidEntityId() async throws {
        // Given: Invalid entity ID
        let portfolioData = PortfolioData(
            name: "Invalid Portfolio",
            entityId: UUID(), // Non-existent entity
            description: "Test invalid entity",
            strategy: .aggressive,
            riskProfile: .high
        )
        
        // When/Then: Should throw error for invalid entity
        do {
            _ = try await portfolioManager.createPortfolio(portfolioData)
            XCTFail("Should throw error for invalid entity ID")
        } catch PortfolioManager.PortfolioError.invalidEntity {
            // Expected error
        } catch {
            XCTFail("Should throw PortfolioError.invalidEntity")
        }
    }
    
    func testCreateMultiplePortfoliosForSameEntity() async throws {
        // Given: Multiple portfolio data for same entity
        let portfolio1Data = PortfolioData(
            name: "Conservative Portfolio",
            entityId: testEntity.id!,
            description: "Conservative investments",
            strategy: .conservative,
            riskProfile: .low
        )
        
        let portfolio2Data = PortfolioData(
            name: "Growth Portfolio",
            entityId: testEntity.id!,
            description: "Growth investments", 
            strategy: .growth,
            riskProfile: .high
        )
        
        // When: Creating multiple portfolios
        let portfolio1 = try await portfolioManager.createPortfolio(portfolio1Data)
        let portfolio2 = try await portfolioManager.createPortfolio(portfolio2Data)
        
        // Then: Should create both portfolios successfully
        XCTAssertNotEqual(portfolio1.id, portfolio2.id, "Should have different portfolio IDs")
        XCTAssertEqual(portfolio1.entityId, portfolio2.entityId, "Should belong to same entity")
        XCTAssertNotEqual(portfolio1.strategy, portfolio2.strategy, "Should have different strategies")
    }
    
    // MARK: - Asset Management Tests
    
    func testAddAssetToPortfolio() async throws {
        // Given: Portfolio and asset data
        let portfolio = try await createTestPortfolio()
        let assetData = AssetData(
            symbol: "CBA.AX",
            market: .asx,
            name: "Commonwealth Bank of Australia",
            assetType: .equity,
            currency: "AUD"
        )
        
        // When: Adding asset to portfolio
        let holding = try await portfolioManager.addAsset(assetData, to: portfolio.id!)
        
        // Then: Should add asset successfully
        XCTAssertNotNil(holding, "Should create holding successfully")
        XCTAssertEqual(holding.symbol, "CBA.AX", "Should set correct symbol")
        XCTAssertEqual(holding.market, "ASX", "Should set correct market")
        XCTAssertEqual(holding.quantity, 0.0, "New holding should have zero quantity")
        XCTAssertEqual(holding.averageCostBasis, 0.0, "New holding should have zero cost basis")
    }
    
    func testAddDuplicateAssetToPortfolio() async throws {
        // Given: Portfolio with existing asset
        let portfolio = try await createTestPortfolio()
        let assetData = AssetData(
            symbol: "AAPL",
            market: .nasdaq,
            name: "Apple Inc.",
            assetType: .equity,
            currency: "USD"
        )
        
        // When: Adding same asset twice
        let holding1 = try await portfolioManager.addAsset(assetData, to: portfolio.id!)
        
        do {
            _ = try await portfolioManager.addAsset(assetData, to: portfolio.id!)
            XCTFail("Should not allow duplicate assets in same portfolio")
        } catch PortfolioManager.PortfolioError.duplicateAsset {
            // Expected behavior
        } catch {
            XCTFail("Should throw PortfolioError.duplicateAsset")
        }
        
        // Then: Should maintain original holding
        XCTAssertNotNil(holding1, "Original holding should remain")
        XCTAssertEqual(holding1.symbol, "AAPL", "Should preserve original holding data")
    }
    
    func testAddCryptocurrencyAsset() async throws {
        // Given: Portfolio and cryptocurrency data
        let portfolio = try await createTestPortfolio()
        let cryptoData = AssetData(
            symbol: "BTC-USD",
            market: .crypto,
            name: "Bitcoin",
            assetType: .cryptocurrency,
            currency: "USD"
        )
        
        // When: Adding cryptocurrency
        let holding = try await portfolioManager.addAsset(cryptoData, to: portfolio.id!)
        
        // Then: Should handle crypto asset correctly
        XCTAssertEqual(holding.symbol, "BTC-USD", "Should set crypto symbol")
        XCTAssertEqual(holding.market, "CRYPTO", "Should set crypto market")
        XCTAssertEqual(holding.assetType, "cryptocurrency", "Should set crypto asset type")
        XCTAssertEqual(holding.currency, "USD", "Should set USD currency for crypto")
    }
    
    // MARK: - Transaction Processing Tests
    
    func testRecordBuyTransaction() async throws {
        // Given: Portfolio with asset
        let portfolio = try await createTestPortfolio()
        let holding = try await createTestHolding(in: portfolio, symbol: "CBA.AX")
        
        let transactionData = InvestmentTransactionData(
            holdingId: holding.id!,
            type: .buy,
            quantity: 100.0,
            price: 105.50,
            transactionFee: 19.95,
            transactionDate: Date()
        )
        
        // When: Recording buy transaction
        let transaction = try await portfolioManager.recordTransaction(transactionData)
        
        // Then: Should update holding correctly
        let updatedHolding = try await portfolioManager.getHolding(holding.id!)
        XCTAssertEqual(updatedHolding.quantity, 100.0, "Should update quantity")
        XCTAssertEqual(updatedHolding.averageCostBasis, 105.6995, accuracy: 0.0001, "Should calculate average cost basis including fees")
        XCTAssertEqual(updatedHolding.totalCostBasis, 10569.95, accuracy: 0.01, "Should calculate total cost basis")
        XCTAssertNotNil(transaction, "Should create transaction record")
    }
    
    func testRecordSellTransaction() async throws {
        // Given: Portfolio with existing holding
        let portfolio = try await createTestPortfolio()
        let holding = try await createTestHolding(in: portfolio, symbol: "CBA.AX")
        
        // First add shares
        let buyData = InvestmentTransactionData(
            holdingId: holding.id!,
            type: .buy,
            quantity: 200.0,
            price: 100.0,
            transactionFee: 19.95,
            transactionDate: Date().addingTimeInterval(-86400) // Yesterday
        )
        _ = try await portfolioManager.recordTransaction(buyData)
        
        // When: Recording sell transaction
        let sellData = InvestmentTransactionData(
            holdingId: holding.id!,
            type: .sell,
            quantity: 50.0,
            price: 110.0,
            transactionFee: 19.95,
            transactionDate: Date()
        )
        let sellTransaction = try await portfolioManager.recordTransaction(sellData)
        
        // Then: Should update holding and calculate gain/loss
        let updatedHolding = try await portfolioManager.getHolding(holding.id!)
        XCTAssertEqual(updatedHolding.quantity, 150.0, "Should reduce quantity")
        XCTAssertNotNil(sellTransaction, "Should create sell transaction")
        XCTAssertNotNil(sellTransaction.realizedGainLoss, "Should calculate realized gain/loss")
    }
    
    func testRecordSellTransactionInsufficientShares() async throws {
        // Given: Portfolio with insufficient shares
        let portfolio = try await createTestPortfolio()
        let holding = try await createTestHolding(in: portfolio, symbol: "CBA.AX")
        
        let sellData = InvestmentTransactionData(
            holdingId: holding.id!,
            type: .sell,
            quantity: 100.0, // More than we own (0)
            price: 110.0,
            transactionFee: 19.95,
            transactionDate: Date()
        )
        
        // When/Then: Should throw insufficient shares error
        do {
            _ = try await portfolioManager.recordTransaction(sellData)
            XCTFail("Should throw error for insufficient shares")
        } catch PortfolioManager.PortfolioError.insufficientShares {
            // Expected error
        } catch {
            XCTFail("Should throw PortfolioError.insufficientShares")
        }
    }
    
    // MARK: - Portfolio Performance Tests
    
    func testCalculatePortfolioValue() async throws {
        // Given: Portfolio with multiple holdings
        let portfolio = try await createTestPortfolio()
        let holding1 = try await createTestHolding(in: portfolio, symbol: "CBA.AX")
        let holding2 = try await createTestHolding(in: portfolio, symbol: "AAPL")
        
        // Add transactions
        let buyData1 = InvestmentTransactionData(
            holdingId: holding1.id!,
            type: .buy,
            quantity: 100.0,
            price: 100.0,
            transactionFee: 19.95,
            transactionDate: Date()
        )
        
        let buyData2 = InvestmentTransactionData(
            holdingId: holding2.id!,
            type: .buy,
            quantity: 50.0,
            price: 150.0,
            transactionFee: 19.95,
            transactionDate: Date()
        )
        
        _ = try await portfolioManager.recordTransaction(buyData1)
        _ = try await portfolioManager.recordTransaction(buyData2)
        
        // Mock current prices
        portfolioManager.setMockPrice("CBA.AX", price: 110.0)
        portfolioManager.setMockPrice("AAPL", price: 160.0)
        
        // When: Calculating portfolio value
        let portfolioValue = try await portfolioManager.calculatePortfolioValue(portfolio.id!)
        
        // Then: Should calculate total market value correctly
        let expectedValue = (100.0 * 110.0) + (50.0 * 160.0) // $11,000 + $8,000 = $19,000
        XCTAssertEqual(portfolioValue.totalMarketValue, expectedValue, "Should calculate total market value")
        XCTAssertGreaterThan(portfolioValue.totalUnrealizedGainLoss, 0, "Should have unrealized gains")
    }
    
    func testCalculatePortfolioPerformance() async throws {
        // Given: Portfolio with historical data
        let portfolio = try await createTestPortfolio()
        let holding = try await createTestHolding(in: portfolio, symbol: "CBA.AX")
        
        // Add historical transaction
        let buyData = InvestmentTransactionData(
            holdingId: holding.id!,
            type: .buy,
            quantity: 100.0,
            price: 100.0,
            transactionFee: 19.95,
            transactionDate: Date().addingTimeInterval(-86400 * 30) // 30 days ago
        )
        _ = try await portfolioManager.recordTransaction(buyData)
        
        // Mock current price with gain
        portfolioManager.setMockPrice("CBA.AX", price: 120.0)
        
        // When: Calculating performance metrics
        let performance = try await portfolioManager.calculatePerformanceMetrics(portfolio.id!)
        
        // Then: Should calculate performance correctly
        XCTAssertGreaterThan(performance.totalReturn, 0, "Should have positive total return")
        XCTAssertNotNil(performance.thirtyDayReturn, "Should calculate 30-day return")
        XCTAssertNotNil(performance.annualizedReturn, "Should calculate annualized return")
    }
    
    // MARK: - Australian Tax Compliance Tests
    
    func testCGTCalculationForSale() async throws {
        // Given: Holding with >12 months ownership for CGT discount
        let portfolio = try await createTestPortfolio()
        let holding = try await createTestHolding(in: portfolio, symbol: "CBA.AX")
        
        let buyDate = Date().addingTimeInterval(-86400 * 400) // >12 months ago
        let buyData = InvestmentTransactionData(
            holdingId: holding.id!,
            type: .buy,
            quantity: 100.0,
            price: 100.0,
            transactionFee: 19.95,
            transactionDate: buyDate
        )
        _ = try await portfolioManager.recordTransaction(buyData)
        
        // When: Selling after >12 months
        let sellData = InvestmentTransactionData(
            holdingId: holding.id!,
            type: .sell,
            quantity: 100.0,
            price: 150.0,
            transactionFee: 19.95,
            transactionDate: Date()
        )
        let sellTransaction = try await portfolioManager.recordTransaction(sellData)
        
        // Then: Should apply 50% CGT discount
        XCTAssertNotNil(sellTransaction.capitalGainLoss, "Should calculate capital gain/loss")
        XCTAssertTrue(sellTransaction.eligibleForCGTDiscount, "Should be eligible for CGT discount")
        
        let expectedGain = (150.0 * 100.0 - 19.95) - (100.0 * 100.0 + 19.95) // $14,980.05 - $10,019.95 = $4,960.10
        let discountedGain = expectedGain * 0.5 // 50% discount
        XCTAssertEqual(sellTransaction.discountedCapitalGain!, discountedGain, accuracy: 0.01, "Should apply 50% CGT discount")
    }
    
    func testFrankingCreditCalculation() async throws {
        // Given: Portfolio with ASX dividend-paying stock
        let portfolio = try await createTestPortfolio()
        let holding = try await createTestHolding(in: portfolio, symbol: "CBA.AX")
        
        let buyData = InvestmentTransactionData(
            holdingId: holding.id!,
            type: .buy,
            quantity: 100.0,
            price: 100.0,
            transactionFee: 19.95,
            transactionDate: Date().addingTimeInterval(-86400 * 100)
        )
        _ = try await portfolioManager.recordTransaction(buyData)
        
        // When: Recording dividend with franking credits
        let dividendData = DividendData(
            holdingId: holding.id!,
            dividendPerShare: 2.50,
            frankingPercentage: 100.0, // Fully franked
            paymentDate: Date(),
            exDividendDate: Date().addingTimeInterval(-86400 * 7),
            isDRP: false
        )
        let dividend = try await portfolioManager.recordDividend(dividendData)
        
        // Then: Should calculate franking credits correctly
        let expectedGrossDividend = 100.0 * 2.50 // $250
        let expectedFrankingCredit = expectedGrossDividend * (30.0 / 70.0) // Company tax rate 30%
        
        XCTAssertEqual(dividend.cashDividend, expectedGrossDividend, "Should calculate cash dividend")
        XCTAssertEqual(dividend.frankingCredit, expectedFrankingCredit, accuracy: 0.01, "Should calculate franking credit")
        XCTAssertEqual(dividend.grossDividend, expectedGrossDividend + expectedFrankingCredit, accuracy: 0.01, "Should calculate gross dividend")
    }
    
    // MARK: - Multi-Entity Support Tests
    
    func testPortfolioIsolationBetweenEntities() async throws {
        // Given: Two different entities
        let entity2 = FinancialEntity(context: testContext)
        entity2.id = UUID()
        entity2.name = "Entity 2"
        entity2.type = "Business"
        entity2.isActive = true
        try testContext.save()
        
        // Create portfolios for different entities
        let portfolio1Data = PortfolioData(
            name: "Personal Portfolio",
            entityId: testEntity.id!,
            description: "Personal investments",
            strategy: .balanced,
            riskProfile: .moderate
        )
        
        let portfolio2Data = PortfolioData(
            name: "Business Portfolio", 
            entityId: entity2.id!,
            description: "Business investments",
            strategy: .growth,
            riskProfile: .high
        )
        
        let portfolio1 = try await portfolioManager.createPortfolio(portfolio1Data)
        let portfolio2 = try await portfolioManager.createPortfolio(portfolio2Data)
        
        // When: Fetching portfolios for each entity
        let entity1Portfolios = try await portfolioManager.getPortfolios(for: testEntity.id!)
        let entity2Portfolios = try await portfolioManager.getPortfolios(for: entity2.id!)
        
        // Then: Should return only portfolios for each entity
        XCTAssertEqual(entity1Portfolios.count, 1, "Entity 1 should have 1 portfolio")
        XCTAssertEqual(entity2Portfolios.count, 1, "Entity 2 should have 1 portfolio")
        XCTAssertEqual(entity1Portfolios.first?.id, portfolio1.id, "Should return correct portfolio for entity 1")
        XCTAssertEqual(entity2Portfolios.first?.id, portfolio2.id, "Should return correct portfolio for entity 2")
    }
    
    // MARK: - Performance Tests
    
    func testLargePortfolioPerformance() async throws {
        // Given: Portfolio with many holdings
        let portfolio = try await createTestPortfolio()
        
        // Add 100 different holdings
        for i in 1...100 {
            let assetData = AssetData(
                symbol: "TEST\(i).AX",
                market: .asx,
                name: "Test Stock \(i)",
                assetType: .equity,
                currency: "AUD"
            )
            let holding = try await portfolioManager.addAsset(assetData, to: portfolio.id!)
            
            // Add transaction for each holding
            let buyData = InvestmentTransactionData(
                holdingId: holding.id!,
                type: .buy,
                quantity: Double(i * 10),
                price: Double(100 + i),
                transactionFee: 19.95,
                transactionDate: Date()
            )
            _ = try await portfolioManager.recordTransaction(buyData)
            
            // Mock price
            portfolioManager.setMockPrice("TEST\(i).AX", price: Double(105 + i))
        }
        
        // When: Calculating portfolio value (performance test)
        let startTime = CFAbsoluteTimeGetCurrent()
        let portfolioValue = try await portfolioManager.calculatePortfolioValue(portfolio.id!)
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then: Should complete within performance target
        XCTAssertLessThan(processingTime, 2.0, "Large portfolio calculation should complete within 2 seconds")
        XCTAssertGreaterThan(portfolioValue.totalMarketValue, 0, "Should calculate non-zero portfolio value")
    }
    
    // MARK: - Helper Methods
    
    private func createTestPortfolio() async throws -> Portfolio {
        let portfolioData = PortfolioData(
            name: "Test Portfolio",
            entityId: testEntity.id!,
            description: "Testing portfolio",
            strategy: .balanced,
            riskProfile: .moderate
        )
        return try await portfolioManager.createPortfolio(portfolioData)
    }
    
    private func createTestHolding(in portfolio: Portfolio, symbol: String) async throws -> Holding {
        let assetData = AssetData(
            symbol: symbol,
            market: symbol.contains("AX") ? .asx : .nasdaq,
            name: "Test Asset \(symbol)",
            assetType: .equity,
            currency: symbol.contains("AX") ? "AUD" : "USD"
        )
        return try await portfolioManager.addAsset(assetData, to: portfolio.id!)
    }
    
}