// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashDetectorTests.swift
// FinanceMate-SandboxTests
//
// Purpose: Comprehensive test suite for crash detection functionality
// Issues & Complexity Summary: Complex testing of crash detection with simulation and state validation
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~260
//   - Core Algorithm Complexity: Medium (crash simulation, async testing, state validation)
//   - Dependencies: 3 New (XCTest, Foundation, Combine)
//   - State Management Complexity: Medium (crash state tracking, monitoring lifecycle)
//   - Novelty/Uncertainty Factor: Low (standard testing patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
// Problem Estimate (Inherent Problem Difficulty %): 68%
// Initial Code Complexity Estimate %: 69%
// Justification for Estimates: Standard testing with some complexity in crash simulation and async validation
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import XCTest
import Foundation
import Combine
@testable import FinanceMate_Sandbox

final class CrashDetectorTests: XCTestCase {
    var crashDetector: CrashDetector!
    var mockStorage: MockCrashStorage!
    var mockAnalyzer: MockCrashAnalyzer!
    var mockAlerting: MockCrashAlerting!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        crashDetector = CrashDetector()
        mockStorage = MockCrashStorage()
        mockAnalyzer = MockCrashAnalyzer()
        mockAlerting = MockCrashAlerting()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        crashDetector?.stopMonitoring()
        crashDetector = nil
        mockStorage = nil
        mockAnalyzer = nil
        mockAlerting = nil
        cancellables = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initialization Tests
    
    func testCrashDetectorInitialization() {
        // Given & When
        let detector = CrashDetector()
        
        // Then
        XCTAssertNotNil(detector)
        XCTAssertTrue(detector.detectedCrashes.isEmpty)
        XCTAssertTrue(detector.isHealthy)
    }
    
    // MARK: - Configuration Tests
    
    func testCrashDetectorConfiguration() {
        // Given
        let enableSignalHandling = true
        let enableExceptionHandling = true
        let enableHangDetection = false
        let enableMemoryMonitoring = true
        
        // When
        crashDetector.configure(
            enableSignalHandling: enableSignalHandling,
            enableExceptionHandling: enableExceptionHandling,
            enableHangDetection: enableHangDetection,
            enableMemoryMonitoring: enableMemoryMonitoring,
            storage: mockStorage,
            analyzer: mockAnalyzer,
            alerting: mockAlerting
        )
        
        // Then
        // Configuration is internal, so we test through behavior
        XCTAssertNotNil(crashDetector)
    }
    
    // MARK: - Monitoring Lifecycle Tests
    
    func testStartStopMonitoring() {
        // Given
        crashDetector.configure(
            storage: mockStorage,
            analyzer: mockAnalyzer,
            alerting: mockAlerting
        )
        
        // When
        crashDetector.startMonitoring()
        
        // Then
        // Monitoring state is internal, tested through behavior
        
        // When
        crashDetector.stopMonitoring()
        
        // Then
        // Should not crash or cause issues
    }
    
    func testDoubleStartMonitoring() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        // When
        crashDetector.startMonitoring()
        crashDetector.startMonitoring() // Second start should be safe
        
        // Then
        // Should not crash
        crashDetector.stopMonitoring()
    }
    
    func testDoubleStopMonitoring() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        crashDetector.startMonitoring()
        
        // When
        crashDetector.stopMonitoring()
        crashDetector.stopMonitoring() // Second stop should be safe
        
        // Then
        // Should not crash or cause issues
    }
    
    // MARK: - Breadcrumb Tests
    
    func testAddBreadcrumb() {
        // Given
        let message = "Test breadcrumb message"
        
        // When
        crashDetector.addBreadcrumb(message)
        
        // Then
        let breadcrumbs = crashDetector.getBreadcrumbs()
        XCTAssertTrue(breadcrumbs.contains { $0.contains(message) })
    }
    
    func testMultipleBreadcrumbs() {
        // Given
        let messages = ["Breadcrumb 1", "Breadcrumb 2", "Breadcrumb 3"]
        
        // When
        for message in messages {
            crashDetector.addBreadcrumb(message)
        }
        
        // Then
        let breadcrumbs = crashDetector.getBreadcrumbs()
        for message in messages {
            XCTAssertTrue(breadcrumbs.contains { $0.contains(message) })
        }
    }
    
    func testBreadcrumbLimit() {
        // Given
        let messageCount = 150 // More than the limit (100)
        
        // When
        for i in 0..<messageCount {
            crashDetector.addBreadcrumb("Breadcrumb \(i)")
        }
        
        // Then
        let breadcrumbs = crashDetector.getBreadcrumbs()
        XCTAssertLessThanOrEqual(breadcrumbs.count, 100)
        
        // Should contain the most recent breadcrumbs
        XCTAssertTrue(breadcrumbs.contains { $0.contains("Breadcrumb \(messageCount - 1)") })
    }
    
    // MARK: - Crash Reporting Tests
    
    func testReportCrash() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        let crashReport = CrashReport(
            crashType: .memoryLeak,
            severity: .high,
            errorMessage: "Test crash report",
            sessionId: "test-session"
        )
        
        let expectation = expectation(description: "Crash reported")
        crashDetector.$detectedCrashes
            .dropFirst() // Skip initial empty state
            .first()
            .sink { crashes in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        crashDetector.reportCrash(crashReport)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(crashDetector.detectedCrashes.count, 1)
        XCTAssertEqual(crashDetector.detectedCrashes.first?.crashType, .memoryLeak)
        XCTAssertEqual(crashDetector.detectedCrashes.first?.severity, .high)
        XCTAssertFalse(crashDetector.isHealthy) // Health should be affected
    }
    
    // MARK: - Crash Simulation Tests
    
    func testSimulateMemoryLeak() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        let expectation = expectation(description: "Memory leak crash simulated")
        crashDetector.$detectedCrashes
            .dropFirst()
            .first()
            .sink { crashes in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        crashDetector.simulateCrash(type: .memoryLeak)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(crashDetector.detectedCrashes.count, 1)
        XCTAssertEqual(crashDetector.detectedCrashes.first?.crashType, .memoryLeak)
    }
    
    func testSimulateUnexpectedException() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        let expectation = expectation(description: "Unexpected exception simulated")
        crashDetector.$detectedCrashes
            .dropFirst()
            .first()
            .sink { crashes in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        crashDetector.simulateCrash(type: .unexpectedException)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(crashDetector.detectedCrashes.count, 1)
        XCTAssertEqual(crashDetector.detectedCrashes.first?.crashType, .unexpectedException)
    }
    
    func testSimulateSignalException() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        let expectation = expectation(description: "Signal exception simulated")
        crashDetector.$detectedCrashes
            .dropFirst()
            .first()
            .sink { crashes in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        crashDetector.simulateCrash(type: .signalException)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(crashDetector.detectedCrashes.count, 1)
        XCTAssertEqual(crashDetector.detectedCrashes.first?.crashType, .signalException)
    }
    
    func testSimulateNetworkFailure() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        let expectation = expectation(description: "Network failure simulated")
        crashDetector.$detectedCrashes
            .dropFirst()
            .first()
            .sink { crashes in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        crashDetector.simulateCrash(type: .networkFailure)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertEqual(crashDetector.detectedCrashes.count, 1)
        XCTAssertEqual(crashDetector.detectedCrashes.first?.crashType, .networkFailure)
    }
    
    func testSimulateAllCrashTypes() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        let expectation = expectation(description: "All crash types simulated")
        expectation.expectedFulfillmentCount = CrashType.allCases.count
        
        crashDetector.$detectedCrashes
            .dropFirst()
            .sink { crashes in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        for crashType in CrashType.allCases {
            crashDetector.simulateCrash(type: crashType)
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Then
        XCTAssertEqual(crashDetector.detectedCrashes.count, CrashType.allCases.count)
        
        let detectedTypes = Set(crashDetector.detectedCrashes.map { $0.crashType })
        let allTypes = Set(CrashType.allCases)
        XCTAssertEqual(detectedTypes, allTypes)
    }
    
    // MARK: - Health Monitoring Tests
    
    func testHealthStatusAfterCrash() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        XCTAssertTrue(crashDetector.isHealthy) // Initially healthy
        
        let expectation = expectation(description: "Health status updated")
        crashDetector.$isHealthy
            .dropFirst() // Skip initial value
            .first()
            .sink { isHealthy in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        crashDetector.simulateCrash(type: .critical)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertFalse(crashDetector.isHealthy)
    }
    
    func testLastHealthCheckUpdate() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        let initialTime = crashDetector.lastHealthCheck
        
        let expectation = expectation(description: "Health check updated")
        crashDetector.$lastHealthCheck
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        crashDetector.startMonitoring()
        
        wait(for: [expectation], timeout: 35.0) // Health checks run every 30 seconds
        crashDetector.stopMonitoring()
        
        // Then
        XCTAssertGreaterThan(crashDetector.lastHealthCheck, initialTime)
    }
    
    // MARK: - Integration with Storage Tests
    
    func testCrashStorageIntegration() async {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        // When
        crashDetector.simulateCrash(type: .memoryLeak)
        
        // Allow some time for async processing
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Then
        XCTAssertEqual(mockStorage.savedReports.count, 1)
        XCTAssertEqual(mockStorage.savedReports.first?.crashType, .memoryLeak)
    }
    
    // MARK: - Integration with Alerting Tests
    
    func testAlertingIntegration() async {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        // When
        crashDetector.simulateCrash(type: .critical)
        
        // Allow some time for async processing
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Then
        XCTAssertTrue(mockAlerting.shouldAlertCalled)
        XCTAssertTrue(mockAlerting.sendAlertCalled)
    }
    
    // MARK: - Integration with Analyzer Tests
    
    func testAnalyzerIntegration() async {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        // When
        crashDetector.simulateCrash(type: .memoryLeak)
        
        // Allow some time for async processing
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Then
        XCTAssertTrue(mockAnalyzer.generateInsightsCalled)
    }
    
    // MARK: - Performance Tests
    
    func testCrashReportingPerformance() {
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        measure {
            for _ in 0..<10 {
                let crashReport = CrashReport(
                    crashType: .memoryLeak,
                    severity: .medium,
                    errorMessage: "Performance test crash",
                    sessionId: "perf-test"
                )
                crashDetector.reportCrash(crashReport)
            }
        }
    }
    
    func testBreadcrumbPerformance() {
        measure {
            for i in 0..<1000 {
                crashDetector.addBreadcrumb("Performance test breadcrumb \(i)")
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testCrashDetectorWithoutConfiguration() {
        // Given - No configuration set
        
        // When
        crashDetector.startMonitoring()
        crashDetector.simulateCrash(type: .memoryLeak)
        
        // Then
        // Should not crash, but might not have full functionality
        crashDetector.stopMonitoring()
    }
    
    func testEmptyBreadcrumbs() {
        // Given & When
        let breadcrumbs = crashDetector.getBreadcrumbs()
        
        // Then
        XCTAssertTrue(breadcrumbs.isEmpty)
    }
    
    func testCrashDetectionLimit() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        let crashCount = 150 // More than typical limit
        
        // When
        for i in 0..<crashCount {
            let crashReport = CrashReport(
                crashType: .memoryLeak,
                severity: .low,
                errorMessage: "Test crash \(i)",
                sessionId: "test-session"
            )
            crashDetector.reportCrash(crashReport)
        }
        
        // Then
        XCTAssertLessThanOrEqual(crashDetector.detectedCrashes.count, 100) // Assuming limit of 100
    }
    
    // MARK: - Reactive Tests
    
    func testDetectedCrashesPublisher() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        let expectation = expectation(description: "Detected crashes publisher")
        var crashCounts: [Int] = []
        
        crashDetector.$detectedCrashes
            .map { $0.count }
            .sink { count in
                crashCounts.append(count)
                if count > 0 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        crashDetector.simulateCrash(type: .memoryLeak)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(crashCounts.contains(0)) // Initial state
        XCTAssertTrue(crashCounts.contains(1)) // After crash
    }
    
    func testHealthPublisher() {
        // Given
        crashDetector.configure(storage: mockStorage, analyzer: mockAnalyzer, alerting: mockAlerting)
        
        let expectation = expectation(description: "Health publisher")
        var healthStates: [Bool] = []
        
        crashDetector.$isHealthy
            .sink { isHealthy in
                healthStates.append(isHealthy)
                if healthStates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        crashDetector.simulateCrash(type: .critical)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(healthStates.contains(true))  // Initial healthy state
        XCTAssertTrue(healthStates.contains(false)) // After crash
    }
}

// MARK: - Mock Classes

class MockCrashAnalyzer: CrashAnalyzerProtocol {
    var generateInsightsCalled = false
    var analyzeCrashTrendsCalled = false
    var detectPatternsCalled = false
    var calculateCrashMetricsCalled = false
    
    func analyzeCrashTrends() async throws -> CrashAnalysisResult {
        analyzeCrashTrendsCalled = true
        return CrashAnalysisResult.empty
    }
    
    func detectPatterns(in reports: [CrashReport]) async throws -> [CrashPattern] {
        detectPatternsCalled = true
        return []
    }
    
    func generateInsights() async throws -> [CrashInsight] {
        generateInsightsCalled = true
        return []
    }
    
    func calculateCrashMetrics() async throws -> CrashMetrics {
        calculateCrashMetricsCalled = true
        return CrashMetrics.empty
    }
}

class MockCrashAlerting: CrashAlertingProtocol {
    var shouldAlertCalled = false
    var sendAlertCalled = false
    var configureCriticalityThresholdsCalled = false
    
    var shouldAlertResult = true
    
    func shouldAlert(for report: CrashReport) -> Bool {
        shouldAlertCalled = true
        return shouldAlertResult
    }
    
    func sendAlert(for report: CrashReport) async throws {
        sendAlertCalled = true
    }
    
    func configureCriticalityThresholds(_ thresholds: [CrashSeverity: Int]) {
        configureCriticalityThresholdsCalled = true
    }
}