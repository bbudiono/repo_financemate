import XCTest
import CoreData
import NaturalLanguage
@testable import FinanceMate

/**
 * TransactionMatcherTests.swift
 * 
 * Purpose: Comprehensive TDD unit tests for OCR-to-transaction matching algorithm with fuzzy matching and tolerance
 * Issues & Complexity Summary: Tests fuzzy matching, date/amount tolerance, confidence scoring, and duplicate detection
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~250+
 *   - Core Algorithm Complexity: High
 *   - Dependencies: 3 (CoreData, NaturalLanguage, XCTest)
 *   - State Management Complexity: Medium
 *   - Novelty/Uncertainty Factor: Medium-High
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 88%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: Intelligent transaction matching with Australian financial patterns
 * Last Updated: 2025-07-08
 */

final class TransactionMatcherTests: XCTestCase {
    var transactionMatcher: TransactionMatcher!
    var testContext: NSManagedObjectContext!
    var persistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        testContext = persistenceController.container.viewContext
        transactionMatcher = TransactionMatcher(context: testContext)
    }
    
    override func tearDown() {
        transactionMatcher = nil
        testContext = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Exact Matching Tests
    
    func testExactAmountMatching() throws {
        // Given: A transaction with exact amount match
        let targetAmount = 45.67
        let targetDate = Date()
        let merchantName = "Coffee Shop"
        
        let existingTransaction = createTestTransaction(
            amount: targetAmount,
            date: targetDate,
            note: merchantName
        )
        
        let ocrResult = OCRResult(
            totalAmount: targetAmount,
            transactionDate: targetDate,
            merchantName: merchantName,
            confidence: 0.95
        )
        
        // When: Finding matching transaction
        let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
        
        // Then: Should find exact match
        XCTAssertNotNil(matchedTransaction, "Should find exact matching transaction")
        XCTAssertEqual(matchedTransaction?.id, existingTransaction.id, "Should match correct transaction")
        XCTAssertEqual(matchedTransaction?.amount, targetAmount, "Amount should match exactly")
    }
    
    func testToleranceBasedMatching() throws {
        // Given: A transaction with slight amount difference (within 5% tolerance)
        let originalAmount = 100.00
        let ocrAmount = 102.50 // 2.5% difference, within 5% tolerance
        let targetDate = Date()
        let merchantName = "Restaurant"
        
        let existingTransaction = createTestTransaction(
            amount: originalAmount,
            date: targetDate,
            note: merchantName
        )
        
        let ocrResult = OCRResult(
            totalAmount: ocrAmount,
            transactionDate: targetDate,
            merchantName: merchantName,
            confidence: 0.90
        )
        
        // When: Finding matching transaction
        let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
        
        // Then: Should find match within tolerance
        XCTAssertNotNil(matchedTransaction, "Should find transaction within tolerance")
        XCTAssertEqual(matchedTransaction?.id, existingTransaction.id, "Should match correct transaction")
    }
    
    func testAmountOutsideTolerance() throws {
        // Given: A transaction with amount difference exceeding 5% tolerance
        let originalAmount = 100.00
        let ocrAmount = 110.00 // 10% difference, outside 5% tolerance
        let targetDate = Date()
        let merchantName = "Store"
        
        let existingTransaction = createTestTransaction(
            amount: originalAmount,
            date: targetDate,
            note: merchantName
        )
        
        let ocrResult = OCRResult(
            totalAmount: ocrAmount,
            transactionDate: targetDate,
            merchantName: merchantName,
            confidence: 0.90
        )
        
        // When: Finding matching transaction
        let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
        
        // Then: Should not find match outside tolerance
        XCTAssertNil(matchedTransaction, "Should not match transaction outside tolerance")
    }
    
    // MARK: - Date Range Matching Tests
    
    func testDateRangeMatching() throws {
        // Given: A transaction 2 days before OCR date (within 3-day tolerance)
        let transactionDate = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        let ocrDate = Date()
        let amount = 25.99
        let merchantName = "Gas Station"
        
        let existingTransaction = createTestTransaction(
            amount: amount,
            date: transactionDate,
            note: merchantName
        )
        
        let ocrResult = OCRResult(
            totalAmount: amount,
            transactionDate: ocrDate,
            merchantName: merchantName,
            confidence: 0.88
        )
        
        // When: Finding matching transaction
        let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
        
        // Then: Should find match within date range
        XCTAssertNotNil(matchedTransaction, "Should find transaction within date range")
        XCTAssertEqual(matchedTransaction?.id, existingTransaction.id, "Should match correct transaction")
    }
    
    func testDateOutsideRange() throws {
        // Given: A transaction 5 days before OCR date (outside 3-day tolerance)
        let transactionDate = Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
        let ocrDate = Date()
        let amount = 25.99
        let merchantName = "Gas Station"
        
        let existingTransaction = createTestTransaction(
            amount: amount,
            date: transactionDate,
            note: merchantName
        )
        
        let ocrResult = OCRResult(
            totalAmount: amount,
            transactionDate: ocrDate,
            merchantName: merchantName,
            confidence: 0.88
        )
        
        // When: Finding matching transaction
        let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
        
        // Then: Should not find match outside date range
        XCTAssertNil(matchedTransaction, "Should not match transaction outside date range")
    }
    
    // MARK: - Fuzzy Text Matching Tests
    
    func testFuzzyTextMatching() throws {
        // Given: Transactions with similar but not identical merchant names
        let amount = 15.50
        let date = Date()
        
        let existingTransaction = createTestTransaction(
            amount: amount,
            date: date,
            note: "McDonald's Restaurant"
        )
        
        let ocrResult = OCRResult(
            totalAmount: amount,
            transactionDate: date,
            merchantName: "McDonalds", // Slightly different spelling
            confidence: 0.85
        )
        
        // When: Finding matching transaction
        let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
        
        // Then: Should find fuzzy match
        XCTAssertNotNil(matchedTransaction, "Should find fuzzy text match")
        XCTAssertEqual(matchedTransaction?.id, existingTransaction.id, "Should match correct transaction")
    }
    
    func testFuzzyMatchThreshold() {
        // Given: Text pairs with known similarity scores
        let testCases = [
            ("McDonald's", "McDonalds", 0.90), // High similarity
            ("Starbucks Coffee", "Starbucks", 0.75), // Medium similarity  
            ("KFC", "McDonald's", 0.10), // Low similarity
            ("Woolworths", "Coles", 0.20), // Different stores
            ("BP Service Station", "BP Station", 0.85) // High similarity
        ]
        
        for (text1, text2, expectedSimilarity) in testCases {
            // When: Calculating fuzzy match score
            let similarity = transactionMatcher.calculateFuzzyMatch(text1, text2)
            
            // Then: Should match expected similarity within tolerance
            XCTAssertEqual(similarity, expectedSimilarity, accuracy: 0.15, 
                          "Fuzzy match for '\(text1)' vs '\(text2)' should be ~\(expectedSimilarity)")
        }
    }
    
    func testCaseInsensitiveFuzzyMatching() throws {
        // Given: Transactions with different casing
        let amount = 8.75
        let date = Date()
        
        let existingTransaction = createTestTransaction(
            amount: amount,
            date: date,
            note: "COLES SUPERMARKET"
        )
        
        let ocrResult = OCRResult(
            totalAmount: amount,
            transactionDate: date,
            merchantName: "coles supermarket", // Different casing
            confidence: 0.92
        )
        
        // When: Finding matching transaction
        let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
        
        // Then: Should find case-insensitive match
        XCTAssertNotNil(matchedTransaction, "Should find case-insensitive match")
        XCTAssertEqual(matchedTransaction?.id, existingTransaction.id, "Should match correct transaction")
    }
    
    // MARK: - No Match Scenarios Tests
    
    func testNoMatchScenarios() throws {
        // Given: Transactions that shouldn't match
        let existingTransaction = createTestTransaction(
            amount: 50.00,
            date: Date(),
            note: "Existing Store"
        )
        
        let noMatchScenarios = [
            // Different merchant, different amount
            OCRResult(totalAmount: 25.00, transactionDate: Date(), merchantName: "Different Store", confidence: 0.95),
            // Same merchant, very different amount
            OCRResult(totalAmount: 200.00, transactionDate: Date(), merchantName: "Existing Store", confidence: 0.95),
            // Same amount, very old date
            OCRResult(totalAmount: 50.00, transactionDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(), merchantName: "Existing Store", confidence: 0.95)
        ]
        
        for ocrResult in noMatchScenarios {
            // When: Finding matching transaction
            let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
            
            // Then: Should not find match
            XCTAssertNil(matchedTransaction, "Should not match for scenario: \(ocrResult.merchantName)")
        }
    }
    
    func testMultipleMatchesPriority() throws {
        // Given: Multiple transactions that could match
        let amount = 30.00
        let date = Date()
        let merchantName = "Coffee Shop"
        
        // Create transactions at different times (should prefer most recent)
        let olderTransaction = createTestTransaction(
            amount: amount,
            date: Calendar.current.date(byAdding: .hour, value: -2, to: date) ?? date,
            note: merchantName
        )
        
        let newerTransaction = createTestTransaction(
            amount: amount,
            date: Calendar.current.date(byAdding: .hour, value: -1, to: date) ?? date,
            note: merchantName
        )
        
        let ocrResult = OCRResult(
            totalAmount: amount,
            transactionDate: date,
            merchantName: merchantName,
            confidence: 0.90
        )
        
        // When: Finding matching transaction
        let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
        
        // Then: Should match the more recent transaction
        XCTAssertNotNil(matchedTransaction, "Should find a matching transaction")
        XCTAssertEqual(matchedTransaction?.id, newerTransaction.id, "Should prefer more recent transaction")
    }
    
    // MARK: - Already Processed Transactions Tests
    
    func testExcludeAlreadyProcessedTransactions() throws {
        // Given: A transaction that already has OCR data
        let amount = 12.50
        let date = Date()
        let merchantName = "Bookstore"
        
        let processedTransaction = createTestTransaction(
            amount: amount,
            date: date,
            note: merchantName
        )
        
        // Mark transaction as already processed
        processedTransaction.ocrProcessedDate = Date()
        try testContext.save()
        
        let ocrResult = OCRResult(
            totalAmount: amount,
            transactionDate: date,
            merchantName: merchantName,
            confidence: 0.95
        )
        
        // When: Finding matching transaction
        let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
        
        // Then: Should not match already processed transaction
        XCTAssertNil(matchedTransaction, "Should not match already processed transaction")
    }
    
    // MARK: - Australian-Specific Tests
    
    func testAustralianMerchantPatterns() throws {
        // Given: Common Australian merchant patterns
        let australianMerchants = [
            ("Woolworths", "WOOLWORTHS 1234"),
            ("Coles", "COLES EXPRESS"),
            ("IGA", "IGA SUPERMARKET"),
            ("Bunnings", "BUNNINGS WAREHOUSE"),
            ("JB Hi-Fi", "JB HIFI")
        ]
        
        for (shortName, receiptName) in australianMerchants {
            let amount = 25.99
            let date = Date()
            
            let existingTransaction = createTestTransaction(
                amount: amount,
                date: date,
                note: shortName
            )
            
            let ocrResult = OCRResult(
                totalAmount: amount,
                transactionDate: date,
                merchantName: receiptName,
                confidence: 0.88
            )
            
            // When: Finding matching transaction
            let matchedTransaction = transactionMatcher.findMatchingTransaction(for: ocrResult)
            
            // Then: Should match Australian merchant patterns
            XCTAssertNotNil(matchedTransaction, "Should match Australian merchant: \(shortName)")
            XCTAssertEqual(matchedTransaction?.id, existingTransaction.id, "Should match correct transaction for \(shortName)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testMatchingPerformance() {
        // Given: A large number of transactions to search through
        let targetDate = Date()
        let targetAmount = 42.50
        let targetMerchant = "Target Store"
        
        // Create 100 transactions
        for i in 1...100 {
            createTestTransaction(
                amount: Double(i) * 1.50,
                date: Calendar.current.date(byAdding: .hour, value: -i, to: targetDate) ?? targetDate,
                note: "Store \(i)"
            )
        }
        
        // Create the target transaction
        let targetTransaction = createTestTransaction(
            amount: targetAmount,
            date: targetDate,
            note: targetMerchant
        )
        
        let ocrResult = OCRResult(
            totalAmount: targetAmount,
            transactionDate: targetDate,
            merchantName: targetMerchant,
            confidence: 0.90
        )
        
        // When: Measuring matching performance
        measure {
            // Synchronous execution
let _ = transactionMatcher.findMatchingTransaction(for: ocrResult)
            
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestTransaction(amount: Double, date: Date, note: String) -> Transaction {
        let transaction = Transaction.create(
            in: testContext,
            amount: amount,
            category: "General"
        )
        transaction.date = date
        transaction.note = note
        transaction.createdAt = Date()
        
        try! testContext.save()
        return transaction
    }
}

// MARK: - Mock OCRResult for Testing

extension TransactionMatcherTests {
    struct OCRResult {
        let totalAmount: Double
        let transactionDate: Date
        let merchantName: String
        let confidence: Double
        let lineItems: [LineItemData] = []
        let gstAmount: Double = 0.0
        let hasGST: Bool = false
        let merchantABN: String? = nil
        let currencyCode: String = "AUD"
        let extractedText: String = ""
        let requiresManualReview: Bool = false
        
        init(totalAmount: Double, transactionDate: Date, merchantName: String, confidence: Double) {
            self.totalAmount = totalAmount
            self.transactionDate = transactionDate
            self.merchantName = merchantName
            self.confidence = confidence
        }
    }
    
    struct LineItemData {
        let description: String
        let amount: Double
        let confidence: Double
    }
}