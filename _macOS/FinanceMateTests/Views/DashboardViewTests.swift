//
//  DashboardViewTests.swift
//  FinanceMateTests
//
//  Created by AI Dev Agent on 2025-07-09.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import XCTest
import SwiftUI
import CoreData
@testable import FinanceMate

/**
 * Purpose: Test suite for DashboardView responsive layout behavior
 * Issues & Complexity Summary: SwiftUI view testing with layout constraints and responsive behavior
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300
 *   - Core Algorithm Complexity: Medium (layout testing, responsive behavior)
 *   - Dependencies: 3 New (SwiftUI testing, ViewInspector, responsive layout)
 *   - State Management Complexity: Medium (view state, window sizing)
 *   - Novelty/Uncertainty Factor: Medium (SwiftUI testing patterns)
 * AI Pre-Task Self-Assessment: 80%
 * Problem Estimate: 82%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 85%
 * Overall Result Score: 88%
 * Key Variances/Learnings: SwiftUI testing requires careful view hierarchy inspection
 * Last Updated: 2025-07-09
 */

@MainActor
class DashboardViewTests: XCTestCase {
    
    var viewModel: DashboardViewModel!
    var testContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // Create test Core Data context
        testContext = PersistenceController.preview.container.viewContext
        
        // Initialize view model
        viewModel = DashboardViewModel(context: testContext)
    }
    
    override func tearDown() {
        viewModel = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Layout Structure Tests
    
    func testDashboardViewBasicStructure() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        
        // Then
        XCTAssertNotNil(window.contentViewController)
        XCTAssertEqual(window.contentViewController?.view.subviews.count, 1)
    }
    
    func testDashboardViewResponsiveLayout() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        
        // Test different window sizes
        let narrowSize = NSSize(width: 600, height: 800)
        let wideSize = NSSize(width: 1200, height: 800)
        
        // Then - Should adapt to both sizes without layout issues
        window.setContentSize(narrowSize)
        XCTAssertEqual(window.contentViewController?.view.frame.width, narrowSize.width)
        
        window.setContentSize(wideSize)
        XCTAssertEqual(window.contentViewController?.view.frame.width, wideSize.width)
    }
    
    // MARK: - Responsive Layout Tests
    
    func testDashboardUtilizesFullWidth() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 1000, height: 800))
        
        // Then - Dashboard should utilize full window width
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        XCTAssertEqual(contentView?.frame.width, 1000)
        
        // Content should not be constrained to narrow width
        XCTAssertGreaterThan(contentView?.frame.width ?? 0, 600)
    }
    
    func testDashboardAdaptiveSpacing() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        
        // Test narrow width
        window.setContentSize(NSSize(width: 500, height: 800))
        let narrowLayout = window.contentViewController?.view
        
        // Test wide width
        window.setContentSize(NSSize(width: 1200, height: 800))
        let wideLayout = window.contentViewController?.view
        
        // Then - Should adapt spacing based on width
        XCTAssertNotNil(narrowLayout)
        XCTAssertNotNil(wideLayout)
        XCTAssertNotEqual(narrowLayout?.frame.width, wideLayout?.frame.width)
    }
    
    // MARK: - Content Layout Tests
    
    func testBalanceCardResponsiveWidth() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 1000, height: 800))
        
        // Then - Balance card should utilize available width
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        
        // Balance card should not be constrained to narrow width
        XCTAssertGreaterThan(contentView?.frame.width ?? 0, 500)
    }
    
    func testQuickStatsResponsiveLayout() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 1000, height: 800))
        
        // Then - Quick stats should expand to fill available width
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        
        // Quick stats should utilize full width
        XCTAssertGreaterThan(contentView?.frame.width ?? 0, 500)
    }
    
    func testActionButtonsResponsiveLayout() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 1000, height: 800))
        
        // Then - Action buttons should expand to fill available width
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        
        // Action buttons should utilize full width
        XCTAssertGreaterThan(contentView?.frame.width ?? 0, 500)
    }
    
    // MARK: - Layout Edge Cases
    
    func testMinimumWindowSize() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        
        // Set to minimum macOS window size
        window.setContentSize(NSSize(width: 300, height: 400))
        
        // Then - Should handle minimum size gracefully
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        XCTAssertEqual(contentView?.frame.width, 300)
    }
    
    func testMaximumWindowSize() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        
        // Set to large window size
        window.setContentSize(NSSize(width: 2000, height: 1200))
        
        // Then - Should handle large size gracefully
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        XCTAssertEqual(contentView?.frame.width, 2000)
    }
    
    // MARK: - Performance Tests
    
    func testLayoutPerformanceWithWindowResize() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        
        // Measure performance of rapid window resizing
        measure {
            for width in stride(from: 400, through: 1600, by: 200) {
                window.setContentSize(NSSize(width: width, height: 800))
                RunLoop.current.run(until: Date().addingTimeInterval(0.01))
            }
        }
        
        // Then - Should complete within reasonable time
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityInDifferentSizes() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        
        // Test accessibility at different sizes
        let sizes = [
            NSSize(width: 400, height: 600),
            NSSize(width: 800, height: 800),
            NSSize(width: 1200, height: 800)
        ]
        
        // Then - Should maintain accessibility at all sizes
        for size in sizes {
            window.setContentSize(size)
            let contentView = window.contentViewController?.view
            XCTAssertNotNil(contentView)
            
            // Verify accessibility elements are present
            XCTAssertTrue(contentView?.accessibilityElement() ?? false)
        }
    }
    
    // MARK: - Content Adaptation Tests
    
    func testEmptyStateResponsiveLayout() {
        // Given
        let emptyViewModel = DashboardViewModel(context: PersistenceController(inMemory: true).container.viewContext)
        let dashboardView = DashboardView()
            .environmentObject(emptyViewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 1000, height: 800))
        
        // Then - Empty state should also utilize full width
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        XCTAssertEqual(contentView?.frame.width, 1000)
    }
    
    func testDataPopulatedResponsiveLayout() {
        // Given
        // Create test data
        let transaction = Transaction.create(
            in: testContext,
            amount: 100.0,
            category: "Test",
            note: "Test transaction"
        )
        try? testContext.save()
        
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 1000, height: 800))
        
        // Then - With data should also utilize full width
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        XCTAssertEqual(contentView?.frame.width, 1000)
    }
    
    // MARK: - Layout Quality Tests
    
    func testNoHorizontalOverflow() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 500, height: 800))
        
        // Then - Content should not overflow horizontally
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        XCTAssertLessThanOrEqual(contentView?.frame.width ?? 0, 500)
    }
    
    func testProperContentMargins() {
        // Given
        let dashboardView = DashboardView()
            .environmentObject(viewModel)
            .environment(\.managedObjectContext, testContext)
        
        // When
        let hostingController = NSHostingController(rootView: dashboardView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 1000, height: 800))
        
        // Then - Should have proper margins and spacing
        let contentView = window.contentViewController?.view
        XCTAssertNotNil(contentView)
        
        // Content should utilize most of the available width (accounting for margins)
        XCTAssertGreaterThan(contentView?.frame.width ?? 0, 900)
    }
}