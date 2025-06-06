// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  FinancialPatternMatchingServiceTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/6/25.
//

import XCTest
@testable import FinanceMate_Sandbox

class FinancialPatternMatchingServiceTests: XCTestCase {
    
    var service: FinancialPatternMatchingService!
    
    override func setUp() {
        super.setUp()
        service = FinancialPatternMatchingService()
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Amount Extraction Tests
    
    func testExtractAmountsBasicFormats() {
        let text = """
        Invoice Total: $1,234.56
        Subtotal: USD 1000.00
        Tax: 234.56 USD
        Discount: 50.00
        """
        
        let amounts = service.extractAmounts(from: text)
        
        XCTAssertEqual(amounts.count, 4, "Should extract 4 amounts")
        XCTAssertEqual(amounts[0].value, 1234.56, accuracy: 0.01, "Largest amount should be first")
        XCTAssertEqual(amounts[1].value, 1000.00, accuracy: 0.01, "Second largest amount")
        XCTAssertEqual(amounts[2].value, 234.56, accuracy: 0.01, "Third amount")
        XCTAssertEqual(amounts[3].value, 50.00, accuracy: 0.01, "Smallest amount")
    }
    
    func testExtractAmountsWithCommas() {
        let text = "Total: $12,345.67 and Subtotal: $10,000.00"
        
        let amounts = service.extractAmounts(from: text)
        
        XCTAssertEqual(amounts.count, 2, "Should extract 2 amounts")
        XCTAssertEqual(amounts[0].value, 12345.67, accuracy: 0.01, "Should handle comma-separated amounts")
        XCTAssertEqual(amounts[1].value, 10000.00, accuracy: 0.01, "Should handle comma-separated amounts")
    }
    
    func testParseAmountVariousFormats() {
        let testCases = [
            ("$1,234.56", 1234.56),
            ("USD 500.00", 500.00),
            ("750.25 USD", 750.25),
            ("1000", 1000.00),
            ("$50", 50.00)
        ]
        
        for (input, expected) in testCases {
            let amount = service.parseAmount(from: input)
            XCTAssertNotNil(amount, "Should parse amount from: \(input)")
            XCTAssertEqual(amount!.value, expected, accuracy: 0.01, "Should parse correct value from: \(input)")
        }
    }
    
    func testParseInvalidAmounts() {
        let invalidInputs = ["abc", "$", "USD", "", "not a number"]
        
        for input in invalidInputs {
            let amount = service.parseAmount(from: input)
            XCTAssertNil(amount, "Should not parse invalid amount: \(input)")
        }
    }
    
    // MARK: - Date Extraction Tests
    
    func testExtractDatesWithTypes() {
        let text = """
        Invoice Date: 2024-06-06
        Due Date: 2024-07-06
        Service Date: 2024-05-15
        Payment received on 2024-06-10
        """
        
        let dates = service.extractDates(from: text)
        
        XCTAssertGreaterThanOrEqual(dates.count, 3, "Should extract at least 3 dates")
        
        // Check for specific date types
        let hasInvoiceDate = dates.contains { $0.type == .invoiceDate }
        let hasDueDate = dates.contains { $0.type == .dueDate }
        let hasServiceDate = dates.contains { $0.type == .serviceDate }
        
        XCTAssertTrue(hasInvoiceDate, "Should identify invoice date")
        XCTAssertTrue(hasDueDate, "Should identify due date")
        XCTAssertTrue(hasServiceDate, "Should identify service date")
    }
    
    func testClassifyDateTypes() {
        let testCases = [
            ("Due Date: 2024-07-01", "Invoice due 2024-07-01", ExtractedDateType.dueDate),
            ("Invoice Date: 2024-06-01", "Invoice created 2024-06-01", ExtractedDateType.invoiceDate),
            ("Service Date: 2024-05-01", "Service provided 2024-05-01", ExtractedDateType.serviceDate),
            ("Payment on 2024-06-15", "Payment received", ExtractedDateType.paymentDate),
            ("2024-06-01", "Transaction occurred", ExtractedDateType.transactionDate)
        ]
        
        for (context, fullText, expectedType) in testCases {
            let dateType = service.classifyDateType(context: context, fullText: fullText)
            XCTAssertEqual(dateType, expectedType, "Should classify date type correctly for: \(context)")
        }
    }
    
    // MARK: - Vendor Extraction Tests
    
    func testExtractVendorsFromText() {
        let text = """
        FROM: ABC Company LLC
        123 Main Street
        Tax ID: 12-3456789
        
        VENDOR: XYZ Corp
        456 Oak Avenue
        """
        
        let vendors = service.extractVendors(from: text, documentType: .invoice)
        
        XCTAssertGreaterThanOrEqual(vendors.count, 1, "Should extract at least 1 vendor")
        
        let firstVendor = vendors.first!
        XCTAssertTrue(firstVendor.name.contains("ABC Company"), "Should extract vendor name")
    }
    
    func testExtractCustomerInfo() {
        let text = """
        Bill To: John Doe Company
        123 Customer Street
        City, State 12345
        """
        
        let customer = service.extractCustomer(from: text)
        
        XCTAssertNotNil(customer, "Should extract customer information")
        XCTAssertEqual(customer!.name, "John Doe Company", "Should extract correct customer name")
    }
    
    // MARK: - Document-Specific Pattern Tests
    
    func testExtractInvoiceNumber() {
        let testCases = [
            "Invoice: INV-12345",
            "INV #: ABC-789",
            "Invoice Number: 2024-001",
            "#INV-456-789"
        ]
        
        for text in testCases {
            let invoiceNumber = service.extractInvoiceNumber(from: text)
            XCTAssertNotNil(invoiceNumber, "Should extract invoice number from: \(text)")
            XCTAssertFalse(invoiceNumber!.isEmpty, "Invoice number should not be empty")
        }
    }
    
    func testExtractPaymentTerms() {
        let testCases = [
            ("Payment Terms: Net 30", "Net 30"),
            ("Terms: Due in 15 days", "Due in 15 days"),
            ("Net 45 days", "45"),
            ("Due in 30 days", "30")
        ]
        
        for (text, expectedTerm) in testCases {
            let terms = service.extractPaymentTerms(from: text)
            XCTAssertNotNil(terms, "Should extract payment terms from: \(text)")
            XCTAssertTrue(terms!.contains(expectedTerm), "Should contain expected term: \(expectedTerm)")
        }
    }
    
    func testExtractTaxInformation() {
        let text = """
        Subtotal: $1,000.00
        Tax (8.5%): $85.00
        Tax ID: 12-3456789
        Total: $1,085.00
        """
        
        let taxInfo = service.extractTaxInformation(from: text)
        
        XCTAssertNotNil(taxInfo.taxAmount, "Should extract tax amount")
        XCTAssertEqual(taxInfo.taxAmount!.value, 85.00, accuracy: 0.01, "Should extract correct tax amount")
        XCTAssertNotNil(taxInfo.taxRate, "Should extract tax rate")
        XCTAssertEqual(taxInfo.taxRate!, 8.5, accuracy: 0.01, "Should extract correct tax rate")
        XCTAssertNotNil(taxInfo.taxId, "Should extract tax ID")
    }
    
    func testExtractCurrency() {
        let testCases = [
            ("Total: EUR 500.00", "EUR"),
            ("GBP 250.50 charged", "GBP"),
            ("CAD 1000.00 invoice", "CAD"),
            ("Amount: USD 750.00", "USD")
        ]
        
        for (text, expectedCurrency) in testCases {
            let currency = service.extractCurrency(from: text)
            XCTAssertEqual(currency, expectedCurrency, "Should extract currency from: \(text)")
        }
    }
    
    // MARK: - Utility Method Tests
    
    func testFindSubTotal() {
        let amounts = [
            ExtractedAmount(value: 1085.00, currency: "USD", formattedString: "$1,085.00"),
            ExtractedAmount(value: 1000.00, currency: "USD", formattedString: "$1,000.00"),
            ExtractedAmount(value: 85.00, currency: "USD", formattedString: "$85.00")
        ]
        
        let subtotal = service.findSubTotal(in: amounts)
        
        XCTAssertNotNil(subtotal, "Should find subtotal")
        XCTAssertEqual(subtotal!.value, 1000.00, accuracy: 0.01, "Should identify subtotal as second largest amount")
    }
    
    func testExtractDiscountAmount() {
        let text = """
        Subtotal: $100.00
        Discount: $10.00
        Total: $90.00
        """
        
        let discount = service.extractDiscountAmount(from: text)
        
        XCTAssertNotNil(discount, "Should extract discount amount")
        XCTAssertEqual(discount!.value, 10.00, accuracy: 0.01, "Should extract correct discount amount")
    }
    
    // MARK: - Edge Cases and Error Handling Tests
    
    func testEmptyTextHandling() {
        let amounts = service.extractAmounts(from: "")
        let dates = service.extractDates(from: "")
        let vendors = service.extractVendors(from: "", documentType: .invoice)
        
        XCTAssertTrue(amounts.isEmpty, "Should return empty array for empty text")
        XCTAssertTrue(dates.isEmpty, "Should return empty array for empty text")
        XCTAssertTrue(vendors.isEmpty, "Should return empty array for empty text")
    }
    
    func testNoMatchesFound() {
        let text = "This text contains no financial information."
        
        let amounts = service.extractAmounts(from: text)
        let customer = service.extractCustomer(from: text)
        let invoiceNumber = service.extractInvoiceNumber(from: text)
        
        XCTAssertTrue(amounts.isEmpty, "Should return empty array when no amounts found")
        XCTAssertNil(customer, "Should return nil when no customer found")
        XCTAssertNil(invoiceNumber, "Should return nil when no invoice number found")
    }
    
    func testDuplicateAmountHandling() {
        let text = """
        Total: $100.00
        Amount: $100.00
        Final Total: $100.00
        """
        
        let amounts = service.extractAmounts(from: text)
        
        // Should remove duplicates and keep only unique values
        XCTAssertEqual(amounts.count, 1, "Should remove duplicate amounts")
        XCTAssertEqual(amounts[0].value, 100.00, accuracy: 0.01, "Should keep the unique amount")
    }
    
    func testDuplicateVendorHandling() {
        let text = """
        FROM: ABC Company
        VENDOR: ABC Company
        Bill From: ABC COMPANY
        """
        
        let vendors = service.extractVendors(from: text, documentType: .invoice)
        
        // Should remove duplicates based on normalized names
        XCTAssertEqual(vendors.count, 1, "Should remove duplicate vendors")
    }
    
    func testLargeTextPerformance() {
        // Create a large text with multiple amounts and patterns
        var largeText = ""
        for i in 1...1000 {
            largeText += "Invoice \(i): $\(i).00\n"
        }
        
        measure {
            let amounts = service.extractAmounts(from: largeText)
            XCTAssertEqual(amounts.count, 1000, "Should extract all amounts from large text")
        }
    }
    
    func testComplexFinancialDocument() {
        let complexText = """
        INVOICE #INV-2024-001
        Date: 2024-06-06
        Due Date: 2024-07-06
        
        FROM: ABC Consulting LLC
        123 Business Street
        Tax ID: 12-3456789
        
        Bill To: XYZ Corporation
        456 Client Avenue
        
        Services:
        Consulting Hours    40.0    $150.00    $6,000.00
        Travel Expenses     1.0     $500.00    $500.00
        
        Subtotal:                              $6,500.00
        Tax (8.25%):                           $536.25
        Discount:                              -$100.00
        Total:                                 $6,936.25
        
        Payment Terms: Net 30
        """
        
        let amounts = service.extractAmounts(from: complexText)
        let dates = service.extractDates(from: complexText)
        let vendors = service.extractVendors(from: complexText, documentType: .invoice)
        let customer = service.extractCustomer(from: complexText)
        let invoiceNumber = service.extractInvoiceNumber(from: complexText)
        let taxInfo = service.extractTaxInformation(from: complexText)
        let paymentTerms = service.extractPaymentTerms(from: complexText)
        
        // Verify all extractions work on complex document
        XCTAssertGreaterThan(amounts.count, 5, "Should extract multiple amounts")
        XCTAssertGreaterThan(dates.count, 1, "Should extract multiple dates")
        XCTAssertGreaterThan(vendors.count, 0, "Should extract vendor information")
        XCTAssertNotNil(customer, "Should extract customer information")
        XCTAssertNotNil(invoiceNumber, "Should extract invoice number")
        XCTAssertNotNil(taxInfo.taxAmount, "Should extract tax information")
        XCTAssertNotNil(paymentTerms, "Should extract payment terms")
        
        // Verify specific values
        XCTAssertTrue(invoiceNumber!.contains("INV-2024-001"), "Should extract correct invoice number")
        XCTAssertTrue(customer!.name.contains("XYZ Corporation"), "Should extract correct customer")
        XCTAssertTrue(paymentTerms!.contains("Net 30"), "Should extract correct payment terms")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceAmountExtraction() {
        let text = "Invoice Total: $1,234.56 Subtotal: $1,000.00 Tax: $234.56"
        
        measure {
            for _ in 0..<1000 {
                _ = service.extractAmounts(from: text)
            }
        }
    }
    
    func testPerformanceDateExtraction() {
        let text = "Invoice Date: 2024-06-06 Due Date: 2024-07-06 Service Date: 2024-05-15"
        
        measure {
            for _ in 0..<1000 {
                _ = service.extractDates(from: text)
            }
        }
    }
}