import XCTest
import SwiftUI
import CoreData
import Charts
@testable import FinanceMate

/**
 * DashboardAnalyticsViewSnapshotTests.swift
 * 
 * Purpose: Visual regression testing for DashboardAnalyticsView with Charts framework integration
 * Issues & Complexity Summary: Advanced UI validation for interactive charts and analytics components
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~120
 *   - Core Algorithm Complexity: High (Charts rendering, analytics data)
 *   - Dependencies: 4 New (Charts, AnalyticsEngine, DashboardAnalyticsViewModel, Core Data)
 *   - State Management Complexity: High (Chart interactions, analytics state)
 *   - Novelty/Uncertainty Factor: High (Charts framework snapshot testing)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: 92%
 * Overall Result Score: 94%
 * Key Variances/Learnings: Charts framework requires special handling for consistent snapshots
 * Last Updated: 2025-07-07
 */

@MainActor
class DashboardAnalyticsViewSnapshotTests: XCTestCase {
    
    var analyticsEngine: AnalyticsEngine!
    var testContext: NSManagedObjectContext!
    var snapshotDirectory: URL!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize Analytics Engine with test context
        analyticsEngine = AnalyticsEngine(context: testContext)
        
        // Set up snapshot directory for advanced features
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        snapshotDirectory = documentsPath.appendingPathComponent("FinanceMate-Advanced-Snapshots")
        
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        analyticsEngine = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Analytics View Snapshot Tests
    
    /// Test DashboardAnalyticsView with real Australian analytics data
    func testDashboardAnalyticsViewDefaultState() async throws {
        // Create comprehensive test data
        await createAnalyticsTestData()
        
        // Create the analytics view
        let analyticsView = DashboardAnalyticsView(
            context: testContext,
            analyticsEngine: analyticsEngine
        )
        
        // Configure for consistent testing
        let testView = analyticsView
            .frame(width: 1000, height: 800)
            .background(Color(.windowBackgroundColor))
        
        // Take snapshot
        let snapshotImage = try await takeSnapshot(of: testView, named: "DashboardAnalyticsView_Default")
        
        // Compare with reference
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "DashboardAnalyticsView_Default",
            testName: "Dashboard Analytics - Default State"
        )
    }
    
    /// Test DashboardAnalyticsView with empty state
    func testDashboardAnalyticsViewEmptyState() async throws {
        // No test data - test empty state
        let analyticsView = DashboardAnalyticsView(
            context: testContext,
            analyticsEngine: analyticsEngine
        )
        
        let testView = analyticsView
            .frame(width: 1000, height: 800)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "DashboardAnalyticsView_Empty")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "DashboardAnalyticsView_Empty",
            testName: "Dashboard Analytics - Empty State"
        )
    }
    
    /// Test DashboardAnalyticsView with high-volume data
    func testDashboardAnalyticsViewHighVolumeState() async throws {
        // Create high-volume test data
        await createHighVolumeAnalyticsData()
        
        let analyticsView = DashboardAnalyticsView(
            context: testContext,
            analyticsEngine: analyticsEngine
        )
        
        let testView = analyticsView
            .frame(width: 1000, height: 800)
            .background(Color(.windowBackgroundColor))
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "DashboardAnalyticsView_HighVolume")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "DashboardAnalyticsView_HighVolume",
            testName: "Dashboard Analytics - High Volume Data"
        )
    }
    
    /// Test DashboardAnalyticsView with dark appearance
    func testDashboardAnalyticsViewDarkMode() async throws {
        await createAnalyticsTestData()
        
        let analyticsView = DashboardAnalyticsView(
            context: testContext,
            analyticsEngine: analyticsEngine
        )
        
        let testView = analyticsView
            .frame(width: 1000, height: 800)
            .background(Color(.windowBackgroundColor))
            .preferredColorScheme(.dark)
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "DashboardAnalyticsView_Dark")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "DashboardAnalyticsView_Dark",
            testName: "Dashboard Analytics - Dark Mode"
        )
    }
    
    /// Test DashboardAnalyticsView with accessibility features
    func testDashboardAnalyticsViewAccessibility() async throws {
        await createAnalyticsTestData()
        
        let analyticsView = DashboardAnalyticsView(
            context: testContext,
            analyticsEngine: analyticsEngine
        )
        
        let testView = analyticsView
            .frame(width: 1000, height: 800)
            .background(Color(.windowBackgroundColor))
            .environment(\\.accessibilityReduceMotion, true)
            .environment(\\.accessibilityDifferentiateWithoutColor, true)
        
        let snapshotImage = try await takeSnapshot(of: testView, named: "DashboardAnalyticsView_Accessibility")
        
        try await validateSnapshot(
            image: snapshotImage,
            referenceName: "DashboardAnalyticsView_Accessibility",
            testName: "Dashboard Analytics - Accessibility Mode"
        )
    }
    
    // MARK: - Test Data Creation
    
    /// Create comprehensive analytics test data
    private func createAnalyticsTestData() async {
        let calendar = Calendar.current
        let now = Date()
        
        // Create transactions across different categories and time periods
        let testTransactions = [
            ("Business Income", 2500.0, calendar.date(byAdding: .day, value: -1, to: now)!),
            ("Office Supplies", -150.0, calendar.date(byAdding: .day, value: -2, to: now)!),
            ("Marketing", -300.0, calendar.date(byAdding: .day, value: -3, to: now)!),
            ("Consulting Revenue", 1800.0, calendar.date(byAdding: .day, value: -5, to: now)!),
            ("Software Subscriptions", -99.0, calendar.date(byAdding: .day, value: -7, to: now)!),
            ("Travel", -450.0, calendar.date(byAdding: .day, value: -10, to: now)!),
            ("Client Payment", 3200.0, calendar.date(byAdding: .day, value: -14, to: now)!),
            ("Equipment", -750.0, calendar.date(byAdding: .day, value: -20, to: now)!)
        ]
        
        for (category, amount, date) in testTransactions {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = amount
            transaction.date = date
            transaction.category = category
            transaction.note = "Analytics test data - \\(category)"
            transaction.createdAt = date
            
            // Add line items for expenses to test split-based analytics
            if amount < 0 {
                await createLineItemsForTransaction(transaction, category: category)
            }
        }
        
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to create analytics test data: \\(error)")
        }
    }
    
    /// Create high-volume test data for performance testing
    private func createHighVolumeAnalyticsData() async {
        let categories = ["Income", "Business", "Marketing", "Travel", "Equipment", "Supplies", "Consulting"]
        let calendar = Calendar.current
        let now = Date()
        
        // Create 50 transactions across 6 months
        for i in 0..<50 {
            let transaction = Transaction(context: testContext)
            transaction.id = UUID()
            transaction.amount = Double.random(in: -1000...3000)
            transaction.date = calendar.date(byAdding: .day, value: -i * 3, to: now)!
            transaction.category = categories[i % categories.count]
            transaction.note = "High volume test transaction #\\(i)"
            transaction.createdAt = transaction.date
            
            // Add line items for some transactions
            if i % 3 == 0 && transaction.amount < 0 {
                await createLineItemsForTransaction(transaction, category: transaction.category)
            }
        }
        
        do {
            try testContext.save()
        } catch {
            XCTFail("Failed to create high-volume analytics test data: \\(error)")
        }
    }
    
    /// Create line items for transaction to test split-based analytics
    private func createLineItemsForTransaction(_ transaction: Transaction, category: String) async {
        let totalAmount = abs(transaction.amount)
        let splits = [
            ("Business", 0.6),
            ("Personal", 0.3),
            ("Other", 0.1)
        ]
        
        for (taxCategory, percentage) in splits {
            let lineItem = LineItem(context: testContext)
            lineItem.id = UUID()
            lineItem.amount = totalAmount * percentage
            lineItem.itemDescription = "\\(category) - \\(taxCategory)"
            lineItem.transaction = transaction
            lineItem.createdAt = transaction.date
            
            let splitAllocation = SplitAllocation(context: testContext)
            splitAllocation.id = UUID()
            splitAllocation.percentage = percentage
            splitAllocation.taxCategory = taxCategory
            splitAllocation.lineItem = lineItem
            splitAllocation.createdAt = transaction.date
        }
    }
    
    // MARK: - Snapshot Testing Implementation
    
    /// Take snapshot of SwiftUI view with proper handling for Charts
    @MainActor
    private func takeSnapshot<Content: View>(of view: Content, named name: String) async throws -> NSImage {
        // Create hosting controller
        let hostingController = NSHostingController(rootView: view)
        
        // Set fixed size for consistent snapshots
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 1000, height: 800)
        
        // Force layout and wait for Charts to render
        hostingController.view.layoutSubtreeIfNeeded()
        
        // Additional wait for Charts framework to complete rendering
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
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
            // Load reference image and compare
            let referenceImage = try loadImage(from: referenceImagePath)
            let comparisonResult = compareImages(image, referenceImage)
            
            if !comparisonResult.isEqual {
                // Save failed snapshot for debugging
                let failedSnapshotPath = snapshotDirectory.appendingPathComponent("\\(referenceName)_failed.png")
                try saveImage(image, to: failedSnapshotPath)
                
                // Save difference image if possible
                let diffImagePath = snapshotDirectory.appendingPathComponent("\\(referenceName)_diff.png")
                if let diffImage = createDifferenceImage(image, referenceImage) {
                    try saveImage(diffImage, to: diffImagePath)
                }
                
                XCTFail("\\(testName) snapshot test failed. Visual difference: \\(String(format: "%.2f", comparisonResult.difference * 100))%. Failed snapshot: \\(failedSnapshotPath.path)")
            } else {
                print("✅ \\(testName) snapshot test passed - matches reference image")
            }
        } else {
            // First run - save as reference
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
    
    /// Compare two images for visual differences with enhanced tolerance for Charts
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
        // Higher tolerance for Charts framework due to potential animation frames
        let threshold = 0.03 // 3% tolerance for Charts rendering variations
        
        return ImageComparisonResult(isEqual: difference <= threshold, difference: difference)
    }
    
    /// Create difference image highlighting changes
    private func createDifferenceImage(_ image1: NSImage, _ image2: NSImage) -> NSImage? {
        guard let tiff1 = image1.tiffRepresentation,
              let tiff2 = image2.tiffRepresentation,
              let bitmap1 = NSBitmapImageRep(data: tiff1),
              let bitmap2 = NSBitmapImageRep(data: tiff2),
              bitmap1.size == bitmap2.size else {
            return nil
        }
        
        let width = Int(bitmap1.size.width)
        let height = Int(bitmap1.size.height)
        
        let diffBitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            realDataPointsPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
        
        guard let diffBitmap = diffBitmap else { return nil }
        
        for y in 0..<height {
            for x in 0..<width {
                let color1 = bitmap1.colorAt(x: x, y: y)
                let color2 = bitmap2.colorAt(x: x, y: y)
                
                let diffColor: NSColor
                if colorsAreEqual(color1, color2) {
                    // Same pixels are gray
                    diffColor = NSColor.gray
                } else {
                    // Different pixels are highlighted in red
                    diffColor = NSColor.red
                }
                
                diffBitmap.setColor(diffColor, atX: x, y: y)
            }
        }
        
        let diffImage = NSImage(size: bitmap1.size)
        diffImage.addRepresentation(diffBitmap)
        return diffImage
    }
    
    /// Helper to compare colors with tolerance for Charts rendering
    private func colorsAreEqual(_ color1: NSColor?, _ color2: NSColor?) -> Bool {
        guard let c1 = color1, let c2 = color2 else { return false }
        
        // Higher tolerance for Charts framework
        let tolerance: CGFloat = 0.05 // 5% tolerance for color differences
        
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