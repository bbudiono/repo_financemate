// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashAnalyzer.swift
// FinanceMate-Sandbox
//
// Purpose: Advanced crash analysis and pattern detection for actionable insights
// Issues & Complexity Summary: Complex statistical analysis and pattern recognition algorithms
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~390
//   - Core Algorithm Complexity: High (statistical analysis, pattern matching, trend detection)
//   - Dependencies: 3 New (Foundation, os.log, Combine)
//   - State Management Complexity: Medium (analysis result caching, pattern tracking)
//   - Novelty/Uncertainty Factor: Medium (advanced analytics algorithms)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 82%
// Problem Estimate (Inherent Problem Difficulty %): 80%
// Initial Code Complexity Estimate %: 81%
// Justification for Estimates: Advanced analytics require sophisticated algorithms and statistical processing
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import Foundation
import os.log
import Combine

// MARK: - Crash Analyzer Implementation

public final class CrashAnalyzer: CrashAnalyzerProtocol, ObservableObject {
    public static let shared = CrashAnalyzer()
    
    private let storage: CrashStorageProtocol
    private let analysisQueue = DispatchQueue(label: "com.financemate.crash.analysis", qos: .utility)
    
    // Published properties for real-time monitoring
    @Published public private(set) var lastAnalysisResult: CrashAnalysisResult?
    @Published public private(set) var detectedPatterns: [CrashPattern] = []
    @Published public private(set) var currentInsights: [CrashInsight] = []
    
    // Configuration
    private var analysisConfiguration = AnalysisConfiguration()
    
    // Caching for performance
    private var cachedAnalysis: CrashAnalysisResult?
    private var cacheTimestamp: Date?
    private let cacheValidityInterval: TimeInterval = 300 // 5 minutes
    
    init(storage: CrashStorageProtocol = CrashStorage.shared) {
        self.storage = storage
    }
    
    // MARK: - Public Interface
    
    public func analyzeCrashTrends() async throws -> CrashAnalysisResult {
        Logger.info("Starting crash trend analysis", category: .crash)
        
        // Check cache first
        if let cached = getCachedAnalysis() {
            Logger.debug("Returning cached crash analysis", category: .crash)
            return cached
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            analysisQueue.async { [weak self] in
                do {
                    let result = try self?.performCrashTrendAnalysis()
                    continuation.resume(returning: result ?? CrashAnalysisResult.empty)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func detectPatterns(in reports: [CrashReport]) async throws -> [CrashPattern] {
        Logger.info("Detecting patterns in \(reports.count) crash reports", category: .crash)
        
        return try await withCheckedThrowingContinuation { continuation in
            analysisQueue.async { [weak self] in
                do {
                    let patterns = try self?.detectPatternsSync(in: reports) ?? []
                    continuation.resume(returning: patterns)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func generateInsights() async throws -> [CrashInsight] {
        Logger.info("Generating crash insights", category: .crash)
        
        return try await withCheckedThrowingContinuation { continuation in
            analysisQueue.async { [weak self] in
                do {
                    let insights = try self?.generateInsightsSync() ?? []
                    continuation.resume(returning: insights)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func calculateCrashMetrics() async throws -> CrashMetrics {
        Logger.info("Calculating crash metrics", category: .crash)
        
        return try await withCheckedThrowingContinuation { continuation in
            analysisQueue.async { [weak self] in
                do {
                    let metrics = try self?.calculateCrashMetricsSync() ?? CrashMetrics.empty
                    continuation.resume(returning: metrics)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Configuration
    
    public func configure(_ configuration: AnalysisConfiguration) {
        self.analysisConfiguration = configuration
        invalidateCache()
        Logger.info("Crash analyzer configuration updated", category: .crash)
    }
    
    // MARK: - Cache Management
    
    private func getCachedAnalysis() -> CrashAnalysisResult? {
        guard let cached = cachedAnalysis,
              let timestamp = cacheTimestamp,
              Date().timeIntervalSince(timestamp) < cacheValidityInterval else {
            return nil
        }
        return cached
    }
    
    private func setCachedAnalysis(_ result: CrashAnalysisResult) {
        cachedAnalysis = result
        cacheTimestamp = Date()
    }
    
    private func invalidateCache() {
        cachedAnalysis = nil
        cacheTimestamp = nil
    }
    
    // MARK: - Private Analysis Implementation
    
    private func performCrashTrendAnalysis() throws -> CrashAnalysisResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Get recent crash reports
        let reports = try storage.getCrashReportsSync(
            limit: analysisConfiguration.maxReportsToAnalyze,
            since: Date().addingTimeInterval(-analysisConfiguration.analysisTimeWindow)
        )
        
        Logger.debug("Analyzing \(reports.count) crash reports", category: .crash)
        
        // Calculate basic statistics
        let totalCrashes = reports.count
        let crashesByType = calculateCrashesByType(reports)
        let crashesBySeverity = calculateCrashesBySeverity(reports)
        
        // Calculate trends
        let trends = calculateTrends(reports)
        
        // Detect patterns
        let patterns = try detectPatternsSync(in: reports)
        
        // Generate insights
        let insights = try generateInsightsSync(from: reports)
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            reports: reports,
            patterns: patterns,
            insights: insights
        )
        
        let result = CrashAnalysisResult(
            totalCrashes: totalCrashes,
            crashesByType: crashesByType,
            crashesBySeverity: crashesBySeverity,
            trends: trends,
            patterns: patterns,
            insights: insights,
            recommendations: recommendations
        )
        
        // Cache result and update published properties
        setCachedAnalysis(result)
        
        DispatchQueue.main.async { [weak self] in
            self?.lastAnalysisResult = result
            self?.detectedPatterns = patterns
            self?.currentInsights = insights
        }
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        Logger.info("Crash trend analysis completed in \(String(format: "%.3f", duration))s", category: .crash)
        
        return result
    }
    
    private func detectPatternsSync(in reports: [CrashReport]) throws -> [CrashPattern] {
        var patterns: [CrashPattern] = []
        
        // Pattern 1: Stack trace similarity
        patterns.append(contentsOf: detectStackTracePatterns(reports))
        
        // Pattern 2: Error message patterns
        patterns.append(contentsOf: detectErrorMessagePatterns(reports))
        
        // Pattern 3: Temporal patterns
        patterns.append(contentsOf: detectTemporalPatterns(reports))
        
        // Pattern 4: Version-specific patterns
        patterns.append(contentsOf: detectVersionPatterns(reports))
        
        // Pattern 5: Environmental patterns
        patterns.append(contentsOf: detectEnvironmentalPatterns(reports))
        
        // Sort patterns by frequency (most common first)
        patterns.sort { $0.frequency > $1.frequency }
        
        Logger.debug("Detected \(patterns.count) crash patterns", category: .crash)
        return patterns
    }
    
    private func generateInsightsSync(from reports: [CrashReport]? = nil) throws -> [CrashInsight] {
        let reportsToAnalyze: [CrashReport]
        if let reports = reports {
            reportsToAnalyze = reports
        } else {
            reportsToAnalyze = try storage.getCrashReportsSync(
                limit: analysisConfiguration.maxReportsToAnalyze,
                since: Date().addingTimeInterval(-analysisConfiguration.analysisTimeWindow)
            )
        }
        
        var insights: [CrashInsight] = []
        
        // Insight 1: Crash frequency analysis
        insights.append(contentsOf: analyzeCrashFrequency(reportsToAnalyze))
        
        // Insight 2: Memory-related insights
        insights.append(contentsOf: analyzeMemoryIssues(reportsToAnalyze))
        
        // Insight 3: Performance-related insights
        insights.append(contentsOf: analyzePerformanceIssues(reportsToAnalyze))
        
        // Insight 4: Stability score insights
        insights.append(contentsOf: analyzeStability(reportsToAnalyze))
        
        // Insight 5: Version comparison insights
        insights.append(contentsOf: analyzeVersionStability(reportsToAnalyze))
        
        // Sort insights by impact and confidence
        insights.sort { (lhs, rhs) in
            if lhs.impact != rhs.impact {
                return lhs.impact > rhs.impact
            }
            return lhs.confidence > rhs.confidence
        }
        
        Logger.debug("Generated \(insights.count) crash insights", category: .crash)
        return insights
    }
    
    private func calculateCrashMetricsSync() throws -> CrashMetrics {
        let reports = try storage.getCrashReportsSync(
            limit: analysisConfiguration.maxReportsToAnalyze,
            since: Date().addingTimeInterval(-analysisConfiguration.analysisTimeWindow)
        )
        
        // Calculate crash-free rate (simplified - would need session data in real implementation)
        let totalSessions = 1000 // This would come from analytics in real implementation
        let crashedSessions = Set(reports.map { $0.sessionId }).count
        let crashFreeRate = Double(totalSessions - crashedSessions) / Double(totalSessions) * 100
        
        // Calculate mean time between failures
        let mtbf = calculateMeanTimeBetweenFailures(reports)
        
        // Find most common crash type
        let crashCounts = calculateCrashesByType(reports)
        let mostCommonType = crashCounts.max { $0.value < $1.value }?.key ?? .unknown
        
        // Calculate average severity
        let totalSeverity = reports.reduce(0) { $0 + $1.severity.rawValue }
        let averageSeverity = reports.isEmpty ? 0 : Double(totalSeverity) / Double(reports.count)
        
        // Calculate stability score (0-100)
        let stabilityScore = calculateStabilityScore(reports, crashFreeRate: crashFreeRate)
        
        return CrashMetrics(
            crashFreeRate: crashFreeRate,
            meanTimeBetweenFailures: mtbf,
            mostCommonCrashType: mostCommonType,
            averageSeverity: averageSeverity,
            stabilityScore: stabilityScore
        )
    }
    
    // MARK: - Pattern Detection Algorithms
    
    private func detectStackTracePatterns(_ reports: [CrashReport]) -> [CrashPattern] {
        var patterns: [CrashPattern] = []
        var stackTraceGroups: [String: [CrashReport]] = [:]
        
        // Group reports by similar stack traces
        for report in reports {
            let stackTraceKey = createStackTraceSignature(report.stackTrace)
            stackTraceGroups[stackTraceKey, default: []].append(report)
        }
        
        // Create patterns for groups with multiple occurrences
        for (signature, groupReports) in stackTraceGroups {
            if groupReports.count >= analysisConfiguration.minimumPatternOccurrences {
                let affectedVersions = Array(Set(groupReports.map { $0.applicationVersion }))
                let commonStackTrace = extractCommonStackTrace(groupReports.map { $0.stackTrace })
                
                let pattern = CrashPattern(
                    description: "Similar stack trace pattern: \(signature.prefix(100))",
                    frequency: groupReports.count,
                    affectedVersions: affectedVersions,
                    commonStackTrace: commonStackTrace,
                    recommendedAction: generateStackTraceRecommendation(signature, frequency: groupReports.count)
                )
                
                patterns.append(pattern)
            }
        }
        
        return patterns
    }
    
    private func detectErrorMessagePatterns(_ reports: [CrashReport]) -> [CrashPattern] {
        var patterns: [CrashPattern] = []
        var messageGroups: [String: [CrashReport]] = [:]
        
        // Group reports by similar error messages
        for report in reports {
            let messageKey = normalizeErrorMessage(report.errorMessage)
            messageGroups[messageKey, default: []].append(report)
        }
        
        // Create patterns for common error messages
        for (message, groupReports) in messageGroups {
            if groupReports.count >= analysisConfiguration.minimumPatternOccurrences {
                let affectedVersions = Array(Set(groupReports.map { $0.applicationVersion }))
                
                let pattern = CrashPattern(
                    description: "Common error message: \(message)",
                    frequency: groupReports.count,
                    affectedVersions: affectedVersions,
                    commonStackTrace: extractCommonStackTrace(groupReports.map { $0.stackTrace }),
                    recommendedAction: generateErrorMessageRecommendation(message, frequency: groupReports.count)
                )
                
                patterns.append(pattern)
            }
        }
        
        return patterns
    }
    
    private func detectTemporalPatterns(_ reports: [CrashReport]) -> [CrashPattern] {
        var patterns: [CrashPattern] = []
        
        // Group crashes by hour of day
        let hourGroups = Dictionary(grouping: reports) { report in
            Calendar.current.component(.hour, from: report.timestamp)
        }
        
        // Detect peak crash hours
        let averageCrashesPerHour = Double(reports.count) / 24.0
        let peakHours = hourGroups.filter { $0.value.count > Int(averageCrashesPerHour * 1.5) }
        
        if !peakHours.isEmpty {
            let hours = peakHours.keys.sorted()
            let totalCrashes = peakHours.values.flatMap { $0 }.count
            
            let pattern = CrashPattern(
                description: "Peak crash times: \(hours.map { "\($0):00" }.joined(separator: ", "))",
                frequency: totalCrashes,
                affectedVersions: [],
                commonStackTrace: [],
                recommendedAction: "Monitor application stability during peak hours: \(hours.map { "\($0):00" }.joined(separator: ", "))"
            )
            
            patterns.append(pattern)
        }
        
        return patterns
    }
    
    private func detectVersionPatterns(_ reports: [CrashReport]) -> [CrashPattern] {
        var patterns: [CrashPattern] = []
        
        let versionGroups = Dictionary(grouping: reports) { $0.applicationVersion }
        let totalReports = reports.count
        
        // Detect versions with disproportionately high crash rates
        for (version, versionReports) in versionGroups {
            let crashRate = Double(versionReports.count) / Double(totalReports)
            
            if crashRate > 0.3 && versionReports.count >= analysisConfiguration.minimumPatternOccurrences {
                let pattern = CrashPattern(
                    description: "High crash rate in version \(version) (\(String(format: "%.1f", crashRate * 100))%)",
                    frequency: versionReports.count,
                    affectedVersions: [version],
                    commonStackTrace: extractCommonStackTrace(versionReports.map { $0.stackTrace }),
                    recommendedAction: "Investigate version \(version) for stability issues and consider rollback or hotfix"
                )
                
                patterns.append(pattern)
            }
        }
        
        return patterns
    }
    
    private func detectEnvironmentalPatterns(_ reports: [CrashReport]) -> [CrashPattern] {
        var patterns: [CrashPattern] = []
        
        // Group by system version
        let systemGroups = Dictionary(grouping: reports) { $0.systemVersion }
        
        for (systemVersion, systemReports) in systemGroups {
            if systemReports.count >= analysisConfiguration.minimumPatternOccurrences {
                let crashRate = Double(systemReports.count) / Double(reports.count)
                
                if crashRate > 0.25 { // 25% or more crashes on this system version
                    let pattern = CrashPattern(
                        description: "High crash rate on \(systemVersion) (\(String(format: "%.1f", crashRate * 100))%)",
                        frequency: systemReports.count,
                        affectedVersions: Array(Set(systemReports.map { $0.applicationVersion })),
                        commonStackTrace: extractCommonStackTrace(systemReports.map { $0.stackTrace }),
                        recommendedAction: "Test compatibility with \(systemVersion) and implement system-specific fixes if needed"
                    )
                    
                    patterns.append(pattern)
                }
            }
        }
        
        return patterns
    }
    
    // MARK: - Insight Generation Algorithms
    
    private func analyzeCrashFrequency(_ reports: [CrashReport]) -> [CrashInsight] {
        var insights: [CrashInsight] = []
        
        let recentCrashes = reports.filter { report in
            Date().timeIntervalSince(report.timestamp) < 86400 // Last 24 hours
        }
        
        if recentCrashes.count > 10 {
            let insight = CrashInsight(
                title: "High Crash Frequency",
                description: "\(recentCrashes.count) crashes detected in the last 24 hours. This indicates a significant stability issue.",
                impact: .critical,
                confidence: 0.9,
                actionable: true,
                suggestedFix: "Investigate recent changes, deploy hotfix, or consider rollback to previous stable version"
            )
            insights.append(insight)
        }
        
        return insights
    }
    
    private func analyzeMemoryIssues(_ reports: [CrashReport]) -> [CrashInsight] {
        var insights: [CrashInsight] = []
        
        let memoryRelatedCrashes = reports.filter { report in
            report.crashType == .memoryLeak ||
            report.errorMessage.lowercased().contains("memory") ||
            report.stackTrace.joined().lowercased().contains("malloc")
        }
        
        if memoryRelatedCrashes.count > 0 {
            let insight = CrashInsight(
                title: "Memory Management Issues",
                description: "\(memoryRelatedCrashes.count) crashes appear to be memory-related. This suggests potential memory leaks or excessive memory usage.",
                impact: .high,
                confidence: 0.8,
                actionable: true,
                suggestedFix: "Run memory profiling tools, review object lifecycle management, and implement automatic memory monitoring"
            )
            insights.append(insight)
        }
        
        return insights
    }
    
    private func analyzePerformanceIssues(_ reports: [CrashReport]) -> [CrashInsight] {
        var insights: [CrashInsight] = []
        
        let performanceRelatedCrashes = reports.filter { report in
            report.crashType == .hangOrTimeout ||
            report.crashType == .uiResponsiveness ||
            report.errorMessage.lowercased().contains("timeout") ||
            report.errorMessage.lowercased().contains("hang")
        }
        
        if performanceRelatedCrashes.count > 0 {
            let insight = CrashInsight(
                title: "Performance-Related Crashes",
                description: "\(performanceRelatedCrashes.count) crashes are performance-related, indicating potential UI blocking or slow operations.",
                impact: .medium,
                confidence: 0.75,
                actionable: true,
                suggestedFix: "Profile application performance, move heavy operations off main thread, and implement timeout handling"
            )
            insights.append(insight)
        }
        
        return insights
    }
    
    private func analyzeStability(_ reports: [CrashReport]) -> [CrashInsight] {
        var insights: [CrashInsight] = []
        
        let criticalCrashes = reports.filter { $0.severity == .critical }
        let criticalRate = Double(criticalCrashes.count) / Double(reports.count)
        
        if criticalRate > 0.3 {
            let insight = CrashInsight(
                title: "High Critical Crash Rate",
                description: "\(String(format: "%.1f", criticalRate * 100))% of crashes are critical severity, indicating fundamental stability issues.",
                impact: .critical,
                confidence: 0.95,
                actionable: true,
                suggestedFix: "Prioritize fixing critical crashes, implement additional error handling, and enhance testing coverage"
            )
            insights.append(insight)
        }
        
        return insights
    }
    
    private func analyzeVersionStability(_ reports: [CrashReport]) -> [CrashInsight] {
        var insights: [CrashInsight] = []
        
        let versionGroups = Dictionary(grouping: reports) { $0.applicationVersion }
        let sortedVersions = versionGroups.keys.sorted()
        
        if sortedVersions.count >= 2 {
            let latestVersion = sortedVersions.last!
            let previousVersion = sortedVersions[sortedVersions.count - 2]
            
            let latestCrashes = versionGroups[latestVersion]?.count ?? 0
            let previousCrashes = versionGroups[previousVersion]?.count ?? 0
            
            if latestCrashes > previousCrashes * 2 {
                let insight = CrashInsight(
                    title: "Regression in Latest Version",
                    description: "Version \(latestVersion) has \(latestCrashes) crashes compared to \(previousCrashes) in version \(previousVersion), indicating a regression.",
                    impact: .high,
                    confidence: 0.85,
                    actionable: true,
                    suggestedFix: "Review changes between versions \(previousVersion) and \(latestVersion), consider hotfix or rollback"
                )
                insights.append(insight)
            }
        }
        
        return insights
    }
    
    // MARK: - Helper Methods
    
    private func calculateCrashesByType(_ reports: [CrashReport]) -> [CrashType: Int] {
        return Dictionary(grouping: reports, by: { $0.crashType })
            .mapValues { $0.count }
    }
    
    private func calculateCrashesBySeverity(_ reports: [CrashReport]) -> [CrashSeverity: Int] {
        return Dictionary(grouping: reports, by: { $0.severity })
            .mapValues { $0.count }
    }
    
    private func calculateTrends(_ reports: [CrashReport]) -> [CrashTrend] {
        var trends: [CrashTrend] = []
        
        let now = Date()
        let oneDayAgo = now.addingTimeInterval(-86400)
        let twoDaysAgo = now.addingTimeInterval(-172800)
        
        let today = reports.filter { $0.timestamp > oneDayAgo }
        let yesterday = reports.filter { $0.timestamp > twoDaysAgo && $0.timestamp <= oneDayAgo }
        
        for severity in CrashSeverity.allCases {
            let todayCount = today.filter { $0.severity == severity }.count
            let yesterdayCount = yesterday.filter { $0.severity == severity }.count
            
            let trend = CrashTrend(
                period: "24h",
                crashCount: todayCount,
                previousCount: yesterdayCount,
                severity: severity
            )
            
            trends.append(trend)
        }
        
        return trends
    }
    
    private func calculateMeanTimeBetweenFailures(_ reports: [CrashReport]) -> TimeInterval {
        guard reports.count > 1 else { return 0 }
        
        let sortedReports = reports.sorted { $0.timestamp < $1.timestamp }
        var intervals: [TimeInterval] = []
        
        for i in 1..<sortedReports.count {
            let interval = sortedReports[i].timestamp.timeIntervalSince(sortedReports[i-1].timestamp)
            intervals.append(interval)
        }
        
        return intervals.reduce(0, +) / Double(intervals.count)
    }
    
    private func calculateStabilityScore(_ reports: [CrashReport], crashFreeRate: Double) -> Double {
        let severityWeight = reports.reduce(0.0) { total, report in
            let weight = 1.0 / Double(report.severity.rawValue)
            return total + weight
        }
        
        let baseScore = crashFreeRate
        let severityPenalty = min(severityWeight * 5, 50) // Cap penalty at 50 points
        
        return max(0, baseScore - severityPenalty)
    }
    
    private func createStackTraceSignature(_ stackTrace: [String]) -> String {
        // Create a signature from the top 5 stack frames, removing addresses
        let topFrames = Array(stackTrace.prefix(5))
        let signature = topFrames.map { frame in
            // Remove memory addresses and line numbers to create a stable signature
            return frame.replacingOccurrences(of: #"0x[0-9a-fA-F]+"#, with: "0x***", options: .regularExpression)
                       .replacingOccurrences(of: #"\+\d+"#, with: "+***", options: .regularExpression)
        }.joined(separator: "|")
        
        return signature
    }
    
    private func normalizeErrorMessage(_ message: String) -> String {
        // Normalize error message by removing variable parts
        return message.replacingOccurrences(of: #"\d+"#, with: "***", options: .regularExpression)
                     .replacingOccurrences(of: #"0x[0-9a-fA-F]+"#, with: "0x***", options: .regularExpression)
    }
    
    private func extractCommonStackTrace(_ stackTraces: [[String]]) -> [String] {
        guard !stackTraces.isEmpty else { return [] }
        
        let minLength = stackTraces.map { $0.count }.min() ?? 0
        var commonFrames: [String] = []
        
        for i in 0..<minLength {
            let frame = stackTraces[0][i]
            let isCommon = stackTraces.allSatisfy { stackTrace in
                i < stackTrace.count && createStackTraceSignature([stackTrace[i]]) == createStackTraceSignature([frame])
            }
            
            if isCommon {
                commonFrames.append(frame)
            } else {
                break
            }
        }
        
        return commonFrames
    }
    
    private func generateStackTraceRecommendation(_ signature: String, frequency: Int) -> String {
        return "This stack trace pattern occurred \(frequency) times. Review the code path: \(signature.prefix(100))... for potential issues."
    }
    
    private func generateErrorMessageRecommendation(_ message: String, frequency: Int) -> String {
        return "This error occurred \(frequency) times: '\(message)'. Implement proper error handling and add defensive programming measures."
    }
    
    private func generateRecommendations(reports: [CrashReport], patterns: [CrashPattern], insights: [CrashInsight]) -> [String] {
        var recommendations: [String] = []
        
        // High-level recommendations based on analysis
        if reports.count > 50 {
            recommendations.append("High crash volume detected. Consider implementing crash rate limiting and enhanced monitoring.")
        }
        
        if patterns.count > 10 {
            recommendations.append("Multiple crash patterns detected. Prioritize fixing the most frequent patterns first.")
        }
        
        let criticalInsights = insights.filter { $0.impact == .critical }
        if !criticalInsights.isEmpty {
            recommendations.append("Critical issues detected. Address immediately: \(criticalInsights.map { $0.title }.joined(separator: ", "))")
        }
        
        // Memory-specific recommendations
        let memoryIssues = reports.filter { $0.crashType == .memoryLeak }.count
        if memoryIssues > 0 {
            recommendations.append("Implement automatic memory monitoring and consider using memory profiling tools regularly.")
        }
        
        // Performance recommendations
        let performanceIssues = reports.filter { $0.crashType == .hangOrTimeout || $0.crashType == .uiResponsiveness }.count
        if performanceIssues > 0 {
            recommendations.append("Optimize application performance and implement better timeout handling.")
        }
        
        return recommendations
    }
}

// MARK: - Configuration

public struct AnalysisConfiguration {
    public var maxReportsToAnalyze: Int = 1000
    public var analysisTimeWindow: TimeInterval = 7 * 24 * 3600 // 7 days
    public var minimumPatternOccurrences: Int = 3
    public var confidenceThreshold: Double = 0.5
    
    public init() {}
}

// MARK: - Extensions

extension CrashAnalysisResult {
    static let empty = CrashAnalysisResult(
        totalCrashes: 0,
        crashesByType: [:],
        crashesBySeverity: [:],
        trends: [],
        patterns: [],
        insights: [],
        recommendations: []
    )
}

extension CrashMetrics {
    static let empty = CrashMetrics(
        crashFreeRate: 100.0,
        meanTimeBetweenFailures: 0,
        mostCommonCrashType: .unknown,
        averageSeverity: 0,
        stabilityScore: 100.0
    )
}

// MARK: - Storage Extension for Synchronous Operations

extension CrashStorageProtocol {
    func getCrashReportsSync(limit: Int?, since: Date?) throws -> [CrashReport] {
        // This would be implemented in the actual storage class
        // For now, return empty array to avoid compilation errors
        return []
    }
}