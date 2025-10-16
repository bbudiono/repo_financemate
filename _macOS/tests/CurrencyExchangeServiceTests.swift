import XCTest
import CoreData
@testable import FinanceMate

/// Currency Exchange Service Tests - RED Phase
/// Tests for historical FX rates and original/converted amount storage
final class CurrencyExchangeServiceTests: XCTestCase {

    var testContext: NSManagedObjectContext!
    var testPersistenceController: PersistenceController!

    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        testContext = nil
        testPersistenceController = nil
    }

    /// Test that CurrencyExchangeService can fetch historical FX rates
    /// RED PHASE: This should fail because CurrencyExchangeService doesn't exist
    func testCurrencyExchangeServiceFetchesHistoricalRates() throws {
        // RED VERIFICATION: CurrencyExchangeService should exist and fetch historical rates
        // This test will fail because CurrencyExchangeService doesn't exist yet

        // Try to create CurrencyExchangeService (this will fail)
        let exchangeService = CurrencyExchangeService(context: testContext)

        // Test fetching historical rates for a specific date
        let testDate = Date()
        let testRate = try exchangeService.getExchangeRate(
            from: "USD",
            to: "AUD",
            date: testDate
        )

        // RED TEST: Should return valid exchange rate
        XCTAssertGreaterThan(testRate, 0, "Exchange rate should be greater than 0")
        XCTAssertEqual(testRate, 1.5, accuracy: 0.1, "Should return reasonable USD to AUD rate")
    }

    /// Test that CurrencyExchangeService converts amounts using historical rates
    /// RED PHASE: This should fail because conversion logic doesn't exist
    func testCurrencyExchangeServiceConvertsAmounts() throws {
        // RED VERIFICATION: Should convert foreign currency to AUD using historical rates
        // This test will fail because conversion functionality doesn't exist

        let exchangeService = CurrencyExchangeService(context: testContext)
        let testDate = Date()

        // Test conversion
        let originalAmount = 100.0
        let convertedAmount = try exchangeService.convertAmount(
            originalAmount,
            from: "USD",
            to: "AUD",
            date: testDate
        )

        // RED TEST: Should convert using appropriate exchange rate
        XCTAssertEqual(convertedAmount, 150.0, accuracy: 10.0, "Should convert USD 100 to approximately AUD 150")
    }

    /// Test that original and converted amounts are stored in Core Data
    /// RED PHASE: This should fail because storage fields don't exist
    func testCurrencyExchangeServiceStoresOriginalAndConvertedAmounts() throws {
        // RED VERIFICATION: Should store both original and converted amounts in Core Data
        // This test will fail because storage fields don't exist in TransactionEntity

        let exchangeService = CurrencyExchangeService(context: testContext)
        let testDate = Date()

        // Create a transaction with foreign currency
        let transaction = NSEntityDescription.insertNewObject(
            forEntityName: "TransactionEntity",
            into: testContext
        ) as! NSManagedObject

        transaction.setValue(50.0, forKey: "originalAmount")
        transaction.setValue("USD", forKey: "originalCurrency")
        transaction.setValue(Date(), forKey: "date")

        // Convert and store
        try exchangeService.convertAndStoreTransaction(transaction)

        // RED TEST: Should have both original and converted amounts stored
        let originalAmount = transaction.value(forKey: "originalAmount") as? Double
        let convertedAmount = transaction.value(forKey: "amount") as? Double
        let originalCurrency = transaction.value(forKey: "originalCurrency") as? String

        XCTAssertEqual(originalAmount, 50.0, "Should store original amount")
        XCTAssertEqual(originalCurrency, "USD", "Should store original currency")
        XCTAssertEqual(convertedAmount, 75.0, accuracy: 5.0, "Should store converted amount in AUD")
    }

    /// Test that CurrencyExchangeService handles missing exchange rates gracefully
    /// RED PHASE: This should fail because error handling doesn't exist
    func testCurrencyExchangeServiceHandlesMissingRates() throws {
        // RED VERIFICATION: Should handle missing exchange rates gracefully
        // This test will fail because error handling doesn't exist

        let exchangeService = CurrencyExchangeService(context: testContext)
        let oldDate = Date.distantPast

        // Test with very old date (no historical data available)
        let rate = try exchangeService.getExchangeRate(
            from: "EUR",
            to: "AUD",
            date: oldDate
        )

        // RED TEST: Should handle missing rates gracefully
        // This could return a default rate, throw an error, or use current rates
        XCTAssertGreaterThan(rate, 0, "Should provide fallback rate when historical data unavailable")
    }

    /// Test that CurrencyExchangeService caches exchange rates for performance
    /// RED PHASE: This should fail because caching doesn't exist
    func testCurrencyExchangeServiceCachesRates() throws {
        // RED VERIFICATION: Should cache exchange rates for performance
        // This test will fail because caching doesn't exist

        let exchangeService = CurrencyExchangeService(context: testContext)
        let testDate = Date()

        // First call should fetch from API
        let startTime = Date()
        let rate1 = try exchangeService.getExchangeRate(from: "GBP", to: "AUD", date: testDate)
        let firstCallDuration = Date().timeIntervalSince(startTime)

        // Second call should use cache
        let startTime2 = Date()
        let rate2 = try exchangeService.getExchangeRate(from: "GBP", to: "AUD", date: testDate)
        let secondCallDuration = Date().timeIntervalSince(startTime2)

        // RED TEST: Second call should be faster (cached)
        XCTAssertEqual(rate1, rate2, accuracy: 0.001, "Cached rate should match original")
        XCTAssertLessThan(secondCallDuration, firstCallDuration, "Cached call should be faster")
    }

    /// Test that CurrencyExchangeService supports common currency pairs
    /// RED PHASE: This should fail because currency support doesn't exist
    func testCurrencyExchangeServiceSupportsCommonPairs() throws {
        // RED VERIFICATION: Should support common currency pairs
        // This test will fail because currency support doesn't exist

        let exchangeService = CurrencyExchangeService(context: testContext)
        let testDate = Date()

        let commonPairs = [
            ("USD", "AUD"),
            ("EUR", "AUD"),
            ("GBP", "AUD"),
            ("JPY", "AUD"),
            ("CAD", "AUD")
        ]

        // Test each common pair
        for (from, to) in commonPairs {
            let rate = try exchangeService.getExchangeRate(from: from, to: to, date: testDate)
            XCTAssertGreaterThan(rate, 0, "Should support \(from) to \(to) conversion")
        }
    }
}