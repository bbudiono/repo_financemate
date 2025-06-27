//
//  DocumentViewPerformanceManagerTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/27/25.
//

import XCTest
import SwiftUI
@testable import FinanceMate

@MainActor
final class DocumentViewPerformanceManagerTests: XCTestCase {
    
    var performanceManager: DocumentViewPerformanceManager!
    var appPerformanceMonitor: AppPerformanceMonitor!
    
    override func setUp() {
        super.setUp()
        performanceManager = DocumentViewPerformanceManager()
        appPerformanceMonitor = AppPerformanceMonitor()
    }
    
    override func tearDown() {
        performanceManager = nil
        appPerformanceMonitor = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testPerformanceManagerInitialization() {
        XCTAssertNotNil(performanceManager)
        XCTAssertFalse(performanceManager.isVirtualizationEnabled)
        XCTAssertEqual(performanceManager.visibleRange, 0..<50)
        XCTAssertEqual(performanceManager.totalDocumentCount, 0)
        XCTAssertEqual(performanceManager.filterPerformanceMetrics.totalFilters, 0)
    }
    
    // MARK: - Performance Metrics Tests
    
    func testPerformanceGradeCalculation() {
        var metrics = DocumentViewPerformanceMetrics()
        
        // Test unknown grade (no filters)
        XCTAssertEqual(metrics.performanceGrade, .unknown)
        
        // Test excellent grade
        metrics.totalFilters = 1
        metrics.lastFilterTime = 0.03
        XCTAssertEqual(metrics.performanceGrade, .excellent)
        
        // Test good grade
        metrics.lastFilterTime = 0.08
        XCTAssertEqual(metrics.performanceGrade, .good)
        
        // Test average grade
        metrics.lastFilterTime = 0.15
        XCTAssertEqual(metrics.performanceGrade, .average)
        
        // Test poor grade
        metrics.lastFilterTime = 0.25
        XCTAssertEqual(metrics.performanceGrade, .poor)
    }
    
    func testPerformanceGradeColors() {
        let grades: [PerformanceGrade] = [.excellent, .good, .average, .poor, .unknown]
        let expectedColors: [Color] = [.green, .blue, .orange, .red, .gray]
        
        for (grade, expectedColor) in zip(grades, expectedColors) {
            XCTAssertEqual(grade.color, expectedColor)
        }
    }
    
    func testPerformanceGradeDescriptions() {
        let testCases: [(PerformanceGrade, String)] = [
            (.excellent, "Excellent"),
            (.good, "Good"),
            (.average, "Average"),
            (.poor, "Poor"),
            (.unknown, "Unknown")
        ]
        
        for (grade, expectedDescription) in testCases {
            XCTAssertEqual(grade.description, expectedDescription)
        }
    }
    
    // MARK: - Document Count Management Tests
    
    func testUpdateDocumentCount() {
        // Test small count (no virtualization)
        performanceManager.updateDocumentCount(50)
        XCTAssertEqual(performanceManager.totalDocumentCount, 50)
        XCTAssertFalse(performanceManager.isVirtualizationEnabled)
        
        // Test large count (enables virtualization)
        performanceManager.updateDocumentCount(150)
        XCTAssertEqual(performanceManager.totalDocumentCount, 150)
        XCTAssertTrue(performanceManager.isVirtualizationEnabled)
    }
    
    func testVirtualizationThreshold() {
        // Test exact threshold
        performanceManager.updateDocumentCount(100)
        XCTAssertFalse(performanceManager.isVirtualizationEnabled)
        
        performanceManager.updateDocumentCount(101)
        XCTAssertTrue(performanceManager.isVirtualizationEnabled)
    }
    
    // MARK: - Filter Performance Tests
    
    func testUpdateFilterPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate some processing time
        Thread.sleep(forTimeInterval: 0.01)
        
        performanceManager.updateFilterPerformance(startTime: startTime, documentCount: 100)
        
        XCTAssertEqual(performanceManager.filterPerformanceMetrics.totalFilters, 1)
        XCTAssertGreaterThan(performanceManager.filterPerformanceMetrics.lastFilterTime, 0)
    }
    
    func testMultipleFilterUpdates() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Multiple filter operations
        for _ in 0..<3 {
            performanceManager.updateFilterPerformance(startTime: startTime, documentCount: 100)
        }
        
        XCTAssertEqual(performanceManager.filterPerformanceMetrics.totalFilters, 3)
    }
    
    // MARK: - Virtualized Range Management Tests
    
    func testUpdateVirtualizedRange() {
        // Test normal range
        performanceManager.visibleRange = 0..<50
        performanceManager.updateVirtualizedRange(for: 100)
        XCTAssertEqual(performanceManager.visibleRange, 0..<50)
        
        // Test range beyond document count
        performanceManager.visibleRange = 90..<140
        performanceManager.updateVirtualizedRange(for: 100)
        XCTAssertEqual(performanceManager.visibleRange, 0..<50)
    }
    
    func testLoadMoreDocuments() {
        // Test normal load more
        performanceManager.visibleRange = 0..<50
        performanceManager.loadMoreDocuments(totalCount: 200)
        XCTAssertEqual(performanceManager.visibleRange, 0..<100)
        
        // Test load more at end of documents
        performanceManager.visibleRange = 150..<200
        performanceManager.loadMoreDocuments(totalCount: 200)
        XCTAssertEqual(performanceManager.visibleRange, 150..<200)
    }
    
    func testLoadMoreDocumentsWithLimitedTotal() {
        performanceManager.visibleRange = 0..<50
        performanceManager.loadMoreDocuments(totalCount: 75)
        XCTAssertEqual(performanceManager.visibleRange, 0..<75)
    }
    
    // MARK: - Reset Functionality Tests
    
    func testResetMetrics() {
        // Set up some state
        performanceManager.filterPerformanceMetrics.totalFilters = 5
        performanceManager.filterPerformanceMetrics.lastFilterTime = 0.15
        performanceManager.visibleRange = 50..<100
        
        // Reset
        performanceManager.resetMetrics()
        
        XCTAssertEqual(performanceManager.filterPerformanceMetrics.totalFilters, 0)
        XCTAssertEqual(performanceManager.filterPerformanceMetrics.lastFilterTime, 0.0)
        XCTAssertEqual(performanceManager.visibleRange, 0..<50)
    }
    
    // MARK: - App Performance Monitor Tests
    
    func testAppPerformanceMonitorInitialization() {
        XCTAssertNotNil(appPerformanceMonitor)
        XCTAssertFalse(appPerformanceMonitor.isLowMemoryMode)
    }
    
    func testAppPerformanceMonitorMemoryCheck() {
        // Test that memory check method exists and can be called
        XCTAssertNoThrow(appPerformanceMonitor.checkMemoryUsage())
    }
    
    // MARK: - Integration Tests
    
    func testPerformanceManagerLifecycle() {
        // Test complete lifecycle
        performanceManager.updateDocumentCount(200)
        XCTAssertTrue(performanceManager.isVirtualizationEnabled)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        performanceManager.updateFilterPerformance(startTime: startTime, documentCount: 200)
        XCTAssertEqual(performanceManager.filterPerformanceMetrics.totalFilters, 1)
        
        performanceManager.loadMoreDocuments(totalCount: 200)
        XCTAssertEqual(performanceManager.visibleRange.upperBound, 100)
        
        performanceManager.resetMetrics()
        XCTAssertEqual(performanceManager.filterPerformanceMetrics.totalFilters, 0)
    }
    
    // MARK: - Performance Tests
    
    func testFilterPerformanceTracking() {
        measure {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // Simulate filter operation
            for _ in 0..<1000 {
                // Simulate some work
                _ = String(repeating: "test", count: 10)
            }
            
            performanceManager.updateFilterPerformance(startTime: startTime, documentCount: 1000)
        }
    }
    
    // MARK: - Snapshot Tests
    
    func testPerformanceManagerSnapshot() {
        // Set up specific state
        performanceManager.updateDocumentCount(150)
        performanceManager.loadMoreDocuments(totalCount: 150)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        performanceManager.updateFilterPerformance(startTime: startTime, documentCount: 150)
        
        // Verify snapshot state
        XCTAssertTrue(performanceManager.isVirtualizationEnabled)
        XCTAssertEqual(performanceManager.totalDocumentCount, 150)
        XCTAssertEqual(performanceManager.visibleRange.upperBound, 100)
        XCTAssertEqual(performanceManager.filterPerformanceMetrics.totalFilters, 1)
    }
}

// MARK: - Test Utilities

extension DocumentViewPerformanceManagerTests {
    
    private func createMockDocuments(count: Int) -> [Document] {
        // This would require Core Data context setup
        // For now, return empty array as placeholder
        return []
    }
}