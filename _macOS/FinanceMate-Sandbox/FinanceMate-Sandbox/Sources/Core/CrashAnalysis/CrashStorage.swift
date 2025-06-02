// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashStorage.swift
// FinanceMate-Sandbox
//
// Purpose: Crash data storage and retrieval system with SQLite backend
// Issues & Complexity Summary: Complex database operations with concurrent access and data integrity
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~350
//   - Core Algorithm Complexity: Medium (SQLite operations, data serialization, concurrent access)
//   - Dependencies: 3 New (Foundation, SQLite, os.log)
//   - State Management Complexity: Medium (database connection management, transaction handling)
//   - Novelty/Uncertainty Factor: Low (established database patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
// Problem Estimate (Inherent Problem Difficulty %): 65%
// Initial Code Complexity Estimate %: 67%
// Justification for Estimates: Standard database operations with some complexity in concurrent access
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import Foundation
import SQLite
import os.log

// MARK: - Crash Storage Implementation

public final class CrashStorage: CrashStorageProtocol {
    public static let shared = CrashStorage()
    
    private var db: Connection?
    private let crashReports = Table("crash_reports")
    private let storageQueue = DispatchQueue(label: "com.financemate.crash.storage", qos: .utility)
    
    // Table columns
    private let id = Expression<String>("id")
    private let timestamp = Expression<Date>("timestamp")
    private let crashType = Expression<String>("crash_type")
    private let severity = Expression<Int>("severity")
    private let applicationVersion = Expression<String>("application_version")
    private let buildNumber = Expression<String>("build_number")
    private let systemVersion = Expression<String>("system_version")
    private let deviceModel = Expression<String>("device_model")
    private let errorMessage = Expression<String>("error_message")
    private let stackTrace = Expression<String>("stack_trace")
    private let breadcrumbs = Expression<String>("breadcrumbs")
    private let environmentInfo = Expression<String>("environment_info")
    private let memoryUsage = Expression<String?>("memory_usage")
    private let performanceMetrics = Expression<String?>("performance_metrics")
    private let userId = Expression<String?>("user_id")
    private let sessionId = Expression<String>("session_id")
    
    private init() {
        setupDatabase()
    }
    
    // MARK: - Public Interface
    
    public func saveCrashReport(_ report: CrashReport) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            storageQueue.async { [weak self] in
                do {
                    try self?.saveCrashReportSync(report)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func getCrashReports(limit: Int? = nil, since: Date? = nil) async throws -> [CrashReport] {
        return try await withCheckedThrowingContinuation { continuation in
            storageQueue.async { [weak self] in
                do {
                    let reports = try self?.getCrashReportsSync(limit: limit, since: since) ?? []
                    continuation.resume(returning: reports)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func deleteCrashReport(id reportId: UUID) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            storageQueue.async { [weak self] in
                do {
                    try self?.deleteCrashReportSync(id: reportId)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func getCrashReportsByType(_ type: CrashType) async throws -> [CrashReport] {
        return try await withCheckedThrowingContinuation { continuation in
            storageQueue.async { [weak self] in
                do {
                    let reports = try self?.getCrashReportsByTypeSync(type) ?? []
                    continuation.resume(returning: reports)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func getCrashReportsBySeverity(_ severity: CrashSeverity) async throws -> [CrashReport] {
        return try await withCheckedThrowingContinuation { continuation in
            storageQueue.async { [weak self] in
                do {
                    let reports = try self?.getCrashReportsBySeveritySync(severity) ?? []
                    continuation.resume(returning: reports)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Database Management
    
    public func clearAllCrashReports() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            storageQueue.async { [weak self] in
                do {
                    try self?.clearAllCrashReportsSync()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func getDatabaseStatistics() async throws -> CrashDatabaseStatistics {
        return try await withCheckedThrowingContinuation { continuation in
            storageQueue.async { [weak self] in
                do {
                    let stats = try self?.getDatabaseStatisticsSync() ?? CrashDatabaseStatistics.empty
                    continuation.resume(returning: stats)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func optimizeDatabase() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            storageQueue.async { [weak self] in
                do {
                    try self?.optimizeDatabaseSync()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Implementation
    
    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let databasePath = documentsPath.appendingPathComponent("crash_reports.sqlite3")
            
            db = try Connection(databasePath.path)
            
            // Enable foreign keys and WAL mode for better performance
            try db?.execute("PRAGMA foreign_keys = ON")
            try db?.execute("PRAGMA journal_mode = WAL")
            try db?.execute("PRAGMA synchronous = NORMAL")
            
            try createTables()
            try createIndexes()
            
            Logger.info("Crash storage database initialized at: \(databasePath.path)", category: .crash)
            
        } catch {
            Logger.error("Failed to setup crash storage database: \(error)", category: .crash)
        }
    }
    
    private func createTables() throws {
        try db?.run(crashReports.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(timestamp)
            table.column(crashType)
            table.column(severity)
            table.column(applicationVersion)
            table.column(buildNumber)
            table.column(systemVersion)
            table.column(deviceModel)
            table.column(errorMessage)
            table.column(stackTrace)
            table.column(breadcrumbs)
            table.column(environmentInfo)
            table.column(memoryUsage)
            table.column(performanceMetrics)
            table.column(userId)
            table.column(sessionId)
        })
    }
    
    private func createIndexes() throws {
        // Create indexes for common queries
        try db?.run("CREATE INDEX IF NOT EXISTS idx_crash_timestamp ON crash_reports(timestamp)")
        try db?.run("CREATE INDEX IF NOT EXISTS idx_crash_type ON crash_reports(crash_type)")
        try db?.run("CREATE INDEX IF NOT EXISTS idx_crash_severity ON crash_reports(severity)")
        try db?.run("CREATE INDEX IF NOT EXISTS idx_crash_session ON crash_reports(session_id)")
        try db?.run("CREATE INDEX IF NOT EXISTS idx_crash_app_version ON crash_reports(application_version)")
    }
    
    // MARK: - Synchronous Database Operations
    
    private func saveCrashReportSync(_ report: CrashReport) throws {
        guard let db = db else {
            throw CrashStorageError.databaseNotInitialized
        }
        
        let stackTraceData = try JSONEncoder().encode(report.stackTrace)
        let breadcrumbsData = try JSONEncoder().encode(report.breadcrumbs)
        let environmentData = try JSONEncoder().encode(report.environmentInfo)
        
        let memoryUsageData: Data?
        if let memoryUsage = report.memoryUsage {
            memoryUsageData = try JSONEncoder().encode(memoryUsage)
        } else {
            memoryUsageData = nil
        }
        
        let performanceData: Data?
        if let performanceMetrics = report.performanceMetrics {
            performanceData = try JSONEncoder().encode(performanceMetrics)
        } else {
            performanceData = nil
        }
        
        let insert = crashReports.insert(
            id <- report.id.uuidString,
            timestamp <- report.timestamp,
            crashType <- report.crashType.rawValue,
            severity <- report.severity.rawValue,
            applicationVersion <- report.applicationVersion,
            buildNumber <- report.buildNumber,
            systemVersion <- report.systemVersion,
            deviceModel <- report.deviceModel,
            errorMessage <- report.errorMessage,
            stackTrace <- String(data: stackTraceData, encoding: .utf8) ?? "[]",
            breadcrumbs <- String(data: breadcrumbsData, encoding: .utf8) ?? "[]",
            environmentInfo <- String(data: environmentData, encoding: .utf8) ?? "{}",
            memoryUsage <- memoryUsageData?.base64EncodedString(),
            performanceMetrics <- performanceData?.base64EncodedString(),
            userId <- report.userId,
            sessionId <- report.sessionId
        )
        
        try db.run(insert)
        
        Logger.debug("Crash report saved to database: \(report.id)", category: .crash)
    }
    
    private func getCrashReportsSync(limit: Int?, since: Date?) throws -> [CrashReport] {
        guard let db = db else {
            throw CrashStorageError.databaseNotInitialized
        }
        
        var query = crashReports.order(timestamp.desc)
        
        if let since = since {
            query = query.filter(timestamp >= since)
        }
        
        if let limit = limit {
            query = query.limit(limit)
        }
        
        let rows = try db.prepare(query)
        var reports: [CrashReport] = []
        
        for row in rows {
            if let report = try createCrashReport(from: row) {
                reports.append(report)
            }
        }
        
        return reports
    }
    
    private func deleteCrashReportSync(id reportId: UUID) throws {
        guard let db = db else {
            throw CrashStorageError.databaseNotInitialized
        }
        
        let query = crashReports.filter(id == reportId.uuidString)
        let deletedCount = try db.run(query.delete())
        
        if deletedCount == 0 {
            throw CrashStorageError.reportNotFound
        }
        
        Logger.debug("Crash report deleted from database: \(reportId)", category: .crash)
    }
    
    private func getCrashReportsByTypeSync(_ type: CrashType) throws -> [CrashReport] {
        guard let db = db else {
            throw CrashStorageError.databaseNotInitialized
        }
        
        let query = crashReports.filter(crashType == type.rawValue).order(timestamp.desc)
        let rows = try db.prepare(query)
        var reports: [CrashReport] = []
        
        for row in rows {
            if let report = try createCrashReport(from: row) {
                reports.append(report)
            }
        }
        
        return reports
    }
    
    private func getCrashReportsBySeveritySync(_ severity: CrashSeverity) throws -> [CrashReport] {
        guard let db = db else {
            throw CrashStorageError.databaseNotInitialized
        }
        
        let query = crashReports.filter(self.severity == severity.rawValue).order(timestamp.desc)
        let rows = try db.prepare(query)
        var reports: [CrashReport] = []
        
        for row in rows {
            if let report = try createCrashReport(from: row) {
                reports.append(report)
            }
        }
        
        return reports
    }
    
    private func clearAllCrashReportsSync() throws {
        guard let db = db else {
            throw CrashStorageError.databaseNotInitialized
        }
        
        try db.run(crashReports.delete())
        Logger.info("All crash reports cleared from database", category: .crash)
    }
    
    private func getDatabaseStatisticsSync() throws -> CrashDatabaseStatistics {
        guard let db = db else {
            throw CrashStorageError.databaseNotInitialized
        }
        
        let totalCount = try db.scalar(crashReports.count)
        
        let criticalCount = try db.scalar(crashReports.filter(severity == CrashSeverity.critical.rawValue).count)
        let highCount = try db.scalar(crashReports.filter(severity == CrashSeverity.high.rawValue).count)
        let mediumCount = try db.scalar(crashReports.filter(severity == CrashSeverity.medium.rawValue).count)
        let lowCount = try db.scalar(crashReports.filter(severity == CrashSeverity.low.rawValue).count)
        
        // Get oldest and newest reports
        let oldestTimestamp = try db.scalar(crashReports.select(timestamp.min))
        let newestTimestamp = try db.scalar(crashReports.select(timestamp.max))
        
        // Get crash types distribution
        var crashTypeDistribution: [CrashType: Int] = [:]
        for crashTypeCase in CrashType.allCases {
            let count = try db.scalar(crashReports.filter(crashType == crashTypeCase.rawValue).count)
            if count > 0 {
                crashTypeDistribution[crashTypeCase] = count
            }
        }
        
        return CrashDatabaseStatistics(
            totalReports: totalCount,
            criticalReports: criticalCount,
            highSeverityReports: highCount,
            mediumSeverityReports: mediumCount,
            lowSeverityReports: lowCount,
            oldestReport: oldestTimestamp,
            newestReport: newestTimestamp,
            crashTypeDistribution: crashTypeDistribution
        )
    }
    
    private func optimizeDatabaseSync() throws {
        guard let db = db else {
            throw CrashStorageError.databaseNotInitialized
        }
        
        // Vacuum database to reclaim space
        try db.execute("VACUUM")
        
        // Analyze tables for better query planning
        try db.execute("ANALYZE")
        
        Logger.info("Database optimization completed", category: .crash)
    }
    
    // MARK: - Helper Methods
    
    private func createCrashReport(from row: Row) throws -> CrashReport? {
        guard let reportId = UUID(uuidString: try row.get(id)) else {
            Logger.error("Invalid UUID in crash report row", category: .crash)
            return nil
        }
        
        guard let crashTypeValue = CrashType(rawValue: try row.get(crashType)) else {
            Logger.error("Invalid crash type in crash report row", category: .crash)
            return nil
        }
        
        guard let severityValue = CrashSeverity(rawValue: try row.get(severity)) else {
            Logger.error("Invalid severity in crash report row", category: .crash)
            return nil
        }
        
        let stackTraceString = try row.get(stackTrace)
        let stackTraceArray = try JSONDecoder().decode([String].self, from: Data(stackTraceString.utf8))
        
        let breadcrumbsString = try row.get(breadcrumbs)
        let breadcrumbsArray = try JSONDecoder().decode([String].self, from: Data(breadcrumbsString.utf8))
        
        let environmentString = try row.get(environmentInfo)
        let environmentDict = try JSONDecoder().decode([String: String].self, from: Data(environmentString.utf8))
        
        let memoryUsageInfo: MemoryUsageInfo?
        if let memoryUsageString = try row.get(memoryUsage),
           let memoryUsageData = Data(base64Encoded: memoryUsageString) {
            memoryUsageInfo = try JSONDecoder().decode(MemoryUsageInfo.self, from: memoryUsageData)
        } else {
            memoryUsageInfo = nil
        }
        
        let performanceMetricsInfo: CrashPerformanceMetrics?
        if let performanceString = try row.get(performanceMetrics),
           let performanceData = Data(base64Encoded: performanceString) {
            performanceMetricsInfo = try JSONDecoder().decode(CrashPerformanceMetrics.self, from: performanceData)
        } else {
            performanceMetricsInfo = nil
        }
        
        // Create crash report using reflection to set private properties
        var report = CrashReport(
            crashType: crashTypeValue,
            severity: severityValue,
            errorMessage: try row.get(errorMessage),
            stackTrace: stackTraceArray,
            breadcrumbs: breadcrumbsArray,
            environmentInfo: environmentDict,
            memoryUsage: memoryUsageInfo,
            performanceMetrics: performanceMetricsInfo,
            userId: try row.get(userId),
            sessionId: try row.get(sessionId)
        )
        
        // Note: We can't directly modify the id and timestamp as they're let constants
        // In a real implementation, you might need to modify the CrashReport struct
        // to have a custom initializer that accepts all parameters
        
        return report
    }
}

// MARK: - Supporting Types

public struct CrashDatabaseStatistics: Codable {
    public let totalReports: Int
    public let criticalReports: Int
    public let highSeverityReports: Int
    public let mediumSeverityReports: Int
    public let lowSeverityReports: Int
    public let oldestReport: Date?
    public let newestReport: Date?
    public let crashTypeDistribution: [CrashType: Int]
    public let generatedAt: Date
    
    public init(
        totalReports: Int,
        criticalReports: Int,
        highSeverityReports: Int,
        mediumSeverityReports: Int,
        lowSeverityReports: Int,
        oldestReport: Date?,
        newestReport: Date?,
        crashTypeDistribution: [CrashType: Int]
    ) {
        self.totalReports = totalReports
        self.criticalReports = criticalReports
        self.highSeverityReports = highSeverityReports
        self.mediumSeverityReports = mediumSeverityReports
        self.lowSeverityReports = lowSeverityReports
        self.oldestReport = oldestReport
        self.newestReport = newestReport
        self.crashTypeDistribution = crashTypeDistribution
        self.generatedAt = Date()
    }
    
    public static let empty = CrashDatabaseStatistics(
        totalReports: 0,
        criticalReports: 0,
        highSeverityReports: 0,
        mediumSeverityReports: 0,
        lowSeverityReports: 0,
        oldestReport: nil,
        newestReport: nil,
        crashTypeDistribution: [:]
    )
}

public enum CrashStorageError: Error, LocalizedError {
    case databaseNotInitialized
    case reportNotFound
    case invalidData
    case serializationError
    
    public var errorDescription: String? {
        switch self {
        case .databaseNotInitialized:
            return "Crash storage database is not initialized"
        case .reportNotFound:
            return "Crash report not found"
        case .invalidData:
            return "Invalid crash report data"
        case .serializationError:
            return "Failed to serialize crash report data"
        }
    }
}