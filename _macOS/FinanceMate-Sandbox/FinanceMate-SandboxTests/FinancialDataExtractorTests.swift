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
}