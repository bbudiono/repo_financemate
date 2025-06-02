//
//  FinancialReportGeneratorTests.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Comprehensive TDD test suite for Financial Report Generator in Sandbox environment
* Issues & Complexity Summary: TDD approach ensuring robust report generation functionality
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: High
  - Dependencies: 4 New (XCTest, async testing, report generation, export validation)
  - State Management Complexity: Medium-High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
* Problem Estimate (Inherent Problem Difficulty %): 75%
* Initial Code Complexity Estimate %: 77%
* Justification for Estimates: Comprehensive testing of financial analytics and report generation
* Final Code Complexity (Actual %): TBD - TDD implementation
* Overall Result Score (Success & Quality %): TBD - TDD validation
* Key Variances/Learnings: TDD drives robust financial report generation with comprehensive validation
* Last Updated: 2025-06-02
*/

import XCTest
import Foundation
@testable import FinanceMate_Sandbox

@MainActor
final class FinancialReportGeneratorTests: XCTestCase {
    
    var reportGenerator: FinancialReportGenerator!
    var sampleFinancialData: [FinancialData] = []
    
    override func setUp() {
        super.setUp()
        reportGenerator = FinancialReportGenerator()
        sampleFinancialData = createSampleFinancialData()
    }
    
    override func tearDown() {
        reportGenerator = nil
        sampleFinancialData = []
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testFinancialReportGeneratorInitialization() {
        // Given/When: Generator is initialized
        let generator = FinancialReportGenerator()
        
        // Then: Should be properly initialized
        XCTAssertNotNil(generator)
        XCTAssertFalse(generator.isGenerating)
        XCTAssertTrue(generator.generatedReports.isEmpty)
        XCTAssertNotNil(generator.configuration)
    }
    
    // MARK: - Expense Report Tests
    
    func testGenerateExpenseReport() async throws {
        // Given: Sample financial data with expenses
        let expenseData = sampleFinancialData.filter { $0.category.rawValue.contains("Office") || $0.category.rawValue.contains("Travel") }
        
        // When: Generating expense report
        let report = await reportGenerator.generateExpenseReport(from: expenseData, period: .monthly)
        
        // Then: Should create valid expense report
        XCTAssertNotNil(report)
        XCTAssertEqual(report.reportType, .expenses)
        XCTAssertEqual(report.period, .monthly)
        XCTAssertFalse(report.items.isEmpty)
        XCTAssertGreaterThan(report.totalAmount, 0)
        XCTAssertFalse(report.categoryBreakdown.isEmpty)
        XCTAssertEqual(reportGenerator.generatedReports.count, 1)
    }
    
    func testGenerateExpenseReportWithEmptyData() async throws {
        // Given: Empty financial data
        let emptyData: [FinancialData] = []
        
        // When: Generating expense report
        let report = await reportGenerator.generateExpenseReport(from: emptyData, period: .monthly)
        
        // Then: Should handle empty data gracefully
        XCTAssertNotNil(report)
        XCTAssertEqual(report.totalAmount, 0)
        XCTAssertTrue(report.items.isEmpty)
        XCTAssertTrue(report.categoryBreakdown.isEmpty)
    }
    
    // MARK: - Income Report Tests
    
    func testGenerateIncomeReport() async throws {
        // Given: Sample financial data with income
        let incomeData = sampleFinancialData.filter { $0.category.rawValue.contains("Consulting") }
        
        // When: Generating income report
        let report = await reportGenerator.generateIncomeReport(from: incomeData, period: .quarterly)
        
        // Then: Should create valid income report
        XCTAssertNotNil(report)
        XCTAssertEqual(report.reportType, .income)
        XCTAssertEqual(report.period, .quarterly)
        XCTAssertFalse(report.items.isEmpty)
        XCTAssertGreaterThan(report.totalAmount, 0)
        XCTAssertNotNil(report.analytics)
    }
    
    // MARK: - Tax Report Tests
    
    func testGenerateTaxReport() async throws {
        // Given: Sample financial data with tax-deductible expenses
        let taxData = sampleFinancialData.filter { 
            $0.category.rawValue.contains("Office") || 
            $0.category.rawValue.contains("Software") ||
            $0.category.rawValue.contains("Travel")
        }
        
        // When: Generating tax report
        let report = await reportGenerator.generateTaxReport(from: taxData, taxYear: 2025)
        
        // Then: Should create valid tax report
        XCTAssertNotNil(report)
        XCTAssertEqual(report.reportType, .tax)
        XCTAssertEqual(report.period, .yearly)
        XCTAssertFalse(report.deductions.isEmpty)
        XCTAssertGreaterThan(report.totalAmount, 0)
        
        // Verify tax deductions are calculated
        for deduction in report.deductions {
            XCTAssertGreaterThan(deduction.eligiblePercentage, 0)
            XCTAssertGreaterThanOrEqual(deduction.eligiblePercentage, 0.5)
            XCTAssertLessThanOrEqual(deduction.eligiblePercentage, 1.0)
        }
    }
    
    // MARK: - Analytics Tests
    
    func testCalculateMonthlyTrends() async throws {
        // Given: Financial data spanning multiple months
        let multiMonthData = createMultiMonthSampleData()
        
        // When: Calculating monthly trends
        let trends = await reportGenerator.calculateMonthlyTrends(from: multiMonthData)
        
        // Then: Should calculate valid trends
        XCTAssertFalse(trends.isEmpty)
        XCTAssertGreaterThan(trends.count, 1)
        
        for trend in trends {
            XCTAssertFalse(trend.month.isEmpty)
            XCTAssertGreaterThanOrEqual(trend.transactionCount, 0)
        }
    }
    
    func testAnalyzeCategoryBreakdown() async throws {
        // Given: Sample financial data with various categories
        let categorizedData = sampleFinancialData
        
        // When: Analyzing category breakdown
        let analysis = await reportGenerator.analyzeCategoryBreakdown(from: categorizedData)
        
        // Then: Should provide valid analysis
        XCTAssertNotNil(analysis)
        XCTAssertFalse(analysis.categories.isEmpty)
        XCTAssertGreaterThan(analysis.totalCategorized, 0)
        XCTAssertGreaterThanOrEqual(analysis.uncategorized, 0)
    }
    
    func testAnalyzeCashFlow() async throws {
        // Given: Mixed income and expense data
        let mixedData = createMixedIncomeExpenseData()
        
        // When: Analyzing cash flow
        let analysis = await reportGenerator.analyzeCashFlow(from: mixedData, period: .monthly)
        
        // Then: Should provide valid cash flow analysis
        XCTAssertNotNil(analysis)
        XCTAssertEqual(analysis.period, .monthly)
        XCTAssertGreaterThanOrEqual(analysis.totalInflows, 0)
        XCTAssertGreaterThanOrEqual(analysis.totalOutflows, 0)
        XCTAssertEqual(analysis.netCashFlow, analysis.totalInflows - analysis.totalOutflows)
    }
    
    // MARK: - Export Tests
    
    func testExportToPDF() async throws {
        // Given: A generated report
        let report = await reportGenerator.generateExpenseReport(from: sampleFinancialData, period: .monthly)
        
        // When: Exporting to PDF
        let pdfData = await reportGenerator.exportToPDF(report: report)
        
        // Then: Should generate valid PDF data
        XCTAssertFalse(pdfData.isEmpty)
        
        // Verify PDF contains report content
        if let pdfString = String(data: pdfData, encoding: .utf8) {
            XCTAssertTrue(pdfString.contains("FINANCIAL REPORT"))
            XCTAssertTrue(pdfString.contains(report.reportType.displayName))
        }
    }
    
    func testExportToCSV() async throws {
        // Given: A generated report with items
        let report = await reportGenerator.generateExpenseReport(from: sampleFinancialData, period: .monthly)
        
        // When: Exporting to CSV
        let csvContent = await reportGenerator.exportToCSV(report: report)
        
        // Then: Should generate valid CSV content
        XCTAssertFalse(csvContent.isEmpty)
        XCTAssertTrue(csvContent.contains("Date,Vendor,Category,Amount,Currency"))
        
        // Verify CSV contains report items
        let lines = csvContent.components(separatedBy: "\n")
        XCTAssertGreaterThan(lines.count, 1) // Header + at least one data row
    }
    
    // MARK: - Report Management Tests
    
    func testSaveAndRetrieveReport() async throws {
        // Given: A generated report
        let originalReport = await reportGenerator.generateExpenseReport(from: sampleFinancialData, period: .monthly)
        
        // When: Saving and retrieving report
        let savedId = await reportGenerator.saveReport(originalReport)
        let retrievedReport = await reportGenerator.getReport(by: savedId)
        
        // Then: Should save and retrieve correctly
        XCTAssertEqual(savedId, originalReport.reportId)
        XCTAssertNotNil(retrievedReport)
        XCTAssertEqual(retrievedReport?.reportId, originalReport.reportId)
        XCTAssertEqual(retrievedReport?.reportType, originalReport.reportType)
    }
    
    func testDeleteReport() async throws {
        // Given: A saved report
        let report = await reportGenerator.generateExpenseReport(from: sampleFinancialData, period: .monthly)
        let reportId = await reportGenerator.saveReport(report)
        
        // When: Deleting the report
        reportGenerator.deleteReport(by: reportId)
        
        // Then: Should remove the report
        let retrievedReport = await reportGenerator.getReport(by: reportId)
        XCTAssertNil(retrievedReport)
        XCTAssertFalse(reportGenerator.generatedReports.contains { $0.reportId == reportId })
    }
    
    func testGetGeneratedReports() async throws {
        // Given: Multiple generated reports
        let report1 = await reportGenerator.generateExpenseReport(from: sampleFinancialData, period: .monthly)
        let report2 = await reportGenerator.generateIncomeReport(from: sampleFinancialData, period: .quarterly)
        
        // When: Getting all generated reports
        let allReports = reportGenerator.getGeneratedReports()
        
        // Then: Should return all reports
        XCTAssertEqual(allReports.count, 2)
        XCTAssertTrue(allReports.contains { $0.reportId == report1.reportId })
        XCTAssertTrue(allReports.contains { $0.reportId == report2.reportId })
    }
    
    // MARK: - Configuration Tests
    
    func testConfigureSettings() {
        // Given: Default configuration
        let initialCurrency = reportGenerator.configuration.currency
        
        // When: Configuring new settings
        reportGenerator.configureSettings(currency: "EUR", dateFormat: "dd/MM/yyyy", includeCharts: false)
        
        // Then: Should update configuration
        XCTAssertEqual(reportGenerator.configuration.currency, "EUR")
        XCTAssertEqual(reportGenerator.configuration.dateFormat, "dd/MM/yyyy")
        XCTAssertFalse(reportGenerator.configuration.includeCharts)
        XCTAssertNotEqual(reportGenerator.configuration.currency, initialCurrency)
    }
    
    // MARK: - Performance Tests
    
    func testReportGenerationPerformance() {
        // Given: Large dataset
        let largeDataset = createLargeFinancialDataset(count: 1000)
        
        // When: Measuring report generation time
        measure {
            Task {
                _ = await reportGenerator.generateExpenseReport(from: largeDataset, period: .yearly)
            }
        }
        
        // Then: Performance should be within acceptable bounds (implicit in measure)
    }
    
    func testMultipleReportGenerationPerformance() async throws {
        // Given: Sample data
        let data = sampleFinancialData
        
        // When: Generating multiple reports with performance measurement
        let startTime = Date()
        
        _ = await reportGenerator.generateExpenseReport(from: data, period: .monthly)
        _ = await reportGenerator.generateIncomeReport(from: data, period: .monthly)
        _ = await reportGenerator.generateTaxReport(from: data, taxYear: 2025)
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Then: Performance should be acceptable for multiple reports (under 5 seconds)
        XCTAssertLessThan(duration, 5.0, "Multiple report generation should complete within 5 seconds")
    }
    
    // MARK: - Error Handling Tests
    
    func testReportGenerationWithInvalidData() async throws {
        // Given: Financial data with invalid amounts
        let invalidData = createInvalidFinancialData()
        
        // When: Generating report with invalid data
        let report = await reportGenerator.generateExpenseReport(from: invalidData, period: .monthly)
        
        // Then: Should handle invalid data gracefully
        XCTAssertNotNil(report)
        // Should filter out invalid entries or handle them appropriately
    }
    
    // MARK: - Integration Tests
    
    func testCompleteReportWorkflow() async throws {
        // Given: Sample financial data
        let data = sampleFinancialData
        
        // When: Executing complete workflow
        // 1. Generate report
        let report = await reportGenerator.generateExpenseReport(from: data, period: .monthly)
        
        // 2. Save report
        let savedId = await reportGenerator.saveReport(report)
        
        // 3. Export to multiple formats
        let pdfData = await reportGenerator.exportToPDF(report: report)
        let csvContent = await reportGenerator.exportToCSV(report: report)
        
        // 4. Retrieve saved report
        let retrievedReport = await reportGenerator.getReport(by: savedId)
        
        // Then: Complete workflow should succeed
        XCTAssertNotNil(report)
        XCTAssertEqual(savedId, report.reportId)
        XCTAssertFalse(pdfData.isEmpty)
        XCTAssertFalse(csvContent.isEmpty)
        XCTAssertNotNil(retrievedReport)
        XCTAssertEqual(retrievedReport?.reportId, report.reportId)
    }
    
    // MARK: - Helper Methods for Test Data
    
    private func createSampleFinancialData() -> [FinancialData] {
        return [
            FinancialData(
                documentType: .invoice,
                amounts: ["150.00"],
                totalAmount: "150.00",
                currency: .usd,
                category: .officeExpenses,
                vendor: "Office Supply Co",
                documentDate: "2025-06-02",
                accountNumber: nil,
                transactions: [],
                confidence: 0.95
            ),
            FinancialData(
                documentType: .receipt,
                amounts: ["299.99"],
                totalAmount: "299.99",
                currency: .usd,
                category: .software,
                vendor: "Software Solutions Inc",
                documentDate: "2025-06-01",
                accountNumber: nil,
                transactions: [],
                confidence: 0.92
            ),
            FinancialData(
                documentType: .invoice,
                amounts: ["750.00"],
                totalAmount: "750.00",
                currency: .usd,
                category: .travel,
                vendor: "Travel Agency",
                documentDate: "2025-05-31",
                accountNumber: nil,
                transactions: [],
                confidence: 0.88
            ),
            FinancialData(
                documentType: .invoice,
                amounts: ["2500.00"],
                totalAmount: "2500.00",
                currency: .usd,
                category: .consulting,
                vendor: "Consulting Client",
                documentDate: "2025-05-30",
                accountNumber: nil,
                transactions: [],
                confidence: 0.98
            )
        ]
    }
    
    private func createMultiMonthSampleData() -> [FinancialData] {
        return [
            FinancialData(
                documentType: .invoice,
                amounts: ["500.00"],
                totalAmount: "500.00",
                currency: .usd,
                category: .officeExpenses,
                vendor: "January Vendor",
                documentDate: "2025-04-02",
                accountNumber: nil,
                transactions: [],
                confidence: 0.9
            ),
            FinancialData(
                documentType: .receipt,
                amounts: ["300.00"],
                totalAmount: "300.00",
                currency: .usd,
                category: .software,
                vendor: "February Vendor",
                documentDate: "2025-05-02",
                accountNumber: nil,
                transactions: [],
                confidence: 0.85
            ),
            FinancialData(
                documentType: .invoice,
                amounts: ["800.00"],
                totalAmount: "800.00",
                currency: .usd,
                category: .travel,
                vendor: "March Vendor",
                documentDate: "2025-06-02",
                accountNumber: nil,
                transactions: [],
                confidence: 0.93
            )
        ]
    }
    
    private func createMixedIncomeExpenseData() -> [FinancialData] {
        return [
            // Income
            FinancialData(
                documentType: .invoice,
                amounts: ["5000.00"],
                totalAmount: "5000.00",
                currency: .usd,
                category: .consulting,
                vendor: "Client Payment",
                documentDate: "2025-06-02",
                accountNumber: nil,
                transactions: [],
                confidence: 0.98
            ),
            // Expenses
            FinancialData(
                documentType: .receipt,
                amounts: ["200.00"],
                totalAmount: "200.00",
                currency: .usd,
                category: .officeExpenses,
                vendor: "Office Supplies",
                documentDate: "2025-06-02",
                accountNumber: nil,
                transactions: [],
                confidence: 0.9
            ),
            FinancialData(
                documentType: .invoice,
                amounts: ["99.99"],
                totalAmount: "99.99",
                currency: .usd,
                category: .software,
                vendor: "Software License",
                documentDate: "2025-06-02",
                accountNumber: nil,
                transactions: [],
                confidence: 0.95
            )
        ]
    }
    
    private func createLargeFinancialDataset(count: Int) -> [FinancialData] {
        var dataset: [FinancialData] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for i in 0..<count {
            let amount = String(format: "%.2f", Double.random(in: 10...1000))
            let date = Date().addingTimeInterval(Double(-i * 86400))
            let data = FinancialData(
                documentType: .invoice,
                amounts: [amount],
                totalAmount: amount,
                currency: .usd,
                category: ExpenseCategory.allCases.randomElement() ?? .other,
                vendor: "Vendor \(i)",
                documentDate: dateFormatter.string(from: date),
                accountNumber: nil,
                transactions: [],
                confidence: Double.random(in: 0.7...0.99)
            )
            dataset.append(data)
        }
        
        return dataset
    }
    
    private func createInvalidFinancialData() -> [FinancialData] {
        return [
            FinancialData(
                documentType: .invoice,
                amounts: ["invalid_amount"],
                totalAmount: "invalid_amount",
                currency: .usd,
                category: .other,
                vendor: "",
                documentDate: "2025-06-02",
                accountNumber: nil,
                transactions: [],
                confidence: 0.5
            ),
            FinancialData(
                documentType: .receipt,
                amounts: ["-100.00"],
                totalAmount: "-100.00", // Negative expense
                currency: .usd,
                category: .officeExpenses,
                vendor: "Valid Vendor",
                documentDate: "2025-06-02",
                accountNumber: nil,
                transactions: [],
                confidence: 0.8
            )
        ]
    }
}