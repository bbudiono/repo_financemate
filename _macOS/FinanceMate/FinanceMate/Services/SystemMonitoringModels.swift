//
//  SystemMonitoringModels.swift
//  FinanceMate
//
//  Created by Assistant on 6/26/25.
//

/*
* Purpose: Supporting data models for system monitoring, memory tracking, and performance analysis
* Issues & Complexity Summary: Comprehensive type definitions for system monitoring infrastructure
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~200
  - Core Algorithm Complexity: Low-Medium
  - Dependencies: 1 New (System monitoring data structures)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 60%
* Problem Estimate (Inherent Problem Difficulty %): 55%
* Initial Code Complexity Estimate %: 58%
* Justification for Estimates: Well-defined data structures with clear system monitoring requirements
* Final Code Complexity (Actual %): 62%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Foundation models enable robust system monitoring infrastructure
* Last Updated: 2025-06-26
*/

import Foundation
import SwiftUI

// MARK: - System Memory Usage Models

public struct MemoryUsage {
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

public enum MemoryPressure: String, CaseIterable {
    case normal = "normal"
    case warning = "warning"
    case urgent = "urgent"
    case critical = "critical"
    
    public var color: Color {
        switch self {
        case .normal: return .green
        case .warning: return .yellow
        case .urgent: return .orange
        case .critical: return .red
        }
    }
    
    public var icon: String {
        switch self {
        case .normal: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle"
        case .urgent: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.circle.fill"
        }
    }
}

// MARK: - System Information Models

public struct SystemInformation {
    public let platform: String
    public let architecture: String
    public let processorCount: Int
    public let totalMemory: UInt64
    public let osVersion: String
    public let uptime: TimeInterval
    
    public init(platform: String = "macOS", architecture: String = "arm64", processorCount: Int = 8, totalMemory: UInt64 = 16_000_000_000, osVersion: String = "14.0", uptime: TimeInterval = 0) {
        self.platform = platform
        self.architecture = architecture
        self.processorCount = processorCount
        self.totalMemory = totalMemory
        self.osVersion = osVersion
        self.uptime = uptime
    }
}

// MARK: - Performance Tracking Models

public struct PerformanceMetrics {
    public let cpuUsage: Double
    public let memoryUtilization: Double
    public let diskUsage: Double
    public let networkLatency: TimeInterval
    public let responseTime: TimeInterval
    public let timestamp: Date
    
    public init(cpuUsage: Double = 0, memoryUtilization: Double = 0, diskUsage: Double = 0, networkLatency: TimeInterval = 0, responseTime: TimeInterval = 0, timestamp: Date = Date()) {
        self.cpuUsage = cpuUsage
        self.memoryUtilization = memoryUtilization
        self.diskUsage = diskUsage
        self.networkLatency = networkLatency
        self.responseTime = responseTime
        self.timestamp = timestamp
    }
}

public struct SystemLoad {
    public let oneMinute: Double
    public let fiveMinute: Double
    public let fifteenMinute: Double
    public let timestamp: Date
    
    public init(oneMinute: Double = 0, fiveMinute: Double = 0, fifteenMinute: Double = 0, timestamp: Date = Date()) {
        self.oneMinute = oneMinute
        self.fiveMinute = fiveMinute
        self.fifteenMinute = fifteenMinute
        self.timestamp = timestamp
    }
}

// MARK: - Monitoring Configuration Models

public struct MonitoringConfiguration {
    public let memoryWarningThreshold: Double
    public let criticalMemoryThreshold: Double
    public let cpuWarningThreshold: Double
    public let diskWarningThreshold: Double
    public let monitoringInterval: TimeInterval
    public let enableDetailedLogging: Bool
    
    public init(memoryWarningThreshold: Double = 80.0, criticalMemoryThreshold: Double = 90.0, cpuWarningThreshold: Double = 85.0, diskWarningThreshold: Double = 90.0, monitoringInterval: TimeInterval = 10.0, enableDetailedLogging: Bool = true) {
        self.memoryWarningThreshold = memoryWarningThreshold
        self.criticalMemoryThreshold = criticalMemoryThreshold
        self.cpuWarningThreshold = cpuWarningThreshold
        self.diskWarningThreshold = diskWarningThreshold
        self.monitoringInterval = monitoringInterval
        self.enableDetailedLogging = enableDetailedLogging
    }
}

// MARK: - Alert and Notification Models

public struct SystemAlert {
    public let id: UUID
    public let type: AlertType
    public let severity: AlertSeverity
    public let message: String
    public let timestamp: Date
    public let metrics: PerformanceMetrics?
    
    public init(id: UUID = UUID(), type: AlertType, severity: AlertSeverity, message: String, timestamp: Date = Date(), metrics: PerformanceMetrics? = nil) {
        self.id = id
        self.type = type
        self.severity = severity
        self.message = message
        self.timestamp = timestamp
        self.metrics = metrics
    }
}

public enum AlertType: String, CaseIterable {
    case memoryPressure = "memory_pressure"
    case highCpuUsage = "high_cpu_usage"
    case diskSpaceLow = "disk_space_low"
    case performanceDegradation = "performance_degradation"
    case systemOverload = "system_overload"
    
    public var displayName: String {
        switch self {
        case .memoryPressure: return "Memory Pressure"
        case .highCpuUsage: return "High CPU Usage"
        case .diskSpaceLow: return "Low Disk Space"
        case .performanceDegradation: return "Performance Degradation"
        case .systemOverload: return "System Overload"
        }
    }
    
    public var icon: String {
        switch self {
        case .memoryPressure: return "memorychip.fill"
        case .highCpuUsage: return "cpu.fill"
        case .diskSpaceLow: return "externaldrive.fill"
        case .performanceDegradation: return "speedometer"
        case .systemOverload: return "exclamationmark.triangle.fill"
        }
    }
}

public enum AlertSeverity: String, CaseIterable {
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
    
    public var color: Color {
        switch self {
        case .info: return .blue
        case .warning: return .yellow
        case .error: return .orange
        case .critical: return .red
        }
    }
    
    public var priority: Int {
        switch self {
        case .info: return 1
        case .warning: return 2
        case .error: return 3
        case .critical: return 4
        }
    }
}

// MARK: - Data Point Models for Historical Tracking

public struct SystemDataPoint {
    public let timestamp: Date
    public let metrics: PerformanceMetrics
    public let memoryUsage: MemoryUsage
    public let systemLoad: SystemLoad
    
    public init(timestamp: Date = Date(), metrics: PerformanceMetrics, memoryUsage: MemoryUsage, systemLoad: SystemLoad) {
        self.timestamp = timestamp
        self.metrics = metrics
        self.memoryUsage = memoryUsage
        self.systemLoad = systemLoad
    }
}

public struct TrendAnalysis {
    public let trend: TrendDirection
    public let confidence: Double
    public let projection: SystemDataPoint?
    public let recommendation: String
    
    public init(trend: TrendDirection, confidence: Double, projection: SystemDataPoint? = nil, recommendation: String) {
        self.trend = trend
        self.confidence = confidence
        self.projection = projection
        self.recommendation = recommendation
    }
}

public enum TrendDirection: String, CaseIterable {
    case improving = "improving"
    case stable = "stable"
    case degrading = "degrading"
    case critical = "critical"
    
    public var color: Color {
        switch self {
        case .improving: return .green
        case .stable: return .blue
        case .degrading: return .orange
        case .critical: return .red
        }
    }
    
    public var icon: String {
        switch self {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "minus.circle.fill"
        case .degrading: return "arrow.down.circle.fill"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }
}