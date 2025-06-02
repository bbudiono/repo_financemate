// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashAnalysisCore.swift
// FinanceMate-Sandbox
//
// Purpose: Core crash analysis infrastructure providing systematic crash detection, logging, and analysis
// Issues & Complexity Summary: Complex crash handling with multiple data collection points and real-time analysis
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~450
//   - Core Algorithm Complexity: High (crash detection, signal handling, concurrent logging)
//   - Dependencies: 5 New (Foundation, os.log, CrashReporter, MetricKit, os.signpost)
//   - State Management Complexity: High (concurrent crash data collection, thread safety)
//   - Novelty/Uncertainty Factor: Medium (established crash reporting patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
// Problem Estimate (Inherent Problem Difficulty %): 80%
// Initial Code Complexity Estimate %: 82%
// Justification for Estimates: Crash analysis requires deep system integration and thread-safe operations
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import Foundation
import os.log
import os.signpost
import MetricKit

// MARK: - Core Crash Models

/// Represents different types of crashes in the system
public enum CrashType: String, CaseIterable, Codable {
    case memoryLeak = "memory_leak"
    case unexpectedException = "unexpected_exception"
    case signalException = "signal_exception"
    case hangOrTimeout = "hang_timeout"
    case networkFailure = "network_failure"
    case uiResponsiveness = "ui_responsiveness"
    case dataCorruption = "data_corruption"
    case authenticationFailure = "auth_failure"
    case unknown = "unknown"
}

/// Severity levels for crash categorization
public enum CrashSeverity: Int, CaseIterable, Codable, Comparable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
    
    public static func < (lhs: CrashSeverity, rhs: CrashSeverity) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
}

/// Comprehensive crash report structure
public struct CrashReport: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let crashType: CrashType
    public let severity: CrashSeverity
    public let applicationVersion: String
    public let buildNumber: String
    public let systemVersion: String
    public let deviceModel: String
    public let errorMessage: String
    public let stackTrace: [String]
    public let breadcrumbs: [String]
    public let environmentInfo: [String: String]
    public let memoryUsage: MemoryUsageInfo?
    public let performanceMetrics: CrashPerformanceMetrics?
    public let userId: String?
    public let sessionId: String
    
    public init(
        crashType: CrashType,
        severity: CrashSeverity,
        errorMessage: String,
        stackTrace: [String] = [],
        breadcrumbs: [String] = [],
        environmentInfo: [String: String] = [:],
        memoryUsage: MemoryUsageInfo? = nil,
        performanceMetrics: CrashPerformanceMetrics? = nil,
        userId: String? = nil,
        sessionId: String
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.crashType = crashType
        self.severity = severity
        self.applicationVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        self.buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        self.systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        self.deviceModel = ProcessInfo.processInfo.machineModelName
        self.errorMessage = errorMessage
        self.stackTrace = stackTrace
        self.breadcrumbs = breadcrumbs
        self.environmentInfo = environmentInfo
        self.memoryUsage = memoryUsage
        self.performanceMetrics = performanceMetrics
        self.userId = userId
        self.sessionId = sessionId
    }
}

/// Memory usage information for crash analysis
public struct MemoryUsageInfo: Codable {
    public let totalMemory: UInt64
    public let usedMemory: UInt64
    public let freeMemory: UInt64
    public let memoryPressure: String
    public let timestamp: Date
    
    public init(totalMemory: UInt64, usedMemory: UInt64, freeMemory: UInt64, memoryPressure: String) {
        self.totalMemory = totalMemory
        self.usedMemory = usedMemory
        self.freeMemory = freeMemory
        self.memoryPressure = memoryPressure
        self.timestamp = Date()
    }
}

/// Performance metrics for crash context
public struct CrashPerformanceMetrics: Codable {
    public let cpuUsage: Double
    public let memoryUsage: Double
    public let diskUsage: Double
    public let networkLatency: Double?
    public let uiFrameRate: Double?
    public let timestamp: Date
    
    public init(
        cpuUsage: Double,
        memoryUsage: Double,
        diskUsage: Double,
        networkLatency: Double? = nil,
        uiFrameRate: Double? = nil
    ) {
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.diskUsage = diskUsage
        self.networkLatency = networkLatency
        self.uiFrameRate = uiFrameRate
        self.timestamp = Date()
    }
}

// MARK: - Core Protocols

/// Protocol for crash detection and reporting
public protocol CrashDetectorProtocol {
    func startMonitoring()
    func stopMonitoring()
    func reportCrash(_ report: CrashReport)
    func simulateCrash(type: CrashType) // For testing purposes
}

/// Protocol for crash data storage and retrieval
public protocol CrashStorageProtocol {
    func saveCrashReport(_ report: CrashReport) async throws
    func getCrashReports(limit: Int?, since: Date?) async throws -> [CrashReport]
    func deleteCrashReport(id: UUID) async throws
    func getCrashReportsByType(_ type: CrashType) async throws -> [CrashReport]
    func getCrashReportsBySeverity(_ severity: CrashSeverity) async throws -> [CrashReport]
}

/// Protocol for crash analysis and pattern detection
public protocol CrashAnalyzerProtocol {
    func analyzeCrashTrends() async throws -> CrashAnalysisResult
    func detectPatterns(in reports: [CrashReport]) async throws -> [CrashPattern]
    func generateInsights() async throws -> [CrashInsight]
    func calculateCrashMetrics() async throws -> CrashMetrics
}

/// Protocol for crash alerting and notification
public protocol CrashAlertingProtocol {
    func shouldAlert(for report: CrashReport) -> Bool
    func sendAlert(for report: CrashReport) async throws
    func configureCriticalityThresholds(_ thresholds: [CrashSeverity: Int])
}

// MARK: - Analysis Results

/// Comprehensive crash analysis result
public struct CrashAnalysisResult: Codable {
    public let analysisDate: Date
    public let totalCrashes: Int
    public let crashesByType: [CrashType: Int]
    public let crashesBySeverity: [CrashSeverity: Int]
    public let trends: [CrashTrend]
    public let patterns: [CrashPattern]
    public let insights: [CrashInsight]
    public let recommendations: [String]
    
    public init(
        totalCrashes: Int,
        crashesByType: [CrashType: Int],
        crashesBySeverity: [CrashSeverity: Int],
        trends: [CrashTrend],
        patterns: [CrashPattern],
        insights: [CrashInsight],
        recommendations: [String]
    ) {
        self.analysisDate = Date()
        self.totalCrashes = totalCrashes
        self.crashesByType = crashesByType
        self.crashesBySeverity = crashesBySeverity
        self.trends = trends
        self.patterns = patterns
        self.insights = insights
        self.recommendations = recommendations
    }
}

/// Crash trend information
public struct CrashTrend: Codable {
    public let period: String
    public let crashCount: Int
    public let previousCount: Int
    public let changePercentage: Double
    public let severity: CrashSeverity
    
    public init(period: String, crashCount: Int, previousCount: Int, severity: CrashSeverity) {
        self.period = period
        self.crashCount = crashCount
        self.previousCount = previousCount
        self.changePercentage = previousCount > 0 ? Double(crashCount - previousCount) / Double(previousCount) * 100 : 0
        self.severity = severity
    }
}

/// Detected crash pattern
public struct CrashPattern: Codable, Identifiable {
    public var id = UUID()
    public let description: String
    public let frequency: Int
    public let affectedVersions: [String]
    public let commonStackTrace: [String]
    public let recommendedAction: String
    
    public init(
        description: String,
        frequency: Int,
        affectedVersions: [String],
        commonStackTrace: [String],
        recommendedAction: String
    ) {
        self.description = description
        self.frequency = frequency
        self.affectedVersions = affectedVersions
        self.commonStackTrace = commonStackTrace
        self.recommendedAction = recommendedAction
    }
}

/// Crash insight for actionable intelligence
public struct CrashInsight: Codable, Identifiable {
    public var id = UUID()
    public let title: String
    public let description: String
    public let impact: CrashSeverity
    public let confidence: Double // 0.0 to 1.0
    public let actionable: Bool
    public let suggestedFix: String?
    
    public init(
        title: String,
        description: String,
        impact: CrashSeverity,
        confidence: Double,
        actionable: Bool,
        suggestedFix: String? = nil
    ) {
        self.title = title
        self.description = description
        self.impact = impact
        self.confidence = confidence
        self.actionable = actionable
        self.suggestedFix = suggestedFix
    }
}

/// Overall crash metrics for dashboard
public struct CrashMetrics: Codable {
    public let crashFreeRate: Double // Percentage of sessions without crashes
    public let meanTimeBetweenFailures: TimeInterval
    public let mostCommonCrashType: CrashType
    public let averageSeverity: Double
    public let stabilityScore: Double // 0.0 to 100.0
    public let lastUpdated: Date
    
    public init(
        crashFreeRate: Double,
        meanTimeBetweenFailures: TimeInterval,
        mostCommonCrashType: CrashType,
        averageSeverity: Double,
        stabilityScore: Double
    ) {
        self.crashFreeRate = crashFreeRate
        self.meanTimeBetweenFailures = meanTimeBetweenFailures
        self.mostCommonCrashType = mostCommonCrashType
        self.averageSeverity = averageSeverity
        self.stabilityScore = stabilityScore
        self.lastUpdated = Date()
    }
}

// MARK: - Extensions

extension ProcessInfo {
    /// Get machine model name for crash reporting
    var machineModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)) ?? UnicodeScalar(0)!)
        }
        return identifier.isEmpty ? "Unknown" : identifier
    }
}