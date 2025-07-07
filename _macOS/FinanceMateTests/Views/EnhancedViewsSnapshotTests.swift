import XCTest
import SwiftUI
import CoreData
@testable import FinanceMate

/**
 * EnhancedViewsSnapshotTests.swift
 * 
 * Purpose: Visual regression testing for enhanced existing views (TransactionsView, SettingsView, AddEditTransactionView)
 * Issues & Complexity Summary: Comprehensive UI validation for enhanced features and new capabilities
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~100
 *   - Core Algorithm Complexity: Medium (Enhanced UI states, new features)
 *   - Dependencies: 3 New (Enhanced ViewModels, New UI states, Line item integration)
 *   - State Management Complexity: High (Enhanced view states, new interactions)
 *   - Novelty/Uncertainty Factor: Medium (Enhanced existing components)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 87%
 * Initial Code Complexity Estimate: 88%
 * Final Code Complexity: 90%
 * Overall Result Score: 92%
 * Key Variances/Learnings: Enhanced views require testing of both legacy and new states
 * Last Updated: 2025-07-07
 */

@MainActor
class EnhancedViewsSnapshotTests: XCTestCase {
    
    var transactionsViewModel: TransactionsViewModel!
    var settingsViewModel: SettingsViewModel!
    var testContext: NSManagedObjectContext!
    var snapshotDirectory: URL!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize ViewModels
        transactionsViewModel = TransactionsViewModel(context: testContext)
        settingsViewModel = SettingsViewModel()
        
        // Set up snapshot directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        snapshotDirectory = documentsPath.appendingPathComponent("FinanceMate-Enhanced-Snapshots")
        
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        transactionsViewModel = nil
        settingsViewModel = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Enhanced TransactionsView Snapshot Tests
    
    /// Test TransactionsView with line item enhanced transactions
    func testTransactionsViewWithLineItems() async throws {
        // Create transactions with line items
        await createTransactionsWithLineItems()
        
        let transactionsView = TransactionsView(viewModel: transactionsViewModel)
        
        let testView = transactionsView
            .frame(width: 900, height: 700)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "TransactionsView_WithLineItems")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "TransactionsView_WithLineItems",
            testName: "Transactions View - With Line Items"
        )
    }
    
    /// Test TransactionsView with search and filtering
    func testTransactionsViewWithSearchAndFilter() async throws {
        await createDiverseTransactionsData()
        
        // Simulate search and filter state
        transactionsViewModel.searchText = "Business"
        transactionsViewModel.selectedCategory = "Business"
        
        let transactionsView = TransactionsView(viewModel: transactionsViewModel)
        
        let testView = transactionsView
            .frame(width: 900, height: 700)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "TransactionsView_SearchFilter")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "TransactionsView_SearchFilter",
            testName: "Transactions View - Search and Filter"
        )
    }
    
    /// Test TransactionsView empty state with enhanced messaging
    func testTransactionsViewEmptyStateEnhanced() async throws {
        // No data - test enhanced empty state
        let transactionsView = TransactionsView(viewModel: transactionsViewModel)
        
        let testView = transactionsView
            .frame(width: 900, height: 700)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "TransactionsView_EmptyEnhanced")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "TransactionsView_EmptyEnhanced",
            testName: "Transactions View - Enhanced Empty State"
        )
    }
    
    /// Test TransactionsView in dark mode with enhanced features
    func testTransactionsViewDarkModeEnhanced() async throws {
        await createTransactionsWithLineItems()
        
        let transactionsView = TransactionsView(viewModel: transactionsViewModel)
        
        let testView = transactionsView
            .frame(width: 900, height: 700)
            .background(Color(.windowBackgroundColor))
            .preferredColorScheme(.dark)
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "TransactionsView_DarkEnhanced")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "TransactionsView_DarkEnhanced",
            testName: "Transactions View - Dark Mode Enhanced"
        )
    }
    
    // MARK: - Enhanced AddEditTransactionView Snapshot Tests
    
    /// Test AddEditTransactionView with line items section visible
    func testAddEditTransactionViewWithLineItemsSection() async throws {
        // Create expense transaction to show line items section
        let expenseTransaction = TransactionData()
        expenseTransaction.amount = -500.0
        expenseTransaction.category = "Business Expense"
        expenseTransaction.note = "Test expense with line items"
        expenseTransaction.isExpense = true
        
        transactionsViewModel.newTransaction = expenseTransaction
        transactionsViewModel.isEditing = true
        
        let addEditView = AddEditTransactionView(viewModel: transactionsViewModel)
        
        let testView = addEditView
            .frame(width: 600, height: 800)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "AddEditTransactionView_LineItemsSection")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "AddEditTransactionView_LineItemsSection",
            testName: "Add/Edit Transaction - Line Items Section"
        )
    }
    
    /// Test AddEditTransactionView form validation states
    func testAddEditTransactionViewValidationStates() async throws {
        // Create transaction with validation issues
        let invalidTransaction = TransactionData()
        invalidTransaction.amount = 0.0 // Invalid amount
        invalidTransaction.category = "" // Empty category
        invalidTransaction.note = ""
        
        transactionsViewModel.newTransaction = invalidTransaction
        transactionsViewModel.isEditing = true
        
        let addEditView = AddEditTransactionView(viewModel: transactionsViewModel)
        
        let testView = addEditView
            .frame(width: 600, height: 700)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "AddEditTransactionView_ValidationStates")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "AddEditTransactionView_ValidationStates",
            testName: "Add/Edit Transaction - Validation States"
        )
    }
    
    /// Test AddEditTransactionView with Australian locale formatting
    func testAddEditTransactionViewAustralianLocale() async throws {
        let transaction = TransactionData()
        transaction.amount = 1234.56
        transaction.category = "Income"
        transaction.note = "Australian formatted transaction"
        
        transactionsViewModel.newTransaction = transaction
        transactionsViewModel.isEditing = true
        
        let addEditView = AddEditTransactionView(viewModel: transactionsViewModel)
        
        let testView = addEditView
            .frame(width: 600, height: 700)
            .background(Color(.windowBackgroundColor))
            .environment(\\.locale, Locale(identifier: "en_AU"))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "AddEditTransactionView_AustralianLocale")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "AddEditTransactionView_AustralianLocale",
            testName: "Add/Edit Transaction - Australian Locale"
        )
    }
    
    // MARK: - Enhanced SettingsView Snapshot Tests
    
    /// Test SettingsView with all enhanced options
    func testSettingsViewEnhancedOptions() async throws {
        let settingsView = SettingsView(viewModel: settingsViewModel)
        
        let testView = settingsView
            .frame(width: 500, height: 600)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "SettingsView_EnhancedOptions")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "SettingsView_EnhancedOptions",
            testName: "Settings View - Enhanced Options"
        )
    }
    
    /// Test SettingsView with different theme selections
    func testSettingsViewThemeSelections() async throws {
        // Test with Dark theme selected
        settingsViewModel.theme = "Dark"
        
        let settingsView = SettingsView(viewModel: settingsViewModel)
        
        let testView = settingsView
            .frame(width: 500, height: 600)
            .background(Color(.windowBackgroundColor))
            .preferredColorScheme(.dark)
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "SettingsView_DarkTheme")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "SettingsView_DarkTheme",
            testName: "Settings View - Dark Theme Selection"
        )
    }
    
    /// Test SettingsView with Australian currency settings
    func testSettingsViewAustralianCurrency() async throws {
        settingsViewModel.currency = "AUD"
        
        let settingsView = SettingsView(viewModel: settingsViewModel)
        
        let testView = settingsView
            .frame(width: 500, height: 600)
            .background(Color(.windowBackgroundColor))
            .environment(\\.locale, Locale(identifier: "en_AU"))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "SettingsView_AustralianCurrency")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "SettingsView_AustralianCurrency",
            testName: "Settings View - Australian Currency"
        )
    }
    
    // MARK: - Integration State Tests
    
    /// Test views with accessibility features enabled
    func testViewsWithAccessibilityFeatures() async throws {
        await createTransactionsWithLineItems()
        
        let transactionsView = TransactionsView(viewModel: transactionsViewModel)
        
        let testView = transactionsView
            .frame(width: 900, height: 700)
            .background(Color(.windowBackgroundColor))
            .environment(\\.accessibilityReduceMotion, true)
            .environment(\\.accessibilityDifferentiateWithoutColor, true)
            .environment(\\.accessibilityReduceTransparency, true)
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "TransactionsView_Accessibility")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "TransactionsView_Accessibility",
            testName: "Transactions View - Accessibility Features"
        )
    }
    
    /// Test views with glassmorphism effects in different states
    func testViewsGlassmorphismEffects() async throws {
        await createDiverseTransactionsData()
        
        let transactionsView = TransactionsView(viewModel: transactionsViewModel)
        
        let testView = ZStack {
            // Background with gradient to test glassmorphism
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            transactionsView
                .frame(width: 900, height: 700)
        }
        .frame(width: 900, height: 700)
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "TransactionsView_Glassmorphism")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "TransactionsView_Glassmorphism",
            testName: "Transactions View - Glassmorphism Effects"
        )
    }
    
    // MARK: - Test Data Creation
    
    /// Create transactions with line items for comprehensive testing
    private func createTransactionsWithLineItems() async {
        let transactionsData = [
            ("Business Revenue", 2500.0, "Income", false),
            ("Office Equipment", -800.0, "Business", true),
            ("Marketing Campaign", -1200.0, "Marketing", true),
            ("Consulting Fee", 1500.0, "Income", false)
        ]
        
        for (note, amount, category, hasLineItems) in transactionsData {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = amount
            transaction.date = Date().addingTimeInterval(Double.random(in: -604800...0)) // Last week
            transaction.category = category
            transaction.note = note
            transaction.createdAt = Date()
            
            if hasLineItems {
                await createLineItemsForTransaction(transaction)
            }
        }
        
        do {
            try testContext.save()
            await transactionsViewModel.fetchTransactions()
        } catch {
            XCTFail("Failed to create transactions with line items: \\(error)")
        }
    }
    
    /// Create diverse transaction data for search/filter testing
    private func createDiverseTransactionsData() async {
        let categories = ["Business", "Personal", "Investment", "Travel", "Education"]
        
        for i in 0..<15 {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: -2000...3000)
            transaction.date = Date().addingTimeInterval(Double(-i * 86400)) // Spread over days
            transaction.category = categories[i % categories.count]
            transaction.note = "\\(transaction.category) transaction #\\(i)"
            transaction.createdAt = Date()
        }
        
        do {
            try testContext.save()
            await transactionsViewModel.fetchTransactions()
        } catch {
            XCTFail("Failed to create diverse transaction data: \\(error)")
        }
    }
    
    /// Create line items for a transaction
    private func createLineItemsForTransaction(_ transaction: Transaction) async {
        let totalAmount = abs(transaction.amount)
        let lineItemsData = [
            ("Primary Component", 0.6),
            ("Secondary Component", 0.3),
            ("Miscellaneous", 0.1)
        ]
        
        for (description, percentage) in lineItemsData {
            let lineItem = LineItem(context: testContext)
            lineItem.id = UUID()
            lineItem.amount = totalAmount * percentage
            lineItem.itemDescription = description
            lineItem.transaction = transaction
            lineItem.createdAt = Date()
            
            // Add split allocation
            let split = SplitAllocation(context: testContext)
            split.id = UUID()
            split.percentage = 1.0 // 100% to single category for simplicity
            split.taxCategory = transaction.category
            split.lineItem = lineItem
            split.createdAt = Date()
        }
    }
    
    // MARK: - Snapshot Testing Implementation
    
    /// Take snapshot with enhanced UI component handling
    @MainActor
    private func takeSnapshot<Content: View>(of view: Content, named name: String) async throws -> NSImage {
        let hostingController = NSHostingController(rootView: view)
        
        // Set fixed size for consistent snapshots
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 900, height: 800)
        
        // Force layout
        hostingController.view.layoutSubtreeIfNeeded()
        
        // Wait for enhanced UI components to render
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        // Force another layout pass
        hostingController.view.layoutSubtreeIfNeeded()
        
        // Create bitmap representation
        guard let bitmapRep = hostingController.view.bitmapImageRepForCachingDisplay(in: hostingController.view.bounds) else {
            throw SnapshotError.failedToCreateBitmap
        }
        
        hostingController.view.cacheDisplay(in: hostingController.view.bounds, to: bitmapRep)
        
        // Create NSImage from bitmap
        let image = NSImage(size: hostingController.view.bounds.size)
        image.addRepresentation(bitmapRep)
        
        return image
    }
    
    /// Validate snapshot against reference image
    private func validateSnapshot(image: NSImage, referenceName: String, testName: String) async throws {
        let referenceImagePath = snapshotDirectory.appendingPathComponent("\\(referenceName)_reference.png")
        
        if FileManager.default.fileExists(atPath: referenceImagePath.path) {
            let referenceImage = try loadImage(from: referenceImagePath)
            let comparisonResult = compareImages(image, referenceImage)
            
            if !comparisonResult.isEqual {
                let failedSnapshotPath = snapshotDirectory.appendingPathComponent("\\(referenceName)_failed.png")
                try saveImage(image, to: failedSnapshotPath)
                
                XCTFail("\\(testName) snapshot test failed. Visual difference: \\(String(format: "%.2f", comparisonResult.difference * 100))%. Failed snapshot: \\(failedSnapshotPath.path)")
            } else {
                print("✅ \\(testName) snapshot test passed - matches reference image")
            }
        } else {
            try saveImage(image, to: referenceImagePath)
            print("📸 Reference snapshot saved for \\(testName) at: \\(referenceImagePath.path)")
        }
    }
    
    /// Load image from file
    private func loadImage(from url: URL) throws -> NSImage {
        guard let image = NSImage(contentsOf: url) else {
            throw SnapshotError.failedToLoadImage
        }
        return image
    }
    
    /// Save image to file
    private func saveImage(_ image: NSImage, to url: URL) throws {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            throw SnapshotError.failedToSaveImage
        }
        
        try pngData.write(to: url)
    }
    
    /// Compare two images for visual differences
    private func compareImages(_ image1: NSImage, _ image2: NSImage) -> ImageComparisonResult {
        guard let tiff1 = image1.tiffRepresentation,
              let tiff2 = image2.tiffRepresentation,
              let bitmap1 = NSBitmapImageRep(data: tiff1),
              let bitmap2 = NSBitmapImageRep(data: tiff2) else {
            return ImageComparisonResult(isEqual: false, difference: 1.0)
        }
        
        guard bitmap1.size == bitmap2.size else {
            return ImageComparisonResult(isEqual: false, difference: 1.0)
        }
        
        let width = Int(bitmap1.size.width)
        let height = Int(bitmap1.size.height)
        let totalPixels = width * height
        var differentPixels = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let color1 = bitmap1.colorAt(x: x, y: y)
                let color2 = bitmap2.colorAt(x: x, y: y)
                
                if !colorsAreEqual(color1, color2) {
                    differentPixels += 1
                }
            }
        }
        
        let difference = Double(differentPixels) / Double(totalPixels)
        let threshold = 0.02 // 2% tolerance for enhanced views
        
        return ImageComparisonResult(isEqual: difference <= threshold, difference: difference)
    }
    
    /// Helper to compare colors with tolerance
    private func colorsAreEqual(_ color1: NSColor?, _ color2: NSColor?) -> Bool {
        guard let c1 = color1, let c2 = color2 else { return false }
        
        let tolerance: CGFloat = 0.03 // 3% tolerance for enhanced views
        
        return abs(c1.redComponent - c2.redComponent) <= tolerance &&
               abs(c1.greenComponent - c2.greenComponent) <= tolerance &&
               abs(c1.blueComponent - c2.blueComponent) <= tolerance &&
               abs(c1.alphaComponent - c2.alphaComponent) <= tolerance
    }
    
    // MARK: - Supporting Types
    
    enum SnapshotError: Error {
        case failedToCreateBitmap
        case failedToLoadImage
        case failedToSaveImage
    }
    
    struct ImageComparisonResult {
        let isEqual: Bool
        let difference: Double
    }
}