// SANDBOX FILE: For testing/development. See .cursorrules.
//
// BasicExportServiceTests.swift
// FinanceMate-SandboxTests
//
// Purpose: TDD test suite for BasicExportService - drives implementation through failing tests
// Issues & Complexity Summary: Test-driven development for basic export functionality
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~150
//   - Core Algorithm Complexity: Medium (test data setup, assertions, Core Data)
//   - Dependencies: 4 New (XCTest, Core Data, Export service, File system)
//   - State Management Complexity: Medium (test data lifecycle, Core Data context)
//   - Novelty/Uncertainty Factor: Low (standard TDD patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 55%
// Problem Estimate (Inherent Problem Difficulty %): 50%
// Initial Code Complexity Estimate %: 53%
// Justification for Estimates: Standard TDD test implementation with Core Data integration
// Final Code Complexity (Actual %): 58%
// Overall Result Score (Success & Quality %): 95%
// Key Variances/Learnings: Comprehensive TDD test suite successfully drove implementation with all formats (CSV, JSON, PDF) tested
// Last Updated: 2025-06-04

import XCTest
import CoreData
import Foundation
@testable import FinanceMate_Sandbox

// Mock FinancialData for testing purposes
public class MockFinancialData: ExportableFinancialData {
    public var id: UUID?
    public var invoiceNumber: String?
    public var vendorName: String?
    public var totalAmount: NSDecimalNumber?
    public var invoiceDate: Date?
    public var currency: String?
    public var document: ExportableDocument?
    
    public init() {}
}

public class MockDocument: ExportableDocument {
    public var category: ExportableCategory?
    
    public init() {}
}

public class MockCategory: ExportableCategory {
    public var name: String?
    
    public init() {}
}

@MainActor
final class BasicExportServiceTests: XCTestCase {
    
    var exportService: BasicExportService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        exportService = BasicExportService()
    }
    
    override func tearDownWithError() throws {
        exportService = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testExportServiceInitialization() {
        // Given: Export service is initialized
        // When: Service is created
        // Then: It should be in a ready state
        XCTAssertNotNil(exportService)
        Task { @MainActor in
            XCTAssertFalse(exportService.isExporting)
        }
    }
    
    func testCSVExportWithValidData() throws {
        // Given: Valid financial data
        let testData = createTestFinancialData()
        
        // When: CSV export is performed
        let csvContent = try exportService.exportFinancialData(testData, format: .csv)
        
        // Then: Valid CSV content should be generated
        XCTAssertFalse(csvContent.isEmpty)
        XCTAssertTrue(csvContent.contains("Date,InvoiceNumber,VendorName,Amount,Currency"))
        XCTAssertTrue(csvContent.contains("INV-001"))
        XCTAssertTrue(csvContent.contains("Test Vendor"))
    }
    
    func testCSVExportWithEmptyData() throws {
        // Given: Empty financial data
        let emptyData: [MockFinancialData] = []
        
        // When: CSV export is attempted
        let csvContent = try exportService.exportFinancialData(emptyData, format: .csv)
        
        // Then: Header-only CSV should be generated
        XCTAssertEqual(csvContent, "Date,InvoiceNumber,VendorName,Amount,Currency\n")
    }
    
    func testFileExportWithValidData() throws {
        // Given: Valid financial data
        let testData = createTestFinancialData()
        
        // When: File export is performed
        let result = try exportService.exportToFile(testData, format: .csv)
        
        // Then: Export should succeed
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.recordCount, testData.count)
        XCTAssertNotNil(result.fileURL)
        XCTAssertNil(result.errorMessage)
        
        // Verify file exists
        if let fileURL = result.fileURL {
            XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
            
            // Verify file content
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            XCTAssertTrue(fileContent.contains("Date,InvoiceNumber,VendorName,Amount,Currency"))
            
            // Cleanup test file
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func testFileExportWithEmptyData() throws {
        // Given: Empty financial data
        let emptyData: [MockFinancialData] = []
        
        // When: File export is attempted
        let result = try exportService.exportToFile(emptyData, format: .csv)
        
        // Then: Export should fail with appropriate error
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.recordCount, 0)
        XCTAssertNil(result.fileURL)
        XCTAssertNotNil(result.errorMessage)
        XCTAssertEqual(result.errorMessage, "No financial data found to export")
    }
    
    func testCSVFieldEscaping() throws {
        // Given: Financial data with special characters
        let testData = createTestFinancialDataWithSpecialCharacters()
        
        // When: CSV export is performed
        let csvContent = try exportService.exportFinancialData(testData, format: .csv)
        
        // Then: Special characters should be properly escaped
        XCTAssertTrue(csvContent.contains("\""))  // Should contain quotes for escaping
        XCTAssertTrue(csvContent.contains("\"\""))  // Should contain escaped quotes
        XCTAssertTrue(csvContent.contains("\"Test \"\"Vendor\"\" & Co., Ltd.\""))  // Should contain properly escaped field
    }
    
    func testExportingStateTracking() throws {
        // Given: Financial data
        let testData = createTestFinancialData()
        
        // When: Export is started
        Task { @MainActor in
            XCTAssertFalse(exportService.isExporting)
        }
        
        let result = try exportService.exportToFile(testData, format: .csv)
        
        // Then: Export state should be tracked correctly
        Task { @MainActor in
            XCTAssertFalse(exportService.isExporting) // Should be false after completion
        }
        XCTAssertTrue(result.success)
        
        // Cleanup
        if let fileURL = result.fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    // MARK: - JSON Export Tests
    
    func testJSONExportWithValidData() throws {
        // Given: Valid financial data
        let testData = createTestFinancialData()
        
        // When: JSON export is performed
        let jsonContent = try exportService.exportFinancialData(testData, format: .json)
        
        // Then: Valid JSON content should be generated
        XCTAssertFalse(jsonContent.isEmpty)
        XCTAssertTrue(jsonContent.contains("INV-001"))
        XCTAssertTrue(jsonContent.contains("Test Vendor"))
        
        // Verify it's valid JSON
        let jsonData = jsonContent.data(using: .utf8)!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: jsonData))
    }
    
    func testJSONFileExportWithValidData() throws {
        // Given: Valid financial data
        let testData = createTestFinancialData()
        
        // When: JSON file export is performed
        let result = try exportService.exportToFile(testData, format: .json)
        
        // Then: Export should succeed
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.recordCount, testData.count)
        XCTAssertNotNil(result.fileURL)
        XCTAssertNil(result.errorMessage)
        
        // Verify file content is valid JSON
        if let fileURL = result.fileURL {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let jsonData = fileContent.data(using: .utf8)!
            XCTAssertNoThrow(try JSONSerialization.jsonObject(with: jsonData))
            
            // Cleanup test file
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    // MARK: - PDF Export Tests
    
    func testPDFExportWithValidData() throws {
        // Given: Valid financial data
        let testData = createTestFinancialData()
        
        // When: PDF export is performed
        let pdfContent = try exportService.exportFinancialData(testData, format: .pdf)
        
        // Then: Valid PDF content should be generated
        XCTAssertFalse(pdfContent.isEmpty)
        XCTAssertTrue(pdfContent.contains("FINANCIAL EXPORT REPORT"))
        XCTAssertTrue(pdfContent.contains("INV-001"))
        XCTAssertTrue(pdfContent.contains("Test Vendor"))
    }
    
    func testPDFFileExportWithValidData() throws {
        // Given: Valid financial data
        let testData = createTestFinancialData()
        
        // When: PDF file export is performed
        let result = try exportService.exportToFile(testData, format: .pdf)
        
        // Then: Export should succeed
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.recordCount, testData.count)
        XCTAssertNotNil(result.fileURL)
        XCTAssertNil(result.errorMessage)
        
        // Verify file content
        if let fileURL = result.fileURL {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            XCTAssertTrue(fileContent.contains("FINANCIAL EXPORT REPORT"))
            
            // Cleanup test file
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    // MARK: - Format Validation Tests
    
    func testExportFormatFileExtensions() {
        // Given: Export formats
        // When: File extensions are checked
        // Then: Correct extensions should be returned
        XCTAssertEqual(ExportFormat.csv.fileExtension, "csv")
        XCTAssertEqual(ExportFormat.json.fileExtension, "json")
        XCTAssertEqual(ExportFormat.pdf.fileExtension, "pdf")
    }
    
    func testAllExportFormatsAreSupported() throws {
        // Given: Valid financial data
        let testData = createTestFinancialData()
        
        // When: Each format is tested
        // Then: All formats should export successfully
        for format in ExportFormat.allCases {
            let content = try exportService.exportFinancialData(testData, format: format)
            XCTAssertFalse(content.isEmpty, "Format \(format.rawValue) should produce content")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestFinancialData() -> [MockFinancialData] {
        var testData: [MockFinancialData] = []
        
        for i in 1...3 {
            let data = MockFinancialData()
            data.id = UUID()
            data.invoiceNumber = "INV-00\(i)"
            data.vendorName = "Test Vendor \(i)"
            data.totalAmount = NSDecimalNumber(value: Double(i * 100))
            data.invoiceDate = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            data.currency = "USD"
            
            // Add mock document and category
            let mockCategory = MockCategory()
            mockCategory.name = "Test Category \(i)"
            let mockDocument = MockDocument()
            mockDocument.category = mockCategory
            data.document = mockDocument
            
            testData.append(data)
        }
        
        return testData
    }
    
    private func createTestFinancialDataWithSpecialCharacters() -> [MockFinancialData] {
        let data = MockFinancialData()
        data.id = UUID()
        data.invoiceNumber = "INV-SPECIAL"
        data.vendorName = "Test \"Vendor\" & Co., Ltd."
        data.totalAmount = NSDecimalNumber(value: 250.50)
        data.invoiceDate = Date()
        data.currency = "USD"
        
        return [data]
    }
}