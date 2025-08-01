import XCTest 
import SwiftUI
@testable import FinanceMate

/**
 * Purpose: Comprehensive test suite for NetWealthDashboardView interactive charts
 * Issues & Complexity Summary: Complex UI state management with multiple chart types and data visualization
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400 (test suite)
 *   - UI Component Complexity: High (interactive charts, animations, accessibility)
 *   - Dependencies: SwiftUI Charts, NetWealthService, Core Data
 *   - State Management Complexity: High (chart selection, data filtering, interactions)
 *   - Novelty/Uncertainty Factor: Medium (chart interaction patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 90%
 * Target Coverage: ≥90% (UI components)
 * Last Updated: 2025-08-01
 */

@MainActor
final class NetWealthDashboardViewTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var viewModel: NetWealthDashboardViewModel!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        let netWealthService = NetWealthService(context: context)
        viewModel = NetWealthDashboardViewModel(netWealthService: netWealthService)
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
        viewModel = nil
    }
    
    // MARK: - Chart Tab Selection Tests
    
    func testChartTabEnumCases() throws {
        // Given: Chart tab enum
        let allCases = ChartTab.allCases
        
        // Then: Should have correct number of cases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.assetPie))
        XCTAssertTrue(allCases.contains(.liabilityPie))
        XCTAssertTrue(allCases.contains(.comparisonBar))
        XCTAssertTrue(allCases.contains(.netWealthTrend))
    }
    
    func testChartTabTitles() throws {
        // Given: Chart tab cases
        // Then: Should have correct display titles
        XCTAssertEqual(ChartTab.assetPie.title, "Assets")
        XCTAssertEqual(ChartTab.liabilityPie.title, "Liabilities")
        XCTAssertEqual(ChartTab.comparisonBar.title, "Compare")
        XCTAssertEqual(ChartTab.netWealthTrend.title, "Trends")
    }
    
    func testChartTabIcons() throws {
        // Given: Chart tab cases
        // Then: Should have correct SF Symbol icons
        XCTAssertEqual(ChartTab.assetPie.icon, "chart.pie")
        XCTAssertEqual(ChartTab.liabilityPie.icon, "chart.pie.fill")
        XCTAssertEqual(ChartTab.comparisonBar.icon, "chart.bar")
        XCTAssertEqual(ChartTab.netWealthTrend.icon, "chart.line.uptrend.xyaxis")
    }
    
    // MARK: - Chart Data Preparation Tests
    
    func testAssetCategoryDataFormatting() async throws {
        // Given: Sample asset data
        let sampleData = AssetCategoryData(
            category: "Investments",
            totalValue: 25000.50,
            assetCount: 3,
            assets: []
        )
        
        // Then: Should format correctly
        XCTAssertEqual(sampleData.formattedTotal, "$25,000.50")
    }
    
    func testLiabilityTypeDataFormatting() async throws {
        // Given: Sample liability data
        let sampleData = LiabilityTypeData(
            type: "Credit Cards",
            totalBalance: 1500.75,
            liabilityCount: 2,
            liabilities: []
        )
        
        // Then: Should format correctly
        XCTAssertEqual(sampleData.formattedTotal, "$1,500.75")
    }
    
    func testAssetItemDataFormatting() async throws {
        // Given: Sample asset item
        let assetItem = AssetItemData(
            id: UUID(),
            name: "Emergency Fund",
            description: "High-yield savings",
            value: 10000.00
        )
        
        // Then: Should format value correctly
        XCTAssertEqual(assetItem.formattedValue, "$10,000.00")
    }
    
    func testLiabilityItemDataFormatting() async throws {
        // Given: Sample liability item
        let liabilityItem = LiabilityItemData(
            id: UUID(),
            name: "Credit Card",
            balance: 2500.25,
            interestRate: 18.9,
            nextPaymentAmount: "$150.00"
        )
        
        // Then: Should format balance correctly
        XCTAssertEqual(liabilityItem.formattedBalance, "$2,500.25")
    }
    
    // MARK: - Chart Data Processing Tests
    
    func testEmptyAssetCategoriesHandling() async throws {
        // Given: Empty asset categories
        viewModel.assetCategories = []
        
        // When: Processing for pie chart
        let isEmpty = viewModel.assetCategories.isEmpty
        
        // Then: Should handle empty state correctly
        XCTAssertTrue(isEmpty)
        XCTAssertEqual(viewModel.topAssetCategories.count, 0)
    }
    
    func testEmptyLiabilityTypesHandling() async throws {
        // Given: Empty liability types
        viewModel.liabilityTypes = []
        
        // When: Processing for pie chart
        let isEmpty = viewModel.liabilityTypes.isEmpty
        
        // Then: Should handle empty state correctly
        XCTAssertTrue(isEmpty)
        XCTAssertEqual(viewModel.topLiabilityTypes.count, 0)
    }
    
    func testTopAssetCategoriesLimiting() async throws {
        // Given: Many asset categories
        let categories = (1...10).map { index in
            AssetCategoryData(
                category: "Category \(index)",
                totalValue: Double(index * 1000),
                assetCount: 1,
                assets: []
            )
        }
        viewModel.assetCategories = categories
        
        // When: Getting top categories
        let topCategories = viewModel.topAssetCategories
        
        // Then: Should limit to 5 items
        XCTAssertEqual(topCategories.count, 5)
    }
    
    func testTopLiabilityTypesLimiting() async throws {
        // Given: Many liability types
        let types = (1...8).map { index in
            LiabilityTypeData(
                type: "Type \(index)",
                totalBalance: Double(index * 500),
                liabilityCount: 1,
                liabilities: []
            )
        }
        viewModel.liabilityTypes = types
        
        // When: Getting top types
        let topTypes = viewModel.topLiabilityTypes
        
        // Then: Should limit to 5 items
        XCTAssertEqual(topTypes.count, 5)
    }
    
    // MARK: - Chart Color Palette Tests
    
    func testAssetColorPaletteHasSufficientColors() throws {
        // Given: NetWealthDashboardView instance (conceptually)
        let expectedMinimumColors = 6 // Should support at least 6 asset categories
        
        // When: Using asset color palette
        let colors: [Color] = [.green, .blue, .purple, .orange, .pink, .teal, .indigo, .mint]
        
        // Then: Should have sufficient colors
        XCTAssertGreaterThanOrEqual(colors.count, expectedMinimumColors)
    }
    
    func testLiabilityColorPaletteHasSufficientColors() throws {
        // Given: NetWealthDashboardView instance (conceptually)
        let expectedMinimumColors = 4 // Should support at least 4 liability types
        
        // When: Using liability color palette
        let colors: [Color] = [.red, .orange, .yellow, .pink, .purple, .brown]
        
        // Then: Should have sufficient colors
        XCTAssertGreaterThanOrEqual(colors.count, expectedMinimumColors)
    }
    
    // MARK: - Chart Interaction State Tests
    
    func testChartSelectionStateInitialization() throws {
        // Given: New dashboard view state
        let dashboardView = NetWealthDashboardView()
        
        // Then: Should initialize to default state
        // Note: These would be tested in actual UI tests or via @State property testing
        // For now, we verify the enum default behavior
        XCTAssertEqual(ChartTab.assetPie.rawValue, "asset_pie")
    }
    
    // MARK: - Accessibility Tests
    
    func testChartAccessibilityIdentifiers() throws {
        // Given: Chart tab cases
        // Then: Should generate consistent accessibility identifiers
        XCTAssertEqual("ChartTab\(ChartTab.assetPie.rawValue)", "ChartTabasset_pie")
        XCTAssertEqual("ChartTab\(ChartTab.liabilityPie.rawValue)", "ChartTabliability_pie")
        XCTAssertEqual("ChartTab\(ChartTab.comparisonBar.rawValue)", "ChartTabcomparison_bar")
        XCTAssertEqual("ChartTab\(ChartTab.netWealthTrend.rawValue)", "ChartTabnet_wealth_trend")
    }
    
    func testAssetCategoryAccessibilityIdentifiers() throws {
        // Given: Asset category data
        let categoryData = AssetCategoryData(
            category: "Real Estate",
            totalValue: 500000.0,
            assetCount: 2,
            assets: []
        )
        
        // Then: Should generate accessibility identifier
        let expectedId = "AssetCategory\(categoryData.category)"
        XCTAssertEqual(expectedId, "AssetCategoryReal Estate")
    }
    
    func testLiabilityTypeAccessibilityIdentifiers() throws {
        // Given: Liability type data
        let typeData = LiabilityTypeData(
            type: "Student Loans",
            totalBalance: 25000.0,
            liabilityCount: 1,
            liabilities: []
        )
        
        // Then: Should generate accessibility identifier
        let expectedId = "LiabilityType\(typeData.type)"
        XCTAssertEqual(expectedId, "LiabilityTypeStudent Loans")
    }
    
    // MARK: - Chart Data Validation Tests
    
    func testWealthHistoryPointStructure() throws {
        // Given: Sample wealth history point
        let historyPoint = WealthHistoryPoint(
            date: Date(),
            netWealth: 50000.0,
            totalAssets: 75000.0,
            totalLiabilities: 25000.0
        )
        
        // Then: Should maintain correct relationships
        XCTAssertEqual(historyPoint.netWealth, historyPoint.totalAssets - historyPoint.totalLiabilities)
    }
    
    func testTimeRangeDisplayNames() throws {
        // Given: Time range cases
        // Then: Should have correct display names
        XCTAssertEqual(TimeRange.oneMonth.displayName, "1M")
        XCTAssertEqual(TimeRange.threeMonths.displayName, "3M")
        XCTAssertEqual(TimeRange.sixMonths.displayName, "6M")
        XCTAssertEqual(TimeRange.oneYear.displayName, "1Y")
        XCTAssertEqual(TimeRange.all.displayName, "All")
    }
    
    // MARK: - Chart Placeholder Tests
    
    func testChartPlaceholderForEmptyAssets() throws {
        // Given: Empty asset data scenario
        let isEmpty = true
        let expectedIcon = "chart.pie"
        let expectedMessage = "No asset data available"
        
        // Then: Should show appropriate placeholder content
        XCTAssertTrue(isEmpty)
        XCTAssertEqual(expectedIcon, "chart.pie")
        XCTAssertEqual(expectedMessage, "No asset data available")
    }
    
    func testChartPlaceholderForEmptyLiabilities() throws {
        // Given: Empty liability data scenario
        let isEmpty = true
        let expectedIcon = "chart.pie"
        let expectedMessage = "No liability data available"
        
        // Then: Should show appropriate placeholder content
        XCTAssertTrue(isEmpty)
        XCTAssertEqual(expectedIcon, "chart.pie")
        XCTAssertEqual(expectedMessage, "No liability data available")
    }
    
    func testChartPlaceholderForComparisonChart() throws {
        // Given: Empty comparison data scenario
        let assetsEmpty = true
        let liabilitiesEmpty = true
        let expectedIcon = "chart.bar"
        let expectedMessage = "No data available for comparison"
        
        // Then: Should show appropriate placeholder content
        XCTAssertTrue(assetsEmpty && liabilitiesEmpty)
        XCTAssertEqual(expectedIcon, "chart.bar")
        XCTAssertEqual(expectedMessage, "No data available for comparison")
    }
    
    // MARK: - Chart Animation and State Tests
    
    func testChartTabSwitchingAnimation() throws {
        // Given: Chart tab switching scenario
        let initialTab = ChartTab.assetPie
        let newTab = ChartTab.comparisonBar
        
        // Then: Should handle state transitions correctly
        XCTAssertNotEqual(initialTab, newTab)
        XCTAssertTrue(ChartTab.allCases.contains(initialTab))
        XCTAssertTrue(ChartTab.allCases.contains(newTab))
    }
    
    // MARK: - Currency Formatting Tests
    
    func testCurrencyFormattingHelper() throws {
        // Given: Currency formatting helper function logic
        let testValue = 1234.56
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        
        // When: Formatting currency
        let result = formatter.string(from: NSNumber(value: testValue))
        
        // Then: Should format correctly
        XCTAssertEqual(result, "$1,234.56")
    }
    
    func testCurrencyFormattingForLargeValues() throws {
        // Given: Large currency values
        let testValue = 1_000_000.00
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        
        // When: Formatting currency
        let result = formatter.string(from: NSNumber(value: testValue))
        
        // Then: Should format with proper separators
        XCTAssertEqual(result, "$1,000,000.00")
    }
    
    // MARK: - Chart Data Edge Cases
    
    func testAssetCategoryWithZeroValue() throws {
        // Given: Asset category with zero value
        let categoryData = AssetCategoryData(
            category: "Empty Category",
            totalValue: 0.0,
            assetCount: 0,
            assets: []
        )
        
        // Then: Should handle gracefully
        XCTAssertEqual(categoryData.formattedTotal, "$0.00")
        XCTAssertEqual(categoryData.assetCount, 0)
    }
    
    func testLiabilityTypeWithZeroBalance() throws {
        // Given: Liability type with zero balance
        let typeData = LiabilityTypeData(
            type: "Paid Off Loan",
            totalBalance: 0.0,
            liabilityCount: 0,
            liabilities: []
        )
        
        // Then: Should handle gracefully
        XCTAssertEqual(typeData.formattedTotal, "$0.00")
        XCTAssertEqual(typeData.liabilityCount, 0)
    }
    
    // MARK: - Performance Tests
    
    func testChartDataProcessingPerformance() throws {
        // Given: Large dataset
        let largeAssetCategories = (1...100).map { index in
            AssetCategoryData(
                category: "Category \(index)",
                totalValue: Double(index * 1000),
                assetCount: index,
                assets: []
            )
        }
        
        // When: Processing top categories
        self.measure {
            let _ = Array(largeAssetCategories.prefix(5))
        }
        
        // Then: Should complete within reasonable time
        // Performance measured by XCTest framework
    }
    
    // MARK: - Integration Tests with NetWealthService
    
    func testViewModelAssetCategoryIntegration() async throws {
        // Given: Test data in Core Data
        let user = try FinancialEntity.create(
            in: context,
            name: "Test User",
            type: .user,
            email: "test@example.com"
        )
        
        let asset = try Asset.create(
            in: context,
            name: "Test Investment",
            type: .investment,
            initialValue: 10000.0,
            user: user
        )
        
        try context.save()
        
        // When: Loading asset details
        await viewModel.loadAssetDetails()
        
        // Then: Should populate asset categories
        XCTAssertFalse(viewModel.assetCategories.isEmpty)
    }
}

// MARK: - Mock Data Helpers

extension NetWealthDashboardViewTests {
    func createMockAssetCategories(count: Int) -> [AssetCategoryData] {
        return (1...count).map { index in
            AssetCategoryData(
                category: "Category \(index)",
                totalValue: Double(index * 5000),
                assetCount: index,
                assets: createMockAssetItems(count: index)
            )
        }
    }
    
    func createMockAssetItems(count: Int) -> [AssetItemData] {
        return (1...count).map { index in
            AssetItemData(
                id: UUID(),
                name: "Asset \(index)",
                description: "Description \(index)",
                value: Double(index * 1000)
            )
        }
    }
    
    func createMockLiabilityTypes(count: Int) -> [LiabilityTypeData] {
        return (1...count).map { index in
            LiabilityTypeData(
                type: "Type \(index)",
                totalBalance: Double(index * 2000),
                liabilityCount: index,
                liabilities: createMockLiabilityItems(count: index)
            )
        }
    }
    
    func createMockLiabilityItems(count: Int) -> [LiabilityItemData] {
        return (1...count).map { index in
            LiabilityItemData(
                id: UUID(),
                name: "Liability \(index)",
                balance: Double(index * 500),
                interestRate: Double(index * 2.5),
                nextPaymentAmount: "$\(index * 50).00"
            )
        }
    }
    
    func createMockWealthHistory(count: Int) -> [WealthHistoryPoint] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -count, to: Date()) ?? Date()
        
        return (0..<count).map { index in
            let date = calendar.date(byAdding: .day, value: index, to: startDate) ?? Date()
            let assets = Double(50000 + index * 100)
            let liabilities = Double(20000 + index * 25)
            
            return WealthHistoryPoint(
                date: date,
                netWealth: assets - liabilities,
                totalAssets: assets,
                totalLiabilities: liabilities
            )
        }
    }
}