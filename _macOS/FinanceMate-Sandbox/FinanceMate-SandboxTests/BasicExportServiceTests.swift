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
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-04

import XCTest
import CoreData
@testable import FinanceMate_Sandbox

@MainActor
final class BasicExportServiceTests: XCTestCase {
    
    var exportService: BasicExportService!
    var testContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Setup in-memory Core Data stack for testing
        testContext = createInMemoryContext()
        exportService = BasicExportService()
    }
    
    override func tearDownWithError() throws {
        testContext = nil
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
        let testData = try createTestFinancialData()
        
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
        let emptyData: [FinancialData] = []
        
        // When: CSV export is attempted
        let csvContent = try exportService.exportFinancialData(emptyData, format: .csv)
        
        // Then: Header-only CSV should be generated
        XCTAssertEqual(csvContent, "Date,InvoiceNumber,VendorName,Amount,Currency\n")
    }
    
    func testFileExportWithValidData() throws {
        // Given: Valid financial data
        let testData = try createTestFinancialData()
        
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
            let fileContent = try String(contentsOf: fileURL)
            XCTAssertTrue(fileContent.contains("Date,InvoiceNumber,VendorName,Amount,Currency"))
            
            // Cleanup test file
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func testFileExportWithEmptyData() throws {
        // Given: Empty financial data
        let emptyData: [FinancialData] = []
        
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
        let testData = try createTestFinancialDataWithSpecialCharacters()
        
        // When: CSV export is performed
        let csvContent = try exportService.exportFinancialData(testData, format: .csv)
        
        // Then: Special characters should be properly escaped
        XCTAssertTrue(csvContent.contains("\""))  // Should contain quotes for escaping
        XCTAssertTrue(csvContent.contains("Test \"Vendor\" & Co."))
    }
    
    func testExportingStateTracking() throws {
        // Given: Financial data
        let testData = try createTestFinancialData()
        
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
    
    // MARK: - Helper Methods
    
    private func createInMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "DataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to create in-memory store: \(error)")
            }
        }
        
        return container.viewContext
    }
    
    private func createTestFinancialData() throws -> [FinancialData] {
        var testData: [FinancialData] = []
        
        for i in 1...3 {
            let data = FinancialData(context: testContext)
            data.id = UUID()
            data.invoiceNumber = "INV-00\(i)"
            data.vendorName = "Test Vendor \(i)"
            data.totalAmount = NSDecimalNumber(value: Double(i * 100))
            data.invoiceDate = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            data.currency = "USD"
            
            testData.append(data)
        }
        
        try testContext.save()
        return testData
    }
    
    private func createTestFinancialDataWithSpecialCharacters() throws -> [FinancialData] {
        let data = FinancialData(context: testContext)
        data.id = UUID()
        data.invoiceNumber = "INV-SPECIAL"
        data.vendorName = "Test \"Vendor\" & Co., Ltd."
        data.totalAmount = NSDecimalNumber(value: 250.50)
        data.invoiceDate = Date()
        data.currency = "USD"
        
        try testContext.save()
        return [data]
    }
}