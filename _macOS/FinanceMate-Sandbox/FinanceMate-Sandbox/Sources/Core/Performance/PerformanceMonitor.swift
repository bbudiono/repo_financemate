// SANDBOX FILE: For testing/development. See .cursorrules.
//
// PerformanceMonitor.swift
// FinanceMate-Sandbox
//
// Purpose: Performance monitoring and memory leak detection for crash analysis
// Issues & Complexity Summary: Complex system resource monitoring with real-time analysis
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~320
//   - Core Algorithm Complexity: High (memory tracking, CPU monitoring, concurrent data collection)
//   - Dependencies: 4 New (Foundation, MetricKit, os.signpost, Combine)
//   - State Management Complexity: Medium (performance metric aggregation)
//   - Novelty/Uncertainty Factor: Medium (MetricKit integration patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 78%
// Problem Estimate (Inherent Problem Difficulty %): 75%
// Initial Code Complexity Estimate %: 76%
// Justification for Estimates: System-level monitoring requires careful resource management
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import Foundation
import MetricKit
import os.signpost
import Combine

// MARK: - Performance Monitoring Protocols

public protocol PerformanceMonitorProtocol {
    func startMonitoring()
    func stopMonitoring()
    func getCurrentMetrics() async -> PerformanceSnapshot
    func getMemoryUsage() async -> MemoryUsageInfo
    func detectMemoryLeaks() async -> [MemoryLeak]
    func measureExecutionTime<T>(operation: () async throws -> T) async rethrows -> (result: T, duration: TimeInterval)
}

// MARK: - Performance Data Models

/// Codable wrapper for ProcessInfo.ThermalState
public enum ThermalStateValue: String, Codable, CaseIterable {
    case nominal = "nominal"
    case fair = "fair"
    case serious = "serious"
    case critical = "critical"
    
    init(from thermalState: ProcessInfo.ThermalState) {
        switch thermalState {
        case .nominal: self = .nominal
        case .fair: self = .fair
        case .serious: self = .serious
        case .critical: self = .critical
        @unknown default: self = .nominal
        }
    }
    
    var description: String {
        switch self {
        case .nominal: return "Nominal"
        case .fair: return "Fair"
        case .serious: return "Serious"
        case .critical: return "Critical"
        }
    }
}

public struct PerformanceSnapshot: Codable {
    public let timestamp: Date
    public let cpuUsage: CPUUsage
    public let memoryUsage: MemoryUsage
    public let diskUsage: DiskUsage
    public let networkMetrics: NetworkMetrics?
    public let thermalState: ThermalStateValue
    public let energyImpact: EnergyImpact
    
    public init(
        cpuUsage: CPUUsage,
        memoryUsage: MemoryUsage,
        diskUsage: DiskUsage,
        networkMetrics: NetworkMetrics? = nil,
        thermalState: ThermalStateValue,
        energyImpact: EnergyImpact
    ) {
        self.timestamp = Date()
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.diskUsage = diskUsage
        self.networkMetrics = networkMetrics
        self.thermalState = thermalState
        self.energyImpact = energyImpact
    }
}

public struct CPUUsage: Codable {
    public let userTime: Double
    public let systemTime: Double
    public let idleTime: Double
    public let totalUsage: Double
    public let coreCount: Int
    
    public init(userTime: Double, systemTime: Double, idleTime: Double, coreCount: Int) {
        self.userTime = userTime
        self.systemTime = systemTime
        self.idleTime = idleTime
        self.totalUsage = userTime + systemTime
        self.coreCount = coreCount
    }
}

public struct MemoryUsage: Codable {
    public let physical: UInt64
    public let virtual: UInt64
    public let resident: UInt64
    public let shared: UInt64
    public let peak: UInt64
    public let pressure: MemoryPressure
    
    public init(physical: UInt64, virtual: UInt64, resident: UInt64, shared: UInt64, peak: UInt64, pressure: MemoryPressure) {
        self.physical = physical
        self.virtual = virtual
        self.resident = resident
        self.shared = shared
        self.peak = peak
        self.pressure = pressure
    }
}

public enum MemoryPressure: String, Codable, CaseIterable {
    case normal = "normal"
    case warning = "warning"
    case urgent = "urgent"
    case critical = "critical"
    
    var description: String {
        switch self {
        case .normal: return "Normal"
        case .warning: return "Warning"
        case .urgent: return "Urgent"
        case .critical: return "Critical"
        }
    }
}

public struct MemoryUsageInfo {
    public let totalMemory: UInt64
    public let usedMemory: UInt64
    public let freeMemory: UInt64
    public let memoryPressure: String
    
    public init(totalMemory: UInt64, usedMemory: UInt64, freeMemory: UInt64, memoryPressure: String) {
        self.totalMemory = totalMemory
        self.usedMemory = usedMemory
        self.freeMemory = freeMemory
        self.memoryPressure = memoryPressure
    }
}

public struct DiskUsage: Codable {
    public let totalSpace: UInt64
    public let freeSpace: UInt64
    public let usedSpace: UInt64
    public let readOperations: UInt64
    public let writeOperations: UInt64
    public let readThroughput: Double // MB/s
    public let writeThroughput: Double // MB/s
    
    public init(
        totalSpace: UInt64,
        freeSpace: UInt64,
        usedSpace: UInt64,
        readOperations: UInt64,
        writeOperations: UInt64,
        readThroughput: Double,
        writeThroughput: Double
    ) {
        self.totalSpace = totalSpace
        self.freeSpace = freeSpace
        self.usedSpace = usedSpace
        self.readOperations = readOperations
        self.writeOperations = writeOperations
        self.readThroughput = readThroughput
        self.writeThroughput = writeThroughput
    }
}

public struct NetworkMetrics: Codable {
    public let bytesReceived: UInt64
    public let bytesSent: UInt64
    public let packetsReceived: UInt64
    public let packetsSent: UInt64
    public let latency: TimeInterval
    public let connectionFailures: Int
    
    public init(
        bytesReceived: UInt64,
        bytesSent: UInt64,
        packetsReceived: UInt64,
        packetsSent: UInt64,
        latency: TimeInterval,
        connectionFailures: Int
    ) {
        self.bytesReceived = bytesReceived
        self.bytesSent = bytesSent
        self.packetsReceived = packetsReceived
        self.packetsSent = packetsSent
        self.latency = latency
        self.connectionFailures = connectionFailures
    }
}

public struct EnergyImpact: Codable {
    public let cpuImpact: Double
    public let gpuImpact: Double
    public let networkImpact: Double
    public let displayImpact: Double
    public let overallImpact: EnergyImpactLevel
    
    public init(cpuImpact: Double, gpuImpact: Double, networkImpact: Double, displayImpact: Double) {
        self.cpuImpact = cpuImpact
        self.gpuImpact = gpuImpact
        self.networkImpact = networkImpact
        self.displayImpact = displayImpact
        
        let total = cpuImpact + gpuImpact + networkImpact + displayImpact
        if total < 25 {
            self.overallImpact = .low
        } else if total < 75 {
            self.overallImpact = .medium
        } else {
            self.overallImpact = .high
        }
    }
}

public enum EnergyImpactLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

public struct MemoryLeak: Codable, Identifiable {
    public var id = UUID()
    public let objectType: String
    public let instanceCount: Int
    public let totalMemory: UInt64
    public let detectionTime: Date
    public let severity: MemoryLeakSeverity
    public let stackTrace: [String]
    
    public init(objectType: String, instanceCount: Int, totalMemory: UInt64, severity: MemoryLeakSeverity, stackTrace: [String]) {
        self.objectType = objectType
        self.instanceCount = instanceCount
        self.totalMemory = totalMemory
        self.detectionTime = Date()
        self.severity = severity
        self.stackTrace = stackTrace
    }
}

public enum MemoryLeakSeverity: String, Codable, CaseIterable {
    case minor = "minor"
    case moderate = "moderate"
    case major = "major"
    case critical = "critical"
    
    var description: String {
        switch self {
        case .minor: return "Minor"
        case .moderate: return "Moderate"
        case .major: return "Major"
        case .critical: return "Critical"
        }
    }
}

// MARK: - Performance Monitor Implementation

public final class PerformanceMonitor: NSObject, PerformanceMonitorProtocol, ObservableObject {
    public static let shared = PerformanceMonitor()
    
    private var isMonitoring = false
    private var monitoringTimer: Timer?
    private let monitoringQueue = DispatchQueue(label: "com.financemate.performance", qos: .utility)
    
    // Published properties for real-time monitoring
    @Published public private(set) var currentSnapshot: PerformanceSnapshot?
    @Published public private(set) var memoryLeaks: [MemoryLeak] = []
    @Published public private(set) var performanceAlerts: [PerformanceAlert] = []
    
    // Configuration
    private var monitoringInterval: TimeInterval = 5.0 // seconds
    private var memoryLeakThreshold: UInt64 = 100 * 1024 * 1024 // 100MB
    private var cpuThreshold: Double = 80.0 // 80%
    
    // Metrics tracking
    private var metricHistory: [PerformanceSnapshot] = []
    private let maxHistorySize = 1000
    private var baselineMemory: UInt64 = 0
    private var memoryGrowthPattern: [UInt64] = []
    
    override init() {
        super.init()
        setupMetricKit()
        captureBaselineMemory()
    }
    
    // MARK: - Public Interface
    
    public func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        Logger.info("Starting performance monitoring", category: .performance)
        
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: monitoringInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.captureMetrics()
            }
        }
        
        // Start MetricKit if available (iOS only)
        #if os(iOS)
        if #available(iOS 14.0, *) {
            MXMetricManager.shared.add(self)
        }
        #endif
    }
    
    public func stopMonitoring() {
        guard isMonitoring else { return }
        
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        
        Logger.info("Stopped performance monitoring", category: .performance)
        
        // Remove MetricKit observer (iOS only)
        #if os(iOS)
        if #available(iOS 14.0, *) {
            MXMetricManager.shared.remove(self)
        }
        #endif
    }
    
    public func getCurrentMetrics() async -> PerformanceSnapshot {
        return await withCheckedContinuation { continuation in
            monitoringQueue.async { [weak self] in
                let snapshot = self?.captureCurrentSnapshot() ?? self?.createEmptySnapshot()
                continuation.resume(returning: snapshot!)
            }
        }
    }
    
    public func getMemoryUsage() async -> MemoryUsageInfo {
        let usage = getCurrentMemoryUsage()
        return MemoryUsageInfo(
            totalMemory: usage.physical,
            usedMemory: usage.resident,
            freeMemory: usage.physical - usage.resident,
            memoryPressure: usage.pressure.description
        )
    }
    
    public func detectMemoryLeaks() async -> [MemoryLeak] {
        return await withCheckedContinuation { continuation in
            monitoringQueue.async { [weak self] in
                let leaks = self?.analyzeMemoryLeaks() ?? []
                continuation.resume(returning: leaks)
            }
        }
    }
    
    public func measureExecutionTime<T>(operation: () async throws -> T) async rethrows -> (result: T, duration: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        
        Logger.debug("Operation completed in \(String(format: "%.3f", duration))s", category: .performance)
        
        return (result, duration)
    }
    
    // MARK: - Configuration
    
    public func configure(
        monitoringInterval: TimeInterval = 5.0,
        memoryLeakThreshold: UInt64 = 100 * 1024 * 1024,
        cpuThreshold: Double = 80.0
    ) {
        self.monitoringInterval = monitoringInterval
        self.memoryLeakThreshold = memoryLeakThreshold
        self.cpuThreshold = cpuThreshold
        
        // Restart monitoring with new interval if already running
        if isMonitoring {
            stopMonitoring()
            startMonitoring()
        }
    }
    
    // MARK: - Private Implementation
    
    private func setupMetricKit() {
        // MetricKit setup for iOS only
        #if os(iOS)
        if #available(iOS 14.0, *) {
            // MetricKit will be configured when monitoring starts
            Logger.debug("MetricKit available for performance monitoring", category: .performance)
        } else {
            Logger.warning("MetricKit not available on this iOS version", category: .performance)
        }
        #else
        Logger.debug("MetricKit not available on macOS, using system-level monitoring", category: .performance)
        #endif
    }
    
    private func captureBaselineMemory() {
        let usage = getCurrentMemoryUsage()
        baselineMemory = usage.resident
        Logger.debug("Baseline memory captured: \(formatBytes(baselineMemory))", category: .performance)
    }
    
    private func captureMetrics() async {
        let snapshot = captureCurrentSnapshot()
        
        // Update published properties on main thread
        await MainActor.run {
            currentSnapshot = snapshot
            metricHistory.append(snapshot)
            
            // Maintain history size
            if metricHistory.count > maxHistorySize {
                metricHistory.removeFirst(metricHistory.count - maxHistorySize)
            }
        }
        
        // Analyze for potential issues
        await analyzePerformanceIssues(snapshot)
        
        // Track memory growth
        trackMemoryGrowth(snapshot.memoryUsage.resident)
    }
    
    private func captureCurrentSnapshot() -> PerformanceSnapshot {
        let cpuUsage = getCurrentCPUUsage()
        let memoryUsage = getCurrentMemoryUsage()
        let diskUsage = getCurrentDiskUsage()
        let networkMetrics = getCurrentNetworkMetrics()
        let thermalState = ThermalStateValue(from: ProcessInfo.processInfo.thermalState)
        let energyImpact = getCurrentEnergyImpact()
        
        return PerformanceSnapshot(
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            diskUsage: diskUsage,
            networkMetrics: networkMetrics,
            thermalState: thermalState,
            energyImpact: energyImpact
        )
    }
    
    private func getCurrentCPUUsage() -> CPUUsage {
        // Simplified CPU usage calculation
        // In a real implementation, you would use mach_host_self() and host_statistics64()
        let coreCount = ProcessInfo.processInfo.processorCount
        
        // Placeholder values - real implementation would use system calls
        let userTime = Double.random(in: 0...50)
        let systemTime = Double.random(in: 0...25)
        let idleTime = 100 - userTime - systemTime
        
        return CPUUsage(
            userTime: userTime,
            systemTime: systemTime,
            idleTime: idleTime,
            coreCount: coreCount
        )
    }
    
    private func getCurrentMemoryUsage() -> MemoryUsage {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        var usage = MemoryUsage(
            physical: 0,
            virtual: UInt64(taskInfo.virtual_size),
            resident: UInt64(taskInfo.resident_size),
            shared: 0,
            peak: UInt64(taskInfo.resident_size_max),
            pressure: .normal
        )
        
        if result == KERN_SUCCESS {
            // Get system memory info
            var vmstat = vm_statistics64()
            var vmstatCount = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<natural_t>.size)
            
            let vmResult = withUnsafeMutablePointer(to: &vmstat) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    host_statistics64(mach_host_self(),
                                    HOST_VM_INFO64,
                                    $0,
                                    &vmstatCount)
                }
            }
            
            if vmResult == KERN_SUCCESS {
                let pageSize = UInt64(vm_kernel_page_size)
                usage = MemoryUsage(
                    physical: UInt64(vmstat.free_count + vmstat.active_count + vmstat.inactive_count + vmstat.wire_count) * pageSize,
                    virtual: UInt64(taskInfo.virtual_size),
                    resident: UInt64(taskInfo.resident_size),
                    shared: 0, // shared_count not available on all macOS versions
                    peak: UInt64(taskInfo.resident_size_max),
                    pressure: determineMemoryPressure(vmstat)
                )
            }
        }
        
        return usage
    }
    
    private func determineMemoryPressure(_ vmstat: vm_statistics64) -> MemoryPressure {
        let pageSize = UInt64(vm_kernel_page_size)
        let freeMemory = UInt64(vmstat.free_count) * pageSize
        let totalMemory = UInt64(vmstat.free_count + vmstat.active_count + vmstat.inactive_count + vmstat.wire_count) * pageSize
        
        let freePercentage = Double(freeMemory) / Double(totalMemory) * 100
        
        switch freePercentage {
        case 0..<5: return .critical
        case 5..<15: return .urgent
        case 15..<30: return .warning
        default: return .normal
        }
    }
    
    private func getCurrentDiskUsage() -> DiskUsage {
        // Simplified disk usage - real implementation would query system statistics
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let url = urls.first else {
            return DiskUsage(totalSpace: 0, freeSpace: 0, usedSpace: 0, readOperations: 0, writeOperations: 0, readThroughput: 0, writeThroughput: 0)
        }
        
        do {
            let values = try url.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            let totalSpace = UInt64(values.volumeTotalCapacity ?? 0)
            let freeSpace = UInt64(values.volumeAvailableCapacity ?? 0)
            let usedSpace = totalSpace - freeSpace
            
            return DiskUsage(
                totalSpace: totalSpace,
                freeSpace: freeSpace,
                usedSpace: usedSpace,
                readOperations: 0, // Would need system-level monitoring
                writeOperations: 0,
                readThroughput: 0,
                writeThroughput: 0
            )
        } catch {
            Logger.error("Failed to get disk usage: \(error)", category: .performance)
            return DiskUsage(totalSpace: 0, freeSpace: 0, usedSpace: 0, readOperations: 0, writeOperations: 0, readThroughput: 0, writeThroughput: 0)
        }
    }
    
    private func getCurrentNetworkMetrics() -> NetworkMetrics? {
        // Placeholder for network metrics - real implementation would use system network statistics
        return NetworkMetrics(
            bytesReceived: 0,
            bytesSent: 0,
            packetsReceived: 0,
            packetsSent: 0,
            latency: 0,
            connectionFailures: 0
        )
    }
    
    private func getCurrentEnergyImpact() -> EnergyImpact {
        // Simplified energy impact calculation
        return EnergyImpact(
            cpuImpact: Double.random(in: 0...50),
            gpuImpact: Double.random(in: 0...20),
            networkImpact: Double.random(in: 0...15),
            displayImpact: Double.random(in: 0...30)
        )
    }
    
    private func analyzeMemoryLeaks() -> [MemoryLeak] {
        var leaks: [MemoryLeak] = []
        
        // Analyze memory growth pattern
        if memoryGrowthPattern.count >= 10 {
            let recentGrowth = memoryGrowthPattern.suffix(10)
            let growthRate = calculateGrowthRate(Array(recentGrowth))
            
            if growthRate > 0.1 { // 10% growth consistently
                let currentMemory = getCurrentMemoryUsage().resident
                if currentMemory > baselineMemory + memoryLeakThreshold {
                    let leak = MemoryLeak(
                        objectType: "Unknown",
                        instanceCount: 1,
                        totalMemory: currentMemory - baselineMemory,
                        severity: determineSeverity(currentMemory - baselineMemory),
                        stackTrace: ["Memory leak detected through growth pattern analysis"]
                    )
                    leaks.append(leak)
                }
            }
        }
        
        return leaks
    }
    
    private func calculateGrowthRate(_ values: [UInt64]) -> Double {
        guard values.count >= 2 else { return 0 }
        
        let first = Double(values.first!)
        let last = Double(values.last!)
        
        return (last - first) / first
    }
    
    private func determineSeverity(_ memoryIncrease: UInt64) -> MemoryLeakSeverity {
        let mb = memoryIncrease / (1024 * 1024)
        
        switch mb {
        case 0..<50: return .minor
        case 50..<200: return .moderate
        case 200..<500: return .major
        default: return .critical
        }
    }
    
    private func trackMemoryGrowth(_ currentMemory: UInt64) {
        memoryGrowthPattern.append(currentMemory)
        
        // Keep only recent data points
        if memoryGrowthPattern.count > 100 {
            memoryGrowthPattern.removeFirst(memoryGrowthPattern.count - 100)
        }
    }
    
    private func analyzePerformanceIssues(_ snapshot: PerformanceSnapshot) async {
        var alerts: [PerformanceAlert] = []
        
        // Check CPU usage
        if snapshot.cpuUsage.totalUsage > cpuThreshold {
            alerts.append(PerformanceAlert(
                type: .highCPUUsage,
                message: "High CPU usage detected: \(String(format: "%.1f", snapshot.cpuUsage.totalUsage))%",
                severity: .warning,
                timestamp: Date()
            ))
        }
        
        // Check memory pressure
        if snapshot.memoryUsage.pressure != .normal {
            alerts.append(PerformanceAlert(
                type: .memoryPressure,
                message: "Memory pressure: \(snapshot.memoryUsage.pressure.description)",
                severity: snapshot.memoryUsage.pressure == .critical ? .critical : .warning,
                timestamp: Date()
            ))
        }
        
        // Check thermal state
        if snapshot.thermalState != .nominal {
            alerts.append(PerformanceAlert(
                type: .thermalIssue,
                message: "Thermal state: \(snapshot.thermalState.description)",
                severity: snapshot.thermalState == .critical ? .critical : .warning,
                timestamp: Date()
            ))
        }
        
        await MainActor.run {
            performanceAlerts.append(contentsOf: alerts)
            
            // Maintain alerts history
            if performanceAlerts.count > 100 {
                performanceAlerts.removeFirst(performanceAlerts.count - 100)
            }
        }
    }
    
    private func createEmptySnapshot() -> PerformanceSnapshot {
        return PerformanceSnapshot(
            cpuUsage: CPUUsage(userTime: 0, systemTime: 0, idleTime: 100, coreCount: 1),
            memoryUsage: MemoryUsage(physical: 0, virtual: 0, resident: 0, shared: 0, peak: 0, pressure: .normal),
            diskUsage: DiskUsage(totalSpace: 0, freeSpace: 0, usedSpace: 0, readOperations: 0, writeOperations: 0, readThroughput: 0, writeThroughput: 0),
            thermalState: .nominal,
            energyImpact: EnergyImpact(cpuImpact: 0, gpuImpact: 0, networkImpact: 0, displayImpact: 0)
        )
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - MetricKit Integration

#if os(iOS)
@available(iOS 14.0, *)
extension PerformanceMonitor: MXMetricManagerSubscriber {
    public func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            Logger.info("Received MetricKit payload for: \(payload.timeStampBegin) - \(payload.timeStampEnd)", category: .performance)
            
            // Process CPU metrics
            if let cpuMetrics = payload.cpuMetrics {
                Logger.debug("CPU metrics - cumulative time: \(cpuMetrics.cumulativeCPUTime)", category: .performance)
            }
            
            // Process memory metrics
            if let memoryMetrics = payload.memoryMetrics {
                Logger.debug("Memory metrics - peak: \(memoryMetrics.peakMemoryUsage)", category: .performance)
            }
            
            // Process hang metrics
            if let hangMetrics = payload.applicationResponsivenessMetrics {
                Logger.warning("App responsiveness issues detected", category: .performance)
            }
        }
    }
    
    public func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            Logger.critical("Received diagnostic payload: \(payload.timeStampBegin) - \(payload.timeStampEnd)", category: .crash)
            
            // Process crash diagnostics
            if let crashDiagnostic = payload.crashDiagnostics?.first {
                Logger.emergency("Crash diagnostic received: \(crashDiagnostic)", category: .crash)
            }
            
            // Process hang diagnostics
            if let hangDiagnostic = payload.hangDiagnostics?.first {
                Logger.critical("Hang diagnostic received: \(hangDiagnostic)", category: .performance)
            }
        }
    }
}
#endif

// MARK: - Supporting Types

public struct PerformanceAlert: Codable, Identifiable {
    public var id = UUID()
    public let type: PerformanceAlertType
    public let message: String
    public let severity: PerformanceAlertSeverity
    public let timestamp: Date
    
    public init(type: PerformanceAlertType, message: String, severity: PerformanceAlertSeverity, timestamp: Date) {
        self.type = type
        self.message = message
        self.severity = severity
        self.timestamp = timestamp
    }
}

public enum PerformanceAlertType: String, Codable {
    case highCPUUsage = "high_cpu"
    case memoryPressure = "memory_pressure"
    case memoryLeak = "memory_leak"
    case thermalIssue = "thermal"
    case diskSpaceLow = "disk_space"
    case networkIssue = "network"
}

public enum PerformanceAlertSeverity: String, Codable {
    case info = "info"
    case warning = "warning"
    case critical = "critical"
}

extension ProcessInfo.ThermalState {
    var description: String {
        switch self {
        case .nominal: return "Nominal"
        case .fair: return "Fair"
        case .serious: return "Serious"
        case .critical: return "Critical"
        @unknown default: return "Unknown"
        }
    }
}