/**
 * Purpose: Comprehensive unit tests for Investment Core Data models and portfolio management
 * Issues & Complexity Summary: Testing investment tracking, portfolio calculations, and Australian tax compliance
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~800
 *   - Core Algorithm Complexity: High (financial calculations, tax compliance)
 *   - Dependencies: Core Data, Date calculations, financial algorithms
 *   - State Management Complexity: High (portfolio relationships, transaction history)
 *   - Novelty/Uncertainty Factor: Medium (Australian investment regulations)
 * AI Pre-Task Self-Assessment: 80%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 80%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-10
 */

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
class InvestmentTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var persistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDown() {
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Basic Setup Test
    
    func testBasicSetup() {
        XCTAssertNotNil(context, "Context should be initialized")
        XCTAssertNotNil(persistenceController, "PersistenceController should be initialized")
    }
    
    // MARK: - Portfolio Tests
    
    func testPortfolioCreation() {
        // Given
        let name = "My Investment Portfolio"
        let currency = "AUD"
        
        // When
        let portfolio = Portfolio.create(
            in: context,
            name: name,
            currency: currency
        )
        
        // Then
        XCTAssertEqual(portfolio.name, name, "Portfolio name should match input")
        XCTAssertEqual(portfolio.currency, currency, "Portfolio currency should match input")
        XCTAssertNotNil(portfolio.id, "Portfolio should have a UUID")
        XCTAssertNotNil(portfolio.createdAt, "Portfolio should have creation date")
        XCTAssertEqual(portfolio.totalValue, 0.0, "New portfolio should have zero value")
        XCTAssertTrue(portfolio.investments.isEmpty, "New portfolio should have no investments")
    }
    
    func testPortfolioValueCalculation() {
        // Given
        let portfolio = Portfolio.create(
            in: context,
            name: "Test Portfolio",
            currency: "AUD"
        )
        
        let investment1 = Investment.create(
            in: context,
            symbol: "CBA",
            name: "Commonwealth Bank",
            assetType: "Stock",
            quantity: 100,
            averageCost: 95.50,
            currentPrice: 102.30,
            portfolio: portfolio
        )
        
        let investment2 = Investment.create(
            in: context,
            symbol: "VAS",
            name: "Vanguard Australian Shares",
            assetType: "ETF",
            quantity: 50,
            averageCost: 88.20,
            currentPrice: 91.75,
            portfolio: portfolio
        )
        
        // When
        let totalValue = portfolio.calculateTotalValue()
        
        // Then
        let expectedValue = (100 * 102.30) + (50 * 91.75) // 10230 + 4587.5 = 14817.5
        XCTAssertEqual(totalValue, expectedValue, accuracy: 0.01, "Portfolio value should be sum of investment values")
    }
    
    func testPortfolioPerformanceCalculation() {
        // Given
        let portfolio = Portfolio.create(
            in: context,
            name: "Performance Test",
            currency: "AUD"
        )
        
        let investment = Investment.create(
            in: context,
            symbol: "AAPL",
            name: "Apple Inc",
            assetType: "Stock",
            quantity: 10,
            averageCost: 150.00,
            currentPrice: 165.00,
            portfolio: portfolio
        )
        
        // When
        let performance = portfolio.calculatePerformance()
        
        // Then
        let expectedGain = (165.00 - 150.00) * 10 // $150 gain
        let expectedReturn = (165.00 - 150.00) / 150.00 // 10% return
        
        XCTAssertEqual(performance.totalGain, expectedGain, accuracy: 0.01, "Total gain should be calculated correctly")
        XCTAssertEqual(performance.totalReturn, expectedReturn, accuracy: 0.001, "Total return percentage should be calculated correctly")
    }
    
    // MARK: - Investment Tests
    
    func testInvestmentCreation() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let symbol = "BHP"
        let name = "BHP Group Limited"
        let assetType = "Stock"
        let quantity = 200.0
        let averageCost = 45.30
        let currentPrice = 47.85
        
        // When
        let investment = Investment.create(
            in: context,
            symbol: symbol,
            name: name,
            assetType: assetType,
            quantity: quantity,
            averageCost: averageCost,
            currentPrice: currentPrice,
            portfolio: portfolio
        )
        
        // Then
        XCTAssertEqual(investment.symbol, symbol, "Investment symbol should match input")
        XCTAssertEqual(investment.name, name, "Investment name should match input")
        XCTAssertEqual(investment.assetType, assetType, "Asset type should match input")
        XCTAssertEqual(investment.quantity, quantity, "Quantity should match input")
        XCTAssertEqual(investment.averageCost, averageCost, "Average cost should match input")
        XCTAssertEqual(investment.currentPrice, currentPrice, "Current price should match input")
        XCTAssertEqual(investment.portfolio, portfolio, "Investment should be linked to portfolio")
        XCTAssertNotNil(investment.id, "Investment should have a UUID")
        XCTAssertNotNil(investment.lastUpdated, "Investment should have last updated date")
    }
    
    func testInvestmentValueCalculation() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let investment = Investment.create(
            in: context,
            symbol: "WES",
            name: "Wesfarmers Limited",
            assetType: "Stock",
            quantity: 75,
            averageCost: 52.40,
            currentPrice: 58.20,
            portfolio: portfolio
        )
        
        // When
        let currentValue = investment.calculateCurrentValue()
        let bookValue = investment.calculateBookValue()
        let unrealizedGain = investment.calculateUnrealizedGain()
        
        // Then
        XCTAssertEqual(currentValue, 75 * 58.20, accuracy: 0.01, "Current value should be quantity × current price")
        XCTAssertEqual(bookValue, 75 * 52.40, accuracy: 0.01, "Book value should be quantity × average cost")
        XCTAssertEqual(unrealizedGain, (58.20 - 52.40) * 75, accuracy: 0.01, "Unrealized gain should be price difference × quantity")
    }
    
    func testInvestmentReturnCalculation() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let investment = Investment.create(
            in: context,
            symbol: "TLS",
            name: "Telstra Corporation",
            assetType: "Stock",
            quantity: 500,
            averageCost: 3.80,
            currentPrice: 4.15,
            portfolio: portfolio
        )
        
        // When
        let returnPercentage = investment.calculateReturnPercentage()
        
        // Then
        let expectedReturn = (4.15 - 3.80) / 3.80 // 9.21% return
        XCTAssertEqual(returnPercentage, expectedReturn, accuracy: 0.001, "Return percentage should be calculated correctly")
    }
    
    // MARK: - Investment Transaction Tests
    
    func testInvestmentTransactionCreation() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let investment = Investment.create(
            in: context,
            symbol: "CSL",
            name: "CSL Limited",
            assetType: "Stock",
            quantity: 25,
            averageCost: 280.50,
            currentPrice: 295.20,
            portfolio: portfolio
        )
        
        let transactionType = InvestmentTransactionType.buy
        let quantity = 10.0
        let price = 290.00
        let fees = 15.00
        let date = Date()
        
        // When
        let transaction = InvestmentTransaction.create(
            in: context,
            investment: investment,
            type: transactionType,
            quantity: quantity,
            price: price,
            fees: fees,
            date: date
        )
        
        // Then
        XCTAssertEqual(transaction.type, transactionType.rawValue, "Transaction type should match input")
        XCTAssertEqual(transaction.quantity, quantity, "Transaction quantity should match input")
        XCTAssertEqual(transaction.price, price, "Transaction price should match input")
        XCTAssertEqual(transaction.fees, fees, "Transaction fees should match input")
        XCTAssertEqual(transaction.date, date, "Transaction date should match input")
        XCTAssertEqual(transaction.investment, investment, "Transaction should be linked to investment")
        XCTAssertNotNil(transaction.id, "Transaction should have a UUID")
    }
    
    func testAverageCostUpdate() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let investment = Investment.create(
            in: context,
            symbol: "ANZ",
            name: "ANZ Banking Group",
            assetType: "Stock",
            quantity: 100,
            averageCost: 25.50,
            currentPrice: 26.80,
            portfolio: portfolio
        )
        
        // When - Add more shares at different price
        investment.addTransaction(
            type: .buy,
            quantity: 50,
            price: 27.00,
            fees: 10.00,
            date: Date()
        )
        
        // Then - Average cost should be recalculated
        // Original: 100 shares @ $25.50 = $2550
        // New: 50 shares @ $27.00 + $10 fees = $1360
        // Total: 150 shares for $3910
        // Average: $3910 / 150 = $26.067
        let expectedAverageCost = (100 * 25.50 + 50 * 27.00 + 10.00) / 150
        XCTAssertEqual(investment.averageCost, expectedAverageCost, accuracy: 0.01, "Average cost should be recalculated after purchase")
        XCTAssertEqual(investment.quantity, 150, "Quantity should be updated after purchase")
    }
    
    func testSellTransaction() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let investment = Investment.create(
            in: context,
            symbol: "WOW",
            name: "Woolworths Group",
            assetType: "Stock",
            quantity: 200,
            averageCost: 35.20,
            currentPrice: 38.50,
            portfolio: portfolio
        )
        
        // When - Sell some shares
        investment.addTransaction(
            type: .sell,
            quantity: 75,
            price: 39.00,
            fees: 15.00,
            date: Date()
        )
        
        // Then
        XCTAssertEqual(investment.quantity, 125, "Quantity should be reduced after sale")
        // Average cost should remain the same for remaining shares
        XCTAssertEqual(investment.averageCost, 35.20, accuracy: 0.01, "Average cost should remain unchanged after sale")
    }
    
    // MARK: - Dividend Tests
    
    func testDividendCreation() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let investment = Investment.create(
            in: context,
            symbol: "NAB",
            name: "National Australia Bank",
            assetType: "Stock",
            quantity: 150,
            averageCost: 28.40,
            currentPrice: 30.10,
            portfolio: portfolio
        )
        
        let amount = 225.00 // $1.50 per share × 150 shares
        let frankedAmount = 96.43 // Franking credits
        let exDate = Date()
        let payDate = Calendar.current.date(byAdding: .day, value: 30, to: exDate)!
        
        // When
        let dividend = Dividend.create(
            in: context,
            investment: investment,
            amount: amount,
            frankedAmount: frankedAmount,
            exDate: exDate,
            payDate: payDate
        )
        
        // Then
        XCTAssertEqual(dividend.amount, amount, "Dividend amount should match input")
        XCTAssertEqual(dividend.frankedAmount, frankedAmount, "Franked amount should match input")
        XCTAssertEqual(dividend.exDate, exDate, "Ex-dividend date should match input")
        XCTAssertEqual(dividend.payDate, payDate, "Pay date should match input")
        XCTAssertEqual(dividend.investment, investment, "Dividend should be linked to investment")
        XCTAssertNotNil(dividend.id, "Dividend should have a UUID")
    }
    
    func testDividendYieldCalculation() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let investment = Investment.create(
            in: context,
            symbol: "RIO",
            name: "Rio Tinto Limited",
            assetType: "Stock",
            quantity: 100,
            averageCost: 110.50,
            currentPrice: 115.20,
            portfolio: portfolio
        )
        
        // Add dividends for the year
        let dividend1 = Dividend.create(
            in: context,
            investment: investment,
            amount: 350.00, // $3.50 per share
            frankedAmount: 150.00,
            exDate: Date(),
            payDate: Date()
        )
        
        let dividend2 = Dividend.create(
            in: context,
            investment: investment,
            amount: 320.00, // $3.20 per share
            frankedAmount: 137.14,
            exDate: Date(),
            payDate: Date()
        )
        
        // When
        let dividendYield = investment.calculateDividendYield()
        
        // Then
        // Total dividends: $350 + $320 = $670
        // Current value: 100 × $115.20 = $11,520
        // Yield: $670 / $11,520 = 5.82%
        let expectedYield = (350.00 + 320.00) / (100 * 115.20)
        XCTAssertEqual(dividendYield, expectedYield, accuracy: 0.001, "Dividend yield should be calculated correctly")
    }
    
    // MARK: - Australian Tax Compliance Tests
    
    func testCapitalGainsCalculation() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let investment = Investment.create(
            in: context,
            symbol: "TCL",
            name: "Transurban Group",
            assetType: "Stock",
            quantity: 200,
            averageCost: 12.80,
            currentPrice: 14.20,
            portfolio: portfolio
        )
        
        // Sell 100 shares after holding for > 12 months
        let sellDate = Calendar.current.date(byAdding: .month, value: 15, to: investment.lastUpdated)!
        
        // When
        let capitalGains = investment.calculateCapitalGains(
            soldQuantity: 100,
            sellPrice: 14.50,
            sellDate: sellDate
        )
        
        // Then
        // Capital gain: (14.50 - 12.80) × 100 = $170
        // CGT discount applies (50% after 12 months): $170 × 50% = $85 taxable
        XCTAssertEqual(capitalGains.grossGain, 170.00, accuracy: 0.01, "Gross capital gain should be calculated correctly")
        XCTAssertTrue(capitalGains.discountEligible, "CGT discount should apply for > 12 months holding")
        XCTAssertEqual(capitalGains.taxableGain, 85.00, accuracy: 0.01, "Taxable gain should include CGT discount")
    }
    
    func testFrankingCreditsCalculation() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        let investment = Investment.create(
            in: context,
            symbol: "WBC",
            name: "Westpac Banking Corporation",
            assetType: "Stock",
            quantity: 100,
            averageCost: 22.50,
            currentPrice: 24.80,
            portfolio: portfolio
        )
        
        let dividend = Dividend.create(
            in: context,
            investment: investment,
            amount: 140.00, // $1.40 per share
            frankedAmount: 60.00,
            exDate: Date(),
            payDate: Date()
        )
        
        // When
        let frankingCredits = dividend.calculateFrankingCredits()
        
        // Then
        // Franking credits should be calculated based on company tax rate (30%)
        // Grossed up dividend: $140 / (1 - 0.30) = $200
        // Franking credits: $200 - $140 = $60
        XCTAssertEqual(frankingCredits.frankingCredits, 60.00, accuracy: 0.01, "Franking credits should match input")
        XCTAssertEqual(frankingCredits.grossedUpDividend, 200.00, accuracy: 0.01, "Grossed up dividend should be calculated correctly")
    }
    
    // MARK: - Asset Allocation Tests
    
    func testAssetAllocationCalculation() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Diversified Portfolio", currency: "AUD")
        
        // Add different asset types
        let stock1 = Investment.create(
            in: context,
            symbol: "CBA",
            name: "Commonwealth Bank",
            assetType: "Stock",
            quantity: 50,
            averageCost: 95.00,
            currentPrice: 100.00,
            portfolio: portfolio
        )
        
        let etf1 = Investment.create(
            in: context,
            symbol: "VAS",
            name: "Vanguard Australian Shares",
            assetType: "ETF",
            quantity: 30,
            averageCost: 85.00,
            currentPrice: 90.00,
            portfolio: portfolio
        )
        
        let crypto1 = Investment.create(
            in: context,
            symbol: "BTC",
            name: "Bitcoin",
            assetType: "Cryptocurrency",
            quantity: 0.5,
            averageCost: 60000.00,
            currentPrice: 65000.00,
            portfolio: portfolio
        )
        
        // When
        let allocation = portfolio.calculateAssetAllocation()
        
        // Then
        let totalValue = (50 * 100.00) + (30 * 90.00) + (0.5 * 65000.00) // 5000 + 2700 + 32500 = 40200
        
        let stockAllocation = allocation.first { $0.assetType == "Stock" }
        let etfAllocation = allocation.first { $0.assetType == "ETF" }
        let cryptoAllocation = allocation.first { $0.assetType == "Cryptocurrency" }
        
        XCTAssertNotNil(stockAllocation, "Stock allocation should exist")
        XCTAssertNotNil(etfAllocation, "ETF allocation should exist")
        XCTAssertNotNil(cryptoAllocation, "Crypto allocation should exist")
        
        XCTAssertEqual(stockAllocation!.percentage, 5000.00 / 40200.00, accuracy: 0.001, "Stock allocation percentage should be correct")
        XCTAssertEqual(etfAllocation!.percentage, 2700.00 / 40200.00, accuracy: 0.001, "ETF allocation percentage should be correct")
        XCTAssertEqual(cryptoAllocation!.percentage, 32500.00 / 40200.00, accuracy: 0.001, "Crypto allocation percentage should be correct")
    }
    
    // MARK: - Performance Tests
    
    func testLargePortfolioPerformance() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Large Portfolio", currency: "AUD")
        
        // Create 100 investments
        for i in 1...100 {
            _ = Investment.create(
                in: context,
                symbol: "STOCK\(i)",
                name: "Test Stock \(i)",
                assetType: "Stock",
                quantity: Double(i * 10),
                averageCost: Double(20 + i),
                currentPrice: Double(22 + i),
                portfolio: portfolio
            )
        }
        
        // When & Then - Performance test
        measure {
            _ = portfolio.calculateTotalValue()
            _ = portfolio.calculatePerformance()
            _ = portfolio.calculateAssetAllocation()
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvestmentCreationWithInvalidData() {
        // Given
        let portfolio = Portfolio.create(in: context, name: "Test Portfolio", currency: "AUD")
        
        // When & Then
        XCTAssertThrowsError(try Investment.createWithValidation(
            in: context,
            symbol: "",
            name: "Invalid Investment",
            assetType: "Stock",
            quantity: -10,
            averageCost: -50.0,
            currentPrice: 0.0,
            portfolio: portfolio
        )) { error in
            XCTAssertTrue(error is InvestmentValidationError, "Should throw investment validation error")
        }
    }
    
    func testPortfolioFetchWithInvalidContext() {
        // Given
        let invalidContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // When & Then
        XCTAssertThrowsError(try Portfolio.fetchPortfolios(in: invalidContext)) { error in
            XCTAssertTrue(error is CoreDataError, "Should throw Core Data error")
        }
    }
}