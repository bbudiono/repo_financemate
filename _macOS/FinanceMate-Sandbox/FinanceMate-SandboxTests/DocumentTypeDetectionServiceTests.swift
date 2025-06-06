// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  DocumentTypeDetectionServiceTests.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/6/25.
//

import XCTest
@testable import FinanceMate_Sandbox

class DocumentTypeDetectionServiceTests: XCTestCase {
    
    var service: DocumentTypeDetectionService!
    
    override func setUp() {
        super.setUp()
        service = DocumentTypeDetectionService()
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // MARK: - Filename Pattern Detection Tests
    
    func testDetectInvoiceFromFilename() {
        let testCases = [
            "invoice-123.pdf",
            "Invoice_ABC.jpg",
            "company-invoice.png",
            "inv-456.pdf",
            "INV_789.jpeg"
        ]
        
        for filename in testCases {
            let url = URL(fileURLWithPath: "/test/\(filename)")
            let result = service.detectDocumentType(from: url)
            XCTAssertEqual(result, .invoice, "Failed to detect invoice from filename: \(filename)")
        }
    }
    
    func testDetectReceiptFromFilename() {
        let testCases = [
            "receipt-store.jpg",
            "Receipt_123.png",
            "gas-receipt.pdf",
            "rcpt-456.heic"
        ]
        
        for filename in testCases {
            let url = URL(fileURLWithPath: "/test/\(filename)")
            let result = service.detectDocumentType(from: url)
            XCTAssertEqual(result, .receipt, "Failed to detect receipt from filename: \(filename)")
        }
    }
    
    func testDetectBankStatementFromFilename() {
        let testCases = [
            "bank-statement.pdf",
            "Statement_June.pdf",
            "chase-bank-stmt.pdf",
            "monthly-statement.pdf"
        ]
        
        for filename in testCases {
            let url = URL(fileURLWithPath: "/test/\(filename)")
            let result = service.detectDocumentType(from: url)
            XCTAssertEqual(result, .bankStatement, "Failed to detect bank statement from filename: \(filename)")
        }
    }
    
    func testDetectTaxDocumentFromFilename() {
        let testCases = [
            "tax-return-2024.pdf",
            "1099-misc.pdf",
            "w2-form.pdf",
            "W-2_2024.pdf"
        ]
        
        for filename in testCases {
            let url = URL(fileURLWithPath: "/test/\(filename)")
            let result = service.detectDocumentType(from: url)
            XCTAssertEqual(result, .taxDocument, "Failed to detect tax document from filename: \(filename)")
        }
    }
    
    func testDetectExpenseReportFromFilename() {
        let testCases = [
            "expense-report.pdf",
            "travel-expenses.pdf",
            "monthly-report.pdf"
        ]
        
        for filename in testCases {
            let url = URL(fileURLWithPath: "/test/\(filename)")
            let result = service.detectDocumentType(from: url)
            XCTAssertEqual(result, .expenseReport, "Failed to detect expense report from filename: \(filename)")
        }
    }
    
    // MARK: - File Extension Fallback Tests
    
    func testPDFExtensionFallback() {
        let url = URL(fileURLWithPath: "/test/unknown-document.pdf")
        let result = service.detectDocumentType(from: url)
        XCTAssertEqual(result, .invoice, "PDF files should default to invoice type")
    }
    
    func testImageExtensionFallback() {
        let imageExtensions = ["jpg", "jpeg", "png", "heic", "tiff"]
        
        for ext in imageExtensions {
            let url = URL(fileURLWithPath: "/test/unknown-document.\(ext)")
            let result = service.detectDocumentType(from: url)
            XCTAssertEqual(result, .receipt, "\(ext.uppercased()) files should default to receipt type")
        }
    }
    
    func testTextExtensionFallback() {
        let textExtensions = ["txt", "rtf"]
        
        for ext in textExtensions {
            let url = URL(fileURLWithPath: "/test/unknown-document.\(ext)")
            let result = service.detectDocumentType(from: url)
            XCTAssertEqual(result, .expenseReport, "\(ext.uppercased()) files should default to expense report type")
        }
    }
    
    func testUnknownExtensionFallback() {
        let url = URL(fileURLWithPath: "/test/unknown-document.xyz")
        let result = service.detectDocumentType(from: url)
        XCTAssertEqual(result, .unknown, "Unknown extensions should return unknown type")
    }
    
    // MARK: - Content-Based Detection Tests
    
    func testDetectInvoiceFromContent() {
        let invoiceContent = """
        INVOICE #12345
        Bill To: Customer Name
        Invoice Date: 2024-06-06
        Due Date: 2024-07-06
        
        Description     Qty    Amount
        Consulting      10     $1,000.00
        
        Subtotal:               $1,000.00
        Tax:                    $80.00
        Total:                  $1,080.00
        
        Payment Terms: Net 30
        """
        
        let result = service.detectDocumentTypeFromContent(text: invoiceContent)
        XCTAssertEqual(result, .invoice, "Should detect invoice from content")
    }
    
    func testDetectReceiptFromContent() {
        let receiptContent = """
        THANK YOU FOR YOUR PURCHASE
        
        Store Location: 123 Main St
        Date: 06/06/2024
        
        Items:
        Coffee          $4.50
        Sandwich        $8.99
        
        Subtotal:       $13.49
        Tax:            $1.08
        TOTAL PAID:     $14.57
        
        Credit Card: ****1234
        """
        
        let result = service.detectDocumentTypeFromContent(text: receiptContent)
        XCTAssertEqual(result, .receipt, "Should detect receipt from content")
    }
    
    func testDetectBankStatementFromContent() {
        let statementContent = """
        BANK STATEMENT
        Account Number: ****5678
        Statement Period: 05/01/2024 - 05/31/2024
        
        Beginning Balance:      $2,500.00
        
        Transactions:
        05/02  Deposit          $1,000.00
        05/05  Withdrawal       -$200.00
        05/10  Transfer         -$500.00
        
        Ending Balance:         $2,800.00
        """
        
        let result = service.detectDocumentTypeFromContent(text: statementContent)
        XCTAssertEqual(result, .bankStatement, "Should detect bank statement from content")
    }
    
    func testDetectTaxDocumentFromContent() {
        let taxContent = """
        Form W-2 Wage and Tax Statement
        Tax Year 2024
        
        Employer: ABC Company
        Employee: John Doe
        SSN: ***-**-1234
        
        Federal Income Tax Withheld: $5,000.00
        Social Security Tax: $3,000.00
        Medicare Tax: $700.00
        
        IRS Copy
        """
        
        let result = service.detectDocumentTypeFromContent(text: taxContent)
        XCTAssertEqual(result, .taxDocument, "Should detect tax document from content")
    }
    
    // MARK: - Document Type Support Tests
    
    func testSupportedDocumentTypes() {
        let supportedTypes: [ProcessedDocumentType] = [
            .invoice, .receipt, .bankStatement, .taxDocument, .expenseReport
        ]
        
        for type in supportedTypes {
            XCTAssertTrue(service.isDocumentTypeSupported(type), "\(type.rawValue) should be supported")
        }
    }
    
    func testUnsupportedDocumentTypes() {
        let unsupportedTypes: [ProcessedDocumentType] = [
            .contract, .unknown
        ]
        
        for type in unsupportedTypes {
            XCTAssertFalse(service.isDocumentTypeSupported(type), "\(type.rawValue) should not be supported")
        }
    }
    
    // MARK: - Confidence Level Tests
    
    func testHighConfidenceFilenames() {
        let highConfidenceNames = [
            "invoice-123.pdf",
            "receipt-store.jpg",
            "bank-statement.pdf",
            "tax-return.pdf"
        ]
        
        for filename in highConfidenceNames {
            let confidence = service.getDetectionConfidence(fileName: filename)
            XCTAssertGreaterThanOrEqual(confidence, 0.6, "High confidence filename should have confidence >= 0.6: \(filename)")
        }
    }
    
    func testMediumConfidenceFilenames() {
        let mediumConfidenceNames = [
            "inv-123.pdf",
            "rcpt-456.jpg",
            "stmt-789.pdf",
            "1099-form.pdf"
        ]
        
        for filename in mediumConfidenceNames {
            let confidence = service.getDetectionConfidence(fileName: filename)
            XCTAssertGreaterThanOrEqual(confidence, 0.4, "Medium confidence filename should have confidence >= 0.4: \(filename)")
            XCTAssertLessThan(confidence, 0.6, "Medium confidence filename should have confidence < 0.6: \(filename)")
        }
    }
    
    func testConfidenceWithContent() {
        let filename = "document.pdf"
        let content = "INVOICE #123 Total: $100.00 Date: 2024-06-06"
        
        let confidenceWithContent = service.getDetectionConfidence(fileName: filename, content: content)
        let confidenceWithoutContent = service.getDetectionConfidence(fileName: filename)
        
        XCTAssertGreaterThan(confidenceWithContent, confidenceWithoutContent, "Confidence should be higher with content")
    }
    
    // MARK: - Edge Cases Tests
    
    func testEmptyFilename() {
        let url = URL(fileURLWithPath: "/test/.pdf")
        let result = service.detectDocumentType(from: url)
        XCTAssertEqual(result, .invoice, "Empty filename with PDF extension should default to invoice")
    }
    
    func testCaseInsensitiveDetection() {
        let testCases = [
            ("INVOICE-123.PDF", ProcessedDocumentType.invoice),
            ("Receipt_Store.JPG", ProcessedDocumentType.receipt),
            ("STATEMENT.pdf", ProcessedDocumentType.bankStatement)
        ]
        
        for (filename, expectedType) in testCases {
            let url = URL(fileURLWithPath: "/test/\(filename)")
            let result = service.detectDocumentType(from: url)
            XCTAssertEqual(result, expectedType, "Case insensitive detection failed for: \(filename)")
        }
    }
    
    func testEmptyContent() {
        let result = service.detectDocumentTypeFromContent(text: "")
        XCTAssertEqual(result, .unknown, "Empty content should return unknown type")
    }
    
    func testPartialMatches() {
        let partialContent = "invoice"
        let result = service.detectDocumentTypeFromContent(text: partialContent)
        XCTAssertEqual(result, .invoice, "Should detect document type from minimal content")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceFilenameDetection() {
        let url = URL(fileURLWithPath: "/test/invoice-123.pdf")
        
        measure {
            for _ in 0..<1000 {
                _ = service.detectDocumentType(from: url)
            }
        }
    }
    
    func testPerformanceContentDetection() {
        let content = "INVOICE #12345 Total: $1,000.00 Due Date: 2024-07-06"
        
        measure {
            for _ in 0..<1000 {
                _ = service.detectDocumentTypeFromContent(text: content)
            }
        }
    }
}