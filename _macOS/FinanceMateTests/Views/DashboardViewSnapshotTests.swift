import XCTest
import SwiftUI
import CoreData
@testable import FinanceMate

/**
 * DashboardViewSnapshotTests.swift
 * 
 * Purpose: Visual regression testing for DashboardView using custom snapshot testing
 * Issues & Complexity Summary: Automated UI validation to detect visual regressions
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~80
 *   - Core Algorithm Complexity: Medium (Image comparison)
 *   - Dependencies: 2 New (SwiftUI rendering, FileManager)
 *   - State Management Complexity: Low (Test data setup)
 *   - Novelty/Uncertainty Factor: Medium (Custom snapshot implementation)
 * AI Pre-Task Self-Assessment: 80%
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 70%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-05
 */

@MainActor
class DashboardViewSnapshotTests: XCTestCase {
    
    var viewModel: DashboardViewModel!
    var testContext: NSManagedObjectContext!
    var snapshotDirectory: URL!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize ViewModel with test context
        viewModel = DashboardViewModel(context: testContext)
        
        // Set up snapshot directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        snapshotDirectory = documentsPath.appendingPathComponent("FinanceMate-Snapshots")
        
        try FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        testContext = nil
        try await super.tearDown()
    }
    
    // MARK: - Snapshot Testing Implementation
    
    /// Custom snapshot testing implementation for DashboardView
    func testDashboardViewSnapshot() async throws {
        // Create test data
        await createTestTransactions()
        
        // Create the view to test
        let dashboardView = DashboardView(viewModel: viewModel)
        
        // Configure the view for consistent testing
        let testView = dashboardView
            .frame(width: 800, height: 600)
            .background(Color.white)
        
        // Take snapshot
        let snapshotImage = try await takeSnapshot(of: testView, named: "DashboardView_Default")
        
        // Compare with reference image
        let referenceImagePath = snapshotDirectory.appendingPathComponent("DashboardView_Default_reference.png")
        
        if FileManager.default.fileExists(atPath: referenceImagePath.path) {
            // Load reference image and compare
            let referenceImage = try loadImage(from: referenceImagePath)
            let comparisonResult = compareImages(snapshotImage, referenceImage)
            
            if !comparisonResult.isEqual {
                // Save failed snapshot for debugging
                let failedSnapshotPath = snapshotDirectory.appendingPathComponent("DashboardView_Default_failed.png")
                try saveImage(snapshotImage, to: failedSnapshotPath)
                
                XCTFail("Snapshot test failed. Visual difference detected. Failed snapshot saved to: \(failedSnapshotPath.path)")
            } else {
                print("✅ Snapshot test passed - DashboardView matches reference image")
            }
        } else {
            // First run - save as reference
            try saveImage(snapshotImage, to: referenceImagePath)
            print("📸 Reference snapshot saved for DashboardView at: \(referenceImagePath.path)")
        }
    }
    
    /// Test that demonstrates snapshot test failure when UI changes
    func testDashboardViewSnapshotFailsOnChange() async throws {
        // Create test data
        await createTestTransactions()
        
        // Create modified view (this should fail comparison)
        let dashboardView = DashboardView(viewModel: viewModel)
        
        // Deliberately modify appearance to trigger test failure
        let modifiedView = dashboardView
            .frame(width: 800, height: 600)
            .background(Color.red) // Changed background to red to trigger failure
        
        // Take snapshot
        let snapshotImage = try await takeSnapshot(of: modifiedView, named: "DashboardView_Modified")
        
        // Compare with reference image (should fail)
        let referenceImagePath = snapshotDirectory.appendingPathComponent("DashboardView_Default_reference.png")
        
        if FileManager.default.fileExists(atPath: referenceImagePath.path) {
            let referenceImage = try loadImage(from: referenceImagePath)
            let comparisonResult = compareImages(snapshotImage, referenceImage)
            
            // This test expects failure to demonstrate the testing mechanism
            XCTAssertFalse(comparisonResult.isEqual, "Modified view should NOT match reference image")
            
            // Save the failed snapshot as evidence
            let failedSnapshotPath = snapshotDirectory.appendingPathComponent("DashboardView_Modified_evidence.png")
            try saveImage(snapshotImage, to: failedSnapshotPath)
            
            print("🔴 Expected failure demonstrated - Modified view correctly detected as different")
            print("Evidence saved to: \(failedSnapshotPath.path)")
        } else {
            XCTFail("Reference image not found. Run testDashboardViewSnapshot() first.")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Create test transaction data for consistent snapshots
    private func createTestTransactions() async {
        // Clear existing test data
        await viewModel.fetchTransactions()
        
        // Create real Australian transactions for consistent testing
        let transaction1 = Transaction(context: testContext)
        transaction1.id = UUID()
        transaction1.amount = 1000.0
        transaction1.date = Date()
        transaction1.category = "Income"
        transaction1.note = "Test Income"
        
        let transaction2 = Transaction(context: testContext)
        transaction2.id = UUID()
        transaction2.amount = -250.0
        transaction2.date = Date().addingTimeInterval(-86400) // Yesterday
        transaction2.category = "Expenses"
        transaction2.note = "Test Expense"
        
        do {
            try testContext.save()
            await viewModel.fetchTransactions()
        } catch {
            XCTFail("Failed to create test data: \(error)")
        }
    }
    
    /// Take snapshot of SwiftUI view
    @MainActor
    private func takeSnapshot<Content: View>(of view: Content, named name: String) async throws -> NSImage {
        // Create a hosting view controller for the SwiftUI view
        let hostingController = NSHostingController(rootView: view)
        
        // Set fixed size for consistent snapshots
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
        
        // Force layout
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
        // Convert to bitmap representations
        guard let tiff1 = image1.tiffRepresentation,
              let tiff2 = image2.tiffRepresentation,
              let bitmap1 = NSBitmapImageRep(data: tiff1),
              let bitmap2 = NSBitmapImageRep(data: tiff2) else {
            return ImageComparisonResult(isEqual: false, difference: 1.0)
        }
        
        // Check dimensions
        guard bitmap1.size == bitmap2.size else {
            return ImageComparisonResult(isEqual: false, difference: 1.0)
        }
        
        // Simple pixel-by-pixel comparison
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
        let threshold = 0.01 // 1% tolerance for minor rendering differences
        
        return ImageComparisonResult(isEqual: difference <= threshold, difference: difference)
    }
    
    /// Helper to compare colors with tolerance
    private func colorsAreEqual(_ color1: NSColor?, _ color2: NSColor?) -> Bool {
        guard let c1 = color1, let c2 = color2 else { return false }
        
        let tolerance: CGFloat = 0.02 // 2% tolerance for color differences
        
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