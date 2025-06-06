// SANDBOX FILE: For testing/development. See .cursorrules.
//
// PerformanceMonitorTests.swift
// FinanceMate-SandboxTests
//
// Purpose: Comprehensive test suite for performance monitoring functionality
// Issues & Complexity Summary: Complex async testing with system resource monitoring validation
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~280
//   - Core Algorithm Complexity: Medium (async testing, system resource validation, mock setup)
//   - Dependencies: 3 New (XCTest, Foundation, Combine)
//   - State Management Complexity: Medium (async state validation, timing-sensitive tests)
//   - Novelty/Uncertainty Factor: Low (standard testing patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 68%
// Problem Estimate (Inherent Problem Difficulty %): 65%
// Initial Code Complexity Estimate %: 66%
// Justification for Estimates: Standard testing with some complexity in async and system monitoring tests
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import XCTest
import Foundation
import Combine
@testable import FinanceMate_Sandbox

final class PerformanceMonitorTests: XCTestCase {
    var performanceMonitor: PerformanceMonitor!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        performanceMonitor = PerformanceMonitor()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        performanceMonitor?.stopMonitoring()
        performanceMonitor = nil
        cancellables = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initialization Tests
    
    func testPerformanceMonitorInitialization() {
        // Given & When
        let monitor = PerformanceMonitor()
        
        // Then
        XCTAssertNotNil(monitor)
        XCTAssertNil(monitor.currentSnapshot)
        XCTAssertTrue(monitor.memoryLeaks.isEmpty)
        XCTAssertTrue(monitor.performanceAlerts.isEmpty)
    }
    
    // MARK: - Configuration Tests
    
    func testPerformanceMonitorConfiguration() {
        // Given
        let monitoringInterval: TimeInterval = 10.0
        let memoryLeakThreshold: UInt64 = 200 * 1024 * 1024 // 200MB
        let cpuThreshold: Double = 90.0
        
        // When
        performanceMonitor.configure(
            monitoringInterval: monitoringInterval,
            memoryLeakThreshold: memoryLeakThreshold,
            cpuThreshold: cpuThreshold
        )
        
        // Then
        // Configuration is internal, so we test indirectly through behavior
        XCTAssertNotNil(performanceMonitor)
    }
    
    // MARK: - Monitoring Lifecycle Tests
    
    func testStartStopMonitoring() {
        // Given
        let expectation = expectation(description: "Monitoring state changes")
        var stateChanges: [Bool] = []
        
        // When
        performanceMonitor.$currentSnapshot
            .compactMap { $0 }
            .sink { _ in
                stateChanges.append(true)
                if stateChanges.count >= 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        performanceMonitor.startMonitoring()
        
        wait(for: [expectation], timeout: 10.0)
        
        performanceMonitor.stopMonitoring()
        
        // Then
        XCTAssertTrue(stateChanges.count >= 1)
    }
    
    // MARK: - Performance Snapshot Tests
    
    func testGetCurrentMetrics() async {
        // Given
        performanceMonitor.startMonitoring()
        
        // When
        let snapshot = await performanceMonitor.getCurrentMetrics()
        
        // Then
        XCTAssertNotNil(snapshot)
        XCTAssertTrue(snapshot.timestamp.timeIntervalSinceNow < 5.0) // Recent snapshot
        XCTAssertGreaterThanOrEqual(snapshot.cpuUsage.coreCount, 1)
        XCTAssertGreaterThan(snapshot.memoryUsage.physical, 0)
        XCTAssertNotNil(snapshot.energyImpact)
        
        performanceMonitor.stopMonitoring()
    }
    
    func testPerformanceSnapshotComponents() async {
        // Given
        performanceMonitor.startMonitoring()
        
        // When
        let snapshot = await performanceMonitor.getCurrentMetrics()
        
        // Then
        // CPU Usage validation
        XCTAssertGreaterThanOrEqual(snapshot.cpuUsage.totalUsage, 0)
        XCTAssertLessThanOrEqual(snapshot.cpuUsage.totalUsage, 100)
        XCTAssertGreaterThanOrEqual(snapshot.cpuUsage.coreCount, 1)
        
        // Memory Usage validation
        XCTAssertGreaterThan(snapshot.memoryUsage.resident, 0)
        XCTAssertGreaterThan(snapshot.memoryUsage.virtual, 0)
        
        // Disk Usage validation
        XCTAssertGreaterThanOrEqual(snapshot.diskUsage.totalSpace, 0)
        XCTAssertGreaterThanOrEqual(snapshot.diskUsage.freeSpace, 0)
        
        // Energy Impact validation
        XCTAssertGreaterThanOrEqual(snapshot.energyImpact.cpuImpact, 0)
        XCTAssertGreaterThanOrEqual(snapshot.energyImpact.gpuImpact, 0)
        
        performanceMonitor.stopMonitoring()
    }
    
    // MARK: - Memory Usage Tests
    
    func testGetMemoryUsage() async {
        // Given
        performanceMonitor.startMonitoring()
        
        // When
        let memoryUsage = await performanceMonitor.getMemoryUsage()
        
        // Then
        XCTAssertGreaterThan(memoryUsage.totalMemory, 0)
        XCTAssertGreaterThan(memoryUsage.usedMemory, 0)
        XCTAssertGreaterThanOrEqual(memoryUsage.freeMemory, 0)
        XCTAssertFalse(memoryUsage.memoryPressure.isEmpty)
        XCTAssertTrue(memoryUsage.timestamp.timeIntervalSinceNow < 2.0)
        
        performanceMonitor.stopMonitoring()
    }
    
    // MARK: - Memory Leak Detection Tests
    
    func testDetectMemoryLeaks() async {
        // Given
        performanceMonitor.startMonitoring()
        
        // When
        let memoryLeaks = await performanceMonitor.detectMemoryLeaks()
        
        // Then
        XCTAssertNotNil(memoryLeaks)
        // In a clean test environment, we shouldn't detect leaks initially
        // The actual leak detection would be tested with specific scenarios
        
        performanceMonitor.stopMonitoring()
    }
    
    // MARK: - Execution Time Measurement Tests
    
    func testMeasureExecutionTime() async throws {
        // Given
        let expectedDuration: TimeInterval = 0.1
        
        // When
        let (result, duration) = await performanceMonitor.measureExecutionTime {
            try await Task.sleep(nanoseconds: UInt64(expectedDuration * 1_000_000_000))
            return "test result"
        }
        
        // Then
        XCTAssertEqual(result, "test result")
        XCTAssertGreaterThanOrEqual(duration, expectedDuration - 0.01) // Allow small tolerance
        XCTAssertLessThanOrEqual(duration, expectedDuration + 0.05) // Allow some overhead
    }
    
    func testMeasureExecutionTimeWithThrowingOperation() async {
        // Given
        enum TestError: Error {
            case testError
        }
        
        // When & Then
        do {
            let _ = try await performanceMonitor.measureExecutionTime {
                throw TestError.testError
            }
            XCTFail("Should have thrown an error")
        } catch TestError.testError {
            // Expected behavior
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Performance Data Model Tests
    
    func testCPUUsageInitialization() {
        // Given
        let userTime = 25.5
        let systemTime = 15.2
        let idleTime = 59.3
        let coreCount = 8
        
        // When
        let cpuUsage = CPUUsage(
            userTime: userTime,
            systemTime: systemTime,
            idleTime: idleTime,
            coreCount: coreCount
        )
        
        // Then
        XCTAssertEqual(cpuUsage.userTime, userTime, accuracy: 0.01)
        XCTAssertEqual(cpuUsage.systemTime, systemTime, accuracy: 0.01)
        XCTAssertEqual(cpuUsage.idleTime, idleTime, accuracy: 0.01)
        XCTAssertEqual(cpuUsage.totalUsage, userTime + systemTime, accuracy: 0.01)
        XCTAssertEqual(cpuUsage.coreCount, coreCount)
    }
    
    func testMemoryUsageInitialization() {
        // Given
        let physical: UInt64 = 16_000_000_000
        let virtual: UInt64 = 32_000_000_000
        let resident: UInt64 = 8_000_000_000
        let shared: UInt64 = 1_000_000_000
        let peak: UInt64 = 10_000_000_000
        let pressure = MemoryPressure.warning
        
        // When
        let memoryUsage = MemoryUsage(
            physical: physical,
            virtual: virtual,
            resident: resident,
            shared: shared,
            peak: peak,
            pressure: pressure
        )
        
        // Then
        XCTAssertEqual(memoryUsage.physical, physical)
        XCTAssertEqual(memoryUsage.virtual, virtual)
        XCTAssertEqual(memoryUsage.resident, resident)
        XCTAssertEqual(memoryUsage.shared, shared)
        XCTAssertEqual(memoryUsage.peak, peak)
        XCTAssertEqual(memoryUsage.pressure, pressure)
    }
    
    func testMemoryPressureDescription() {
        // Given & When & Then
        XCTAssertEqual(MemoryPressure.normal.description, "Normal")
        XCTAssertEqual(MemoryPressure.warning.description, "Warning")
        XCTAssertEqual(MemoryPressure.urgent.description, "Urgent")
        XCTAssertEqual(MemoryPressure.critical.description, "Critical")
    }
    
    func testEnergyImpactCalculation() {
        // Given
        let cpuImpact = 30.0
        let gpuImpact = 10.0
        let networkImpact = 5.0
        let displayImpact = 15.0
        
        // When
        let energyImpact = EnergyImpact(
            cpuImpact: cpuImpact,
            gpuImpact: gpuImpact,
            networkImpact: networkImpact,
            displayImpact: displayImpact
        )
        
        // Then
        XCTAssertEqual(energyImpact.cpuImpact, cpuImpact, accuracy: 0.01)
        XCTAssertEqual(energyImpact.gpuImpact, gpuImpact, accuracy: 0.01)
        XCTAssertEqual(energyImpact.networkImpact, networkImpact, accuracy: 0.01)
        XCTAssertEqual(energyImpact.displayImpact, displayImpact, accuracy: 0.01)
        XCTAssertEqual(energyImpact.overallImpact, .medium) // Total = 60, which is medium
    }
    
    func testEnergyImpactLevels() {
        // Test low impact
        let lowImpact = EnergyImpact(cpuImpact: 5, gpuImpact: 5, networkImpact: 5, displayImpact: 5)
        XCTAssertEqual(lowImpact.overallImpact, .low) // Total = 20
        
        // Test medium impact
        let mediumImpact = EnergyImpact(cpuImpact: 15, gpuImpact: 15, networkImpact: 15, displayImpact: 15)
        XCTAssertEqual(mediumImpact.overallImpact, .medium) // Total = 60
        
        // Test high impact
        let highImpact = EnergyImpact(cpuImpact: 25, gpuImpact: 25, networkImpact: 25, displayImpact: 25)
        XCTAssertEqual(highImpact.overallImpact, .high) // Total = 100
    }
    
    func testMemoryLeakInitialization() {
        // Given
        let objectType = "TestObject"
        let instanceCount = 100
        let totalMemory: UInt64 = 1024 * 1024 // 1MB
        let severity = MemoryLeakSeverity.moderate
        let stackTrace = ["frame1", "frame2", "frame3"]
        
        // When
        let memoryLeak = MemoryLeak(
            objectType: objectType,
            instanceCount: instanceCount,
            totalMemory: totalMemory,
            severity: severity,
            stackTrace: stackTrace
        )
        
        // Then
        XCTAssertEqual(memoryLeak.objectType, objectType)
        XCTAssertEqual(memoryLeak.instanceCount, instanceCount)
        XCTAssertEqual(memoryLeak.totalMemory, totalMemory)
        XCTAssertEqual(memoryLeak.severity, severity)
        XCTAssertEqual(memoryLeak.stackTrace, stackTrace)
        XCTAssertNotNil(memoryLeak.id)
        XCTAssertTrue(memoryLeak.detectionTime.timeIntervalSinceNow < 1.0)
    }
    
    // MARK: - Performance Alert Tests
    
    func testPerformanceAlertInitialization() {
        // Given
        let type = PerformanceAlertType.highCPUUsage
        let message = "CPU usage is at 95%"
        let severity = AlertSeverity.warning
        let timestamp = Date()
        
        // When
        let alert = PerformanceAlert(
            type: type,
            message: message,
            severity: severity,
            timestamp: timestamp
        )
        
        // Then
        XCTAssertEqual(alert.type, type)
        XCTAssertEqual(alert.message, message)
        XCTAssertEqual(alert.severity, severity)
        XCTAssertEqual(alert.timestamp, timestamp)
        XCTAssertNotNil(alert.id)
    }
    
    // MARK: - Integration Tests
    
    func testPerformanceSnapshotJSONSerialization() throws {
        // Given
        let cpuUsage = CPUUsage(userTime: 25, systemTime: 15, idleTime: 60, coreCount: 4)
        let memoryUsage = MemoryUsage(
            physical: 16_000_000_000,
            virtual: 32_000_000_000,
            resident: 8_000_000_000,
            shared: 1_000_000_000,
            peak: 10_000_000_000,
            pressure: .normal
        )
        let diskUsage = DiskUsage(
            totalSpace: 1_000_000_000_000,
            freeSpace: 500_000_000_000,
            usedSpace: 500_000_000_000,
            readOperations: 1000,
            writeOperations: 500,
            readThroughput: 100.0,
            writeThroughput: 50.0
        )
        let energyImpact = EnergyImpact(cpuImpact: 30, gpuImpact: 10, networkImpact: 5, displayImpact: 15)
        
        let snapshot = PerformanceSnapshot(
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            diskUsage: diskUsage,
            thermalState: .nominal,
            energyImpact: energyImpact
        )
        
        // When
        let jsonData = try JSONEncoder().encode(snapshot)
        let decodedSnapshot = try JSONDecoder().decode(PerformanceSnapshot.self, from: jsonData)
        
        // Then
        XCTAssertEqual(decodedSnapshot.cpuUsage.totalUsage, snapshot.cpuUsage.totalUsage, accuracy: 0.01)
        XCTAssertEqual(decodedSnapshot.memoryUsage.physical, snapshot.memoryUsage.physical)
        XCTAssertEqual(decodedSnapshot.diskUsage.totalSpace, snapshot.diskUsage.totalSpace)
        XCTAssertEqual(decodedSnapshot.energyImpact.overallImpact, snapshot.energyImpact.overallImpact)
    }
    
    // MARK: - Performance Tests
    
    func testGetCurrentMetricsPerformance() {
        performanceMonitor.startMonitoring()
        
        measure {
            let expectation = expectation(description: "Get metrics")
            Task {
                let _ = await performanceMonitor.getCurrentMetrics()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
        
        performanceMonitor.stopMonitoring()
    }
    
    func testMemoryLeakDetectionPerformance() {
        performanceMonitor.startMonitoring()
        
        measure {
            let expectation = expectation(description: "Detect memory leaks")
            Task {
                let _ = await performanceMonitor.detectMemoryLeaks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
        
        performanceMonitor.stopMonitoring()
    }
    
    // MARK: - Edge Cases
    
    func testMonitoringWithoutStarting() async {
        // Given - Monitor not started
        
        // When
        let snapshot = await performanceMonitor.getCurrentMetrics()
        
        // Then
        XCTAssertNotNil(snapshot) // Should still return a snapshot
    }
    
    func testDoubleStartMonitoring() {
        // Given
        performanceMonitor.startMonitoring()
        
        // When
        performanceMonitor.startMonitoring() // Second start should be safe
        
        // Then
        // Should not crash or cause issues
        performanceMonitor.stopMonitoring()
    }
    
    func testDoubleStopMonitoring() {
        // Given
        performanceMonitor.startMonitoring()
        performanceMonitor.stopMonitoring()
        
        // When
        performanceMonitor.stopMonitoring() // Second stop should be safe
        
        // Then
        // Should not crash or cause issues
    }
    
    // MARK: - Reactive Tests
    
    func testCurrentSnapshotPublisher() {
        // Given
        let expectation = expectation(description: "Current snapshot publisher")
        var receivedSnapshot: PerformanceSnapshot?
        
        // When
        performanceMonitor.$currentSnapshot
            .compactMap { $0 }
            .first()
            .sink { snapshot in
                receivedSnapshot = snapshot
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        performanceMonitor.startMonitoring()
        
        wait(for: [expectation], timeout: 10.0)
        performanceMonitor.stopMonitoring()
        
        // Then
        XCTAssertNotNil(receivedSnapshot)
    }
    
    func testPerformanceAlertsPublisher() {
        // Given
        let expectation = expectation(description: "Performance alerts publisher")
        var alertsReceived = false
        
        // When
        performanceMonitor.$performanceAlerts
            .sink { alerts in
                if !alerts.isEmpty {
                    alertsReceived = true
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        performanceMonitor.startMonitoring()
        
        // Simulate high CPU to trigger an alert (this might not work in test environment)
        // The test validates the publisher mechanism, not necessarily alert generation
        
        wait(for: [expectation], timeout: 5.0)
        performanceMonitor.stopMonitoring()
        
        // Then
        // The test validates the publisher works, actual alerts depend on system state
    }
}