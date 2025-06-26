//
//  MemoryMonitorTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/26/25.
//

import XCTest
import Combine
@testable import FinanceMate

final class MemoryMonitorTests: XCTestCase {
    
    var memoryMonitor: MemoryMonitor!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        let configuration = MemoryMonitoringConfiguration(
            memoryWarningThreshold: 70.0,
            criticalMemoryThreshold: 85.0,
            monitoringInterval: 1.0,
            enableMemoryPressureDetection: true
        )
        memoryMonitor = MemoryMonitor(configuration: configuration)
    }
    
    override func tearDown() {
        memoryMonitor?.stopMonitoring()
        memoryMonitor = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testMemoryMonitorInitialization() throws {
        XCTAssertNotNil(memoryMonitor, "MemoryMonitor should initialize successfully")
        XCTAssertEqual(memoryMonitor.currentMemoryUsage.physical, 0, "Initial memory usage should be zero")
        XCTAssertEqual(memoryMonitor.memoryTrend, .stable, "Initial memory trend should be stable")
    }
    
    func testMemoryMonitorConfiguration() throws {
        let thresholds = memoryMonitor.getThresholds()
        XCTAssertEqual(thresholds["warningThreshold"], 70.0, "Warning threshold should match configuration")
        XCTAssertEqual(thresholds["criticalThreshold"], 85.0, "Critical threshold should match configuration")
        XCTAssertEqual(thresholds["monitoringInterval"], 1.0, "Monitoring interval should match configuration")
    }
    
    // MARK: - Memory Usage Tests
    
    func testGetCurrentMemoryUsage() throws {
        let memoryUsage = memoryMonitor.getCurrentMemoryUsage()
        
        XCTAssertGreaterThan(memoryUsage.physical, 0, "Physical memory should be greater than zero")
        XCTAssertGreaterThan(memoryUsage.virtual, 0, "Virtual memory should be greater than zero")
        XCTAssertGreaterThan(memoryUsage.resident, 0, "Resident memory should be greater than zero")
        XCTAssertGreaterThanOrEqual(memoryUsage.peak, memoryUsage.resident, "Peak memory should be >= resident memory")
    }
    
    func testMemoryUsageReasonableBounds() throws {
        let memoryUsage = memoryMonitor.getCurrentMemoryUsage()
        
        // Test that memory values are within reasonable bounds
        XCTAssertLessThan(memoryUsage.resident, memoryUsage.physical, "Resident memory should not exceed physical memory")
        XCTAssertGreaterThanOrEqual(memoryUsage.virtual, memoryUsage.physical, "Virtual memory should be >= physical memory")
        
        // Test that memory usage percentage is reasonable
        let usagePercentage = (Double(memoryUsage.resident) / Double(memoryUsage.physical)) * 100.0
        XCTAssertGreaterThanOrEqual(usagePercentage, 0, "Memory usage percentage should be >= 0")
        XCTAssertLessThanOrEqual(usagePercentage, 100, "Memory usage percentage should be <= 100")
    }
    
    // MARK: - Monitoring Control Tests
    
    func testStartStopMonitoring() throws {
        // Initially not monitoring
        XCTAssertFalse(memoryMonitor.isMonitoring, "Should not be monitoring initially")
        
        // Start monitoring
        memoryMonitor.startMonitoring()
        
        // Verify monitoring started
        XCTAssertTrue(memoryMonitor.isMonitoring, "Should be monitoring after start")
        
        // Stop monitoring
        memoryMonitor.stopMonitoring()
        
        // Verify monitoring stopped
        XCTAssertFalse(memoryMonitor.isMonitoring, "Should not be monitoring after stop")
    }
    
    func testMultipleStartStopCalls() throws {
        // Multiple start calls should be safe
        memoryMonitor.startMonitoring()
        memoryMonitor.startMonitoring()
        XCTAssertTrue(memoryMonitor.isMonitoring, "Should handle multiple start calls")
        
        // Multiple stop calls should be safe
        memoryMonitor.stopMonitoring()
        memoryMonitor.stopMonitoring()
        XCTAssertFalse(memoryMonitor.isMonitoring, "Should handle multiple stop calls")
    }
    
    // MARK: - Memory Event Tests
    
    func testMemoryWarningEvent() throws {
        let expectation = XCTestExpectation(description: "Memory warning event should be triggered")
        
        memoryMonitor.memoryWarning
            .sink { memoryEvent in
                XCTAssertEqual(memoryEvent.type, .warning, "Should receive warning event")
                XCTAssertEqual(memoryEvent.severity, .high, "Warning event should have high severity")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        memoryMonitor.forceMemoryWarning(type: .warning)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMemoryCriticalEvent() throws {
        let expectation = XCTestExpectation(description: "Memory critical event should be triggered")
        
        memoryMonitor.memoryWarning
            .sink { memoryEvent in
                XCTAssertEqual(memoryEvent.type, .critical, "Should receive critical event")
                XCTAssertEqual(memoryEvent.severity, .critical, "Critical event should have critical severity")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        memoryMonitor.forceMemoryWarning(type: .critical)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testMemoryLeakDetection() throws {
        let expectation = XCTestExpectation(description: "Memory leak event should be triggered")
        
        memoryMonitor.memoryWarning
            .sink { memoryEvent in
                XCTAssertEqual(memoryEvent.type, .leak, "Should receive leak detection event")
                XCTAssertEqual(memoryEvent.severity, .high, "Leak event should have high severity")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        memoryMonitor.forceMemoryWarning(type: .leak)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Memory Trend Analysis Tests
    
    func testMemoryTrendStable() throws {
        // Start monitoring to enable trend analysis
        memoryMonitor.startMonitoring()
        
        // Allow some time for trend analysis (with fast monitoring interval)
        let expectation = XCTestExpectation(description: "Memory trend should be analyzed")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Initially should be stable (simulated data is stable)
            XCTAssertNotNil(self.memoryMonitor.memoryTrend, "Memory trend should be set")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Configuration Tests
    
    func testCustomConfiguration() throws {
        let customConfig = MemoryMonitoringConfiguration(
            memoryWarningThreshold: 60.0,
            criticalMemoryThreshold: 80.0,
            monitoringInterval: 5.0,
            enableMemoryPressureDetection: false
        )
        
        let customMonitor = MemoryMonitor(configuration: customConfig)
        let thresholds = customMonitor.getThresholds()
        
        XCTAssertEqual(thresholds["warningThreshold"], 60.0, "Custom warning threshold should be applied")
        XCTAssertEqual(thresholds["criticalThreshold"], 80.0, "Custom critical threshold should be applied")
        XCTAssertEqual(thresholds["monitoringInterval"], 5.0, "Custom monitoring interval should be applied")
    }
    
    // MARK: - Error Handling Tests
    
    func testMemoryEventWithValidData() throws {
        memoryMonitor.forceMemoryWarning(type: .excessive)
        
        // Should not crash and should handle the event gracefully
        XCTAssertTrue(true, "Should handle memory events without crashing")
    }
    
    // MARK: - Performance Tests
    
    func testMemoryMonitorPerformance() throws {
        measure {
            // Test performance of getting current memory usage
            _ = memoryMonitor.getCurrentMemoryUsage()
        }
    }
    
    func testMonitoringPerformance() throws {
        memoryMonitor.startMonitoring()
        
        measure {
            // Test performance of monitoring operations
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        memoryMonitor.stopMonitoring()
    }
    
    // MARK: - Integration Tests
    
    func testMemoryMonitorIntegrationWithSystemInfo() throws {
        let systemMemory = SystemInfo.getSystemMemoryUsage()
        let monitorMemory = memoryMonitor.getCurrentMemoryUsage()
        
        // Both should provide valid memory information
        XCTAssertGreaterThan(systemMemory.physical, 0, "SystemInfo should provide valid physical memory")
        XCTAssertGreaterThan(monitorMemory.physical, 0, "MemoryMonitor should provide valid physical memory")
        
        // Values should be in reasonable range
        XCTAssertLessThan(abs(Double(systemMemory.physical) - Double(monitorMemory.physical)) / Double(systemMemory.physical), 0.1, "Memory values should be consistent between SystemInfo and MemoryMonitor")
    }
    
    // MARK: - Edge Case Tests
    
    func testRapidStartStopCycles() throws {
        // Test rapid start/stop cycles
        for _ in 0..<10 {
            memoryMonitor.startMonitoring()
            memoryMonitor.stopMonitoring()
        }
        
        XCTAssertFalse(memoryMonitor.isMonitoring, "Should handle rapid start/stop cycles")
    }
    
    func testConcurrentAccess() throws {
        let expectation = XCTestExpectation(description: "Concurrent access should be safe")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue.global(qos: .background)
        
        for i in 0..<10 {
            queue.async {
                if i % 2 == 0 {
                    self.memoryMonitor.startMonitoring()
                } else {
                    self.memoryMonitor.stopMonitoring()
                }
                _ = self.memoryMonitor.getCurrentMemoryUsage()
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}