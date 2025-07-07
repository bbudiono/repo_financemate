import XCTest
import SwiftUI
import CoreData
@testable import FinanceMate

/**
 * LineItemUISnapshotTests.swift
 * 
 * Purpose: Visual regression testing for Line Item UI components (LineItemEntryView and SplitAllocationView)
 * Issues & Complexity Summary: Advanced UI validation for line item entry and split allocation interfaces
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~150
 *   - Core Algorithm Complexity: High (Complex UI interactions, pie charts, real-time validation)
 *   - Dependencies: 4 New (LineItemViewModel, SplitAllocationViewModel, Custom pie chart, Form validation)
 *   - State Management Complexity: Very High (Form state, validation, pie chart interactions)
 *   - Novelty/Uncertainty Factor: High (Custom SwiftUI components, complex form validation)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 92%
 * Final Code Complexity: 94%
 * Overall Result Score: 96%
 * Key Variances/Learnings: Complex UI components require careful state management for consistent snapshots
 * Last Updated: 2025-07-07
 */

@MainActor
class LineItemUISnapshotTests: XCTestCase {
    
    var lineItemViewModel: LineItemViewModel!
    var splitAllocationViewModel: SplitAllocationViewModel!
    var testContext: NSManagedObjectContext!
    var testTransaction: Transaction!
    var snapshotDirectory: URL!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Create test transaction
        testTransaction = Transaction(context: testContext)
        testTransaction.id = UUID()
        testTransaction.amount = -500.0
        testTransaction.date = Date()
        testTransaction.category = "Business Expense"
        testTransaction.note = "Test expense for line item UI"
        testTransaction.createdAt = Date()
        
        try testContext.save()
        
        // Initialize ViewModels
        lineItemViewModel = LineItemViewModel(context: testContext)
        lineItemViewModel.setCurrentTransaction(testTransaction)
        
        splitAllocationViewModel = SplitAllocationViewModel(context: testContext)
        
        // Set up snapshot directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        snapshotDirectory = documentsPath.appendingPathComponent("FinanceMate-LineItem-Snapshots")
        
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        lineItemViewModel = nil
        splitAllocationViewModel = nil
        testTransaction = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - LineItemEntryView Snapshot Tests
    
    /// Test LineItemEntryView in default empty state
    func testLineItemEntryViewEmptyState() async throws {
        let lineItemEntryView = LineItemEntryView(
            viewModel: lineItemViewModel,
            transaction: testTransaction
        )
        
        let testView = lineItemEntryView
            .frame(width: 600, height: 400)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "LineItemEntryView_Empty")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "LineItemEntryView_Empty",
            testName: "Line Item Entry - Empty State"
        )
    }
    
    /// Test LineItemEntryView with data entered
    func testLineItemEntryViewWithData() async throws {
        // Pre-populate some line items
        await createTestLineItems()
        
        let lineItemEntryView = LineItemEntryView(
            viewModel: lineItemViewModel,
            transaction: testTransaction
        )
        
        let testView = lineItemEntryView
            .frame(width: 600, height: 500)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "LineItemEntryView_WithData")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "LineItemEntryView_WithData",
            testName: "Line Item Entry - With Data"
        )
    }
    
    /// Test LineItemEntryView in dark mode
    func testLineItemEntryViewDarkMode() async throws {
        await createTestLineItems()
        
        let lineItemEntryView = LineItemEntryView(
            viewModel: lineItemViewModel,
            transaction: testTransaction
        )
        
        let testView = lineItemEntryView
            .frame(width: 600, height: 500)
            .background(Color(.windowBackgroundColor))
            .preferredColorScheme(.dark)
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "LineItemEntryView_Dark")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "LineItemEntryView_Dark",
            testName: "Line Item Entry - Dark Mode"
        )
    }
    
    /// Test LineItemEntryView with validation errors
    func testLineItemEntryViewValidationErrors() async throws {
        // Create invalid data to trigger validation errors
        await createInvalidLineItems()
        
        let lineItemEntryView = LineItemEntryView(
            viewModel: lineItemViewModel,
            transaction: testTransaction
        )
        
        let testView = lineItemEntryView
            .frame(width: 600, height: 500)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "LineItemEntryView_ValidationErrors")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "LineItemEntryView_ValidationErrors",
            testName: "Line Item Entry - Validation Errors"
        )
    }
    
    // MARK: - SplitAllocationView Snapshot Tests
    
    /// Test SplitAllocationView in default state
    func testSplitAllocationViewDefaultState() async throws {
        // Create a test line item
        let lineItem = await createTestLineItem(amount: 300.0, description: "Test Split Item")
        splitAllocationViewModel.setCurrentLineItem(lineItem)
        
        let splitAllocationView = SplitAllocationView(viewModel: splitAllocationViewModel)
        
        let testView = splitAllocationView
            .frame(width: 700, height: 600)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "SplitAllocationView_Default")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "SplitAllocationView_Default",
            testName: "Split Allocation - Default State"
        )
    }
    
    /// Test SplitAllocationView with allocations configured
    func testSplitAllocationViewWithAllocations() async throws {
        let lineItem = await createTestLineItem(amount: 500.0, description: "Business Expense")
        await createTestSplitAllocations(for: lineItem)
        splitAllocationViewModel.setCurrentLineItem(lineItem)
        
        let splitAllocationView = SplitAllocationView(viewModel: splitAllocationViewModel)
        
        let testView = splitAllocationView
            .frame(width: 700, height: 650)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "SplitAllocationView_WithAllocations")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "SplitAllocationView_WithAllocations",
            testName: "Split Allocation - With Allocations"
        )
    }
    
    /// Test SplitAllocationView pie chart visualization
    func testSplitAllocationViewPieChart() async throws {
        let lineItem = await createTestLineItem(amount: 1000.0, description: "Large Business Expense")
        await createComplexSplitAllocations(for: lineItem)
        splitAllocationViewModel.setCurrentLineItem(lineItem)
        
        let splitAllocationView = SplitAllocationView(viewModel: splitAllocationViewModel)
        
        let testView = splitAllocationView
            .frame(width: 700, height: 700)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "SplitAllocationView_PieChart")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "SplitAllocationView_PieChart",
            testName: "Split Allocation - Pie Chart Visualization"
        )
    }
    
    /// Test SplitAllocationView in dark mode
    func testSplitAllocationViewDarkMode() async throws {
        let lineItem = await createTestLineItem(amount: 400.0, description: "Mixed Expense")
        await createTestSplitAllocations(for: lineItem)
        splitAllocationViewModel.setCurrentLineItem(lineItem)
        
        let splitAllocationView = SplitAllocationView(viewModel: splitAllocationViewModel)
        
        let testView = splitAllocationView
            .frame(width: 700, height: 650)
            .background(Color(.windowBackgroundColor))
            .preferredColorScheme(.dark)
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "SplitAllocationView_Dark")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "SplitAllocationView_Dark",
            testName: "Split Allocation - Dark Mode"
        )
    }
    
    /// Test SplitAllocationView with percentage validation errors
    func testSplitAllocationViewValidationErrors() async throws {
        let lineItem = await createTestLineItem(amount: 200.0, description: "Invalid Split Item")
        await createInvalidSplitAllocations(for: lineItem)
        splitAllocationViewModel.setCurrentLineItem(lineItem)
        
        let splitAllocationView = SplitAllocationView(viewModel: splitAllocationViewModel)
        
        let testView = splitAllocationView
            .frame(width: 700, height: 650)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "SplitAllocationView_ValidationErrors")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "SplitAllocationView_ValidationErrors",
            testName: "Split Allocation - Validation Errors"
        )
    }
    
    // MARK: - Test Data Creation
    
    /// Create test line items for the transaction
    private func createTestLineItems() async {
        let lineItemsData = [
            ("Office Supplies", 150.0),
            ("Software License", 200.0),
            ("Travel Expense", 150.0)
        ]
        
        for (description, amount) in lineItemsData {
            let lineItem = LineItem(context: testContext)
            lineItem.id = UUID()
            lineItem.amount = amount
            lineItem.itemDescription = description
            lineItem.transaction = testTransaction
            lineItem.createdAt = Date()
        }
        
        do {
            try testContext.save()
            await lineItemViewModel.fetchLineItems()
        } catch {
            XCTFail("Failed to create test line items: \\(error)")
        }
    }
    
    /// Create a single test line item
    @discardableResult
    private func createTestLineItem(amount: Double, description: String) async -> LineItem {
        let lineItem = LineItem(context: testContext)
        lineItem.id = UUID()
        lineItem.amount = amount
        lineItem.itemDescription = description
        lineItem.transaction = testTransaction
        lineItem.createdAt = Date()
        
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to create test line item: \\(error)")
        }
        
        return lineItem
    }
    
    /// Create test split allocations for a line item
    private func createTestSplitAllocations(for lineItem: LineItem) async {
        let allocations = [
            ("Business", 0.6),
            ("Personal", 0.4)
        ]
        
        for (category, percentage) in allocations {
            let split = SplitAllocation(context: testContext)
            split.id = UUID()
            split.percentage = percentage
            split.taxCategory = category
            split.lineItem = lineItem
            split.createdAt = Date()
        }
        
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to create test split allocations: \\(error)")
        }
    }
    
    /// Create complex split allocations for pie chart testing
    private func createComplexSplitAllocations(for lineItem: LineItem) async {
        let allocations = [
            ("Business", 0.5),
            ("Personal", 0.25),
            ("Investment", 0.15),
            ("Other", 0.1)
        ]
        
        for (category, percentage) in allocations {
            let split = SplitAllocation(context: testContext)
            split.id = UUID()
            split.percentage = percentage
            split.taxCategory = category
            split.lineItem = lineItem
            split.createdAt = Date()
        }
        
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to create complex split allocations: \\(error)")
        }
    }
    
    /// Create invalid line items to test validation
    private func createInvalidLineItems() async {
        // Create line items that exceed transaction amount
        let lineItem1 = LineItem(context: testContext)
        lineItem1.id = UUID()
        lineItem1.amount = 600.0 // Exceeds transaction amount of 500
        lineItem1.itemDescription = "Invalid Amount Item"
        lineItem1.transaction = testTransaction
        lineItem1.createdAt = Date()
        
        let lineItem2 = LineItem(context: testContext)
        lineItem2.id = UUID()
        lineItem2.amount = 0.0 // Zero amount
        lineItem2.itemDescription = "Zero Amount Item"
        lineItem2.transaction = testTransaction
        lineItem2.createdAt = Date()
        
        do {
            try testContext.save()
            await lineItemViewModel.fetchLineItems()
        } catch {
            XCTFail("Failed to create invalid line items: \\(error)")
        }
    }
    
    /// Create invalid split allocations to test validation
    private func createInvalidSplitAllocations(for lineItem: LineItem) async {
        // Create splits that don't add up to 100%
        let allocations = [
            ("Business", 0.8),
            ("Personal", 0.5) // Total = 130%
        ]
        
        for (category, percentage) in allocations {
            let split = SplitAllocation(context: testContext)
            split.id = UUID()
            split.percentage = percentage
            split.taxCategory = category
            split.lineItem = lineItem
            split.createdAt = Date()
        }
        
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to create invalid split allocations: \\(error)")
        }
    }
    
    // MARK: - Snapshot Testing Implementation
    
    /// Take snapshot with proper handling for complex UI components
    @MainActor
    private func takeSnapshot<Content: View>(of view: Content, named name: String) async throws -> NSImage {
        let hostingController = NSHostingController(rootView: view)
        
        // Set fixed size for consistent snapshots
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 700, height: 700)
        
        // Force layout
        hostingController.view.layoutSubtreeIfNeeded()
        
        // Additional wait for complex UI components to render
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
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
        let threshold = 0.02 // 2% tolerance for UI components
        
        return ImageComparisonResult(isEqual: difference <= threshold, difference: difference)
    }
    
    /// Helper to compare colors with tolerance
    private func colorsAreEqual(_ color1: NSColor?, _ color2: NSColor?) -> Bool {
        guard let c1 = color1, let c2 = color2 else { return false }
        
        let tolerance: CGFloat = 0.03 // 3% tolerance for UI components
        
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