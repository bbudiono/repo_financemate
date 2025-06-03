// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashAnalysisCoreTests.swift
// FinanceMate-SandboxTests
//
// Purpose: Comprehensive test suite for crash analysis core functionality
// Issues & Complexity Summary: Complex test scenarios covering all crash analysis components
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~320
//   - Core Algorithm Complexity: Medium (test setup, mocking, validation)
//   - Dependencies: 3 New (XCTest, Foundation, Combine)
//   - State Management Complexity: Medium (test state management, async testing)
//   - Novelty/Uncertainty Factor: Low (standard testing patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 65%
// Problem Estimate (Inherent Problem Difficulty %): 60%
// Initial Code Complexity Estimate %: 62%
// Justification for Estimates: Standard testing patterns with some complexity in async testing
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import XCTest
import Foundation
import Combine
@testable import FinanceMate_Sandbox

final class CrashAnalysisCoreTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        try super.tearDownWithError()
    }
    
    // MARK: - CrashReport Tests
    
    func testCrashReportInitialization() {
        // Given
        let crashType = CrashType.memoryLeak
        let severity = CrashSeverity.high
        let errorMessage = "Test memory leak detected"
        let sessionId = "test-session-123"
        
        // When
        let crashReport = CrashReport(
            crashType: crashType,
            severity: severity,
            errorMessage: errorMessage,
            sessionId: sessionId
        )
        
        // Then
        XCTAssertEqual(crashReport.crashType, crashType)
        XCTAssertEqual(crashReport.severity, severity)
        XCTAssertEqual(crashReport.errorMessage, errorMessage)
        XCTAssertEqual(crashReport.sessionId, sessionId)
        XCTAssertNotNil(crashReport.id)
        XCTAssertFalse(crashReport.id.uuidString.isEmpty)
        XCTAssertTrue(crashReport.timestamp.timeIntervalSinceNow < 1.0) // Created within last second
    }
    
    func testCrashReportWithMetadata() {
        // Given
        let metadata = ["key1": "value1", "key2": "value2"]
        let stackTrace = ["frame1", "frame2", "frame3"]
        let breadcrumbs = ["breadcrumb1", "breadcrumb2"]
        
        // When
        let crashReport = CrashReport(
            crashType: .unexpectedException,
            severity: .critical,
            errorMessage: "Test exception",
            stackTrace: stackTrace,
            breadcrumbs: breadcrumbs,
            environmentInfo: metadata,
            sessionId: "test-session"
        )
        
        // Then
        XCTAssertEqual(crashReport.stackTrace, stackTrace)
        XCTAssertEqual(crashReport.breadcrumbs, breadcrumbs)
        XCTAssertEqual(crashReport.environmentInfo, metadata)
    }
    
    // MARK: - CrashSeverity Tests
    
    func testCrashSeverityComparison() {
        // Given & When & Then
        XCTAssertTrue(CrashSeverity.low < CrashSeverity.medium)
        XCTAssertTrue(CrashSeverity.medium < CrashSeverity.high)
        XCTAssertTrue(CrashSeverity.high < CrashSeverity.critical)
        
        XCTAssertFalse(CrashSeverity.critical < CrashSeverity.high)
        XCTAssertFalse(CrashSeverity.high < CrashSeverity.medium)
    }
    
    func testCrashSeverityDescription() {
        // Given & When & Then
        XCTAssertEqual(CrashSeverity.low.description, "Low")
        XCTAssertEqual(CrashSeverity.medium.description, "Medium")
        XCTAssertEqual(CrashSeverity.high.description, "High")
        XCTAssertEqual(CrashSeverity.critical.description, "Critical")
    }
    
    // MARK: - MemoryUsageInfo Tests
    
    func testMemoryUsageInfoInitialization() {
        // Given
        let totalMemory: UInt64 = 16_000_000_000 // 16GB
        let usedMemory: UInt64 = 8_000_000_000   // 8GB
        let freeMemory: UInt64 = 8_000_000_000   // 8GB
        let memoryPressure = "warning"
        
        // When
        let memoryInfo = MemoryUsageInfo(
            totalMemory: totalMemory,
            usedMemory: usedMemory,
            freeMemory: freeMemory,
            memoryPressure: memoryPressure
        )
        
        // Then
        XCTAssertEqual(memoryInfo.totalMemory, totalMemory)
        XCTAssertEqual(memoryInfo.usedMemory, usedMemory)
        XCTAssertEqual(memoryInfo.freeMemory, freeMemory)
        XCTAssertEqual(memoryInfo.memoryPressure, memoryPressure)
        XCTAssertTrue(memoryInfo.timestamp.timeIntervalSinceNow < 1.0)
    }
    
    // MARK: - PerformanceMetrics Tests
    
    func testPerformanceMetricsInitialization() {
        // Given
        let cpuUsage = 75.5
        let memoryUsage = 60.2
        let diskUsage = 45.8
        let networkLatency = 120.5
        let uiFrameRate = 58.9
        
        // When
        let metrics = PerformanceMetrics(
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            diskUsage: diskUsage,
            networkLatency: networkLatency,
            uiFrameRate: uiFrameRate
        )
        
        // Then
        XCTAssertEqual(metrics.cpuUsage, cpuUsage, accuracy: 0.01)
        XCTAssertEqual(metrics.memoryUsage, memoryUsage, accuracy: 0.01)
        XCTAssertEqual(metrics.diskUsage, diskUsage, accuracy: 0.01)
        XCTAssertEqual(metrics.networkLatency, networkLatency, accuracy: 0.01)
        XCTAssertEqual(metrics.uiFrameRate, uiFrameRate, accuracy: 0.01)
        XCTAssertTrue(metrics.timestamp.timeIntervalSinceNow < 1.0)
    }
    
    // MARK: - CrashAnalysisResult Tests
    
    func testCrashAnalysisResultInitialization() {
        // Given
        let totalCrashes = 25
        let crashesByType: [CrashType: Int] = [
            .memoryLeak: 10,
            .unexpectedException: 8,
            .signalException: 7
        ]
        let crashesBySeverity: [CrashSeverity: Int] = [
            .critical: 5,
            .high: 8,
            .medium: 12
        ]
        let trends: [CrashTrend] = []
        let patterns: [CrashPattern] = []
        let insights: [CrashInsight] = []
        let recommendations = ["Fix memory leaks", "Improve error handling"]
        
        // When
        let result = CrashAnalysisResult(
            totalCrashes: totalCrashes,
            crashesByType: crashesByType,
            crashesBySeverity: crashesBySeverity,
            trends: trends,
            patterns: patterns,
            insights: insights,
            recommendations: recommendations
        )
        
        // Then
        XCTAssertEqual(result.totalCrashes, totalCrashes)
        XCTAssertEqual(result.crashesByType, crashesByType)
        XCTAssertEqual(result.crashesBySeverity, crashesBySeverity)
        XCTAssertEqual(result.trends.count, trends.count)
        XCTAssertEqual(result.patterns.count, patterns.count)
        XCTAssertEqual(result.insights.count, insights.count)
        XCTAssertEqual(result.recommendations, recommendations)
        XCTAssertTrue(result.analysisDate.timeIntervalSinceNow < 1.0)
    }
    
    // MARK: - CrashTrend Tests
    
    func testCrashTrendCalculation() {
        // Given
        let period = "24h"
        let crashCount = 15
        let previousCount = 10
        let severity = CrashSeverity.high
        
        // When
        let trend = CrashTrend(
            period: period,
            crashCount: crashCount,
            previousCount: previousCount,
            severity: severity
        )
        
        // Then
        XCTAssertEqual(trend.period, period)
        XCTAssertEqual(trend.crashCount, crashCount)
        XCTAssertEqual(trend.previousCount, previousCount)
        XCTAssertEqual(trend.severity, severity)
        XCTAssertEqual(trend.changePercentage, 50.0, accuracy: 0.01) // (15-10)/10 * 100 = 50%
    }
    
    func testCrashTrendWithZeroPrevious() {
        // Given
        let crashCount = 10
        let previousCount = 0
        
        // When
        let trend = CrashTrend(
            period: "1h",
            crashCount: crashCount,
            previousCount: previousCount,
            severity: .medium
        )
        
        // Then
        XCTAssertEqual(trend.changePercentage, 0.0)
    }
    
    // MARK: - CrashPattern Tests
    
    func testCrashPatternInitialization() {
        // Given
        let description = "Common stack trace pattern"
        let frequency = 5
        let affectedVersions = ["1.0.0", "1.0.1"]
        let commonStackTrace = ["frame1", "frame2"]
        let recommendedAction = "Fix the root cause"
        
        // When
        let pattern = CrashPattern(
            description: description,
            frequency: frequency,
            affectedVersions: affectedVersions,
            commonStackTrace: commonStackTrace,
            recommendedAction: recommendedAction
        )
        
        // Then
        XCTAssertEqual(pattern.description, description)
        XCTAssertEqual(pattern.frequency, frequency)
        XCTAssertEqual(pattern.affectedVersions, affectedVersions)
        XCTAssertEqual(pattern.commonStackTrace, commonStackTrace)
        XCTAssertEqual(pattern.recommendedAction, recommendedAction)
        XCTAssertNotNil(pattern.id)
    }
    
    // MARK: - CrashInsight Tests
    
    func testCrashInsightInitialization() {
        // Given
        let title = "High memory usage detected"
        let description = "Memory usage is consistently high across sessions"
        let impact = CrashSeverity.high
        let confidence = 0.85
        let actionable = true
        let suggestedFix = "Implement memory optimization"
        
        // When
        let insight = CrashInsight(
            title: title,
            description: description,
            impact: impact,
            confidence: confidence,
            actionable: actionable,
            suggestedFix: suggestedFix
        )
        
        // Then
        XCTAssertEqual(insight.title, title)
        XCTAssertEqual(insight.description, description)
        XCTAssertEqual(insight.impact, impact)
        XCTAssertEqual(insight.confidence, confidence, accuracy: 0.01)
        XCTAssertEqual(insight.actionable, actionable)
        XCTAssertEqual(insight.suggestedFix, suggestedFix)
        XCTAssertNotNil(insight.id)
    }
    
    // MARK: - CrashMetrics Tests
    
    func testCrashMetricsInitialization() {
        // Given
        let crashFreeRate = 98.5
        let mtbf: TimeInterval = 3600 // 1 hour
        let mostCommonType = CrashType.memoryLeak
        let averageSeverity = 2.5
        let stabilityScore = 95.0
        
        // When
        let metrics = CrashMetrics(
            crashFreeRate: crashFreeRate,
            meanTimeBetweenFailures: mtbf,
            mostCommonCrashType: mostCommonType,
            averageSeverity: averageSeverity,
            stabilityScore: stabilityScore
        )
        
        // Then
        XCTAssertEqual(metrics.crashFreeRate, crashFreeRate, accuracy: 0.01)
        XCTAssertEqual(metrics.meanTimeBetweenFailures, mtbf, accuracy: 0.01)
        XCTAssertEqual(metrics.mostCommonCrashType, mostCommonType)
        XCTAssertEqual(metrics.averageSeverity, averageSeverity, accuracy: 0.01)
        XCTAssertEqual(metrics.stabilityScore, stabilityScore, accuracy: 0.01)
        XCTAssertTrue(metrics.lastUpdated.timeIntervalSinceNow < 1.0)
    }
    
    // MARK: - ProcessInfo Extension Tests
    
    func testMachineModelName() {
        // Given & When
        let modelName = ProcessInfo.processInfo.machineModelName
        
        // Then
        XCTAssertFalse(modelName.isEmpty)
        XCTAssertNotEqual(modelName, "Unknown")
    }
    
    // MARK: - Integration Tests
    
    func testCrashReportJSONSerialization() throws {
        // Given
        let crashReport = CrashReport(
            crashType: .memoryLeak,
            severity: .high,
            errorMessage: "Test crash",
            stackTrace: ["frame1", "frame2"],
            breadcrumbs: ["breadcrumb1", "breadcrumb2"],
            environmentInfo: ["env1": "value1"],
            sessionId: "test-session"
        )
        
        // When
        let jsonData = try JSONEncoder().encode(crashReport)
        let decodedReport = try JSONDecoder().decode(CrashReport.self, from: jsonData)
        
        // Then
        XCTAssertEqual(decodedReport.id, crashReport.id)
        XCTAssertEqual(decodedReport.crashType, crashReport.crashType)
        XCTAssertEqual(decodedReport.severity, crashReport.severity)
        XCTAssertEqual(decodedReport.errorMessage, crashReport.errorMessage)
        XCTAssertEqual(decodedReport.stackTrace, crashReport.stackTrace)
        XCTAssertEqual(decodedReport.breadcrumbs, crashReport.breadcrumbs)
        XCTAssertEqual(decodedReport.environmentInfo, crashReport.environmentInfo)
        XCTAssertEqual(decodedReport.sessionId, crashReport.sessionId)
    }
    
    func testCrashAnalysisResultJSONSerialization() throws {
        // Given
        let result = CrashAnalysisResult(
            totalCrashes: 10,
            crashesByType: [.memoryLeak: 5],
            crashesBySeverity: [.high: 3],
            trends: [],
            patterns: [],
            insights: [],
            recommendations: ["Fix issues"]
        )
        
        // When
        let jsonData = try JSONEncoder().encode(result)
        let decodedResult = try JSONDecoder().decode(CrashAnalysisResult.self, from: jsonData)
        
        // Then
        XCTAssertEqual(decodedResult.totalCrashes, result.totalCrashes)
        XCTAssertEqual(decodedResult.crashesByType, result.crashesByType)
        XCTAssertEqual(decodedResult.crashesBySeverity, result.crashesBySeverity)
        XCTAssertEqual(decodedResult.recommendations, result.recommendations)
    }
    
    // MARK: - Performance Tests
    
    func testCrashReportCreationPerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = CrashReport(
                    crashType: .memoryLeak,
                    severity: .medium,
                    errorMessage: "Performance test crash",
                    sessionId: "perf-test"
                )
            }
        }
    }
    
    func testCrashAnalysisResultCreationPerformance() {
        measure {
            for _ in 0..<100 {
                let _ = CrashAnalysisResult(
                    totalCrashes: 100,
                    crashesByType: [.memoryLeak: 50, .unexpectedException: 30, .signalException: 20],
                    crashesBySeverity: [.critical: 10, .high: 30, .medium: 40, .low: 20],
                    trends: [],
                    patterns: [],
                    insights: [],
                    recommendations: []
                )
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testCrashReportWithEmptyData() {
        // Given & When
        let crashReport = CrashReport(
            crashType: .unknown,
            severity: .low,
            errorMessage: "",
            stackTrace: [],
            breadcrumbs: [],
            environmentInfo: [:],
            sessionId: ""
        )
        
        // Then
        XCTAssertEqual(crashReport.errorMessage, "")
        XCTAssertTrue(crashReport.stackTrace.isEmpty)
        XCTAssertTrue(crashReport.breadcrumbs.isEmpty)
        XCTAssertTrue(crashReport.environmentInfo.isEmpty)
        XCTAssertEqual(crashReport.sessionId, "")
    }
    
    func testCrashAnalysisResultEmpty() {
        // Given & When
        let result = CrashAnalysisResult.empty
        
        // Then
        XCTAssertEqual(result.totalCrashes, 0)
        XCTAssertTrue(result.crashesByType.isEmpty)
        XCTAssertTrue(result.crashesBySeverity.isEmpty)
        XCTAssertTrue(result.trends.isEmpty)
        XCTAssertTrue(result.patterns.isEmpty)
        XCTAssertTrue(result.insights.isEmpty)
        XCTAssertTrue(result.recommendations.isEmpty)
    }
    
    func testCrashMetricsEmpty() {
        // Given & When
        let metrics = CrashMetrics.empty
        
        // Then
        XCTAssertEqual(metrics.crashFreeRate, 100.0)
        XCTAssertEqual(metrics.meanTimeBetweenFailures, 0)
        XCTAssertEqual(metrics.mostCommonCrashType, .unknown)
        XCTAssertEqual(metrics.averageSeverity, 0)
        XCTAssertEqual(metrics.stabilityScore, 100.0)
    }
}

// MARK: - Mock Classes for Testing

class MockCrashStorage: CrashStorageProtocol {
    var savedReports: [CrashReport] = []
    var shouldThrowError = false
    
    func saveCrashReport(_ report: CrashReport) async throws {
        if shouldThrowError {
            throw TestError.mockError
        }
        savedReports.append(report)
    }
    
    func getCrashReports(limit: Int?, since: Date?) async throws -> [CrashReport] {
        if shouldThrowError {
            throw TestError.mockError
        }
        var filtered = savedReports
        if let since = since {
            filtered = filtered.filter { $0.timestamp >= since }
        }
        if let limit = limit {
            filtered = Array(filtered.prefix(limit))
        }
        return filtered.sorted { $0.timestamp > $1.timestamp }
    }
    
    func deleteCrashReport(id: UUID) async throws {
        if shouldThrowError {
            throw TestError.mockError
        }
        savedReports.removeAll { $0.id == id }
    }
    
    func getCrashReportsByType(_ type: CrashType) async throws -> [CrashReport] {
        if shouldThrowError {
            throw TestError.mockError
        }
        return savedReports.filter { $0.crashType == type }
    }
    
    func getCrashReportsBySeverity(_ severity: CrashSeverity) async throws -> [CrashReport] {
        if shouldThrowError {
            throw TestError.mockError
        }
        return savedReports.filter { $0.severity == severity }
    }
    
    func clearAllCrashReports() async throws {
        if shouldThrowError {
            throw TestError.mockError
        }
        savedReports.removeAll()
    }
}

enum TestError: Error {
    case mockError
}