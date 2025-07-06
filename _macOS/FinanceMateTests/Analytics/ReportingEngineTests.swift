//
// ReportingEngineTests.swift
// FinanceMateTests
//
// Comprehensive Reporting Engine Test Suite for Split Intelligence
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for ReportingEngine with tax-optimized report generation
 * Issues & Complexity Summary: Complex tax compliance, export formats, audit trails, scheduled reporting
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~400
   - Core Algorithm Complexity: Very High
   - Dependencies: AnalyticsEngine, export libraries (CSV/PDF), Core Data
   - State Management Complexity: High (report templates, scheduling, export states)
   - Novelty/Uncertainty Factor: High (Australian tax compliance, report templates)
 * AI Pre-Task Self-Assessment: 92%
 * Problem Estimate: 95%
 * Initial Code Complexity Estimate: 96%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

import XCTest
import CoreData
import PDFKit
@testable import FinanceMate

@MainActor
class ReportingEngineTests: XCTestCase {
    
    var reportingEngine: ReportingEngine!
    var analyticsEngine: AnalyticsEngine!
    var testContext: NSManagedObjectContext!
    var persistenceController: PersistenceController!
    var tempDirectory: URL!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory Core Data stack for testing
        persistenceController = PersistenceController(inMemory: true)
        testContext = persistenceController.container.viewContext
        
        // Initialize analytics engine
        analyticsEngine = AnalyticsEngine(context: testContext)
        
        // Initialize reporting engine
        reportingEngine = ReportingEngine(
            context: testContext,
            analyticsEngine: analyticsEngine
        )
        
        // Create temporary directory for export tests
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        // Create comprehensive test data
        try await createTestReportingData()
    }
    
    override func tearDown() async throws {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        
        reportingEngine = nil
        analyticsEngine = nil
        testContext = nil
        persistenceController = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Data Creation
    
    private func createTestReportingData() async throws {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Create diverse transaction data for comprehensive reporting
        for i in 0..<50 {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: 100...5000)
            transaction.date = calendar.date(byAdding: .day, value: -i * 2, to: currentDate)!
            transaction.category = ["Business", "Personal", "Investment", "Education", "Healthcare"][i % 5]
            transaction.note = "Test transaction for reporting \(i)"
            
            // Create line items with varied split patterns
            let lineItem1 = LineItem(context: testContext)
            lineItem1.id = UUID()
            lineItem1.amount = transaction.amount * 0.7
            lineItem1.itemDescription = "Primary item \(i)"
            lineItem1.transaction = transaction
            
            let lineItem2 = LineItem(context: testContext)
            lineItem2.id = UUID()
            lineItem2.amount = transaction.amount * 0.3
            lineItem2.itemDescription = "Secondary item \(i)"
            lineItem2.transaction = transaction
            
            // Create split allocations for tax reporting
            let split1 = SplitAllocation(context: testContext)
            split1.id = UUID()
            split1.percentage = 80.0
            split1.taxCategory = "Business"
            split1.lineItem = lineItem1
            
            let split2 = SplitAllocation(context: testContext)
            split2.id = UUID()
            split2.percentage = 20.0
            split2.taxCategory = "Personal"
            split2.lineItem = lineItem1
            
            let split3 = SplitAllocation(context: testContext)
            split3.id = UUID()
            split3.percentage = 100.0
            split3.taxCategory = transaction.category == "Business" ? "Business" : "Personal"
            split3.lineItem = lineItem2
        }
        
        try testContext.save()
    }
    
    // MARK: - Initialization Tests
    
    func testReportingEngineInitialization() {
        XCTAssertNotNil(reportingEngine, "ReportingEngine should initialize successfully")
        XCTAssertEqual(reportingEngine.context, testContext, "Context should be properly assigned")
        XCTAssertNotNil(reportingEngine.analyticsEngine, "Analytics engine should be assigned")
        XCTAssertFalse(reportingEngine.isGeneratingReport, "Should not be generating report initially")
    }
    
    func testSupportedReportTypes() {
        let supportedTypes = reportingEngine.supportedReportTypes
        XCTAssertTrue(supportedTypes.contains(.taxSummary), "Should support tax summary reports")
        XCTAssertTrue(supportedTypes.contains(.profitLoss), "Should support profit/loss reports")
        XCTAssertTrue(supportedTypes.contains(.auditTrail), "Should support audit trail reports")
        XCTAssertTrue(supportedTypes.contains(.categoryBreakdown), "Should support category breakdown reports")
        XCTAssertTrue(supportedTypes.contains(.scheduledSummary), "Should support scheduled summary reports")
    }
    
    // MARK: - Tax-Optimized Report Generation Tests
    
    func testGenerateTaxSummaryReport() async throws {
        // Test comprehensive tax summary report generation
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .month, value: -3, to: Date())!, duration: 3 * 30 * 24 * 60 * 60)
        
        let report = try await reportingEngine.generateTaxSummaryReport(for: dateRange)
        
        XCTAssertNotNil(report, "Tax summary report should be generated")
        XCTAssertEqual(report.reportType, .taxSummary, "Report type should be tax summary")
        XCTAssertGreaterThan(report.categoryTotals.count, 0, "Should have category totals")
        XCTAssertGreaterThan(report.deductibleExpenses, 0, "Should have deductible expenses")
        XCTAssertNotNil(report.gstClaimable, "Should calculate GST claimable amount")
        XCTAssertTrue(report.isAustralianCompliant, "Report should be Australian tax compliant")
        
        // Verify category breakdown accuracy
        let totalAllocated = report.categoryTotals.values.reduce(0, +)
        XCTAssertGreaterThan(totalAllocated, 0, "Total allocated amount should be positive")
    }
    
    func testGenerateProfitLossReport() async throws {
        // Test entity-specific profit/loss reporting with precise allocations
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, duration: 30 * 24 * 60 * 60)
        
        let report = try await reportingEngine.generateProfitLossReport(for: dateRange, entityFilter: "Business")
        
        XCTAssertNotNil(report, "Profit/loss report should be generated")
        XCTAssertEqual(report.reportType, .profitLoss, "Report type should be profit/loss")
        XCTAssertNotNil(report.revenue, "Should have revenue calculation")
        XCTAssertNotNil(report.expenses, "Should have expenses calculation")
        XCTAssertNotNil(report.netProfit, "Should have net profit calculation")
        XCTAssertTrue(report.allocations.count > 0, "Should have split allocations")
        
        // Verify calculation accuracy
        let calculatedNet = report.revenue - report.expenses
        XCTAssertEqual(report.netProfit, calculatedNet, accuracy: 0.01, "Net profit calculation should be accurate")
    }
    
    func testGenerateAuditTrailReport() async throws {
        // Test audit trail reporting for split allocation history
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .week, value: -2, to: Date())!, duration: 14 * 24 * 60 * 60)
        
        let report = try await reportingEngine.generateAuditTrailReport(for: dateRange)
        
        XCTAssertNotNil(report, "Audit trail report should be generated")
        XCTAssertEqual(report.reportType, .auditTrail, "Report type should be audit trail")
        XCTAssertGreaterThan(report.auditEntries.count, 0, "Should have audit entries")
        
        // Verify audit trail completeness
        for entry in report.auditEntries {
            XCTAssertNotNil(entry.transactionId, "Audit entry should reference transaction")
            XCTAssertNotNil(entry.timestamp, "Audit entry should have timestamp")
            XCTAssertFalse(entry.changeDescription.isEmpty, "Audit entry should have change description")
            XCTAssertNotNil(entry.splitAllocations, "Audit entry should have split allocations")
        }
    }
    
    func testGenerateCategoryBreakdownReport() async throws {
        // Test detailed category breakdown with split intelligence
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .month, value: -6, to: Date())!, duration: 6 * 30 * 24 * 60 * 60)
        
        let report = try await reportingEngine.generateCategoryBreakdownReport(for: dateRange)
        
        XCTAssertNotNil(report, "Category breakdown report should be generated")
        XCTAssertEqual(report.reportType, .categoryBreakdown, "Report type should be category breakdown")
        XCTAssertGreaterThan(report.categories.count, 0, "Should have categories")
        
        // Verify category accuracy
        for category in report.categories {
            XCTAssertGreaterThan(category.totalAmount, 0, "Category should have positive total")
            XCTAssertGreaterThan(category.transactionCount, 0, "Category should have transaction count")
            XCTAssertGreaterThanOrEqual(category.averageAmount, 0, "Category should have average amount")
            XCTAssertTrue(category.subcategories.count >= 0, "Category should have subcategories")
        }
    }
    
    // MARK: - Export Functionality Tests
    
    func testCSVExport() async throws {
        // Test CSV export functionality with Australian tax compliance
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, duration: 30 * 24 * 60 * 60)
        let report = try await reportingEngine.generateTaxSummaryReport(for: dateRange)
        
        let csvURL = tempDirectory.appendingPathComponent("tax_summary.csv")
        try await reportingEngine.exportToCSV(report: report, to: csvURL)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: csvURL.path), "CSV file should be created")
        
        // Verify CSV content
        let csvContent = try String(contentsOf: csvURL)
        XCTAssertTrue(csvContent.contains("Category"), "CSV should contain header")
        XCTAssertTrue(csvContent.contains("Amount"), "CSV should contain amount column")
        XCTAssertTrue(csvContent.contains("AUD"), "CSV should use Australian currency")
        XCTAssertTrue(csvContent.contains("Business"), "CSV should contain business category")
        
        // Verify CSV format compliance
        let lines = csvContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 1, "CSV should have header and data lines")
    }
    
    func testPDFExport() async throws {
        // Test PDF export functionality with professional formatting
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, duration: 30 * 24 * 60 * 60)
        let report = try await reportingEngine.generateProfitLossReport(for: dateRange, entityFilter: "Business")
        
        let pdfURL = tempDirectory.appendingPathComponent("profit_loss.pdf")
        try await reportingEngine.exportToPDF(report: report, to: pdfURL)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: pdfURL.path), "PDF file should be created")
        
        // Verify PDF content
        let pdfDocument = PDFDocument(url: pdfURL)
        XCTAssertNotNil(pdfDocument, "PDF should be readable")
        XCTAssertGreaterThan(pdfDocument!.pageCount, 0, "PDF should have pages")
        
        if let firstPage = pdfDocument?.page(at: 0) {
            let pageText = firstPage.string ?? ""
            XCTAssertTrue(pageText.contains("Profit"), "PDF should contain report content")
            XCTAssertTrue(pageText.contains("AUD"), "PDF should use Australian currency")
        }
    }
    
    func testExportWithAustralianTaxCompliance() async throws {
        // Test export with Australian tax compliance requirements
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .year, value: -1, to: Date())!, duration: 365 * 24 * 60 * 60)
        let report = try await reportingEngine.generateTaxSummaryReport(for: dateRange)
        
        let csvURL = tempDirectory.appendingPathComponent("ato_compliant.csv")
        try await reportingEngine.exportToCSV(report: report, to: csvURL, complianceMode: .australianTax)
        
        let csvContent = try String(contentsOf: csvURL)
        
        // Verify ATO compliance features
        XCTAssertTrue(csvContent.contains("ABN"), "Should include ABN field for business transactions")
        XCTAssertTrue(csvContent.contains("GST"), "Should include GST calculations")
        XCTAssertTrue(csvContent.contains("PAYG"), "Should include PAYG information if applicable")
        XCTAssertTrue(csvContent.contains("FBT"), "Should include FBT categories if applicable")
        
        // Verify date format compliance (dd/mm/yyyy)
        let datePattern = "\\d{2}/\\d{2}/\\d{4}"
        let dateRegex = try NSRegularExpression(pattern: datePattern)
        let dateMatches = dateRegex.numberOfMatches(in: csvContent, range: NSRange(csvContent.startIndex..., in: csvContent))
        XCTAssertGreaterThan(dateMatches, 0, "Should use Australian date format")
    }
    
    // MARK: - Report Template Tests
    
    func testCustomizableReportTemplates() async throws {
        // Test customizable report templates for different user personas
        let accountantTemplate = ReportTemplate.accountantTemplate()
        let businessOwnerTemplate = ReportTemplate.businessOwnerTemplate()
        let individualTemplate = ReportTemplate.individualTemplate()
        
        XCTAssertNotEqual(accountantTemplate.includedSections, businessOwnerTemplate.includedSections, "Templates should have different sections")
        XCTAssertTrue(accountantTemplate.includedSections.contains(.detailedAuditTrail), "Accountant template should include audit trail")
        XCTAssertTrue(businessOwnerTemplate.includedSections.contains(.profitLossAnalysis), "Business template should include P&L")
        XCTAssertTrue(individualTemplate.includedSections.contains(.personalExpenseSummary), "Individual template should include personal expenses")
        
        // Test template application
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, duration: 30 * 24 * 60 * 60)
        let customReport = try await reportingEngine.generateCustomReport(for: dateRange, template: accountantTemplate)
        
        XCTAssertNotNil(customReport, "Custom report should be generated")
        XCTAssertTrue(customReport.sections.contains(where: { $0.type == .detailedAuditTrail }), "Custom report should apply template")
    }
    
    func testReportTemplateCustomization() {
        // Test custom report template creation
        var customTemplate = ReportTemplate()
        customTemplate.name = "Custom Tax Advisor Template"
        customTemplate.includedSections = [.taxSummary, .categoryBreakdown, .auditTrail]
        customTemplate.formatting.currencySymbol = "AUD"
        customTemplate.formatting.dateFormat = "dd/MM/yyyy"
        customTemplate.formatting.includeGST = true
        
        XCTAssertEqual(customTemplate.name, "Custom Tax Advisor Template", "Template name should be set")
        XCTAssertEqual(customTemplate.includedSections.count, 3, "Template should have specified sections")
        XCTAssertTrue(customTemplate.formatting.includeGST, "Template should include GST calculations")
    }
    
    // MARK: - Report Scheduling Tests
    
    func testReportScheduling() async throws {
        // Test report scheduling and automated generation capabilities
        let schedule = ReportSchedule(
            reportType: .taxSummary,
            frequency: .monthly,
            dayOfMonth: 1,
            recipients: ["bernhardbudiono@gmail.com"],
            template: .accountantTemplate()
        )
        
        try reportingEngine.scheduleReport(schedule)
        
        let scheduledReports = reportingEngine.getScheduledReports()
        XCTAssertGreaterThan(scheduledReports.count, 0, "Should have scheduled reports")
        
        let scheduledReport = scheduledReports.first { $0.reportType == .taxSummary }
        XCTAssertNotNil(scheduledReport, "Should find scheduled tax summary report")
        XCTAssertEqual(scheduledReport?.frequency, .monthly, "Schedule frequency should match")
    }
    
    func testAutomatedReportGeneration() async throws {
        // Test automated report generation for scheduled reports
        let schedule = ReportSchedule(
            reportType: .categoryBreakdown,
            frequency: .weekly,
            dayOfMonth: nil,
            recipients: ["test@example.com"],
            template: .businessOwnerTemplate()
        )
        
        try reportingEngine.scheduleReport(schedule)
        
        // Simulate scheduled execution
        let generatedReports = try await reportingEngine.executeScheduledReports()
        
        XCTAssertGreaterThan(generatedReports.count, 0, "Should generate scheduled reports")
        
        let categoryReport = generatedReports.first { $0.reportType == .categoryBreakdown }
        XCTAssertNotNil(categoryReport, "Should generate category breakdown report")
    }
    
    // MARK: - Performance and Error Handling Tests
    
    func testReportGenerationPerformance() async throws {
        // Test performance with large datasets
        await createLargeReportingDataset(transactionCount: 1000)
        
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .year, value: -1, to: Date())!, duration: 365 * 24 * 60 * 60)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let report = try await reportingEngine.generateTaxSummaryReport(for: dateRange)
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertNotNil(report, "Should handle large dataset")
        XCTAssertLessThan(timeElapsed, 5.0, "Should complete within 5 seconds for 1000 transactions")
        XCTAssertGreaterThan(report.categoryTotals.count, 0, "Should process all data")
    }
    
    func testReportGenerationErrorHandling() async throws {
        // Test error handling for invalid date ranges and missing data
        let invalidDateRange = DateInterval(start: Date(), end: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        
        do {
            let _ = try await reportingEngine.generateTaxSummaryReport(for: invalidDateRange)
            XCTFail("Should throw error for invalid date range")
        } catch ReportingError.invalidDateRange {
            // Expected error
        } catch {
            XCTFail("Should throw specific error type")
        }
    }
    
    func testExportErrorHandling() async throws {
        // Test export error handling for invalid paths and permissions
        let report = try await reportingEngine.generateTaxSummaryReport(for: DateInterval(start: Calendar.current.date(byAdding: .week, value: -1, to: Date())!, duration: 7 * 24 * 60 * 60))
        
        let invalidURL = URL(fileURLWithPath: "/invalid/path/report.csv")
        
        do {
            try await reportingEngine.exportToCSV(report: report, to: invalidURL)
            XCTFail("Should throw error for invalid export path")
        } catch ReportingError.exportFailed {
            // Expected error
        } catch {
            XCTFail("Should throw specific error type")
        }
    }
    
    // MARK: - Data Accuracy and Integrity Tests
    
    func testReportDataAccuracy() async throws {
        // Test report data accuracy against raw data
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, duration: 30 * 24 * 60 * 60)
        
        // Get raw analytics data
        let analyticsData = try await analyticsEngine.aggregateSplitsByTaxCategory()
        
        // Generate report
        let report = try await reportingEngine.generateTaxSummaryReport(for: dateRange)
        
        // Verify consistency
        for (category, analyticsAmount) in analyticsData {
            let reportAmount = report.categoryTotals[category] ?? 0
            XCTAssertEqual(reportAmount, analyticsAmount, accuracy: 0.01, "Report should match analytics data for \(category)")
        }
    }
    
    func testSplitAllocationIntegrity() async throws {
        // Test split allocation integrity in reports
        let dateRange = DateInterval(start: Calendar.current.date(byAdding: .week, value: -1, to: Date())!, duration: 7 * 24 * 60 * 60)
        let report = try await reportingEngine.generateAuditTrailReport(for: dateRange)
        
        // Verify all split allocations sum to 100% for each transaction
        for entry in report.auditEntries {
            let totalPercentage = entry.splitAllocations.map(\.percentage).reduce(0, +)
            XCTAssertEqual(totalPercentage, 100.0, accuracy: 0.01, "Split allocations should sum to 100% for transaction \(entry.transactionId)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createLargeReportingDataset(transactionCount: Int) async {
        let calendar = Calendar.current
        let currentDate = Date()
        
        for i in 0..<transactionCount {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: 50...10000)
            transaction.date = calendar.date(byAdding: .day, value: -i, to: currentDate)!
            transaction.category = ["Business", "Personal", "Investment", "Education", "Healthcare", "Travel", "Entertainment"][i % 7]
            
            let lineItem = LineItem(context: testContext)
            lineItem.id = UUID()
            lineItem.amount = transaction.amount
            lineItem.transaction = transaction
            
            // Create varied split patterns
            if i % 4 == 0 {
                // Single category
                let split = SplitAllocation(context: testContext)
                split.id = UUID()
                split.percentage = 100.0
                split.taxCategory = transaction.category
                split.lineItem = lineItem
            } else {
                // Multiple splits
                let businessSplit = SplitAllocation(context: testContext)
                businessSplit.id = UUID()
                businessSplit.percentage = Double.random(in: 30...80)
                businessSplit.taxCategory = "Business"
                businessSplit.lineItem = lineItem
                
                let personalSplit = SplitAllocation(context: testContext)
                personalSplit.id = UUID()
                personalSplit.percentage = 100.0 - businessSplit.percentage
                personalSplit.taxCategory = "Personal"
                personalSplit.lineItem = lineItem
            }
        }
        
        try? testContext.save()
    }
}