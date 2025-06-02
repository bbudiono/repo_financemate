// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashAnalysisManager.swift
// FinanceMate-Sandbox
//
// Purpose: Central coordinator for comprehensive crash analysis infrastructure
// Issues & Complexity Summary: Complex orchestration of multiple subsystems with state coordination
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~250
//   - Core Algorithm Complexity: Medium (component coordination, state management, lifecycle handling)
//   - Dependencies: 5 Existing (all crash analysis components, SwiftUI, Combine)
//   - State Management Complexity: High (coordinating multiple subsystem states)
//   - Novelty/Uncertainty Factor: Low (coordination patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 72%
// Problem Estimate (Inherent Problem Difficulty %): 70%
// Initial Code Complexity Estimate %: 71%
// Justification for Estimates: Standard coordination patterns with complexity in state synchronization
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import Foundation
import SwiftUI
import Combine
import os.log

// MARK: - Crash Analysis Manager

@MainActor
public final class CrashAnalysisManager: ObservableObject {
    public static let shared = CrashAnalysisManager()
    
    // Core components
    private let crashDetector = CrashDetector.shared
    private let crashStorage = CrashStorage.shared
    private let crashAnalyzer = CrashAnalyzer.shared
    private let crashAlerting = CrashAlerting.shared
    private let performanceMonitor = PerformanceMonitor.shared
    
    // Published properties for UI binding
    @Published public private(set) var isMonitoring = false
    @Published public private(set) var systemHealth = SystemHealth()
    @Published public private(set) var dashboardData = CrashDashboardData()
    
    // Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Configuration
    private var configuration = CrashAnalysisConfiguration()
    
    private init() {
        setupSubscriptions()
        Logger.info("CrashAnalysisManager initialized", category: .crash)
    }
    
    // MARK: - Public Interface
    
    /// Start comprehensive crash monitoring
    public func startMonitoring() {
        guard !isMonitoring else { return }
        
        Logger.info("Starting comprehensive crash monitoring", category: .crash)
        
        // Configure components
        configureComponents()
        
        // Start all monitoring components
        crashDetector.startMonitoring()
        performanceMonitor.startMonitoring()
        
        isMonitoring = true
        updateSystemHealth()
        
        // Start periodic analysis
        startPeriodicAnalysis()
        
        Logger.info("Comprehensive crash monitoring started successfully", category: .crash)
    }
    
    /// Stop all crash monitoring
    public func stopMonitoring() {
        guard isMonitoring else { return }
        
        Logger.info("Stopping comprehensive crash monitoring", category: .crash)
        
        crashDetector.stopMonitoring()
        performanceMonitor.stopMonitoring()
        
        isMonitoring = false
        updateSystemHealth()
        
        Logger.info("Comprehensive crash monitoring stopped", category: .crash)
    }
    
    /// Configure the crash analysis system
    public func configure(_ config: CrashAnalysisConfiguration) {
        self.configuration = config
        
        if isMonitoring {
            configureComponents()
        }
        
        Logger.info("Crash analysis system reconfigured", category: .crash)
    }
    
    /// Get comprehensive crash dashboard data
    public func getDashboardData() async -> CrashDashboardData {
        Logger.debug("Generating crash dashboard data", category: .crash)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            // Gather data from all components
            let analysisResult = try await crashAnalyzer.analyzeCrashTrends()
            let crashMetrics = try await crashAnalyzer.calculateCrashMetrics()
            let memoryLeaks = await performanceMonitor.detectMemoryLeaks()
            let performanceSnapshot = await performanceMonitor.getCurrentMetrics()
            let recentCrashes = try await crashStorage.getCrashReports(limit: 10)
            let databaseStats = try await crashStorage.getDatabaseStatistics()
            
            let data = CrashDashboardData(
                analysisResult: analysisResult,
                crashMetrics: crashMetrics,
                memoryLeaks: memoryLeaks,
                performanceSnapshot: performanceSnapshot,
                recentCrashes: recentCrashes,
                databaseStatistics: databaseStats,
                systemHealth: systemHealth
            )
            
            // Update published property
            dashboardData = data
            
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            Logger.debug("Dashboard data generated in \(String(format: "%.3f", duration))s", category: .crash)
            
            return data
        } catch {
            Logger.error("Failed to generate dashboard data: \(error)", category: .crash)
            return CrashDashboardData()
        }
    }
    
    /// Simulate a crash for testing purposes
    public func simulateCrash(type: CrashType) {
        Logger.warning("Simulating crash for testing: \(type)", category: .crash)
        crashDetector.simulateCrash(type: type)
    }
    
    /// Export comprehensive crash report
    public func exportCrashReport() async -> URL? {
        Logger.info("Exporting comprehensive crash report", category: .crash)
        
        do {
            let dashboardData = await getDashboardData()
            let exportData = ComprehensiveCrashReport(
                dashboardData: dashboardData,
                exportTimestamp: Date(),
                systemInfo: collectSystemInfo(),
                configuration: configuration
            )
            
            let jsonData = try JSONEncoder().encode(exportData)
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportURL = documentsPath.appendingPathComponent("crash-report-\(Int(Date().timeIntervalSince1970)).json")
            
            try jsonData.write(to: exportURL)
            
            Logger.info("Crash report exported to: \(exportURL.path)", category: .crash)
            return exportURL
            
        } catch {
            Logger.error("Failed to export crash report: \(error)", category: .crash)
            return nil
        }
    }
    
    /// Clear all crash data
    public func clearAllData() async {
        Logger.warning("Clearing all crash analysis data", category: .crash)
        
        do {
            try await crashStorage.clearAllCrashReports()
            crashAlerting.clearAlertHistory()
            
            // Reset dashboard data
            dashboardData = CrashDashboardData()
            updateSystemHealth()
            
            Logger.info("All crash analysis data cleared", category: .crash)
        } catch {
            Logger.error("Failed to clear crash data: \(error)", category: .crash)
        }
    }
    
    // MARK: - Private Implementation
    
    private func setupSubscriptions() {
        // Subscribe to crash detector updates
        crashDetector.$detectedCrashes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] crashes in
                self?.updateSystemHealth()
                Task {
                    await self?.refreshDashboardData()
                }
            }
            .store(in: &cancellables)
        
        // Subscribe to performance monitor updates
        performanceMonitor.$performanceAlerts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alerts in
                self?.updateSystemHealth()
            }
            .store(in: &cancellables)
        
        // Subscribe to alerting updates
        crashAlerting.$recentAlerts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alerts in
                self?.updateSystemHealth()
            }
            .store(in: &cancellables)
    }
    
    private func configureComponents() {
        Logger.debug("Configuring crash analysis components", category: .crash)
        
        // Configure crash detector
        crashDetector.configure(
            enableSignalHandling: configuration.enableSignalHandling,
            enableExceptionHandling: configuration.enableExceptionHandling,
            enableHangDetection: configuration.enableHangDetection,
            enableMemoryMonitoring: configuration.enableMemoryMonitoring,
            storage: crashStorage,
            analyzer: crashAnalyzer,
            alerting: crashAlerting
        )
        
        // Configure performance monitor
        performanceMonitor.configure(
            monitoringInterval: configuration.performanceMonitoringInterval,
            memoryLeakThreshold: configuration.memoryLeakThreshold,
            cpuThreshold: configuration.cpuThreshold
        )
        
        // Configure crash analyzer
        crashAnalyzer.configure(AnalysisConfiguration())
        
        // Configure alerting
        crashAlerting.configure(configuration.alertConfiguration)
        crashAlerting.configureCriticalityThresholds(configuration.criticalityThresholds)
    }
    
    private func startPeriodicAnalysis() {
        // Run analysis every 30 minutes
        Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            Task {
                await self?.performPeriodicAnalysis()
            }
        }
    }
    
    private func performPeriodicAnalysis() async {
        Logger.debug("Performing periodic crash analysis", category: .crash)
        
        do {
            let _ = try await crashAnalyzer.analyzeCrashTrends()
            let insights = try await crashAnalyzer.generateInsights()
            
            // Log significant insights
            let criticalInsights = insights.filter { $0.impact == .critical }
            if !criticalInsights.isEmpty {
                Logger.critical("Critical insights detected: \(criticalInsights.count)", category: .crash)
            }
            
            await refreshDashboardData()
            
        } catch {
            Logger.error("Periodic analysis failed: \(error)", category: .crash)
        }
    }
    
    private func updateSystemHealth() {
        let hasRecentCrashes = !crashDetector.detectedCrashes.isEmpty
        let hasPerformanceIssues = !performanceMonitor.performanceAlerts.isEmpty
        let hasRecentAlerts = !crashAlerting.recentAlerts.isEmpty
        
        let healthScore = calculateHealthScore()
        let status = determineHealthStatus(healthScore)
        
        systemHealth = SystemHealth(
            status: status,
            score: healthScore,
            hasRecentCrashes: hasRecentCrashes,
            hasPerformanceIssues: hasPerformanceIssues,
            hasRecentAlerts: hasRecentAlerts,
            isMonitoring: isMonitoring,
            lastUpdated: Date()
        )
    }
    
    private func calculateHealthScore() -> Double {
        var score = 100.0
        
        // Penalize for recent crashes
        let recentCrashes = crashDetector.detectedCrashes.filter { crash in
            Date().timeIntervalSince(crash.timestamp) < 3600 // Last hour
        }
        score -= Double(recentCrashes.count) * 10
        
        // Penalize for performance issues
        let recentPerformanceAlerts = performanceMonitor.performanceAlerts.filter { alert in
            Date().timeIntervalSince(alert.timestamp) < 3600 // Last hour
        }
        score -= Double(recentPerformanceAlerts.count) * 5
        
        // Penalize for critical alerts
        let recentCriticalAlerts = crashAlerting.recentAlerts.filter { alert in
            alert.severity == .critical && Date().timeIntervalSince(alert.timestamp) < 3600
        }
        score -= Double(recentCriticalAlerts.count) * 15
        
        return max(0, min(100, score))
    }
    
    private func determineHealthStatus(_ score: Double) -> SystemHealthStatus {
        switch score {
        case 80...100:
            return .excellent
        case 60..<80:
            return .good
        case 40..<60:
            return .fair
        case 20..<40:
            return .poor
        default:
            return .critical
        }
    }
    
    private func refreshDashboardData() async {
        let _ = await getDashboardData()
    }
    
    private func collectSystemInfo() -> [String: String] {
        var info: [String: String] = [:]
        
        info["bundleId"] = Bundle.main.bundleIdentifier ?? "Unknown"
        info["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        info["buildNumber"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        info["systemVersion"] = ProcessInfo.processInfo.operatingSystemVersionString
        info["deviceModel"] = ProcessInfo.processInfo.machineModelName
        info["thermalState"] = ProcessInfo.processInfo.thermalState.description
        info["isLowPowerModeEnabled"] = "\(ProcessInfo.processInfo.isLowPowerModeEnabled)"
        info["processorCount"] = "\(ProcessInfo.processInfo.processorCount)"
        info["physicalMemory"] = "\(ProcessInfo.processInfo.physicalMemory)"
        
        return info
    }
}

// MARK: - Supporting Types

public struct CrashAnalysisConfiguration: Codable {
    public var enableSignalHandling = true
    public var enableExceptionHandling = true
    public var enableHangDetection = true
    public var enableMemoryMonitoring = true
    
    public var performanceMonitoringInterval: TimeInterval = 5.0
    public var memoryLeakThreshold: UInt64 = 100 * 1024 * 1024 // 100MB
    public var cpuThreshold: Double = 80.0
    
    public var alertConfiguration = AlertConfiguration()
    public var criticalityThresholds: [CrashSeverity: Int] = [
        .critical: 1,
        .high: 3,
        .medium: 10,
        .low: 20
    ]
    
    public init() {}
}

public struct SystemHealth: Codable {
    public let status: SystemHealthStatus
    public let score: Double
    public let hasRecentCrashes: Bool
    public let hasPerformanceIssues: Bool
    public let hasRecentAlerts: Bool
    public let isMonitoring: Bool
    public let lastUpdated: Date
    
    public init(
        status: SystemHealthStatus = .excellent,
        score: Double = 100.0,
        hasRecentCrashes: Bool = false,
        hasPerformanceIssues: Bool = false,
        hasRecentAlerts: Bool = false,
        isMonitoring: Bool = false,
        lastUpdated: Date = Date()
    ) {
        self.status = status
        self.score = score
        self.hasRecentCrashes = hasRecentCrashes
        self.hasPerformanceIssues = hasPerformanceIssues
        self.hasRecentAlerts = hasRecentAlerts
        self.isMonitoring = isMonitoring
        self.lastUpdated = lastUpdated
    }
}

public enum SystemHealthStatus: String, CaseIterable, Codable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    case critical = "critical"
    
    public var description: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        case .critical: return "Critical"
        }
    }
    
    public var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .yellow
        case .poor: return .orange
        case .critical: return .red
        }
    }
}

public struct CrashDashboardData: Codable {
    public let analysisResult: CrashAnalysisResult?
    public let crashMetrics: CrashMetrics?
    public let memoryLeaks: [MemoryLeak]
    public let performanceSnapshot: PerformanceSnapshot?
    public let recentCrashes: [CrashReport]
    public let databaseStatistics: CrashDatabaseStatistics?
    public let systemHealth: SystemHealth
    public let generatedAt: Date
    
    public init(
        analysisResult: CrashAnalysisResult? = nil,
        crashMetrics: CrashMetrics? = nil,
        memoryLeaks: [MemoryLeak] = [],
        performanceSnapshot: PerformanceSnapshot? = nil,
        recentCrashes: [CrashReport] = [],
        databaseStatistics: CrashDatabaseStatistics? = nil,
        systemHealth: SystemHealth = SystemHealth()
    ) {
        self.analysisResult = analysisResult
        self.crashMetrics = crashMetrics
        self.memoryLeaks = memoryLeaks
        self.performanceSnapshot = performanceSnapshot
        self.recentCrashes = recentCrashes
        self.databaseStatistics = databaseStatistics
        self.systemHealth = systemHealth
        self.generatedAt = Date()
    }
}

public struct ComprehensiveCrashReport: Codable {
    public let dashboardData: CrashDashboardData
    public let exportTimestamp: Date
    public let systemInfo: [String: String]
    public let configuration: CrashAnalysisConfiguration
    
    public init(
        dashboardData: CrashDashboardData,
        exportTimestamp: Date,
        systemInfo: [String: String],
        configuration: CrashAnalysisConfiguration
    ) {
        self.dashboardData = dashboardData
        self.exportTimestamp = exportTimestamp
        self.systemInfo = systemInfo
        self.configuration = configuration
    }
}