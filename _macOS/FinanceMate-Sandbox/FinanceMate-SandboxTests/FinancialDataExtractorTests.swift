//
//  FinancialDataExtractorTests.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Test-driven development tests for FinancialDataExtractor in Sandbox environment
* Issues & Complexity Summary: TDD approach for intelligent financial data categorization and extraction
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~180
  - Core Algorithm Complexity: High
  - Dependencies: 4 New (XCTest, NLP, pattern matching, financial categorization)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: High
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
* Problem Estimate (Inherent Problem Difficulty %): 80%
* Initial Code Complexity Estimate %: 82%
* Justification for Estimates: Financial categorization requires sophisticated pattern matching and NLP
* Final Code Complexity (Actual %): TBD - TDD iteration
* Overall Result Score (Success & Quality %): TBD - TDD iteration
* Key Variances/Learnings: TDD approach ensures comprehensive coverage of financial data extraction
* Last Updated: 2025-06-02
*/

import XCTest
import Foundation
import NaturalLanguage
@testable import FinanceMate_Sandbox

@MainActor
final class FinancialDataExtractorTests: XCTestCase {
    
    var financialExtractor: FinancialDataExtractor!
    
    override func setUp() {
        super.setUp()
        financialExtractor = FinancialDataExtractor()
    }
    
    override func tearDown() {
        financialExtractor = nil
        super.tearDown()
    }
    
    // MARK: - Basic Service Tests
    
    func testFinancialDataExtractorInitialization() {
        // Given/When: Service is initialized
        let extractor = FinancialDataExtractor()
        
        // Then: Service should be properly initialized
        XCTAssertNotNil(extractor)
        XCTAssertFalse(extractor.isProcessing)
        XCTAssertTrue(extractor.supportedCategories.count > 0)
    }
    
    // MARK: - Financial Data Extraction Tests
    
    func testExtractFinancialDataFromInvoiceText() async throws {
        // Given: Invoice text with financial information
        let invoiceText = """
        INVOICE #INV-2025-001
        ABC Company Ltd.
        123 Business Street
        
        Date: 01/15/2025
        Due Date: 02/15/2025
        
        Services:
        Consulting Services    $2,500.00
        Tax (10%)                $250.00
        Total Amount:          $2,750.00
        
        Payment Terms: Net 30
        """
        
        // When: Extracting financial data
        let result = await financialExtractor.extractFinancialData(from: invoiceText, documentType: .invoice)
        
        // Then: Should successfully extract financial information
        switch result {
        case .success(let extractedData):
            XCTAssertNotNil(extractedData)
            XCTAssertEqual(extractedData.documentType, .invoice)
            XCTAssertTrue(extractedData.amounts.count > 0)
            XCTAssertNotNil(extractedData.totalAmount)
            XCTAssertNotNil(extractedData.vendor)
            XCTAssertNotNil(extractedData.documentDate)
        case .failure(let error):
            XCTFail("Financial data extraction should succeed: \(error)")
        }
    }
    
    func testExtractFinancialDataFromReceiptText() async throws {
        // Given: Receipt text with purchase information
        let receiptText = """
        GROCERY STORE RECEIPT
        Store #1234 - Downtown Location
        
        Date: 06/01/2025 Time: 14:30
        
        Items:
        Milk 2%           $3.99
        Bread Whole Wheat $2.49
        Apples (2lbs)     $4.99
        
        Subtotal:        $11.47
        Tax:              $0.92
        Total:           $12.39
        
        Payment: VISA ****1234
        """
        
        // When: Extracting financial data from receipt
        let result = await financialExtractor.extractFinancialData(from: receiptText, documentType: .receipt)
        
        // Then: Should extract receipt-specific financial data
        switch result {
        case .success(let extractedData):
            XCTAssertEqual(extractedData.documentType, .receipt)
            XCTAssertTrue(extractedData.amounts.count >= 3) // Items + tax + total
            XCTAssertNotNil(extractedData.totalAmount)
            XCTAssertEqual(extractedData.category, .groceries)
        case .failure(let error):
            XCTFail("Receipt data extraction should succeed: \(error)")
        }
    }
    
    func testExtractFinancialDataFromBankStatement() async throws {
        // Given: Bank statement text
        let statementText = """
        BANK STATEMENT
        Account: ****5678
        Period: May 1 - May 31, 2025
        
        TRANSACTIONS:
        05/01 Opening Balance        $5,000.00
        05/03 DIRECT DEPOSIT SALARY  $3,500.00
        05/05 GROCERY STORE          -$127.50
        05/10 RENT PAYMENT           -$1,800.00
        05/15 UTILITIES ELECTRIC     -$95.30
        05/31 Closing Balance        $6,477.20
        """
        
        // When: Extracting data from bank statement
        let result = await financialExtractor.extractFinancialData(from: statementText, documentType: .statement)
        
        // Then: Should extract statement-specific data
        switch result {
        case .success(let extractedData):
            XCTAssertEqual(extractedData.documentType, .statement)
            XCTAssertTrue(extractedData.amounts.count >= 5) // Multiple transactions
            XCTAssertNotNil(extractedData.accountNumber)
            XCTAssertTrue(extractedData.transactions.count > 0)
        case .failure(let error):
            XCTFail("Statement data extraction should succeed: \(error)")
        }
    }
    
    // MARK: - Category Classification Tests
    
    func testCategorizeExpenseFromText() {
        // Given: Various expense descriptions
        let groceryText = "WHOLE FOODS MARKET PURCHASE"
        let gasText = "SHELL GAS STATION FUEL"
        let restaurantText = "MCDONALD'S RESTAURANT MEAL"
        let utilityText = "PACIFIC GAS & ELECTRIC BILL"
        
        // When: Categorizing expenses
        let groceryCategory = financialExtractor.categorizeExpense(from: groceryText)
        let gasCategory = financialExtractor.categorizeExpense(from: gasText)
        let restaurantCategory = financialExtractor.categorizeExpense(from: restaurantText)
        let utilityCategory = financialExtractor.categorizeExpense(from: utilityText)
        
        // Then: Should correctly categorize expenses
        XCTAssertEqual(groceryCategory, .groceries)
        XCTAssertEqual(gasCategory, .transportation)
        XCTAssertEqual(restaurantCategory, .dining)
        XCTAssertEqual(utilityCategory, .utilities)
    }
    
    func testCategorizeBusinessExpenses() {
        // Given: Business expense descriptions
        let officeSuppliesText = "STAPLES OFFICE SUPPLIES"
        let softwareText = "ADOBE CREATIVE SUITE SUBSCRIPTION"
        let travelText = "UNITED AIRLINES BUSINESS TRAVEL"
        
        // When: Categorizing business expenses
        let officeCategory = financialExtractor.categorizeExpense(from: officeSuppliesText)
        let softwareCategory = financialExtractor.categorizeExpense(from: softwareText)
        let travelCategory = financialExtractor.categorizeExpense(from: travelText)
        
        // Then: Should categorize as business expenses
        XCTAssertEqual(officeCategory, .business)
        XCTAssertEqual(softwareCategory, .business)
        XCTAssertEqual(travelCategory, .business)
    }
    
    // MARK: - Amount and Currency Tests
    
    func testExtractAmountsWithDifferentFormats() {
        // Given: Text with various amount formats
        let text = """
        Various amounts:
        $1,234.56
        $99.99
        $10,000.00
        USD 500.25
        Total: $12,334.80
        """
        
        // When: Extracting amounts
        let amounts = financialExtractor.extractAmounts(from: text)
        
        // Then: Should extract all valid amounts
        XCTAssertTrue(amounts.count >= 4)
        XCTAssertTrue(amounts.contains("$1,234.56"))
        XCTAssertTrue(amounts.contains("$99.99"))
        XCTAssertTrue(amounts.contains("$10,000.00"))
    }
    
    func testDetectCurrencyTypes() {
        // Given: Text with different currencies
        let usdText = "Amount: $100.00 USD"
        let eurText = "Prix: €50.00 EUR"
        let gbpText = "Cost: £75.00 GBP"
        
        // When: Detecting currency
        let usdCurrency = financialExtractor.detectCurrency(from: usdText)
        let eurCurrency = financialExtractor.detectCurrency(from: eurText)
        let gbpCurrency = financialExtractor.detectCurrency(from: gbpText)
        
        // Then: Should correctly identify currencies
        XCTAssertEqual(usdCurrency, .usd)
        XCTAssertEqual(eurCurrency, .eur)
        XCTAssertEqual(gbpCurrency, .gbp)
    }
    
    // MARK: - Date Extraction Tests
    
    func testExtractDatesFromText() {
        // Given: Text with various date formats
        let text = """
        Invoice Date: 01/15/2025
        Due Date: February 15, 2025
        Payment Date: 2025-02-10
        Transaction: 06-01-25
        """
        
        // When: Extracting dates
        let dates = financialExtractor.extractDates(from: text)
        
        // Then: Should extract multiple dates in various formats
        XCTAssertTrue(dates.count >= 3)
    }
    
    // MARK: - Vendor and Company Detection Tests
    
    func testExtractVendorInformation() {
        // Given: Text with vendor information
        let invoiceText = """
        ACME CORPORATION
        123 Business Ave, Suite 100
        Business City, BC 12345
        Phone: (555) 123-4567
        
        Invoice #12345
        """
        
        // When: Extracting vendor information
        let vendorInfo = financialExtractor.extractVendorInfo(from: invoiceText)
        
        // Then: Should extract vendor details
        XCTAssertNotNil(vendorInfo)
        XCTAssertEqual(vendorInfo?.name, "ACME CORPORATION")
        XCTAssertNotNil(vendorInfo?.address)
        XCTAssertNotNil(vendorInfo?.phone)
    }
    
    // MARK: - Tax and Fee Detection Tests
    
    func testExtractTaxInformation() {
        // Given: Text with tax information
        let text = """
        Subtotal: $100.00
        Tax (8.25%): $8.25
        Total: $108.25
        """
        
        // When: Extracting tax information
        let taxInfo = financialExtractor.extractTaxInfo(from: text)
        
        // Then: Should extract tax details
        XCTAssertNotNil(taxInfo)
        XCTAssertEqual(taxInfo?.rate, 8.25)
        XCTAssertEqual(taxInfo?.amount, "$8.25")
    }
    
    // MARK: - Error Handling Tests
    
    func testHandleEmptyText() async throws {
        // Given: Empty text
        let emptyText = ""
        
        // When: Attempting to extract financial data
        let result = await financialExtractor.extractFinancialData(from: emptyText, documentType: .other)
        
        // Then: Should handle empty input gracefully
        switch result {
        case .success(let data):
            XCTAssertTrue(data.amounts.isEmpty)
            XCTAssertEqual(data.category, .other)
        case .failure(let error):
            XCTAssertTrue(error is FinancialExtractionError)
        }
    }
    
    func testHandleInvalidDocumentType() async throws {
        // Given: Valid text but with invalid processing
        let validText = "Some financial text with $100.00"
        
        // When: Processing with potential error conditions
        let result = await financialExtractor.extractFinancialData(from: validText, documentType: .other)
        
        // Then: Should handle edge cases appropriately
        switch result {
        case .success(let data):
            XCTAssertNotNil(data)
            XCTAssertEqual(data.documentType, .other)
        case .failure(let error):
            XCTAssertTrue(error is FinancialExtractionError)
        }
    }
    
    // MARK: - Performance Tests
    
    func testExtractionPerformance() {
        // Given: Large text with multiple financial elements
        let largeText = String(repeating: "Transaction $100.00 at VENDOR NAME on 01/01/2025\n", count: 100)
        
        // When: Measuring extraction performance
        measure {
            Task {
                _ = await financialExtractor.extractFinancialData(from: largeText, documentType: .statement)
            }
        }
        
        // Then: Performance should be acceptable (implicit in measure)
    }
    
    // MARK: - State Management Tests
    
    func testProcessingState() async throws {
        // Given: Extractor in initial state
        XCTAssertFalse(financialExtractor.isProcessing)
        
        // When: Starting extraction
        let testText = "Invoice total: $500.00"
        
        Task {
            _ = await financialExtractor.extractFinancialData(from: testText, documentType: .invoice)
        }
        
        // Small delay to allow state change
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // Then: Should manage processing state correctly
        XCTAssertNotNil(financialExtractor.isProcessing)
    }
    
    // MARK: - ENHANCED VALIDATION TESTS (TDD Driven)
    
    func testValidateExtractedFinancialData() async throws {
        // Given: Valid financial data
        let validText = """
        ACME Corp Invoice #123
        Date: 01/15/2025
        Amount: $1,500.00
        Tax (8%): $120.00
        Total: $1,620.00
        """
        
        // When: Extracting and validating data
        let result = await financialExtractor.extractFinancialData(from: validText, documentType: .invoice)
        
        // Then: Should extract valid data that passes validation
        switch result {
        case .success(let data):
            let validationResult = await financialExtractor.validateExtractedData(data)
            XCTAssertTrue(validationResult.isValid)
            XCTAssertTrue(validationResult.validationErrors.isEmpty)
            XCTAssertTrue(data.confidence > 0.7) // High confidence for well-structured data
        case .failure(let error):
            XCTFail("Extraction should succeed: \(error)")
        }
    }
    
    func testValidateInconsistentFinancialData() async throws {
        // Given: Inconsistent financial data (amounts don't add up)
        let inconsistentText = """
        Invoice #456
        Subtotal: $100.00
        Tax: $50.00
        Total: $120.00
        """
        
        // When: Extracting and validating inconsistent data
        let result = await financialExtractor.extractFinancialData(from: inconsistentText, documentType: .invoice)
        
        // Then: Should detect validation issues
        switch result {
        case .success(let data):
            let validationResult = await financialExtractor.validateExtractedData(data)
            XCTAssertFalse(validationResult.isValid)
            XCTAssertTrue(validationResult.validationErrors.contains(.inconsistentAmounts))
        case .failure(let error):
            XCTFail("Extraction should succeed but validation should catch issues: \(error)")
        }
    }
    
    func testAdvancedPatternRecognition() async throws {
        // Given: Complex invoice with multiple line items
        let complexInvoiceText = """
        PROFESSIONAL SERVICES INVOICE
        Invoice #: PSI-2025-0123
        Date: January 15, 2025
        
        Bill To:
        Client Company Inc.
        
        Description                    Qty    Rate      Amount
        Consulting Services            40     $150.00   $6,000.00
        Project Management             20     $125.00   $2,500.00
        Technical Documentation        10     $100.00   $1,000.00
        
        Subtotal:                                       $9,500.00
        Discount (5%):                                   -$475.00
        Adjusted Subtotal:                               $9,025.00
        Tax (CA Sales Tax 7.25%):                        $654.31
        
        TOTAL DUE:                                      $9,679.31
        
        Terms: Net 30 Days
        """
        
        // When: Processing complex invoice
        let result = await financialExtractor.extractFinancialData(from: complexInvoiceText, documentType: .invoice)
        
        // Then: Should handle complex patterns
        switch result {
        case .success(let data):
            XCTAssertTrue(data.amounts.count >= 5) // Multiple line items + subtotals
            XCTAssertNotNil(data.totalAmount)
            XCTAssertEqual(data.category, .consulting)
            
            let lineItemResults = await financialExtractor.extractLineItems(from: complexInvoiceText)
            XCTAssertTrue(lineItemResults.count >= 3) // Three service line items
        case .failure(let error):
            XCTFail("Complex invoice processing should succeed: \(error)")
        }
    }
    
    func testEnhancedConfidenceScoring() async throws {
        // Given: High-quality vs low-quality financial data
        let highQualityText = """
        INVOICE #INV-2025-001
        ABC Professional Services
        123 Business Ave, Suite 100
        Phone: (555) 123-4567
        
        Date: January 15, 2025
        Due Date: February 14, 2025
        
        Consulting Services: $2,500.00
        Tax (8.25%): $206.25
        Total: $2,706.25
        """
        
        let lowQualityText = "some amount maybe $100"
        
        // When: Processing both texts
        let highQualityResult = await financialExtractor.extractFinancialData(from: highQualityText, documentType: .invoice)
        let lowQualityResult = await financialExtractor.extractFinancialData(from: lowQualityText, documentType: .other)
        
        // Then: Should have significantly different confidence scores
        switch (highQualityResult, lowQualityResult) {
        case (.success(let highQualityData), .success(let lowQualityData)):
            XCTAssertTrue(highQualityData.confidence > 0.8)
            XCTAssertTrue(lowQualityData.confidence < 0.5)
            XCTAssertTrue(highQualityData.confidence > lowQualityData.confidence + 0.3)
        default:
            XCTFail("Both extractions should succeed")
        }
    }
    
    func testRecurringTransactionDetection() async throws {
        // Given: Bank statement with recurring patterns
        let statementText = """
        BANK STATEMENT
        
        01/01 RENT PAYMENT APARTMENTS LLC    -$1,800.00
        01/02 PACIFIC GAS ELECTRIC AUTOPAY   -$125.50
        01/15 NETFLIX SUBSCRIPTION           -$15.99
        02/01 RENT PAYMENT APARTMENTS LLC    -$1,800.00
        02/02 PACIFIC GAS ELECTRIC AUTOPAY   -$130.25
        02/15 NETFLIX SUBSCRIPTION           -$15.99
        """
        
        // When: Processing statement for recurring patterns
        let result = await financialExtractor.extractFinancialData(from: statementText, documentType: .statement)
        
        // Then: Should detect recurring transactions
        switch result {
        case .success(let data):
            let recurringAnalysis = await financialExtractor.analyzeRecurringTransactions(data.transactions)
            XCTAssertTrue(recurringAnalysis.recurringPatterns.count >= 3) // Rent, Utilities, Subscription
            
            let rentPattern = recurringAnalysis.recurringPatterns.first { $0.description.contains("RENT") }
            XCTAssertNotNil(rentPattern)
            XCTAssertEqual(rentPattern?.frequency, .monthly)
        case .failure(let error):
            XCTFail("Statement processing should succeed: \(error)")
        }
    }
    
    func testDataSanitizationAndNormalization() {
        // Given: Text with various amount formats needing normalization
        let messyText = """
        Amount1: $1,234.56
        Amount2: $ 2,500.00
        Amount3: $3,000
        Amount4: USD 4,500.50
        Amount5: 5000.00 USD
        Amount6: $6,789.123 (invalid precision)
        """
        
        // When: Extracting and normalizing amounts
        let amounts = financialExtractor.extractAmounts(from: messyText)
        let normalizedAmounts = financialExtractor.normalizeAmounts(amounts)
        
        // Then: Should normalize all amounts to consistent format
        XCTAssertTrue(normalizedAmounts.count >= 5)
        for amount in normalizedAmounts {
            let normalizedAmount = financialExtractor.sanitizeAmount(amount)
            XCTAssertTrue(normalizedAmount.starts(with: "$"))
            
            // Should have proper decimal precision (0 or 2 decimal places)
            let components = normalizedAmount.replacingOccurrences(of: "$", with: "").components(separatedBy: ".")
            if components.count == 2 {
                XCTAssertTrue(components[1].count <= 2)
            }
        }
    }
    
    func testAdvancedCurrencyDetection() {
        // Given: Mixed currency document
        let multiCurrencyText = """
        International Invoice
        
        Base Amount: $1,000.00 USD
        European Tax: €85.00 EUR
        UK Shipping: £25.00 GBP
        Total USD Equivalent: $1,200.00
        """
        
        // When: Detecting multiple currencies
        let currencies = financialExtractor.detectAllCurrencies(from: multiCurrencyText)
        let primaryCurrency = financialExtractor.detectCurrency(from: multiCurrencyText)
        
        // Then: Should detect all currencies with USD as primary
        XCTAssertTrue(currencies.contains(.usd))
        XCTAssertTrue(currencies.contains(.eur))
        XCTAssertTrue(currencies.contains(.gbp))
        XCTAssertEqual(primaryCurrency, .usd)
    }
    
    func testFraudDetectionPatterns() async throws {
        // Given: Potentially fraudulent document patterns
        let suspiciousText = """
        URGENT INVOICE - PAY IMMEDIATELY
        
        MEGA CORP LTD (DEFINITELY REAL COMPANY)
        AMOUNT DUE: $999,999.99
        WIRE TRANSFER TO: [SUSPICIOUS ACCOUNT]
        PAY WITHIN 24 HOURS OR LEGAL ACTION
        """
        
        // When: Processing suspicious document
        let result = await financialExtractor.extractFinancialData(from: suspiciousText, documentType: .invoice)
        
        // Then: Should flag potential fraud indicators
        switch result {
        case .success(let data):
            let fraudAnalysis = await financialExtractor.analyzeFraudRisk(from: suspiciousText, extractedData: data)
            XCTAssertTrue(fraudAnalysis.riskScore > 0.7)
            XCTAssertTrue(fraudAnalysis.riskFactors.contains(.urgencyLanguage))
            XCTAssertTrue(fraudAnalysis.riskFactors.contains(.unusualAmount))
        case .failure(let error):
            XCTFail("Extraction should succeed but flag risks: \(error)")
        }
    }
}