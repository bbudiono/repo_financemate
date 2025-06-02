// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashDetector.swift
// FinanceMate-Sandbox
//
// Purpose: Comprehensive crash detection system with automatic logging and analysis
// Issues & Complexity Summary: Complex signal handling and crash detection with real-time monitoring
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~420
//   - Core Algorithm Complexity: High (signal handling, concurrent crash detection, exception handling)
//   - Dependencies: 6 New (Foundation, os.log, MetricKit, Combine, ObjectiveC, Darwin)
//   - State Management Complexity: High (thread-safe crash state management, signal handling)
//   - Novelty/Uncertainty Factor: Medium (established crash detection patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 88%
// Problem Estimate (Inherent Problem Difficulty %): 85%
// Initial Code Complexity Estimate %: 86%
// Justification for Estimates: Signal handling and crash detection require deep system knowledge
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import Foundation
import os.log
import MetricKit
import Combine
import ObjectiveC
import Darwin

// MARK: - Crash Detector Implementation

public final class CrashDetector: NSObject, CrashDetectorProtocol, ObservableObject {
    public static let shared = CrashDetector()
    
    private var isMonitoring = false
    private let crashQueue = DispatchQueue(label: "com.financemate.crash.detection", qos: .userInitiated)
    private let sessionId = UUID().uuidString
    
    // Published properties for real-time monitoring
    @Published public private(set) var detectedCrashes: [CrashReport] = []
    @Published public private(set) var isHealthy = true
    @Published public private(set) var lastHealthCheck = Date()
    
    // Configuration
    private var enableSignalHandling = true
    private var enableExceptionHandling = true
    private var enableHangDetection = true
    private var enableMemoryMonitoring = true
    
    // Crash detection state
    private var previousSignalHandlers: [Int32: sigaction] = [:]
    private var crashBreadcrumbs: [String] = []
    private var applicationStartTime = Date()
    private var lastActivityTime = Date()
    
    // Health monitoring
    private var healthCheckTimer: Timer?
    private var hangDetectionTimer: Timer?
    private let healthCheckInterval: TimeInterval = 30.0
    private let hangDetectionTimeout: TimeInterval = 10.0
    
    // Crash storage and reporting
    private var crashStorage: CrashStorageProtocol?
    private var crashAnalyzer: CrashAnalyzerProtocol?
    private var alerting: CrashAlertingProtocol?
    
    override init() {
        super.init()
        setupCrashDetection()
        addBreadcrumb("CrashDetector initialized")
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Interface
    
    public func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        applicationStartTime = Date()
        
        Logger.info("Starting crash detection monitoring", category: .crash)
        
        if enableSignalHandling {
            setupSignalHandlers()
        }
        
        if enableExceptionHandling {
            setupExceptionHandling()
        }
        
        if enableHangDetection {
            startHangDetection()
        }
        
        startHealthChecks()
        addBreadcrumb("Crash monitoring started")
    }
    
    public func stopMonitoring() {
        guard isMonitoring else { return }
        
        isMonitoring = false
        
        Logger.info("Stopping crash detection monitoring", category: .crash)
        
        restoreSignalHandlers()
        stopHealthChecks()
        stopHangDetection()
        
        addBreadcrumb("Crash monitoring stopped")
    }
    
    public func reportCrash(_ report: CrashReport) {
        crashQueue.async { [weak self] in
            self?.processCrashReport(report)
        }
    }
    
    public func simulateCrash(type: CrashType) {
        Logger.warning("Simulating crash of type: \(type)", category: .crash)
        addBreadcrumb("Simulating crash: \(type)")
        
        switch type {
        case .memoryLeak:
            simulateMemoryLeak()
        case .unexpectedException:
            simulateUnexpectedException()
        case .signalException:
            simulateSignalException()
        case .hangOrTimeout:
            simulateHang()
        case .networkFailure:
            simulateNetworkFailure()
        case .uiResponsiveness:
            simulateUIResponsiveness()
        case .dataCorruption:
            simulateDataCorruption()
        case .authenticationFailure:
            simulateAuthenticationFailure()
        case .unknown:
            simulateUnknownCrash()
        }
    }
    
    // MARK: - Configuration
    
    public func configure(
        enableSignalHandling: Bool = true,
        enableExceptionHandling: Bool = true,
        enableHangDetection: Bool = true,
        enableMemoryMonitoring: Bool = true,
        storage: CrashStorageProtocol? = nil,
        analyzer: CrashAnalyzerProtocol? = nil,
        alerting: CrashAlertingProtocol? = nil
    ) {
        self.enableSignalHandling = enableSignalHandling
        self.enableExceptionHandling = enableExceptionHandling
        self.enableHangDetection = enableHangDetection
        self.enableMemoryMonitoring = enableMemoryMonitoring
        
        self.crashStorage = storage
        self.crashAnalyzer = analyzer
        self.alerting = alerting
        
        Logger.info("Crash detector configured", category: .crash, metadata: [
            "signalHandling": "\(enableSignalHandling)",
            "exceptionHandling": "\(enableExceptionHandling)",
            "hangDetection": "\(enableHangDetection)",
            "memoryMonitoring": "\(enableMemoryMonitoring)"
        ])
    }
    
    // MARK: - Breadcrumbs
    
    public func addBreadcrumb(_ message: String) {
        crashQueue.async { [weak self] in
            guard let self = self else { return }
            
            let timestamp = DateFormatter.breadcrumbFormatter.string(from: Date())
            let breadcrumb = "[\(timestamp)] \(message)"
            
            self.crashBreadcrumbs.append(breadcrumb)
            
            // Maintain breadcrumb limit
            if self.crashBreadcrumbs.count > 100 {
                self.crashBreadcrumbs.removeFirst(self.crashBreadcrumbs.count - 100)
            }
            
            Logger.trace("Breadcrumb added: \(message)", category: .crash)
        }
    }
    
    public func getBreadcrumbs() -> [String] {
        return crashQueue.sync {
            return Array(crashBreadcrumbs)
        }
    }
    
    // MARK: - Private Implementation
    
    private func setupCrashDetection() {
        // Setup uncaught exception handler
        NSSetUncaughtExceptionHandler { exception in
            CrashDetector.shared.handleUncaughtException(exception)
        }
        
        // Monitor memory warnings (note: memory pressure notifications are iOS-specific)
        // For macOS, we'll rely on performance monitoring for memory detection
        Logger.debug("Memory pressure notifications not available on macOS, using performance monitoring", category: .crash)
        
        Logger.debug("Crash detection setup completed", category: .crash)
    }
    
    private func setupSignalHandlers() {
        let signals = [SIGSEGV, SIGBUS, SIGFPE, SIGILL, SIGABRT, SIGTRAP]
        
        for signal in signals {
            var action = sigaction()
            action.__sigaction_u.__sa_sigaction = { signal, info, context in
                CrashDetector.shared.handleSignal(signal, info: info, context: context)
            }
            action.sa_flags = SA_SIGINFO | SA_NODEFER
            
            var oldAction = sigaction()
            if sigaction(signal, &action, &oldAction) == 0 {
                previousSignalHandlers[signal] = oldAction
                Logger.debug("Signal handler installed for signal: \(signal)", category: .crash)
            } else {
                Logger.error("Failed to install signal handler for signal: \(signal)", category: .crash)
            }
        }
    }
    
    private func restoreSignalHandlers() {
        for (signal, oldAction) in previousSignalHandlers {
            var action = oldAction
            sigaction(signal, &action, nil)
            Logger.debug("Signal handler restored for signal: \(signal)", category: .crash)
        }
        previousSignalHandlers.removeAll()
    }
    
    private func setupExceptionHandling() {
        // NSException handling is already set up in setupCrashDetection
        Logger.debug("Exception handling configured", category: .crash)
    }
    
    private func startHangDetection() {
        guard enableHangDetection else { return }
        
        hangDetectionTimer = Timer.scheduledTimer(withTimeInterval: hangDetectionTimeout, repeats: true) { [weak self] _ in
            self?.checkForHangs()
        }
        
        Logger.debug("Hang detection started with timeout: \(hangDetectionTimeout)s", category: .crash)
    }
    
    private func stopHangDetection() {
        hangDetectionTimer?.invalidate()
        hangDetectionTimer = nil
        Logger.debug("Hang detection stopped", category: .crash)
    }
    
    private func startHealthChecks() {
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: healthCheckInterval, repeats: true) { [weak self] _ in
            self?.performHealthCheck()
        }
        
        Logger.debug("Health checks started with interval: \(healthCheckInterval)s", category: .crash)
    }
    
    private func stopHealthChecks() {
        healthCheckTimer?.invalidate()
        healthCheckTimer = nil
        Logger.debug("Health checks stopped", category: .crash)
    }
    
    private func handleSignal(_ signal: Int32, info: UnsafeMutablePointer<__siginfo>?, context: UnsafeMutableRawPointer?) {
        let signalName = signalName(for: signal)
        Logger.emergency("Signal \(signalName) (\(signal)) received", category: .crash)
        
        let crashReport = CrashReport(
            crashType: .signalException,
            severity: .critical,
            errorMessage: "Signal \(signalName) (\(signal)) received",
            stackTrace: Thread.callStackSymbols,
            breadcrumbs: getBreadcrumbs(),
            environmentInfo: collectEnvironmentInfo(),
            memoryUsage: getCurrentMemoryUsage(),
            performanceMetrics: getCurrentPerformanceMetrics(),
            sessionId: sessionId
        )
        
        processCrashReport(crashReport)
        
        // Restore original handler and re-raise signal
        if let originalHandler = previousSignalHandlers[signal] {
            var action = originalHandler
            sigaction(signal, &action, nil)
            raise(signal)
        }
    }
    
    private func handleUncaughtException(_ exception: NSException) {
        Logger.emergency("Uncaught exception: \(exception.name) - \(exception.reason ?? "No reason")", category: .crash)
        
        let crashReport = CrashReport(
            crashType: .unexpectedException,
            severity: .critical,
            errorMessage: "\(exception.name): \(exception.reason ?? "No reason")",
            stackTrace: exception.callStackSymbols,
            breadcrumbs: getBreadcrumbs(),
            environmentInfo: collectEnvironmentInfo(),
            memoryUsage: getCurrentMemoryUsage(),
            performanceMetrics: getCurrentPerformanceMetrics(),
            sessionId: sessionId
        )
        
        processCrashReport(crashReport)
    }
    
    @objc private func handleMemoryWarning() {
        Logger.warning("Memory warning received", category: .crash)
        addBreadcrumb("Memory warning received")
        
        if enableMemoryMonitoring {
            Task {
                let memoryUsage = await PerformanceMonitor.shared.getMemoryUsage()
                
                if memoryUsage.memoryPressure != "normal" {
                    let crashReport = CrashReport(
                        crashType: .memoryLeak,
                        severity: memoryUsage.memoryPressure == "critical" ? .critical : .high,
                        errorMessage: "Memory pressure detected: \(memoryUsage.memoryPressure)",
                        breadcrumbs: getBreadcrumbs(),
                        environmentInfo: collectEnvironmentInfo(),
                        memoryUsage: memoryUsage,
                        sessionId: sessionId
                    )
                    
                    processCrashReport(crashReport)
                }
            }
        }
    }
    
    private func checkForHangs() {
        lastActivityTime = Date()
        
        // Monitor main thread responsiveness
        DispatchQueue.main.async { [weak self] in
            self?.updateActivityTime()
        }
        
        // Check if main thread is responsive
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let timeSinceActivity = Date().timeIntervalSince(self.lastActivityTime)
            if timeSinceActivity > self.hangDetectionTimeout {
                Logger.warning("Potential hang detected - no main thread activity for \(timeSinceActivity)s", category: .crash)
                
                let crashReport = CrashReport(
                    crashType: .hangOrTimeout,
                    severity: .high,
                    errorMessage: "Application hang detected - no main thread activity for \(timeSinceActivity) seconds",
                    stackTrace: Thread.callStackSymbols,
                    breadcrumbs: self.getBreadcrumbs(),
                    environmentInfo: self.collectEnvironmentInfo(),
                    sessionId: self.sessionId
                )
                
                self.processCrashReport(crashReport)
            }
        }
    }
    
    private func updateActivityTime() {
        lastActivityTime = Date()
    }
    
    private func performHealthCheck() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.lastHealthCheck = Date()
            
            // Check application health
            let uptime = Date().timeIntervalSince(self.applicationStartTime)
            let memoryUsage = self.getCurrentMemoryUsage()
            
            // Determine health status
            let isCurrentlyHealthy = memoryUsage?.memoryPressure != "critical" && uptime > 0
            
            if self.isHealthy != isCurrentlyHealthy {
                self.isHealthy = isCurrentlyHealthy
                Logger.info("Application health status changed: \(isCurrentlyHealthy ? "Healthy" : "Unhealthy")", category: .crash)
            }
            
            self.addBreadcrumb("Health check completed - Status: \(isCurrentlyHealthy ? "Healthy" : "Unhealthy")")
        }
    }
    
    private func processCrashReport(_ report: CrashReport) {
        Logger.critical("Processing crash report: \(report.crashType) - \(report.errorMessage)", category: .crash)
        
        // Update published properties on main thread
        DispatchQueue.main.async { [weak self] in
            self?.detectedCrashes.append(report)
            self?.isHealthy = false
            
            // Maintain crash history limit
            if let count = self?.detectedCrashes.count, count > 100 {
                self?.detectedCrashes.removeFirst(count - 100)
            }
        }
        
        // Save to storage
        Task {
            do {
                try await crashStorage?.saveCrashReport(report)
                Logger.info("Crash report saved to storage", category: .crash)
            } catch {
                Logger.error("Failed to save crash report: \(error)", category: .crash)
            }
        }
        
        // Send alert if configured
        Task {
            do {
                if alerting?.shouldAlert(for: report) == true {
                    try await alerting?.sendAlert(for: report)
                    Logger.info("Crash alert sent", category: .crash)
                }
            } catch {
                Logger.error("Failed to send crash alert: \(error)", category: .crash)
            }
        }
        
        // Trigger analysis
        Task {
            do {
                if let analyzer = crashAnalyzer {
                    let insights = try await analyzer.generateInsights()
                    Logger.info("Generated \(insights.count) crash insights", category: .crash)
                }
            } catch {
                Logger.error("Failed to generate crash insights: \(error)", category: .crash)
            }
        }
    }
    
    private func collectEnvironmentInfo() -> [String: String] {
        var info: [String: String] = [:]
        
        info["bundleId"] = Bundle.main.bundleIdentifier ?? "Unknown"
        info["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        info["buildNumber"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        info["systemVersion"] = ProcessInfo.processInfo.operatingSystemVersionString
        info["deviceModel"] = ProcessInfo.processInfo.machineModelName
        info["thermalState"] = ProcessInfo.processInfo.thermalState.description
        info["isLowPowerModeEnabled"] = "\(ProcessInfo.processInfo.isLowPowerModeEnabled)"
        info["uptime"] = "\(Date().timeIntervalSince(applicationStartTime))"
        info["sessionId"] = sessionId
        
        return info
    }
    
    private func getCurrentMemoryUsage() -> MemoryUsageInfo? {
        let task = mach_task_self_
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(task, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return nil }
        
        return MemoryUsageInfo(
            totalMemory: UInt64(taskInfo.virtual_size),
            usedMemory: UInt64(taskInfo.resident_size),
            freeMemory: UInt64(taskInfo.virtual_size - taskInfo.resident_size),
            memoryPressure: "normal" // Simplified for this example
        )
    }
    
    private func getCurrentPerformanceMetrics() -> CrashPerformanceMetrics? {
        // Simplified performance metrics for crash context
        return CrashPerformanceMetrics(
            cpuUsage: 0, // Would need more complex CPU monitoring
            memoryUsage: 0, // Would calculate based on memory usage
            diskUsage: 0, // Would need disk I/O monitoring
            networkLatency: nil,
            uiFrameRate: nil
        )
    }
    
    private func signalName(for signal: Int32) -> String {
        switch signal {
        case SIGSEGV: return "SIGSEGV"
        case SIGBUS: return "SIGBUS"
        case SIGFPE: return "SIGFPE"
        case SIGILL: return "SIGILL"
        case SIGABRT: return "SIGABRT"
        case SIGTRAP: return "SIGTRAP"
        default: return "UNKNOWN"
        }
    }
    
    // MARK: - Crash Simulation Methods (For Testing)
    
    private func simulateMemoryLeak() {
        Logger.warning("Simulating memory leak", category: .crash)
        
        // Create a memory leak simulation
        var leakedMemory: [Data] = []
        for _ in 0..<1000 {
            leakedMemory.append(Data(count: 1024 * 1024)) // 1MB chunks
        }
        
        // Report as crash
        let report = CrashReport(
            crashType: .memoryLeak,
            severity: .high,
            errorMessage: "Simulated memory leak - allocated \(leakedMemory.count)MB",
            breadcrumbs: getBreadcrumbs(),
            sessionId: sessionId
        )
        
        processCrashReport(report)
    }
    
    private func simulateUnexpectedException() {
        Logger.warning("Simulating unexpected exception", category: .crash)
        
        let exception = NSException(name: .internalInconsistencyException, reason: "Simulated crash for testing", userInfo: nil)
        handleUncaughtException(exception)
    }
    
    private func simulateSignalException() {
        Logger.warning("Simulating signal exception", category: .crash)
        
        // Simulate SIGABRT
        let report = CrashReport(
            crashType: .signalException,
            severity: .critical,
            errorMessage: "Simulated SIGABRT signal",
            stackTrace: Thread.callStackSymbols,
            breadcrumbs: getBreadcrumbs(),
            sessionId: sessionId
        )
        
        processCrashReport(report)
    }
    
    private func simulateHang() {
        Logger.warning("Simulating application hang", category: .crash)
        
        DispatchQueue.main.async {
            // Simulate hang by blocking main thread
            Thread.sleep(forTimeInterval: 15.0)
        }
    }
    
    private func simulateNetworkFailure() {
        Logger.warning("Simulating network failure", category: .crash)
        
        let report = CrashReport(
            crashType: .networkFailure,
            severity: .medium,
            errorMessage: "Simulated network connection failure",
            breadcrumbs: getBreadcrumbs(),
            sessionId: sessionId
        )
        
        processCrashReport(report)
    }
    
    private func simulateUIResponsiveness() {
        Logger.warning("Simulating UI responsiveness issue", category: .crash)
        
        let report = CrashReport(
            crashType: .uiResponsiveness,
            severity: .medium,
            errorMessage: "Simulated UI responsiveness issue",
            breadcrumbs: getBreadcrumbs(),
            sessionId: sessionId
        )
        
        processCrashReport(report)
    }
    
    private func simulateDataCorruption() {
        Logger.warning("Simulating data corruption", category: .crash)
        
        let report = CrashReport(
            crashType: .dataCorruption,
            severity: .high,
            errorMessage: "Simulated data corruption detected",
            breadcrumbs: getBreadcrumbs(),
            sessionId: sessionId
        )
        
        processCrashReport(report)
    }
    
    private func simulateAuthenticationFailure() {
        Logger.warning("Simulating authentication failure", category: .crash)
        
        let report = CrashReport(
            crashType: .authenticationFailure,
            severity: .medium,
            errorMessage: "Simulated authentication system failure",
            breadcrumbs: getBreadcrumbs(),
            sessionId: sessionId
        )
        
        processCrashReport(report)
    }
    
    private func simulateUnknownCrash() {
        Logger.warning("Simulating unknown crash type", category: .crash)
        
        let report = CrashReport(
            crashType: .unknown,
            severity: .medium,
            errorMessage: "Simulated unknown crash type for testing",
            breadcrumbs: getBreadcrumbs(),
            sessionId: sessionId
        )
        
        processCrashReport(report)
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let breadcrumbFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}