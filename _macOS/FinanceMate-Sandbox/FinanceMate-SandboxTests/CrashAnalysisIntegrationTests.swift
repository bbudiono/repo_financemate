// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashAnalysisIntegrationTests.swift
// FinanceMate-SandboxTests
//
// Purpose: Integration tests for the complete crash analysis infrastructure
// Issues & Complexity Summary: Complex integration testing across all crash analysis components
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~200
//   - Core Algorithm Complexity: High (full system integration, async coordination, state validation)
//   - Dependencies: 4 New (XCTest, Foundation, Combine, SwiftUI)
//   - State Management Complexity: High (coordinating multiple component states)
//   - Novelty/Uncertainty Factor: Medium (complex integration scenarios)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 78%
// Problem Estimate (Inherent Problem Difficulty %): 75%
// Initial Code Complexity Estimate %: 76%
// Justification for Estimates: Integration testing requires coordination of multiple complex systems
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import XCTest
import Foundation
import Combine
import SwiftUI
@testable import FinanceMate_Sandbox

@MainActor
final class CrashAnalysisIntegrationTests: XCTestCase {
    var crashAnalysisManager: CrashAnalysisManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        crashAnalysisManager = CrashAnalysisManager.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        crashAnalysisManager?.stopMonitoring()
        cancellables = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Manager Initialization Tests
    
    func testCrashAnalysisManagerInitialization() {
        // Given & When
        let manager = CrashAnalysisManager.shared
        
        // Then
        XCTAssertNotNil(manager)
        XCTAssertFalse(manager.isMonitoring)
        XCTAssertEqual(manager.systemHealth.status, .excellent)
        XCTAssertEqual(manager.systemHealth.score, 100.0, accuracy: 0.1)
    }
    
    // MARK: - Full System Lifecycle Tests
    
    func testStartStopMonitoringIntegration() {
        // Given
        XCTAssertFalse(crashAnalysisManager.isMonitoring)
        
        let expectation = expectation(description: "Monitoring started")
        crashAnalysisManager.$isMonitoring
            .dropFirst()
            .first()
            .sink { isMonitoring in
                if isMonitoring {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        crashAnalysisManager.startMonitoring()
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then
        XCTAssertTrue(crashAnalysisManager.isMonitoring)
        
        // When
        crashAnalysisManager.stopMonitoring()
        
        // Then
        XCTAssertFalse(crashAnalysisManager.isMonitoring)
    }
    
    // MARK: - Configuration Integration Tests
    
    func testConfigurationIntegration() {
        // Given
        var config = CrashAnalysisConfiguration()
        config.enableSignalHandling = false
        config.enableHangDetection = false
        config.performanceMonitoringInterval = 10.0
        config.cpuThreshold = 85.0
        
        // When
        crashAnalysisManager.configure(config)
        
        // Then
        // Configuration is applied internally - test through behavior
        XCTAssertNotNil(crashAnalysisManager)
    }
    
    // MARK: - Dashboard Data Integration Tests
    
    func testGetDashboardDataIntegration() async {
        // Given
        crashAnalysisManager.startMonitoring()
        
        // When
        let dashboardData = await crashAnalysisManager.getDashboardData()
        
        // Then
        XCTAssertNotNil(dashboardData)
        XCTAssertTrue(dashboardData.generatedAt.timeIntervalSinceNow < 5.0)
        XCTAssertEqual(dashboardData.systemHealth.isMonitoring, true)
        
        // Cleanup
        crashAnalysisManager.stopMonitoring()
    }
    
    func testDashboardDataWithCrashes() async {
        // Given
        crashAnalysisManager.startMonitoring()
        
        // Simulate some crashes
        crashAnalysisManager.simulateCrash(type: .memoryLeak)
        crashAnalysisManager.simulateCrash(type: .unexpectedException)
        
        // Allow time for processing
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // When
        let dashboardData = await crashAnalysisManager.getDashboardData()
        
        // Then
        XCTAssertNotNil(dashboardData)
        XCTAssertFalse(dashboardData.recentCrashes.isEmpty)
        XCTAssertTrue(dashboardData.systemHealth.hasRecentCrashes)
        XCTAssertLessThan(dashboardData.systemHealth.score, 100.0)
        
        // Cleanup
        crashAnalysisManager.stopMonitoring()
    }
    
    // MARK: - Crash Simulation Integration Tests
    
    func testCrashSimulationFullPipeline() async {
        // Given
        crashAnalysisManager.startMonitoring()
        
        let expectation = expectation(description: "System health updated after crash")
        crashAnalysisManager.$systemHealth
            .dropFirst()
            .first { !$0.hasRecentCrashes }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        crashAnalysisManager.simulateCrash(type: .critical)
        
        wait(for: [expectation], timeout: 10.0)
        
        // Then
        XCTAssertTrue(crashAnalysisManager.systemHealth.hasRecentCrashes)
        XCTAssertLessThan(crashAnalysisManager.systemHealth.score, 100.0)
        
        // Cleanup
        crashAnalysisManager.stopMonitoring()
    }
    
    func testMultipleCrashTypesIntegration() async {
        // Given
        crashAnalysisManager.startMonitoring()
        
        let crashTypes: [CrashType] = [.memoryLeak, .unexpectedException, .signalException, .networkFailure]
        
        // When
        for crashType in crashTypes {
            crashAnalysisManager.simulateCrash(type: crashType)
        }
        
        // Allow time for processing
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        let dashboardData = await crashAnalysisManager.getDashboardData()
        
        // Then
        XCTAssertGreaterThanOrEqual(dashboardData.recentCrashes.count, crashTypes.count)
        
        let detectedTypes = Set(dashboardData.recentCrashes.map { $0.crashType })
        for crashType in crashTypes {
            XCTAssertTrue(detectedTypes.contains(crashType))
        }
        
        // Cleanup
        crashAnalysisManager.stopMonitoring()
    }
    
    // MARK: - Export Functionality Tests
    
    func testExportCrashReportIntegration() async {
        // Given
        crashAnalysisManager.startMonitoring()
        crashAnalysisManager.simulateCrash(type: .memoryLeak)
        
        // Allow time for processing
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // When
        let exportURL = await crashAnalysisManager.exportCrashReport()
        
        // Then
        XCTAssertNotNil(exportURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL!.path))
        
        // Verify file content
        do {
            let data = try Data(contentsOf: exportURL!)
            let report = try JSONDecoder().decode(ComprehensiveCrashReport.self, from: data)
            
            XCTAssertNotNil(report.dashboardData)
            XCTAssertNotNil(report.systemInfo)
            XCTAssertNotNil(report.configuration)
            XCTAssertTrue(report.exportTimestamp.timeIntervalSinceNow < 5.0)
            
            // Cleanup
            try FileManager.default.removeItem(at: exportURL!)
        } catch {
            XCTFail("Failed to decode exported crash report: \(error)")
        }
        
        crashAnalysisManager.stopMonitoring()
    }
    
    // MARK: - Clear Data Integration Tests
    
    func testClearAllDataIntegration() async {
        // Given
        crashAnalysisManager.startMonitoring()
        crashAnalysisManager.simulateCrash(type: .memoryLeak)
        
        // Allow time for crash to be processed
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let dashboardDataBefore = await crashAnalysisManager.getDashboardData()
        XCTAssertFalse(dashboardDataBefore.recentCrashes.isEmpty)
        
        // When
        await crashAnalysisManager.clearAllData()
        
        // Then
        let dashboardDataAfter = await crashAnalysisManager.getDashboardData()
        XCTAssertTrue(dashboardDataAfter.recentCrashes.isEmpty)
        XCTAssertEqual(crashAnalysisManager.systemHealth.score, 100.0, accuracy: 0.1)
        
        crashAnalysisManager.stopMonitoring()
    }
    
    // MARK: - System Health Integration Tests
    
    func testSystemHealthCalculation() async {
        // Given
        crashAnalysisManager.startMonitoring()
        
        // Initial health should be excellent
        XCTAssertEqual(crashAnalysisManager.systemHealth.status, .excellent)
        XCTAssertEqual(crashAnalysisManager.systemHealth.score, 100.0, accuracy: 0.1)
        
        // When - Simulate critical crashes
        for _ in 0..<3 {
            crashAnalysisManager.simulateCrash(type: .critical)
        }
        
        // Allow time for health calculation
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Then
        XCTAssertNotEqual(crashAnalysisManager.systemHealth.status, .excellent)
        XCTAssertLessThan(crashAnalysisManager.systemHealth.score, 100.0)
        XCTAssertTrue(crashAnalysisManager.systemHealth.hasRecentCrashes)
        
        crashAnalysisManager.stopMonitoring()
    }
    
    func testSystemHealthStatusLevels() async {
        // Given
        crashAnalysisManager.startMonitoring()
        
        // Test excellent health (initial state)
        XCTAssertEqual(crashAnalysisManager.systemHealth.status, .excellent)
        
        // When - Add moderate crashes
        for _ in 0..<2 {
            crashAnalysisManager.simulateCrash(type: .medium)
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Should be good or fair
        let healthAfterModerate = crashAnalysisManager.systemHealth.status
        XCTAssertTrue([.good, .fair].contains(healthAfterModerate))
        
        // When - Add critical crashes
        for _ in 0..<5 {
            crashAnalysisManager.simulateCrash(type: .critical)
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Should be poor or critical
        let healthAfterCritical = crashAnalysisManager.systemHealth.status
        XCTAssertTrue([.poor, .critical].contains(healthAfterCritical))
        
        crashAnalysisManager.stopMonitoring()
    }
    
    // MARK: - Reactive Integration Tests
    
    func testSystemHealthPublisher() {
        // Given
        let expectation = expectation(description: "System health updates")
        var healthUpdates: [SystemHealth] = []
        
        crashAnalysisManager.$systemHealth
            .sink { health in
                healthUpdates.append(health)
                if healthUpdates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        crashAnalysisManager.startMonitoring()
        crashAnalysisManager.simulateCrash(type: .critical)
        
        wait(for: [expectation], timeout: 10.0)
        
        // Then
        XCTAssertGreaterThanOrEqual(healthUpdates.count, 2)
        let initialHealth = healthUpdates.first!
        let updatedHealth = healthUpdates.last!
        
        XCTAssertTrue(initialHealth.isMonitoring)
        XCTAssertLessThan(updatedHealth.score, initialHealth.score)
        
        crashAnalysisManager.stopMonitoring()
    }
    
    func testDashboardDataPublisher() {
        // Given
        let expectation = expectation(description: "Dashboard data updates")
        var dashboardUpdates: [CrashDashboardData] = []
        
        crashAnalysisManager.$dashboardData
            .sink { data in
                dashboardUpdates.append(data)
                if dashboardUpdates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        crashAnalysisManager.startMonitoring()
        
        Task {
            let _ = await crashAnalysisManager.getDashboardData()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Then
        XCTAssertGreaterThanOrEqual(dashboardUpdates.count, 2)
        
        crashAnalysisManager.stopMonitoring()
    }
    
    // MARK: - Performance Integration Tests
    
    func testFullSystemPerformance() {
        measure {
            let expectation = expectation(description: "Full system cycle")
            
            Task {
                crashAnalysisManager.startMonitoring()
                
                // Simulate various operations
                crashAnalysisManager.simulateCrash(type: .memoryLeak)
                let _ = await crashAnalysisManager.getDashboardData()
                
                crashAnalysisManager.stopMonitoring()
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testDashboardDataGenerationPerformance() {
        crashAnalysisManager.startMonitoring()
        
        // Add some test data
        for crashType in CrashType.allCases.prefix(3) {
            crashAnalysisManager.simulateCrash(type: crashType)
        }
        
        measure {
            let expectation = expectation(description: "Dashboard data generation")
            
            Task {
                let _ = await crashAnalysisManager.getDashboardData()
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
        
        crashAnalysisManager.stopMonitoring()
    }
    
    // MARK: - Edge Cases Integration Tests
    
    func testConcurrentOperations() async {
        // Given
        crashAnalysisManager.startMonitoring()
        
        // When - Perform concurrent operations
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                self.crashAnalysisManager.simulateCrash(type: .memoryLeak)
            }
            
            group.addTask {
                self.crashAnalysisManager.simulateCrash(type: .unexpectedException)
            }
            
            group.addTask {
                let _ = await self.crashAnalysisManager.getDashboardData()
            }
            
            group.addTask {
                let _ = await self.crashAnalysisManager.getDashboardData()
            }
        }
        
        // Then - Should not crash or cause data corruption
        let dashboardData = await crashAnalysisManager.getDashboardData()
        XCTAssertNotNil(dashboardData)
        
        crashAnalysisManager.stopMonitoring()
    }
    
    func testRapidStartStop() {
        // Given & When
        for _ in 0..<5 {
            crashAnalysisManager.startMonitoring()
            crashAnalysisManager.stopMonitoring()
        }
        
        // Then - Should not crash or cause issues
        XCTAssertFalse(crashAnalysisManager.isMonitoring)
    }
    
    func testSystemHealthWithNoMonitoring() {
        // Given - Manager not monitoring
        XCTAssertFalse(crashAnalysisManager.isMonitoring)
        
        // When
        let health = crashAnalysisManager.systemHealth
        
        // Then
        XCTAssertFalse(health.isMonitoring)
        XCTAssertEqual(health.status, .excellent)
        XCTAssertEqual(health.score, 100.0, accuracy: 0.1)
    }
    
    // MARK: - Data Consistency Tests
    
    func testDataConsistencyAcrossComponents() async {
        // Given
        crashAnalysisManager.startMonitoring()
        
        // Generate test data
        let crashTypes: [CrashType] = [.memoryLeak, .unexpectedException, .signalException]
        for crashType in crashTypes {
            crashAnalysisManager.simulateCrash(type: crashType)
        }
        
        // Allow processing time
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // When
        let dashboardData = await crashAnalysisManager.getDashboardData()
        
        // Then - Verify data consistency
        XCTAssertEqual(dashboardData.recentCrashes.count, crashTypes.count)
        XCTAssertEqual(dashboardData.systemHealth.hasRecentCrashes, true)
        XCTAssertLessThan(dashboardData.systemHealth.score, 100.0)
        
        // Verify crash types match
        let detectedTypes = Set(dashboardData.recentCrashes.map { $0.crashType })
        for crashType in crashTypes {
            XCTAssertTrue(detectedTypes.contains(crashType))
        }
        
        crashAnalysisManager.stopMonitoring()
    }
}

// MARK: - Supporting Types for Tests

extension CrashType {
    static var critical: CrashType {
        return .signalException // Using signal exception as critical for testing
    }
}